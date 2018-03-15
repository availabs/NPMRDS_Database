#!/usr/bin/env node

// DANGER: DO NOT RUN THIS ON PRODUCTION !!!

const { env } = process;
const { Client } = require('pg');
const { join } = require('path');
const envFile = require('node-env-file');

const SUBSET_PCT = 5;

// ======= Leave the next line as is =======
const configPath = join(__dirname, '../../../config/postgres.env.local');
// =========================================

envFile(configPath);

const client = new Client();

const getStateShapefileTables = async () => {
  const q = `
    SELECT
        ('"' || schemaname || '".' || tablename) AS tbl
      FROM pg_tables
      WHERE tablename LIKE 'inrix_shapefile_%'
    ORDER BY tbl;
  `;

  const result = await client.query(q);

  const tblNames = result.rows.map(({ tbl }) => tbl);

  return tblNames;
};

const createInrixShapefileSubset = async tbl => {
  const q = `
    DELETE FROM ${tbl}
      WHERE tmc IN (
        SELECT tmc FROM ${tbl} TABLESAMPLE BERNOULLI(${100 - SUBSET_PCT})
      )
    ;
  `;

  // console.log(q);
  await client.query(q);
};

const doIt = async () => {
  await client.connect();

  const tableNames = await getStateShapefileTables();

  for (let i = 0; i < tableNames.length; ++i) {
    const tbl = tableNames[i];

    await createInrixShapefileSubset(tbl);
  }

  client.end();
};

doIt();
