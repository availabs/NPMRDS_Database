import { join } from "path";

import TranscomEventsDownloader, { TranscomEventsDownloaderParams } from ".";

const command = "download_transcom_historical_events";

const builder = {
  output_dir: {
    desc: "Directory into which write the Transcom Events data.",
    demand: false,
    type: "string",
    default: join(__dirname, "../../../../data/transcom"),
  },

  start_timestamp: Object.assign({
    desc: "Start timestamp for Transcom Events.",
    demand: false,
    type: "string",
    describe:
      '"yyyy-mm-dd HH:MM:SS" format. (If not provided, the latest timestamp in the transcom_historical_events table is used.)',
  }),

  end_timestamp: {
    desc: "End timestamp for Transcom Events.",
    demand: false,
    type: "string",
    describe:
      '"yyyy-mm-dd HH:MM:SS" format. (If not provided, the current time is used.)',
  },

  pg_env: {
    desc: "PostgreSQL environment. Only required if start_timestamp is not provided.",
    type: "string",
    demand: false,
    choices: ["production", "development"],
    describe:
      "The database used to check for the latest transcom_historical_events timestamp.",
    default: "development",
  },
};

const handler = async (argv: TranscomEventsDownloaderParams) => {
  const downloader = new TranscomEventsDownloader(argv);

  const outputFilePath = await downloader.run();

  return outputFilePath;
};

export const downloadTranscomEvents = {
  desc: "Download the Transcom Events",
  command,
  builder,
  handler,
};
