/* eslint-disable no-restricted-syntax */

import { spawnSync } from "child_process";
import { readdirSync } from "fs";
import { join } from "path";

import { default as PgNative } from "pg-native";
import dotenv from "dotenv";

import test from "tape";

import { getPostgresConfigurationFilePath } from "../../../../make_targets/utils";
// import HereRealtimeTrafficDatabaseLoader from ".";
import {
  HereRealtimeTrafficDatabaseLoader,
  default as HereRealtimeTrafficDatabaseLoaderFactory,
} from ".";

const pg_env = "development";

if (pg_env !== "development") {
  throw new Error("DO NOT RUN THESE TESTS AGAINST THE PRODUCTION DATABASE!");
}

const loader =
  HereRealtimeTrafficDatabaseLoaderFactory.makeHereRealtimeTrafficDatabaseLoader(
    pg_env
  );

const hereRealtimeTrafficDataDir = join(__dirname, "../data/");

const hereRealtimeTrafficJsonGzips = readdirSync(hereRealtimeTrafficDataDir)
  .filter((f) => /^here-realtime-traffic\..*\.json\.gz$/.test(f))
  .sort()
  .map((f) => join(hereRealtimeTrafficDataDir, f));
// .slice(0, 24);

const sqlDir = join(__dirname, "../../../../sql/here_realtime_traffic/");

const createRootTablesSql = join(sqlDir, "create_root_table.sql");
const createAdminViewsSql = join(sqlDir, "create_admin_views.sql");
const createRollProc = join(sqlDir, "create_consolidate_partitions_proc.sql");

const configPath = getPostgresConfigurationFilePath(pg_env);

dotenv.config({ path: configPath });

const db = new PgNative();
db.connectSync();

const dbWrapper = {
  query(query: string, values: any[]) {
    return new Promise((resolve, reject) =>
      db.query(query, values, (err: Error, rows: any[]) => {
        if (err) {
          return reject(err);
        }

        return resolve({ rows });
      })
    );
  },
};

function rootTableExists() {
  const [{ exists }] = db.querySync(`
    SELECT EXISTS (
      SELECT
          1
        FROM information_schema.tables
        WHERE (
          ( table_schema = 'public' )
          AND
          ( table_name   = 'here_realtime_traffic' )
        )
     ) AS exists;
  `);

  return exists;
}

function partitionSchemaExists() {
  const { exists } = db.querySync(`
    SELECT EXISTS (
      SELECT
          1
        FROM information_schema.tables
        WHERE (
          ( table_schema = 'here_realtime_traffic_partitions' )
        )
     ) AS exists;
  `);

  return exists;
}

function partitionTableExists(tableName: string) {
  const [{ exists }] = db.querySync(
    `
      SELECT EXISTS (
        SELECT
            1
          FROM information_schema.tables
          WHERE (
            ( table_schema = 'here_realtime_traffic_partitions' )
            AND
            ( table_name = $1 )
          )
       ) AS exists;
    `,
    [tableName]
  );

  return exists;
}

function tableIsNotEmpty(fullTableName: string) {
  const [{ exists }] = db.querySync(
    `
      SELECT EXISTS (
        SELECT
            1
          FROM ${fullTableName}
       ) AS exists;
    `
  );

  return exists;
}

/*
if (rootTableExists() || partitionSchemaExists()) {
  throw new Error(
    "Before running tests, the public.here_realtime_traffic table and the here_realtime_traffic_partitions schema must not exist."
  );
}
*/

function cleanDatabase() {
  return;
  /*
  spawnSync(
    "psql",
    [
      "-q",
      "-v",
      "ON_ERROR_STOP=1",
      "-c",
      `
        BEGIN;

        DROP TABLE IF EXISTS public.here_realtime_traffic CASCADE;
        DROP TABLE IF EXISTS public.here_npmrds_schema CASCADE;
        DROP SCHEMA IF EXISTS here_realtime_traffic_partitions CASCADE;
        DROP SCHEMA IF EXISTS here_npmrds_schema_partitions CASCADE;

        COMMIT;
      `,
      "-f",
      createRootTablesSql,
      "-f",
      createAdminViewsSql,
      "-f",
      createRollProc,
    ],
    {
      env: {
        ...process.env,
        PGOPTIONS: "--client_min_messages=error",
      },
    }
  );
  */
}

test("HereRealtimeTrafficDatabaseLoader must be created through factory", async (t) => {
  let e: Error | null = null;

  try {
    new HereRealtimeTrafficDatabaseLoader(pg_env, Symbol());
  } catch (err) {
    e = err;
  }

  t.assert(e instanceof Error);

  t.end();
});

test("Parse HERE Realtime Traffic JSON Gzip file name", async (t) => {
  const fileName = "here-realtime-traffic.20211001T194818.json.gz";

  const partitionTimeObj =
    // @ts-ignore
    loader.constructor.parseHereRealtimeTrafficFileName(fileName);

  t.deepEquals(partitionTimeObj, {
    year: "2021",
    month: "10",
    day: "01",
    hour: "19",
    minute: "48",
    second: "18",
  });

  t.end();
});

test("Get Timestamp for HERE Realtime Traffic JSON Gzip file name", async (t) => {
  const fileName = "here-realtime-traffic.20211001T194818.json.gz";

  const timestamp =
    // @ts-ignore
    loader.constructor.getHereRealtimeTrafficFileTimestamp(fileName);

  console.log(timestamp);

  t.equal(timestamp.getFullYear(), 2021, "Correct year");
  t.equal(timestamp.getMonth(), 9, "Correct month");
  t.equal(timestamp.getDate(), 1, "Correct day");
  t.equal(timestamp.getHours(), 19, "Correct hours");
  t.equal(timestamp.getMinutes(), 48, "Correct minutes");
  t.equal(timestamp.getSeconds(), 0, "Correct seconds");

  t.end();
});

test("Load single file", async (t) => {
  cleanDatabase();

  const fileName = "here-realtime-traffic.20211001T194818.json.gz";
  const filePath = join(hereRealtimeTrafficDataDir, fileName);

  // @ts-ignore
  const fullTableName = await loader.loadHereRealtimeTrafficDataFile(filePath);

  t.assert(tableIsNotEmpty(fullTableName), "Partition table loaded");

  t.assert(
    tableIsNotEmpty("public.here_realtime_traffic"),
    "Partition table attached"
  );

  let errMsg: string;
  try {
    await loader.loadHereRealtimeTrafficDataFile(filePath);
  } catch (err) {
    errMsg = err.message;
  }

  t.assert(
    /TIME_RANGE_START <= timestamp/.test(errMsg),
    "Second attempt throws timestamp error"
  );

  t.end();
});

let seriallyBulkLoadedTables: string[] = [];

test.only("Serially bulk load multiple files", async (t) => {
  cleanDatabase();

  loader.initializeDatabase();

  // const files = hereRealtimeTrafficJsonGzips.slice(0, 3);
  const files = hereRealtimeTrafficJsonGzips;
  const results = await loader.bulkLoadDataFiles(files);

  //@ts-ignore
  seriallyBulkLoadedTables = results
    .filter((t) => typeof t === "string")
    .sort();

  t.assert(seriallyBulkLoadedTables.length > 0, "Some tables loaded.");

  t.assert(
    results.some((t) => t instanceof Error),
    "Some tables threw Errors."
  );

  t.assert(
    tableIsNotEmpty("public.here_realtime_traffic"),
    "Partition table attached"
  );

  t.end();
});

test("Simulated mixed bulk archive load and scraper single file loading", async (t) => {
  cleanDatabase();

  // const files = hereRealtimeTrafficJsonGzips.slice(0, 3);
  const files = hereRealtimeTrafficJsonGzips;

  const bulkLoadFiles = hereRealtimeTrafficJsonGzips.slice(
    0,
    Math.floor(files.length / 2)
  );

  const singleLoadFiles = hereRealtimeTrafficJsonGzips.slice(
    Math.floor(files.length / 2)
  );

  const bulkLoadResultsPromise = loader.bulkLoadDataFiles(bulkLoadFiles);

  let i = 0;
  const singleLoadResultsPromise = Promise.all(
    singleLoadFiles.map(async (f) => {
      await new Promise((resolve) => process.nextTick(resolve));

      let resolveResult: Function;

      const result = new Promise((resolve) => {
        resolveResult = resolve;
      });

      setTimeout(async () => {
        try {
          resolveResult(await loader.loadHereRealtimeTrafficDataFile(f));
        } catch (err) {
          resolveResult(null);
        }
      }, 10 * ++i);

      return await result;
    })
  );

  const bulkLoadResults = (await bulkLoadResultsPromise).filter(
    (result) => typeof result === "string"
  );
  const singleLoadResults = (await singleLoadResultsPromise).filter(Boolean);

  t.deepEquals(
    [...bulkLoadResults, ...singleLoadResults].sort(),
    seriallyBulkLoadedTables.sort(),
    "Bulk serially loaded same as mixed concurrent loading."
  );

  t.end();
});

test.onFinish(() => {
  // cleanDatabase();
  db.end();
});
