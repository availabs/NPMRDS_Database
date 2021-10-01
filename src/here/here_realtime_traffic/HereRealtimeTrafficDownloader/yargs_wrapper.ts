import { join } from "path";

import HereRealtimeTrafficDownloader, {
  HereRealtimeTrafficDownloaderParams,
} from ".";

const command = "download_here_realtime_traffic";

const builder = {
  output_dir: {
    desc: "Directory into which write the HERE realtime traffic data.",
    demand: false,
    type: "string",
    default: join(__dirname, "../../../../data/here"),
  },
};

const handler = async (argv: HereRealtimeTrafficDownloaderParams) => {
  const downloader = new HereRealtimeTrafficDownloader(argv);

  const outputFilePath = await downloader.downloadHereRealtimeTraffic();

  return outputFilePath;
};

export const downloadHereRealtimeTraffic = {
  desc: "Download the HERE Realtime Traffic Data",
  command,
  builder,
  handler,
};
