import { execSync } from "child_process";
import { pipeline } from "stream";
import { promisify } from "util";
import { join } from "path";

import { from as copyFrom } from "pg-copy-streams";
import pgFormat from "pg-format";

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

function getMetadataFromSqliteDb(sqliteDB: SQLiteDB) {
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
}

function createPostgesDbTable(
  state: string,
  year: number,
  month: number,
  pgEnv: "development" | "production"
) {
  const sqlDir = join(__dirname, "../../sql/npmrds/");

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

export default async function main({
  npmrds_export_sqlite_db_path,
  pg_env = "development",
}) {
  const sqlite3Connection = new Database(npmrds_export_sqlite_db_path, {
    readonly: true,
  });

  const pgConnection = await getConnectedPgClient(pg_env);

  const { state, year, month } = getMetadataFromSqliteDb(sqlite3Connection);

  createPostgesDbTable(state, year, month, "development");

  const mm = `0${month}`.slice(-2);

  const copyFromSql = pgFormat(
    `COPY %I.%I (${columns}) FROM STDIN WITH CSV HEADER`,
    state,
    `npmrds_y${year}m${mm}`
  );

  await pipelineAsync(
    createDataIterator(sqlite3Connection),
    csvFormat({ quote: true }),
    pgConnection.query(copyFrom(copyFromSql))
  );

  await pgConnection.end();
}
