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

const PG_ENV = "development";

async function main() {
  const db = await getConnectedPgClient(PG_ENV);

  try {
    await db.query("BEGIN;");

    const {
      name,
      update_interval,
      category,
      description,
      categories,
      type,
      display_name,
    } = metadata;

    const sql = `
      INSERT INTO data_manager.sources (
        name,
        update_interval,
        category,
        description,
        categories,
        type,
        display_name
      ) VALUES ($1, $2, $3, $4, $5, $6, $7) ;
    `;

    await db.query(sql, [
      name,
      update_interval,
      category,
      description,
      categories,
      type,
      display_name,
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
