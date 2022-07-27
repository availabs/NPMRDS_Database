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

import {
  getPsqlCredentials,
  getConnectedPgClient,
} from "../../utils/PostgreSQL";

const pipelineAsync = promisify(pipeline);

const columns = [
  "tmc",
  "type",
  "road",
  "road_order",
  "intersection",
  "tmclinear",
  "country",
  "state",
  "county",
  "zip",
  "direction",
  "start_latitude",
  "start_longitude",
  "end_latitude",
  "end_longitude",
  "miles",
  "frc",
  "border_set",
  "isprimary",
  "f_system",
  "urban_code",
  "faciltype",
  "structype",
  "thrulanes",
  "route_numb",
  "route_sign",
  "route_qual",
  "altrtename",
  "aadt",
  "aadt_singl",
  "aadt_combi",
  "nhs",
  "nhs_pct",
  "strhnt_typ",
  "strhnt_pct",
  "truck",
  "timezone_name",
  "active_start_date",
  "active_end_date",
  "download_timestamp",
];

const getMetadataFromSqliteDb = memoize((sqliteDB: SQLiteDB) => {
  const { state, month, year, download_timestamp } = sqliteDB
    .prepare(
      `
        SELECT
            state,
            month,
            year,
            download_timestamp
          FROM metadata
      `
    )
    .get();

  return {
    state,
    month,
    year,
    download_timestamp: download_timestamp.replace(/[^0-9T]/gi, ""),
  };
});

function getPostgresTableName(sqliteDB: SQLiteDB) {
  const { state, year, download_timestamp } = getMetadataFromSqliteDb(sqliteDB);

  return {
    schemaName: state,
    tableName:
      `tmc_identification_${year}_v${download_timestamp}`.toLowerCase(),
  };
}

function createPostgesDbTable(
  sqliteDB: SQLiteDB,
  pgEnv: "development" | "production"
) {
  const { state, year, download_timestamp } = getMetadataFromSqliteDb(sqliteDB);

  const sqlDir = join(__dirname, "../../sql/tmc_identification/");

  const pgCreds = getPsqlCredentials(pgEnv);

  execSync(
    `
      psql \
        --single-transaction \
        -v ON_ERROR_STOP=1 \
        -v STATE=${state} \
        -v YEAR=${year} \
        -v DOWNLOAD_TIMESTAMP=${download_timestamp.toLowerCase()} \
        -f ./root/create_root_year_tmc_identification_table.sql \
        -f ./state/create_state_year_tmc_identification_table.sql \
        -f ./state/create_state_year_month_tmc_identification_version_table.sql
    `,
    { cwd: sqlDir, env: { ...process.env, ...pgCreds }, encoding: "utf8" }
  );
}

function* createDataIterator(sqliteDB: SQLiteDB) {
  const { state, download_timestamp } = getMetadataFromSqliteDb(sqliteDB);

  const iter = sqliteDB
    .prepare(
      `
        SELECT ${columns}
          FROM tmc_identification
            CROSS JOIN (
              SELECT
                  '${download_timestamp}' AS download_timestamp
            )
          WHERE ( UPPER(state) = ? )
      `
    )
    .iterate([state.toUpperCase()]);

  for (const row of iter) {
    columns.forEach((c) => {
      if (/^null$/i.test(row[c])) {
        row[c] = null;
      }
    });

    yield row;
  }
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
