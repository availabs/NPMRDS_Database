/* eslint-disable no-restricted-syntax */

import { readdirSync } from "fs";
import { join } from "path";

import { default as HereRealtimeTrafficDatabaseLoaderFactory } from "./HereRealtimeTrafficDatabaseLoaderFactory";

const pg_env = "development";

const loader =
  HereRealtimeTrafficDatabaseLoaderFactory.makeHereRealtimeTrafficDatabaseLoader(
    pg_env
  );

const hereRealtimeTrafficDataDir = join(__dirname, "../../../../data/here/");

const hereRealtimeTrafficJsonGzips = readdirSync(hereRealtimeTrafficDataDir)
  .filter((f) => /^here-realtime-traffic\..*\.json\.gz$/.test(f))
  .sort()
  .map((f) => join(hereRealtimeTrafficDataDir, f));

async function main() {
  loader.initializeDatabase();

  await loader.bulkLoadDataFiles(hereRealtimeTrafficJsonGzips);
}

main();
