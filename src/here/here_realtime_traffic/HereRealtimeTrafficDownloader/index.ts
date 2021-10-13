import { readFileSync, createWriteStream, mkdirSync, unlinkSync } from "fs";
import { promisify } from "util";
import { createGzip } from "zlib";
import { createHash } from "crypto";
import { isAbsolute, join } from "path";
import through from "through2";
import { pipeline } from "stream";

import got from "got";

import _ from "lodash";

const HereRealtimeTrafficApiToken = readFileSync(
  join(__dirname, "../../../../config/HereRealtimeTrafficApiToken"),
  { encoding: "utf8" }
);

const pipelineAsync = promisify(pipeline);

export type HereRealtimeTrafficDownloaderParams = {
  output_dir: string;
};

export type HereRealtimeTrafficDownloadFilePath = string;

export default class HereRealtimeTrafficDownloader {
  private static HERE_REALTIME_TRAFFIC_URL = `https://here.data.511mobility.org/?authorizationToken=${HereRealtimeTrafficApiToken}`;

  private outputDir: string;

  constructor({ output_dir }: HereRealtimeTrafficDownloaderParams) {
    this.outputDir = isAbsolute(output_dir)
      ? output_dir
      : join(process.cwd(), output_dir);
  }

  private get currentTimestamp() {
    const now = new Date();

    const YYYY = now.getFullYear();
    const MM = `0${now.getMonth() + 1}`.slice(-2);
    const DD = `0${now.getDate()}`.slice(-2);
    const hh = `0${now.getHours()}`.slice(-2);
    const mm = `0${now.getMinutes()}`.slice(-2);
    const ss = `0${now.getSeconds()}`.slice(-2);

    return `${YYYY}${MM}${DD}T${hh}${mm}${ss}`;
  }

  private get downloadFilePath() {
    return join(
      this.outputDir,
      `here-realtime-traffic.${this.currentTimestamp}.json.gz`
    );
  }

  async downloadHereRealtimeTraffic(): Promise<{
    downloadFilePath: HereRealtimeTrafficDownloadFilePath;
    downloadFileHash: string;
  }> {
    const { downloadFilePath } = this;

    try {
      mkdirSync(this.outputDir, { recursive: true });

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
        createWriteStream(downloadFilePath)
      );

      const downloadFileHash = hash.digest("hex");
      return { downloadFilePath, downloadFileHash };
    } catch (err) {
      unlinkSync(downloadFilePath);

      console.error(err);

      throw err;
    }
  }

  private getFutureTimestamp(minutesIntoFuture: number) {
    const time = new Date();
    const min = time.getMinutes() + minutesIntoFuture;

    time.setMinutes(min, 0, 0);

    return time;
  }

  private timestampPause(time: Date): Promise<void> {
    return new Promise((resolve) => {
      const x = setInterval(() => {
        const now = new Date();

        if (now >= time) {
          clearInterval(x);
          resolve();
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
  async *scrapeHereRealtimeTraffic(): AsyncGenerator<HereRealtimeTrafficDownloadFilePath> {
    let lastDownloadFileHash: string | null = null;

    // Wait to the next full minute.
    await this.timestampPause(this.getFutureTimestamp(1));

    while (true) {
      try {
        console.info("INFO: API request.", new Date().toISOString());

        const { downloadFilePath, downloadFileHash } =
          await this.downloadHereRealtimeTraffic();

        console.log("downloadFileHash:", downloadFileHash);

        // If the API response is the same as the last, retry.
        if (downloadFileHash === lastDownloadFileHash) {
          unlinkSync(downloadFilePath);

          console.error(
            "WARNING: API response same as last response.",
            new Date().toISOString()
          );
          console.error(`         waiting 1 minute to retry`);

          await this.oneMinuteSleep();

          // Retry API request.
          continue;
        }

        lastDownloadFileHash = downloadFileHash;

        // Get the timestamp now because yield may block the event loop.
        const nextTimestamp = this.getFutureTimestamp(2);

        const before = new Date();
        yield downloadFilePath;
        const after = new Date();

        if (after.getTime() - before.getTime() > 60000) {
          console.warn(
            "WARNING: Consumer of the scrapeHereRealtimeTraffic MUST not block the event loop for extended periods."
          );
          console.warn("         HERE RealTime Traffic data may be missed.");
        }

        console.info("INFO: API request success. Waiting 2 minutes.");

        await this.timestampPause(nextTimestamp);
      } catch (err) {
        console.error("ERROR: API REQUEST FAILED.", new Date().toISOString());
        console.error(`       waiting 1 minute to retry`);

        await this.oneMinuteSleep();
      }

      console.log();
      console.log();
      console.log();
    }
  }
}
