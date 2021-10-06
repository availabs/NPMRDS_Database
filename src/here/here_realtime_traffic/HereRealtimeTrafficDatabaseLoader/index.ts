import { spawn } from "child_process";
import { readFileSync } from "fs";
import { pipeline } from "stream";
import { join, basename } from "path";

import dotenv from "dotenv";
import _ from "lodash";

import { getPostgresConfigurationFilePath } from "../../../../make_targets/utils";

import createHereRealtimeTrafficCsvStreamChain from "./utils/createHereRealtimeTrafficCsvStreamChain";

import hereRealtimeTrafficDatabaseTableColumns from "./utils/hereRealtimeTrafficDatabaseTableColumns";

import { PGEnv } from "../types";

const sqlDir = join(__dirname, "../../../../sql/here_realtime_traffic");

const loadPartitionTableSql = join(sqlDir, "load_partition_table.sql");

export type HereRealtimeTrafficDownloaderParams = {
  pg_env: PGEnv;
};

export type HereRealtimeTrafficDownloadTimeObj = {
  year: string;
  month: string;
  day: string;
  hour: string;
  minute: string;
  second: string;
};

export const zpad = (d: string | number, n: number) =>
  `${"0".repeat(n)}${d}`.slice(-n);

function getPsqlCredentials(pgEnv: PGEnv) {
  const configPath = getPostgresConfigurationFilePath(pgEnv);
  const configContents = readFileSync(configPath);

  return dotenv.parse(configContents);
}

// TODO: params = pgEnv, hereRealtimeTrafficJsonGzipPath
export default class HereRealtimeTrafficDatabaseLoader {
  static createHereRealtimeTrafficCsvStreamChain =
    createHereRealtimeTrafficCsvStreamChain;

  private static partitionTablesSchema = "here_realtime_traffic_partitions";

  private static validFileNameRE =
    /^here-realtime-traffic\.\d{8}T\d{6}.json.gz$/;

  private static fileNameParserRE =
    /^here-realtime-traffic\.(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2}).json.gz$/;

  private static validPartitionTableSuffix =
    /^y\d{4}m\d{2}w\d{1}d\d{2}h\d{2}m\d{2}$/;

  private static isValidFileName(hereRealtimeTrafficJsonGzip: string) {
    return HereRealtimeTrafficDatabaseLoader.validFileNameRE.test(
      hereRealtimeTrafficJsonGzip
    );
  }

  static parseHereRealtimeTrafficFileName(
    hereRealtimeTrafficJsonGzipPath: string
  ): HereRealtimeTrafficDownloadTimeObj {
    const f = basename(hereRealtimeTrafficJsonGzipPath);

    if (!HereRealtimeTrafficDatabaseLoader.isValidFileName(f)) {
      throw new Error(`Invalid hereRealtimeTrafficJsonGzip file name: ${f}`);
    }

    const [, year, month, day, hour, minute, second] = f.match(
      HereRealtimeTrafficDatabaseLoader.fileNameParserRE
    );

    return { year, month, day, hour, minute, second };
  }

  static getPartitionTableSuffix({
    year,
    month,
    day,
    hour,
    minute,
  }: HereRealtimeTrafficDownloadTimeObj): string {
    const yyyy = zpad(year, 4);
    const mm = zpad(month, 2);
    const dd = zpad(day, 2);
    const hh = zpad(hour, 2);
    const mn = zpad(minute, 2);

    const w = Math.max(0, Math.floor((+day - 1) / 7)) + 1;

    const partitionTableSuffix = `y${yyyy}m${mm}w${w}d${dd}h${hh}m${mn}`;

    // Need to verify or else we might make a mess in the database.
    if (
      !HereRealtimeTrafficDatabaseLoader.validPartitionTableSuffix.test(
        partitionTableSuffix
      )
    ) {
      throw new Error(
        `Invalid Here Realtime Traffic partition table suffix: ${partitionTableSuffix}`
      );
    }

    return partitionTableSuffix;
  }

  static getPartitionTableName(
    partitionTimeObj: HereRealtimeTrafficDownloadTimeObj
  ) {
    const partitionTableSuffix =
      HereRealtimeTrafficDatabaseLoader.getPartitionTableSuffix(
        partitionTimeObj
      );

    return `here_realtime_traffic_${partitionTableSuffix}`;
  }

  static getPartitionTableFullName(
    partitionTimeObj: HereRealtimeTrafficDownloadTimeObj
  ) {
    const partitionTableName =
      HereRealtimeTrafficDatabaseLoader.getPartitionTableName(partitionTimeObj);

    return `${HereRealtimeTrafficDatabaseLoader.partitionTablesSchema}.${partitionTableName}`;
  }

  static getPartitionPostgresTimestampExtent({
    year,
    month,
    day,
    hour,
    minute,
  }: HereRealtimeTrafficDownloadTimeObj): { start: string; end: string } {
    const start = `${year}${month}${day}T${hour}${minute}00`;
    const end = `${start}.1`;

    return { start, end };
  }

  private readonly pgEnv: PGEnv;

  constructor({ pg_env }: HereRealtimeTrafficDownloaderParams) {
    this.pgEnv = pg_env;
  }

  async loadHereRealtimeTrafficData(hereRealtimeTrafficJsonGzipPath: string) {
    const partitionTimeObj =
      HereRealtimeTrafficDatabaseLoader.parseHereRealtimeTrafficFileName(
        hereRealtimeTrafficJsonGzipPath
      );

    const partitionTableSuffix =
      HereRealtimeTrafficDatabaseLoader.getPartitionTableSuffix(
        partitionTimeObj
      );

    const { start, end } =
      HereRealtimeTrafficDatabaseLoader.getPartitionPostgresTimestampExtent(
        partitionTimeObj
      );

    const { year, month, day, hour, minute } = partitionTimeObj;

    const date = new Date(+year, +month - 1, +day);
    const nextDate = new Date(date);
    nextDate.setDate(date.getDate() + 1);

    const epoch = +hour * 12 + Math.floor(+minute / 5);

    const tableCols = hereRealtimeTrafficDatabaseTableColumns.join();

    const creds = getPsqlCredentials(this.pgEnv);

    const streamChain =
      HereRealtimeTrafficDatabaseLoader.createHereRealtimeTrafficCsvStreamChain(
        hereRealtimeTrafficJsonGzipPath
      );

    await new Promise((resolve, reject) => {
      const cproc = spawn(
        "psql",
        [
          "-q",
          "-v",
          "ON_ERROR_STOP=1",
          "-v",
          `PARTITION_TABLE_SUFFIX=${partitionTableSuffix}`,
          "-v",
          `TIME_RANGE_START=${start}`,
          "-v",
          `TIME_RANGE_END=${end}`,
          "-v",
          `DATE=${date.toISOString().replace(/T.*/, "")}`,
          "-v",
          `NEXT_DATE=${nextDate.toISOString().replace(/T.*/, "")}`,
          "-v",
          `EPOCH=${epoch}`,
          "-v",
          `TABLE_COLS=${tableCols}`,
          "-f",
          loadPartitionTableSql,
          "-c",
          "CALL here_realtime_traffic_partitions._admin_consolidate_partitions() ;",
        ],
        {
          env: {
            ...process.env,
            ...creds,
            PGOPTIONS: "--client_min_messages=error",
          },
          stdio: ["pipe", "inherit", "inherit"],
        }
      );

      cproc.on("close", (code) => {
        if (code !== 0) {
          return reject(new Error(`psql exited with code ${code}`));
        }

        resolve(null);
      });

      pipeline(
        // @ts-ignore
        [
          // @ts-ignore
          ...streamChain,
          // @ts-ignore
          cproc.stdin,
        ],
        (err) => {
          // NOTE: Resolving or rejecting in here may cause deadlocks in Postgres
          if (err) {
            console.error(err);
            // Error in the CSV stream. Kill the child process.
            cproc.kill("SIGINT");
          }
        }
      );
    });

    return HereRealtimeTrafficDatabaseLoader.getPartitionTableFullName(
      partitionTimeObj
    );
  }
}
