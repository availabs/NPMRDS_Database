import { join } from "path";

import HereRealtimeTrafficEtlService, {
  HereRealtimeTrafficEtlServiceParams,
} from ".";

const builder = {
  here_realtime_traffic_data_dir: {
    desc: "Directory into which write the HERE realtime traffic data responses.",
    demand: false,
    type: "string",
    default: join(__dirname, "../../../../data/here"),
  },
  pg_env: {
    desc: "The database into which to load the Transcom Events.",
    type: "string",
    demand: false,
    choices: ["production", "development"],
    default: "development",
  },
};

export const startEtlService = {
  desc: "Start the HERE Realtime Traffic Scraper and ETL Service",
  command: "start_here_realtime_etl_service",
  builder,
  async handler(argv: HereRealtimeTrafficEtlServiceParams) {
    const service = new HereRealtimeTrafficEtlService(argv);

    service.bulkLoadExistingHereRealtimeTrafficFiles().then(() => {
      console.log("Existing data files loaded.");
    });

    service.startEtlService();
  },
};
