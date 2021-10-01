import { readFileSync, createWriteStream, mkdirSync } from "fs";
import { promisify } from "util";
import { createGzip } from "zlib";
import { isAbsolute, join } from "path";
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

    const yyyy = now.getFullYear();
    const mm = `0${now.getMonth() + 1}`.slice(-2);
    const dd = `0${now.getDate()}`.slice(-2);
    const HH = `0${now.getHours()}`.slice(-2);
    const MM = `0${now.getMinutes()}`.slice(-2);
    const SS = `0${now.getSeconds()}`.slice(-2);

    return `${yyyy}${mm}${dd}T${HH}${MM}${SS}`;
  }

  private get downloadFilePath() {
    return join(
      this.outputDir,
      `here-realtime-traffic.${this.currentTimestamp}.json.gz`
    );
  }

  async downloadHereRealtimeTraffic(): Promise<HereRealtimeTrafficDownloadFilePath> {
    try {
      mkdirSync(this.outputDir, { recursive: true });

      const { downloadFilePath } = this;

      await pipelineAsync(
        got.stream.get(HereRealtimeTrafficDownloader.HERE_REALTIME_TRAFFIC_URL),
        createGzip({ level: 9 }),
        createWriteStream(downloadFilePath)
      );

      return downloadFilePath;
    } catch (err) {
      console.error(err);
      throw err;
    }
  }

  private get nextEvenMinuteSemaphore(): Promise<void> {
    const m = new Date().getMinutes();

    return new Promise((resolve) => {
      const x = setInterval(() => {
        const n = new Date().getMinutes();

        if (n > m && n % 2 === 0) {
          clearInterval(x);
          resolve();
        }
      }, 100);
    });
  }

  async *scrapeHereRealtimeTraffic(): AsyncGenerator<HereRealtimeTrafficDownloadFilePath> {
    while (true) {
      yield await this.downloadHereRealtimeTraffic();

      await this.nextEvenMinuteSemaphore;
    }
  }
}
