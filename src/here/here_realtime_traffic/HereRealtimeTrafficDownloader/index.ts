// TODO: should get the hash of the latest file in the here_realtime_traffic_data_dir
//       and check it against the 1st download if timestamp diff within threshold.

import { readFileSync, createWriteStream, mkdirSync, unlinkSync } from "fs";
import { promisify } from "util";
import { createGzip } from "zlib";
import { createHash } from "crypto";
import { isAbsolute, join, basename } from "path";
import through from "through2";
import { pipeline } from "stream";
import memoizeOne from "memoize-one";

import got from "got";

import _ from "lodash";

import logger from "../utils/logger";

import {
  HereRealtimeTrafficDownloadTimeObj,
  HereRealtimeTrafficRequestTimestamp,
  HereRealtimeTrafficJsonGzipPath,
  HereRealtimeTrafficDownloaderResponseMetadata,
} from "../types";

const HereRealtimeTrafficApiToken = readFileSync(
  join(__dirname, "../../../../config/HereRealtimeTrafficApiToken"),
  { encoding: "utf8" }
);

const pipelineAsync = promisify(pipeline);

export type HereRealtimeTrafficDownloaderParams = {
  here_realtime_traffic_data_dir: string;
};

export default class HereRealtimeTrafficDownloader {
  static readonly validFileNameRE =
    /^here-realtime-traffic\.\d{8}T\d{6}.json.gz$/;

  static readonly fileNameParserRE =
    /^here-realtime-traffic\.(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2}).json.gz$/;

  static isValidFileName(hereRealtimeTrafficJsonGzip: string) {
    return HereRealtimeTrafficDownloader.validFileNameRE.test(
      hereRealtimeTrafficJsonGzip
    );
  }

  static encodeTimestampForFileName(date: Date) {
    const YYYY = date.getFullYear();
    const MM = `0${date.getMonth() + 1}`.slice(-2);
    const DD = `0${date.getDate()}`.slice(-2);
    const hh = `0${date.getHours()}`.slice(-2);
    const mm = `0${date.getMinutes()}`.slice(-2);
    const ss = `0${date.getSeconds()}`.slice(-2);

    return `${YYYY}${MM}${DD}T${hh}${mm}${ss}`;
  }

  static parseHereRealtimeTrafficFileName = memoizeOne(
    (
      hereRealtimeTrafficJsonGzipPath: string
    ): HereRealtimeTrafficDownloadTimeObj => {
      const f = basename(hereRealtimeTrafficJsonGzipPath);

      if (!HereRealtimeTrafficDownloader.isValidFileName(f)) {
        throw new Error(`Invalid hereRealtimeTrafficJsonGzip file name: ${f}`);
      }

      const [, year, month, day, hour, minute, second] = f.match(
        HereRealtimeTrafficDownloader.fileNameParserRE
      );

      return {
        year,
        month,
        day,
        hour,
        minute,
        second,
      };
    }
  );

  static decodeTimestampFromFileName(
    hereRealtimeTrafficJsonGzipPath: HereRealtimeTrafficJsonGzipPath
  ): HereRealtimeTrafficRequestTimestamp {
    const partitionTimeObj =
      HereRealtimeTrafficDownloader.parseHereRealtimeTrafficFileName(
        hereRealtimeTrafficJsonGzipPath
      );

    const { year, month, day, hour, minute, second } = partitionTimeObj;

    const reqTstamp = new Date(
      `${year}-${month}-${day} ${hour}:${minute}:${second}`
    );

    return reqTstamp;
  }

  static hereRealtimeTrafficJsonGzipPathsToHereRealtimeTrafficRequestMetadata(
    paths: HereRealtimeTrafficJsonGzipPath[]
  ): HereRealtimeTrafficDownloaderResponseMetadata[] {
    return paths.map((p) => ({
      hereRealtimeTrafficRequestTimestamp:
        HereRealtimeTrafficDownloader.decodeTimestampFromFileName(p),
      hereRealtimeTrafficJsonGzipPath: p,
    }));
  }

  private static HERE_REALTIME_TRAFFIC_URL = `https://here.data.511mobility.org/?authorizationToken=${HereRealtimeTrafficApiToken}`;

  private hereRealtimeTrafficDataDir: string;

  constructor({
    here_realtime_traffic_data_dir,
  }: HereRealtimeTrafficDownloaderParams) {
    this.hereRealtimeTrafficDataDir = isAbsolute(here_realtime_traffic_data_dir)
      ? here_realtime_traffic_data_dir
      : join(process.cwd(), here_realtime_traffic_data_dir);
  }

  private get currentTime() {
    return new Date();
  }

  private getHereRealtimeTrafficJsonGzipPath(date: Date) {
    const encodedTimestampForFileName =
      HereRealtimeTrafficDownloader.encodeTimestampForFileName(date);

    return join(
      this.hereRealtimeTrafficDataDir,
      `here-realtime-traffic.${encodedTimestampForFileName}.json.gz`
    );
  }

  private get currentHereRealtimeTrafficRequestMetadata() {
    const hereRealtimeTrafficRequestTimestamp = this.currentTime;

    const hereRealtimeTrafficJsonGzipPath =
      this.getHereRealtimeTrafficJsonGzipPath(
        hereRealtimeTrafficRequestTimestamp
      );

    return {
      hereRealtimeTrafficRequestTimestamp,
      hereRealtimeTrafficJsonGzipPath,
    };
  }

  async downloadHereRealtimeTraffic(): Promise<{
    hereRealtimeTrafficRequestTimestamp: HereRealtimeTrafficRequestTimestamp;
    hereRealtimeTrafficJsonGzipPath: HereRealtimeTrafficJsonGzipPath;
    hereRealtimeTrafficDownloadHash: string;
  }> {
    const {
      hereRealtimeTrafficRequestTimestamp,
      hereRealtimeTrafficJsonGzipPath,
    } = this.currentHereRealtimeTrafficRequestMetadata;

    try {
      mkdirSync(this.hereRealtimeTrafficDataDir, { recursive: true });

      const hash = createHash("md5");

      const hashUpdater = through(function fn(chunk, _$, cb) {
        hash.update(chunk);
        cb(null, chunk);
      });

      await pipelineAsync(
        got.stream.get(
          HereRealtimeTrafficDownloader.HERE_REALTIME_TRAFFIC_URL,
          {
            headers: {
              "Cache-Control": "no-cache",
            },
          }
        ),
        createGzip({ level: 9 }),
        hashUpdater,
        createWriteStream(hereRealtimeTrafficJsonGzipPath)
      );

      const hereRealtimeTrafficDownloadHash = hash.digest("hex");

      return {
        hereRealtimeTrafficRequestTimestamp,
        hereRealtimeTrafficJsonGzipPath,
        hereRealtimeTrafficDownloadHash,
      };
    } catch (err) {
      unlinkSync(hereRealtimeTrafficJsonGzipPath);

      logger.error(err);

      throw err;
    }
  }

  private getFutureTimestamp(minutesIntoFuture: number) {
    const time = new Date();
    const min = time.getMinutes() + minutesIntoFuture;

    time.setMinutes(min, 0, 0);

    return time;
  }

  private timestampPause(time: Date): Promise<Date> {
    return new Promise((resolve) => {
      const x = setInterval(() => {
        const now = new Date();

        if (now >= time) {
          clearInterval(x);
          resolve(now);
        }
      }, 100);
    });
  }

  private oneMinuteSleep() {
    return this.timestampPause(this.getFutureTimestamp(1));
  }

  // IMPORTANT: consumer MUST not block the event loop.
  //            If long database transactions hold up this iterator,
  //              HERE RealTime Traffic downloads may be missed.
  //            Any work that may block the event loop for extended periods
  //              MUST happen in a separate transaction.
  async *scrapeHereRealtimeTraffic(): AsyncGenerator<HereRealtimeTrafficDownloaderResponseMetadata> {
    let lastDownloadFileHash: string | null = null;

    // Wait to the next full minute.
    await this.timestampPause(this.getFutureTimestamp(1));

    const monitorEventLoopBlocks = (before: Date, after: Date) => {
      if (after.getTime() - before.getTime() > 60000) {
        logger.warn(
          "WARNING: The consumer of HereRealtimeTrafficDownloader.scrapeHereRealtimeTraffic"
        );
        logger.warn("  MUST not block the event loop for extended periods");
        logger.warn("  otherwise HERE RealTime Traffic data may be missed.");
      }

      logger.info("INFO: API request success. Waiting 2 minutes.");
    };

    while (true) {
      let reqTstamp = null;

      try {
        logger.info("INFO: API request.", new Date().toISOString());

        const {
          hereRealtimeTrafficRequestTimestamp,
          hereRealtimeTrafficJsonGzipPath,
          hereRealtimeTrafficDownloadHash,
        } = await this.downloadHereRealtimeTraffic();

        // So we have access to the timestamp in the catch block.
        reqTstamp = hereRealtimeTrafficRequestTimestamp;

        // If the API response is the same as the last, retry.
        if (hereRealtimeTrafficDownloadHash === lastDownloadFileHash) {
          // Delete the file
          unlinkSync(hereRealtimeTrafficJsonGzipPath);

          logger.error(
            "WARNING: API response same as last response.",
            new Date().toISOString()
          );
          logger.error(`         waiting 1 minute to retry`);

          const before = new Date();
          yield {
            hereRealtimeTrafficRequestTimestamp,
            hereRealtimeTrafficJsonGzipPath: null,
          };
          const after = new Date();
          monitorEventLoopBlocks(before, after);

          // Wait 1 minute then retry API request.
          await this.oneMinuteSleep();
          continue;
        }

        lastDownloadFileHash = hereRealtimeTrafficDownloadHash;

        // Get the timestamp now because yield may block the event loop.
        const nextTimestamp = this.getFutureTimestamp(2);

        const before = new Date();
        yield {
          hereRealtimeTrafficRequestTimestamp,
          hereRealtimeTrafficJsonGzipPath,
        };
        const after = new Date();
        monitorEventLoopBlocks(before, after);

        await this.timestampPause(nextTimestamp);
      } catch (err) {
        logger.error("ERROR: API REQUEST FAILED.", new Date().toISOString());
        logger.error("       waiting 1 minute to retry");

        if (reqTstamp) {
          const before = new Date();
          yield {
            hereRealtimeTrafficRequestTimestamp: reqTstamp,
            hereRealtimeTrafficJsonGzipPath: null,
          };
          const after = new Date();
          monitorEventLoopBlocks(before, after);
        }

        await this.oneMinuteSleep();
      }
    }
  }
}
