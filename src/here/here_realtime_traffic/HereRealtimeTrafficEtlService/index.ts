import { readdirSync, mkdirSync } from "fs";
import { join } from "path";
import _ from "lodash";

import HereRealtimeTrafficDownloader from "../HereRealtimeTrafficDownloader";
import HereRealtimeTrafficDatabaseLoaderFactory, {
  HereRealtimeTrafficDatabaseLoader,
} from "../HereRealtimeTrafficDatabaseLoader/HereRealtimeTrafficDatabaseLoaderFactory";

export type HereRealtimeTrafficEtlServiceParams = {
  here_realtime_traffic_data_dir: string;
  pg_env: "development" | "production";
};

export type HereRealtimeTrafficDownloadFilePath = string;

export default class HereRealtimeTrafficEtlService {
  readonly here_realtime_traffic_data_dir: string;

  readonly downloader: HereRealtimeTrafficDownloader;
  readonly databaseLoader: HereRealtimeTrafficDatabaseLoader;

  constructor({
    here_realtime_traffic_data_dir,
    pg_env,
  }: HereRealtimeTrafficEtlServiceParams) {
    this.here_realtime_traffic_data_dir = here_realtime_traffic_data_dir;

    mkdirSync(this.here_realtime_traffic_data_dir, { recursive: true });

    this.downloader = new HereRealtimeTrafficDownloader({
      here_realtime_traffic_data_dir,
    });

    this.databaseLoader =
      HereRealtimeTrafficDatabaseLoaderFactory.makeHereRealtimeTrafficDatabaseLoader(
        pg_env
      );
  }

  get existingHereRealtimeTrafficFiles() {
    return readdirSync(this.here_realtime_traffic_data_dir)
      .filter((f) => /^here-realtime-traffic\..*\.json\.gz$/.test(f))
      .sort()
      .map((f) => join(this.here_realtime_traffic_data_dir, f));
  }

  async bulkLoadExistingHereRealtimeTrafficFiles() {
    await this.databaseLoader.bulkLoadDataFiles(
      this.existingHereRealtimeTrafficFiles,
      true
    );
  }

  async startEtlService() {
    const scrapedDataIterator = this.downloader.scrapeHereRealtimeTraffic();

    let i = 0;
    for await (const d of scrapedDataIterator) {
      this.databaseLoader
        .loadHereRealtimeTrafficData(d)
        .then(() => {
          console.log("loaded scraped", ++i);
        })
        .catch(() => {
          // NOTE: Cannot use await here or else we will block the scraper.
          // NOTE: Ignoring error because HereRealtimeTrafficDatabaseLoader handles logging.
        });
    }
  }
}
