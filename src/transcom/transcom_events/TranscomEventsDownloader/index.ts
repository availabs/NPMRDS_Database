import {
  createReadStream,
  createWriteStream,
  mkdirSync,
  WriteStream,
} from "fs";
import { promisify } from "util";
import { createGzip } from "zlib";
import { isAbsolute, join } from "path";
import { pipeline } from "stream";

import dotenv from "dotenv";

// NOTE: Using pg-native because it allows synchonous DB queries
//   https://github.com/brianc/node-pg-native/blob/8de48133dcc8c5587686084cab0402ccfe109d65/README.md#sync
import Client from "pg-native";

import got from "got";
import through from "through2";
import split from "split2";

import _ from "lodash";

import { createTmpDir } from "../../../../make_targets/utils";

import { getPostgresConfigurationFilePath } from "../../../../make_targets/utils";

import { PGEnv } from "../types";

const pipelineAsync = promisify(pipeline);

export type TranscomEventsDownloaderParams = {
  output_dir: string;
  start_timestamp: string | undefined;
  end_timestamp: string;
  pg_env: PGEnv;
};

export default class TranscomEventsDownloader {
  private static TRANSCOM_URI =
    "https://eventsearch.xcmdata.org/HistoricalEventSearch/xcmEvent/getEventGridData";

  private static DEFAULT_START_TIMESTAMP = "2000-01-01 00:00:00";

  // Date format 'YYYY-MM-DD HH:MI:SS'
  private static timestampRE = /^\d{4}-\d{1,2}-\d{1,2} \d{2}:\d{2}:\d{2}$/;

  private static testTimestamp(timestamp: string) {
    if (!TranscomEventsDownloader.timestampRE.test(timestamp)) {
      throw new Error('Timestamps must be in "yyyy-mm-dd HH:MM:SS" format.');
    }
  }

  private static getNowTimestamp(transcomFormat: boolean = false) {
    const now = new Date();

    const yyyy = now.getFullYear();
    const mm = `0${now.getMonth() + 1}`.slice(-2);
    const dd = `0${now.getDate()}`.slice(-2);
    const HH = `0${now.getHours()}`.slice(-2);
    const MM = `0${now.getMinutes()}`.slice(-2);
    const SS = `0${now.getSeconds()}`.slice(-2);

    return transcomFormat
      ? `${yyyy}-${mm}-${dd} ${HH}:${MM}:${SS}`
      : `${yyyy}${mm}${dd}T${HH}${MM}${SS}`;
  }

  private outputDir: string;
  private pgEnv: PGEnv;

  readonly startTimestamp: string;
  readonly endTimestamp: string;

  constructor({
    output_dir,
    pg_env,
    start_timestamp,
    end_timestamp,
  }: TranscomEventsDownloaderParams) {
    this.outputDir = isAbsolute(output_dir)
      ? output_dir
      : join(process.cwd(), output_dir);

    this.pgEnv = pg_env;

    if (start_timestamp) {
      TranscomEventsDownloader.testTimestamp(start_timestamp);
      this.startTimestamp = start_timestamp;
    } else {
      // @ts-ignore
      this.startTimestamp =
        this.latestEventTimestampInDatabase ||
        TranscomEventsDownloader.DEFAULT_START_TIMESTAMP;
    }

    if (end_timestamp) {
      TranscomEventsDownloader.testTimestamp(end_timestamp);
      this.endTimestamp = end_timestamp;
    } else {
      // @ts-ignore
      this.endTimestamp = TranscomEventsDownloader.getNowTimestamp(true);
    }
  }

  private get latestEventTimestampInDatabase() {
    try {
      const configPath = getPostgresConfigurationFilePath(this.pgEnv);

      dotenv.config({ path: configPath });

      const { PGDATABASE, PGHOST, PGPORT } = process.env;

      console.error(
        `Querying ${PGDATABASE} at ${PGHOST}:${PGPORT} for the most recent Transcom event timestamp.`
      );

      const client = new Client();
      client.connectSync();

      const result = client.querySync(`
        SELECT
            to_char(MAX(creation), 'YYYY-MM-DD HH24:MI:SS') AS latest
          FROM transcom.transcom_historical_events;
      `);

      const start_timestamp =
        (Array.isArray(result) && result.length === 1 && result[0].latest) ||
        null;

      return start_timestamp;
    } catch (err) {
      console.error(err);
      throw new Error(
        "Could not connect to retreive the latest event from the database."
      );
    }
  }

  private get partitionedDateTimes() {
    const [startYearStr] = this.startTimestamp.split(/-/);
    const [endYearStr] = this.endTimestamp.split(/-/);

    const startYear = +startYearStr;
    const endYear = +endYearStr;

    const start = new Date(this.startTimestamp);
    const end = new Date(this.endTimestamp);

    const startMonth = start.getMonth() + 1;
    const startDate = start.getDate();
    const [, startTime] = this.startTimestamp.split(" ");

    const endMonth = end.getMonth() + 1;
    const endDate = end.getDate();
    const [, endTime] = this.endTimestamp.split(" ");

    const partitionedDateTimes = _.range(startYear, endYear + 1).reduce(
      (acc, year) => {
        const isStartYear = year === startYear;
        const isEndYear = year === endYear;

        const s_mm = isStartYear ? startMonth : 1;
        const e_mm = isEndYear ? endMonth : 12;

        for (let mm = s_mm; mm <= e_mm; ++mm) {
          const isStartMonth = isStartYear && mm === startMonth;
          const isEndMonth = isEndYear && mm === endMonth;

          const s_dd = isStartMonth ? startDate : 1;
          const s_time = isStartMonth ? startTime : "00:00:00";

          const e_dd = isEndMonth ? endDate : new Date(year, mm, 0).getDate();

          const e_time = isEndMonth ? endTime : "23:59:59";

          const month = _.padStart(`${mm}`, 2, "0");
          const start_day = _.padStart(`${s_dd}`, 2, "0");
          const end_day = _.padStart(`${e_dd}`, 2, "0");

          acc.push([
            `${year}-${month}-${start_day} ${s_time}`,
            `${year}-${month}-${end_day} ${e_time}`,
          ]);
        }

        return acc;
      },
      []
    );

    return partitionedDateTimes;
  }

  private get downloadTimestamp() {
    return TranscomEventsDownloader.getNowTimestamp();
  }

  private get outputFilePath() {
    const startTimestamp = this.startTimestamp
      .replace(/-|:/g, "")
      .replace(/ /, "T");
    const endTimestamp = this.endTimestamp
      .replace(/-|:/g, "")
      .replace(/ /, "T");

    const outputFileName = `${startTimestamp}-${endTimestamp}.${this.downloadTimestamp}.ndjson.gz`;

    return join(this.outputDir, outputFileName);
  }

  private async downloadDateRangeOfIncidents(
    [startDateTime, endDateTime]: [string, string],
    outputStream: WriteStream
  ) {
    const reqBody = {
      // See ./documentation/EventCategoryIds.md
      eventCategoryIds: "1,2,3,4,13",
      eventStatus: "",
      eventType: "",
      state: "",
      county: "",
      city: "",
      reportingOrg: "",
      facility: "",
      primaryLoc: "",
      secondaryLoc: "",
      eventDuration: null,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      orgID: "15",
      direction: "",
      iseventbyweekday: 1,
      tripIds: "",
    };

    const options = {
      searchParams: {
        userId: 78,
      },

      json: reqBody,
    };

    try {
      // Write the transcom events to the outputStream.
      await pipelineAsync(
        got.stream.post(TranscomEventsDownloader.TRANSCOM_URI, options),
        split(JSON.parse),
        through.obj(function fn({ data }, _$: any, cb: Function) {
          // One event per line
          if (Array.isArray(data)) {
            for (let i = 0; i < data.length; ++i) {
              this.push(`${JSON.stringify(data[i])}\n`);
            }
          }
          return cb();
        }),
        outputStream
      );
    } catch (err) {
      console.error(err);
      throw err;
    }
  }

  private async copyTmpOutputToOutputDir(tmpFilePath: string) {
    const outputFilePath = this.outputFilePath;

    await pipelineAsync(
      createReadStream(tmpFilePath),
      createGzip({ level: 9 }),
      createWriteStream(this.outputFilePath)
    );

    return outputFilePath;
  }

  async run() {
    try {
      const tmpDir = createTmpDir();
      const partitionedDateTimes = this.partitionedDateTimes;

      const tmpFilePath = join(tmpDir, "transcom_event.ndjson");

      for (let i = 0; i < partitionedDateTimes.length; ++i) {
        const dateRange = partitionedDateTimes[i];
        console.error("downloading", dateRange[0], "-", dateRange[1]);

        // Create write stream for appending.
        const outputFileStream = createWriteStream(tmpFilePath, { flags: "a" });

        await this.downloadDateRangeOfIncidents(dateRange, outputFileStream);
      }

      mkdirSync(this.outputDir, { recursive: true });

      const outputFilePath = await this.copyTmpOutputToOutputDir(tmpFilePath);

      console.error("Transcom events written to", outputFilePath);

      return this.outputFilePath;
    } catch (err) {
      console.error(err);
    }
  }
}
