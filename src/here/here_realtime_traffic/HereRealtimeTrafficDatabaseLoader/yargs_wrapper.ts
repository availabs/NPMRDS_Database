import { readdirSync } from "fs";
import { join } from "path";

import HereRealtimeTrafficDatabaseLoaderFactory from "./HereRealtimeTrafficDatabaseLoaderFactory";

import { PGEnv, HereRealtimeTrafficDataDir } from "../types";

type BulkLoadParams = {
  here_realtime_traffic_data_dir: HereRealtimeTrafficDataDir;
  pg_env: PGEnv;
};

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

export const bulkLoadDataDirFiles = {
  desc: "Bulk load the HERE Realtime Traffic files in the here_realtime_traffic_data_dir.",
  command: "bulk_load_here_realtime_traffic_data_files",
  builder,
  async handler({ here_realtime_traffic_data_dir, pg_env }: BulkLoadParams) {
    const loader =
      HereRealtimeTrafficDatabaseLoaderFactory.makeHereRealtimeTrafficDatabaseLoader(
        pg_env
      );

    const hereRealtimeTrafficJsonGzips = readdirSync(
      here_realtime_traffic_data_dir
    )
      .filter((f) => /^here-realtime-traffic\..*\.json\.gz$/.test(f))
      .sort()
      .map((f) => join(here_realtime_traffic_data_dir, f));

    await loader.bulkLoadDataFiles(hereRealtimeTrafficJsonGzips);

    console.log("Loaded data files from", here_realtime_traffic_data_dir);
  },
};
