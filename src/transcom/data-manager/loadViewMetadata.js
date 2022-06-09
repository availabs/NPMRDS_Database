#!/usr/bin/env node

const { existsSync, readFileSync } = require("fs");
const { isAbsolute, join } = require("path");

const { getConnectedPgClient } = require("../../utils/PostgreSQL");

if (process.argv.length !== 3) {
  console.error(
    "USAGE: ./generateTSTypeDef <path to ./analyzeSchema.js output>"
  );
  process.exit(1);
}

const metadataFilePath = isAbsolute(process.argv[2])
  ? process.argv[2]
  : join(process.cwd(), process.argv[2]);

if (!existsSync(metadataFilePath)) {
  console.error(`ERROR: file ${metadataFilePath} does not exist.`);
  process.exit(1);
}

const metadata = JSON.parse(
  readFileSync(metadataFilePath, { encoding: "utf8" })
);

const PG_ENV = "production";

async function main() {
  const db = await getConnectedPgClient(PG_ENV);

  try {
    await db.query("BEGIN;");

    const {
      source_name,
      data_type,
      interval_version,
      geography_version,
      version,
      source_url,
      publisher,
      data_table,
      download_url,
      tiles_url,
      start_date,
      end_date,
      last_updated,
    } = metadata;

    const {
      rows: [{ source_id }],
    } = await db.query(
      `
        SELECT
            id AS source_id
          FROM data_manager.sources
          WHERE ( name = $1 )
      `,
      [source_name]
    );

    if (!Number.isFinite(source_id)) {
      throw new Error(
        "Unable to find source named",
        source_name,
        "in the data_manager.sources table."
      );
    }

    const sql = `
      INSERT INTO data_manager.views (
        source_id,
        data_type,
        interval_version,
        geography_version,
        version,
        source_url,
        publisher,
        data_table,
        download_url,
        tiles_url,
        start_date,
        end_date,
        last_updated
      ) VALUES (
        $1,
        $2,
        $3,
        $4,
        $5,
        $6,
        $7,
        $8,
        $9,
        $10,
        $11,
        $12,
        $13
      )
    `;

    await db.query(sql, [
      source_id,
      data_type,
      interval_version,
      geography_version,
      version,
      source_url,
      publisher,
      data_table,
      download_url,
      tiles_url,
      start_date,
      end_date,
      last_updated,
    ]);

    await db.query("COMMIT;");
  } catch (err) {
    await db.query("ROLLBACK;");
    console.error(err);
  } finally {
    await db.end();
  }
}

main();
