import { execSync } from "child_process";
import { existsSync, mkdirSync, createWriteStream, rmSync } from "fs";
import { join } from "path";

import {
  getConnectedPgClient,
  getPsqlCredentials,
} from "../../utils/PostgreSQL";

import { PgEnv, PgClient } from "../../domain/PostgreSQLTypes";

type ViewDataTableMetadata = {
  source_id: number;
  source_name: string;
  view_version: string;
  data_tableschema: string;
  data_tablename: string;
};

enum OutputTypes {
  CSV = "CSV",
  ESRI_SHAPEFILE = "ESRI Shapefile",
  GEOJSON = "GeoJSON",
  GPKG = "GPKG",
}

const outputTypeFileExtensions = {
  [OutputTypes.CSV]: "csv",
  [OutputTypes.ESRI_SHAPEFILE]: "shp",
  [OutputTypes.GEOJSON]: "geojson",
  [OutputTypes.GPKG]: "gpkg",
};

export default class DownloadablesCreator {
  protected _db?: PgClient | null;

  static getFileNameBaseForViewDataTableMetadata({
    view_version,
    data_tableschema,
    data_tablename,
  }: ViewDataTableMetadata) {
    const versionSuffixRE = new RegExp(`_v?${view_version}$`);
    const cleanedTableName = data_tablename.replace(versionSuffixRE, "");
    const cleanedViewVersion = view_version.replace(/^v/, "");

    return `${data_tableschema}.${cleanedTableName}.v${cleanedViewVersion}`;
  }

  constructor(
    protected readonly pgEnv: PgEnv,
    protected readonly outputDirectory: string
  ) {}

  protected async getDbConnection() {
    if (this._db) {
      return this._db;
    }

    if (this._db === null) {
      throw new Error("The DB Connection as been closed.");
    }

    this._db = await getConnectedPgClient(this.pgEnv);

    return this._db;
  }

  protected async closeDbConnection() {
    if (this._db !== null) {
      const db = this._db;
      this._db = null;

      console.log("CLOSE CONNECTION");
      await db.end();
    }
  }

  async getViewsDataTablesMetadata(): Promise<ViewDataTableMetadata[]> {
    const db = await this.getDbConnection();
    const { rows } = await db.query(`
      SELECT
          a.id AS source_id,
          a.name AS source_name,
          b.version AS view_version,

          -- extracts the tableschema and removes any "
          regexp_replace(split_part(b.data_table, '.', 1), '[^_a-z0-9]', '', 'ig') as data_tableschema,

          -- extracts the tablename and removes any "
          regexp_replace(split_part(b.data_table, '.', 2), '[^_a-z0-9]', '', 'ig') as data_tablename
        FROM data_manager.sources AS a
          INNER JOIN data_manager.views AS b
            ON (a.id = b.source_id)
        WHERE ( a.name LIKE 'NYS/NYSDOT/FREIGHT_ATLAS/%' )
        ORDER BY 2
      ;
    `);

    return rows;
  }

  async createDownloadable(
    metadata: ViewDataTableMetadata,
    outputType: OutputTypes
  ) {
    const fileNameBase =
      DownloadablesCreator.getFileNameBaseForViewDataTableMetadata(metadata);
    const extension = outputTypeFileExtensions[outputType];
    const fileName = `${fileNameBase}.${extension}`;
    const filePath = join(this.outputDirectory, fileName);

    if (outputType === OutputTypes.ESRI_SHAPEFILE) {
      mkdirSync(filePath, { recursive: true });
    }

    const logFilePath = `${filePath}.log`;

    const logStream = createWriteStream(logFilePath);

    await new Promise((resolve) => logStream.once("open", resolve));

    const logMetadata = {
      ...metadata,
      outputType,
      timestamp: new Date().toISOString(),
    };

    logStream.write(`${JSON.stringify(logMetadata)}\n\n`);

    const [, layerName] = fileNameBase.split(/\./);

    const { PGHOST, PGUSER, PGDATABASE, PGPASSWORD } = getPsqlCredentials(
      this.pgEnv
    );

    const creds = `host='${PGHOST}' user='${PGUSER}' dbname='${PGDATABASE}' password='${PGPASSWORD}'`;

    console.log("=====", fileNameBase, "=====");

    try {
      const create = `
        set -e

        rm -rf ${fileName}

        ogr2ogr \
          -f '${outputType}' \
          -t_srs 'EPSG:4326' \
          -skipfailures \
          -lco GEOMETRY_NAME=wkb_geometry \
          -nln ${layerName} \
          ${fileName} \
          PG:"${creds}" \
          '${metadata.data_tableschema}.${metadata.data_tablename}'

        echo

        ogrinfo -al -so ${fileName}

        echo

        zip -rm ${fileName}.zip ${fileName}
      `;

      execSync(create, {
        cwd: this.outputDirectory,
        shell: "/bin/bash",
        stdio: ["ignore", logStream, logStream],
      });
    } catch (err) {
      if (err) {
        console.error(err);
      }
      const fpath = join(this.outputDirectory, fileName);
      if (existsSync(fpath)) {
        rmSync(fpath, { recursive: true, force: true });
        rmSync(`${fpath}.zip`, { recursive: true, force: true });
      }
    }

    logStream.end();
  }

  async run() {
    mkdirSync(this.outputDirectory, { recursive: true });

    const viewsDataTablesMetadata = await this.getViewsDataTablesMetadata();
    await this.closeDbConnection();

    for (const metadata of viewsDataTablesMetadata) {
      for (const outputType of Object.values(OutputTypes)) {
        await this.createDownloadable(metadata, outputType);
      }
    }
  }
}
