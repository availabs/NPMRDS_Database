import { readFileSync } from "fs";
import { join } from "path";
import { pipeline } from "stream";
import { promisify } from "util";

import dotenv from "dotenv";
import { Client } from "pg";
import { from as copyFrom } from "pg-copy-streams";

import _ from "lodash";

import { getPostgresConfigurationFilePath } from "../../../../make_targets/utils";

import createTranscomEventsCsvStream, {
  TranscomEventsCsvStream,
} from "./utils/createTranscomEventsCsvStream";

import transcomEventsDatabaseTableColumns from "./utils/transcomEventsDatabaseTableColumns";

import { PGEnv } from "../types";

const pipelineAsync = promisify(pipeline);

function getSql(fName: string) {
  return readFileSync(join(__dirname, "./sql/", fName), {
    encoding: "utf8",
  });
}

export type TranscomEventsDownloaderParams = {
  transcom_events_ndjson_gzip: string;
  pg_env: PGEnv;
};

// TODO: params = pgEnv, transcomEventsNdjsonGzipPath
export default class TranscomEventsDatabaseLoader {
  private static getTmpTableName() {
    return `tmp_transcom_${new Date().getTime()}`;
  }

  private readonly pgEnv: PGEnv;
  private readonly transcomEventsNdjsonGzipPath: string;
  private readonly tmpTableName: string;

  constructor({
    pg_env,
    transcom_events_ndjson_gzip,
  }: TranscomEventsDownloaderParams) {
    this.pgEnv = pg_env;
    this.transcomEventsNdjsonGzipPath = transcom_events_ndjson_gzip;
    this.tmpTableName = TranscomEventsDatabaseLoader.getTmpTableName();
  }

  private async createTranscomTableIfNotExists(db: Client) {
    const {
      rows: [{ exists }],
    } = await db.query(`
      SELECT EXISTS (
        SELECT
            1
          FROM information_schema.tables
          WHERE (
            ( table_schema = 'transcom' )
            AND
            ( table_name   = 'transcom_historical_events' )
          )
       ) AS exists;
    `);

    if (!exists) {
      const sql = readFileSync(
        join(
          __dirname,
          "../../../../sql/transcom_historical_events/create_transcom_historical_events_table.sql"
        ),
        {
          encoding: "utf8",
        }
      );

      await db.query(sql);
    }
  }

  private async createTempTable(db: Client) {
    const sql = getSql("create_tmp_table.sql").replace(
      /__TMP_TABLE_NAME__/g,
      this.tmpTableName
    );

    await db.query(sql);
  }

  private async populateTempTable(
    db: Client,
    transcomEventsCsvStream: TranscomEventsCsvStream
  ) {
    // NOTE: using the transcomEventsDatabaseTableColumns array
    //       keeps column order consistent with transcomEventsCsvStream

    const nullableCols = _.difference(transcomEventsDatabaseTableColumns, [
      "event_id",
    ]);

    const sql = getSql("copy_from.sql")
      .replace(/__TMP_TABLE_NAME__/g, this.tmpTableName)
      .replace(/__TABLE_COLUMNS__/g, transcomEventsDatabaseTableColumns.join())
      .replace(/__NULLABLE_COLUMNS__/g, nullableCols.join());

    const pgCopyStream = db.query(copyFrom(sql));

    await pipelineAsync(transcomEventsCsvStream, pgCopyStream);
  }

  private async setPointGeomInTmpTable(db: Client) {
    await db.query(`
      UPDATE ${this.tmpTableName}
        SET point_geom = ST_MakePoint(longitude, latitude)::geography::geometry
    `);
  }

  private async setDurationIntervalInTmpTable(db: Client) {
    await db.query(`
      UPDATE ${this.tmpTableName}
        SET duration_interval = (close_time - creation);
    `);
  }

  private async copyFromTempIntoTransconEventTable(db: Client) {
    const sql = getSql("load_table_from_tmp.sql").replace(
      /__TMP_TABLE_NAME__/g,
      this.tmpTableName
    );

    await db.query(sql);
  }

  private async dropTempTable(db: Client) {
    await db.query(`DROP TABLE IF EXISTS ${this.tmpTableName};`);
  }

  private async finishUp(db: Client) {
    await db.query(`
      CLUSTER transcom.transcom_historical_events ;

      ANALYZE transcom.transcom_historical_events;
    `);
  }

  async run() {
    const configPath = getPostgresConfigurationFilePath(this.pgEnv);

    dotenv.config({ path: configPath });

    const { PGDATABASE, PGHOST, PGPORT } = process.env;

    console.error(
      `Loading ${PGDATABASE}.transcom.transcom_historical_events at ${PGHOST}:${PGPORT}.`
    );

    const db = new Client();

    try {
      await db.connect();

      const transcomEventsCsvStream = createTranscomEventsCsvStream(
        this.transcomEventsNdjsonGzipPath
      );

      await this.createTranscomTableIfNotExists(db);
      await this.createTempTable(db);

      await this.populateTempTable(db, transcomEventsCsvStream);
      await this.setPointGeomInTmpTable(db);
      await this.setDurationIntervalInTmpTable(db);
      await this.copyFromTempIntoTransconEventTable(db);
      await this.finishUp(db);
    } catch (err) {
      console.error(err);
      throw err;
    } finally {
      await this.dropTempTable(db);
      await db.end();
    }
  }
}
