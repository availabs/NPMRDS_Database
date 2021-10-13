import { join } from "path";

import HereRealtimeTrafficDownloader, {
  HereRealtimeTrafficDownloaderParams,
} from ".";

const builder = {
  output_dir: {
    desc: "Directory into which write the HERE realtime traffic data responses.",
    demand: false,
    type: "string",
    default: join(__dirname, "../../../../data/here"),
  },
};

export const downloadHereRealtimeTraffic = {
  desc: "Download the HERE Realtime Traffic Data",
  command: "download_here_realtime_traffic",
  builder,
  async handler(argv: HereRealtimeTrafficDownloaderParams) {
    const downloader = new HereRealtimeTrafficDownloader(argv);

    return downloader.downloadHereRealtimeTraffic();
  },
};

export const scrapeHereRealtimeTraffic = {
  desc: "Every two minutes download the HERE Realtime Traffic Data",
  command: "scrape_here_realtime_traffic",
  builder,
  async handler(argv: HereRealtimeTrafficDownloaderParams) {
    const downloader = new HereRealtimeTrafficDownloader(argv);

    for await (const tstamp of downloader.scrapeHereRealtimeTraffic()) {
      console.log(tstamp);
    }
  },
};
