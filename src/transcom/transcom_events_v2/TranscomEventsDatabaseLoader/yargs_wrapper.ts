#!/usr/bin/env node

import TranscomEventsDownloader, { TranscomEventsDownloaderParams } from ".";

const command = "load_transcom_historical_events";

const builder = {
  transcom_events_geojsonl_gzip: {
    desc: "Path to the GZipped Transcom Events GeoJSONL file",
    type: "string",
    demand: true,
  },

  pg_env: {
    desc: "The database into which to load the Transcom Events.",
    type: "string",
    demand: false,
    choices: ["production", "development"],
    default: "development",
  },
};

const handler = async (argv: TranscomEventsDownloaderParams) => {
  const loader = new TranscomEventsDownloader(argv);

  await loader.run();
};

export const loadTranscomEvents = {
  desc: "Load the Transcom Events into the database table.",
  command,
  builder,
  handler,
};
