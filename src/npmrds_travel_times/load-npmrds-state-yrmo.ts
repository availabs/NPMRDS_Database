import { execSync } from "child_process";
import { pipeline } from "stream";
import { promisify } from "util";
import { join } from "path";

import { Client as PostgresDB } from "pg";
import { from as copyFrom } from "pg-copy-streams";
import pgFormat from "pg-format";

import memoize from "memoize-one";

import { format as csvFormat } from "fast-csv";

import Database, { Database as SQLiteDB } from "better-sqlite3";

import { getPsqlCredentials, getConnectedPgClient } from "../utils/PostgreSQL";

const pipelineAsync = promisify(pipeline);

const columns = [
  "tmc",
  "date",
  "epoch",
  "travel_time_all_vehicles",
  "travel_time_passenger_vehicles",
  "travel_time_freight_trucks",
  "data_density_all_vehicles",
  "data_density_passenger_vehicles",
  "data_density_freight_trucks",
];

const getMetadataFromSqliteDb = memoize((sqliteDB: SQLiteDB) => {
  const metadata = sqliteDB
    .prepare(
      `
        SELECT
            state,
            month,
            year
          FROM metadata
      `
    )
    .get();

  return metadata;
});

function getPostgresTableName(sqliteDB: SQLiteDB) {
  const { state, year, month } = getMetadataFromSqliteDb(sqliteDB);

  const mm = `0${month}`.slice(-2);

  return {
    schemaName: state,
    tableName: `npmrds_y${year}m${mm}`,
  };
}

function createPostgesDbTable(
  sqliteDB: SQLiteDB,
  pgEnv: "development" | "production"
) {
  const { state, year, month } = getMetadataFromSqliteDb(sqliteDB);

  const sqlDir = join(__dirname, "../../sql/npmrds_travel_times/");

  const pgCreds = getPsqlCredentials(pgEnv);

  console.log(JSON.stringify(pgCreds, null, 4));

  execSync(
    `
      psql \
        --single-transaction \
        -v ON_ERROR_STOP=1 \
        -v STATE=${state} \
        -v YEAR=${year} \
        -v MONTH=${month} \
        -f ./createRootNPMRDSDataTable.sql \
        -f ./createStateNPMRDSDataTable.sql \
        -f ./createStateNPMRDSYrMoTable.sql
    `,
    { cwd: sqlDir, env: { ...process.env, ...pgCreds } }
  );
}

function createDataIterator(sqliteDB: SQLiteDB) {
  return sqliteDB
    .prepare(
      `
        SELECT ${columns}
          FROM npmrds
      `
    )
    .iterate();
}

async function loadPostgresDbTable(sqliteDB: SQLiteDB, pgDB: PostgresDB) {
  const { schemaName, tableName } = getPostgresTableName(sqliteDB);

  const deleteAllSql = pgFormat(`DELETE FROM %I.%I ;`, schemaName, tableName);

  await pgDB.query(deleteAllSql);

  const copyFromSql = pgFormat(
    `COPY %I.%I (${columns}) FROM STDIN WITH CSV`,
    schemaName,
    tableName
  );

  await pipelineAsync(
    createDataIterator(sqliteDB),
    csvFormat({ quote: true }),
    pgDB.query(copyFrom(copyFromSql))
  );
}

async function clusterPostgresTable(sqliteDB: SQLiteDB, pgDB: PostgresDB) {
  const { schemaName, tableName } = getPostgresTableName(sqliteDB);

  const sql = pgFormat(
    `CLUSTER %I.%I USING %I ;`,
    schemaName,
    tableName,
    `${tableName}_pkey`
  );

  await pgDB.query(sql);
}

export default async function main({
  npmrds_export_sqlite_db_path,
  pg_env = "development",
}: {
  npmrds_export_sqlite_db_path: string;
  pg_env: "development" | "production";
}) {
  const sqliteDB = new Database(npmrds_export_sqlite_db_path, {
    readonly: true,
  });

  const pgDB = await getConnectedPgClient(pg_env);

  createPostgesDbTable(sqliteDB, pg_env);

  await pgDB.query("BEGIN ;");

  await loadPostgresDbTable(sqliteDB, pgDB);
  await clusterPostgresTable(sqliteDB, pgDB);

  await pgDB.query("COMMIT ;");

  await pgDB.end();
  sqliteDB.close();
}
