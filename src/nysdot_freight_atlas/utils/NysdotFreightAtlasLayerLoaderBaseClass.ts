import { execSync } from "child_process";
import { join } from "path";

import { getPsqlCredentials } from "../../../make_targets/utils";

export enum PGEnv {
  DEVELOPMENT = "development",
  PRODUCTION = "production",
}

export type NysdotFreightAtlasLayerLoaderBaseClassParams = {
  pg_env?: PGEnv;
  nysdot_freight_atlas_geodatabase_path: string;
  table_version: string;
  geodatabase_layer_name: string;
  table_name_base: string;
};

const versionRegExp = /^\d{4}$/;

export default abstract class NysdotFreightAtlasLayerLoaderBaseClass {
  protected static readonly getPsqlCredentials = getPsqlCredentials;
  protected static readonly versionRegExp = versionRegExp;

  readonly pg_env: PGEnv;
  readonly nysdot_freight_atlas_geodatabase_path: string;

  readonly table_name_base: string;
  readonly table_version: string;
  readonly geodatabase_layer_name: string;

  constructor({
    pg_env,
    nysdot_freight_atlas_geodatabase_path,
    table_name_base,
    table_version,
    geodatabase_layer_name,
  }: NysdotFreightAtlasLayerLoaderBaseClassParams) {
    this.pg_env = pg_env || PGEnv.DEVELOPMENT;
    this.nysdot_freight_atlas_geodatabase_path =
      nysdot_freight_atlas_geodatabase_path;

    this.table_name_base = table_name_base;
    this.table_version = table_version;
    this.geodatabase_layer_name = geodatabase_layer_name;
  }

  initializeDatabase() {
    const creds = getPsqlCredentials(this.pg_env);

    execSync(
      `
        psql \
          -q \
          -f create_nysdot_freight_atlas_schema.sql
        `,
      {
        cwd: join(__dirname, "../../../sql/nysdot_freight_atlas/"),
        env: {
          ...process.env,
          ...creds,
          PGOPTIONS: "--client_min_messages=error",
        },
        stdio: ["ignore", "inherit", "inherit"],
      }
    );
  }

  loadLayer() {
    this.initializeDatabase();

    const { PGHOST, PGUSER, PGDATABASE, PGPASSWORD } = getPsqlCredentials(
      this.pg_env
    );

    const creds = `host='${PGHOST}' user='${PGUSER}' dbname='${PGDATABASE}' password='${PGPASSWORD}'`;

    //  For CONVERT_TO_LINEAR explanation, see
    //    https://gdal.org/programs/ogr2ogr.html#cmdoption-ogr2ogr-nlt
    const cmd = `
      ogr2ogr \
        -f 'PostgreSQL' \
        PG:"${creds}" \
        -t_srs 'EPSG:4326' \
        -skipfailures \
        -lco OVERWRITE=yes \
        -lco GEOMETRY_NAME=wkb_geometry \
        -nln nysdot_freight_atlas.${this.table_name_base}_v${this.table_version} \
        -nlt CONVERT_TO_LINEAR \
        ${this.nysdot_freight_atlas_geodatabase_path} \
        ${this.geodatabase_layer_name}
    `;

    execSync(cmd, {
      stdio: ["ignore", "inherit", "inherit"],
    });
  }
}
