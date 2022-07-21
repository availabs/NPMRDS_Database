import { execSync, spawn } from "child_process";
import {
  createReadStream,
  writeSync,
  mkdirSync,
  closeSync,
  statSync,
} from "fs";
import { join } from "path";
import { createGunzip } from "zlib";

import tmp from "tmp";
import split from "split2";

import {
  getPsqlCredentials,
  getOgr2OgrPostgresConnectionString,
} from "../../utils/PostgreSQL";

const tmpDir = join(__dirname, "tmp");
mkdirSync(tmpDir, { recursive: true });

function createTable(
  state: string,
  year: number,
  versionTimestamp: string,
  pgEnv: "development" | "production"
) {
  const pgCreds = getPsqlCredentials(pgEnv);

  execSync(
    `
      psql \
        --single-transaction \
        -v ON_ERROR_STOP=1 \
        -v STATE=${state} \
        -v YEAR=${year} \
        -v VERSION_TIMESTAMP=${versionTimestamp} \
        -f ./sql/create_root_table.sql \
        -f ./sql/create_state_table.sql \
        -f ./sql/create_state_version_table.sql
    `,
    { cwd: __dirname, env: { ...process.env, ...pgCreds }, encoding: "utf8" }
  );
}

//  Need to convert GeoJSONL to GeoJSON for ogr2ogr.
//    ogr2ogr GeoJSONSeq driver added in v2.4
async function createTmpGeoJsonFile(
  tmc_shapes_geojsonl_gzip_path: string,
  state: string
) {
  const rs = createReadStream(tmc_shapes_geojsonl_gzip_path);
  const iter = rs.pipe(createGunzip()).pipe(split(JSON.parse));

  const { name, fd, removeCallback } = tmp.fileSync({
    dir: tmpDir, // FIXME: Using old version of tmp. Newer version config is tmpdir
    postfix: ".geojson",
  });

  writeSync(
    fd,
    '{"type": "FeatureCollection","name":"mdd_tmc_shapes","features": ['
  );

  let firstLine = true;
  for await (const line of iter) {
    const pre = firstLine ? "" : ",";

    line.properties.state = line.properties.state.toLowerCase();

    if (line.properties.state === state) {
      writeSync(fd, `${pre}${JSON.stringify(line)}`);
      firstLine = false;
    }
  }

  writeSync(fd, "]}");

  closeSync(fd);

  return { tmpGeoJsonFilePath: name, removeCallback };
}

async function load(
  tmpGeoJsonFilePath: string,
  state: string,
  year: number,
  versionTimestamp: string,
  pgEnv: "development" | "production"
) {
  const ogr2ogrArgs = [
    "-doo",
    "PRELUDE_STATEMENTS=BEGIN;",
    "-doo",
    "CLOSING_STATEMENTS=COMMIT;",
    "-skipfailures",
    "-append",
    "-t_srs",
    "EPSG:4326",
    "--config",
    "OGR_TRUNCATE",
    "YES",
    "--config",
    "PG_USE_COPY",
    "YES",
    "-nlt",
    "PROMOTE_TO_MULTI",
    "-nln",
    `${state}.mdd_tmc_shapes_${year}_v${versionTimestamp}`,
    tmpGeoJsonFilePath,
  ];

  const connStr = getOgr2OgrPostgresConnectionString(pgEnv);

  let success: Function;
  let fail: Function;

  const done = new Promise((resolve, reject) => {
    success = resolve;
    fail = reject;
  });

  spawn("ogr2ogr", ["-F", "PostgreSQL", `PG:${connStr}`, ...ogr2ogrArgs], {
    stdio: "inherit",
  })
    // @ts-ignore
    .once("error", fail)
    // @ts-ignore
    .once("close", success);

  await done;
}

function finish(
  state: string,
  year: number,
  versionTimestamp: string,
  pgEnv: "development" | "production"
) {
  const pgCreds = getPsqlCredentials(pgEnv);

  execSync(
    `
      psql \
        --single-transaction \
        -v ON_ERROR_STOP=1 \
        -v STATE=${state} \
        -v YEAR=${year} \
        -v VERSION_TIMESTAMP=${versionTimestamp} \
        -f ./sql/set_state_version.sql
    `,
    { cwd: __dirname, env: { ...process.env, ...pgCreds }, encoding: "utf8" }
  );
}

export default async function main({
  tmc_shapes_geojsonl_gzip_path,
  state,
  year,
  pg_env = "development",
}: {
  tmc_shapes_geojsonl_gzip_path: string;
  state: string;
  year: number;
  pg_env: "development" | "production";
}) {
  const stat = statSync(tmc_shapes_geojsonl_gzip_path);

  const timestamp = stat.atime
    .toISOString()
    .replace(/[^0-9a-z]/gi, "")
    .toLowerCase();

  createTable(state, year, timestamp, pg_env);

  const { tmpGeoJsonFilePath, removeCallback } = await createTmpGeoJsonFile(
    tmc_shapes_geojsonl_gzip_path,
    state
  );

  await load(tmpGeoJsonFilePath, state, year, timestamp, pg_env);

  removeCallback();

  finish(state, year, timestamp, pg_env);
}
