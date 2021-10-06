/* eslint-disable no-restricted-syntax */

import { readdirSync } from "fs";
import { join, basename } from "path";

import { default as PgNative } from "pg-native";
import dotenv from "dotenv";

import test from "tape";

import { getPostgresConfigurationFilePath } from "../../../../make_targets/utils";
// import HereRealtimeTrafficDatabaseLoader from ".";
import HereRealtimeTrafficDatabaseLoader from ".";

// DO NOT CHANGE!
const pg_env = "development";

const hereRealtimeTrafficDataDir = join(__dirname, "../data/");

const hereRealtimeTrafficJsonGzips = readdirSync(hereRealtimeTrafficDataDir)
  .filter((f) => /^here-realtime-traffic\..*\.json\.gz$/.test(f))
  .sort();

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

function partitionTableIsNotEmpty(fullTableName: string) {
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

if (rootTableExists() || partitionSchemaExists()) {
  throw new Error(
    "Before running tests, the public.here_realtime_traffic table and the here_realtime_traffic_partitions schema must not exist."
  );
}

function cleanDatabase() {
  db.querySync(`
    BEGIN;

    DROP TABLE IF EXISTS public.here_realtime_traffic CASCADE;
    DROP SCHEMA IF EXISTS here_realtime_traffic_partitions CASCADE;

    COMMIT;
  `);
}

test("Parse HERE Realtime Traffic JSON Gzip file name", async (t) => {
  const fileName = "here-realtime-traffic.20211001T194818.json.gz";

  const partitionTimeObj =
    HereRealtimeTrafficDatabaseLoader.parseHereRealtimeTrafficFileName(
      fileName
    );

  t.deepEquals(partitionTimeObj, {
    year: "2021",
    month: "10",
    day: "01",
    hour: "19",
    minute: "48",
    second: "18",
  });

  t.assert(true);

  t.end();
});

test("Load partition table", async (t) => {
  cleanDatabase();

  const fileName = "here-realtime-traffic.20211001T194818.json.gz";
  const filePath = join(hereRealtimeTrafficDataDir, fileName);

  const loader = new HereRealtimeTrafficDatabaseLoader({ pg_env });

  // @ts-ignore
  const fullTableName = await loader.loadHereRealtimeTrafficData(filePath);

  t.assert(partitionTableIsNotEmpty(fullTableName), "Partition table loaded");

  t.assert(
    partitionTableIsNotEmpty("public.here_realtime_traffic"),
    "Partition table attached"
  );

  // cleanDatabase();

  t.end();
});

test("Load multiple partition tables", async (t) => {
  cleanDatabase();

  const loader = new HereRealtimeTrafficDatabaseLoader({ pg_env });

  for (const fileName of hereRealtimeTrafficJsonGzips) {
    try {
      const filePath = join(hereRealtimeTrafficDataDir, fileName);
      console.log(basename(filePath));

      await loader.loadHereRealtimeTrafficData(filePath);
    } catch (err) {
      console.error("s".repeat(10));
      console.error(err);
    }
  }

  t.assert(
    partitionTableIsNotEmpty("public.here_realtime_traffic"),
    "Partition table attached"
  );

  t.end();
});

test.onFinish(() => {
  // cleanDatabase();
  db.end();
});
