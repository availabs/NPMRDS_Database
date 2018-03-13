#!/usr/bin/env node

const { env } = process;
const { execSync } = require('child_process');
const { Client } = require('pg');
const { join } = require('path');
const envFile = require('node-env-file');
const readline = require('readline');

const configPath = join(__dirname, '../../config/postgres.env');

envFile(configPath);

const client = new Client();

const states = require('./states.json');

const backfillSpeedlimits = async state => {
  const theSQL = `
    INSERT INTO "${state}".avg_speedlimits (tmc, avg_speedlimit, state)
      SELECT attr.tmc, spd.avg_speedlimit, '${state}' AS state
        FROM inrix_shapefile attr
          INNER JOIN "${state}".avg_speedlimits spd
          ON (
            regexp_replace(regexp_replace(attr.tmc, '-', 'N'), '\\+', 'P') = spd.tmc
          )
        WHERE (
          (spd.state = '${state}')
          AND
          (
            (attr.tmc LIKE '%-%')
            OR
            (attr.tmc LIKE '%+%')
          )
        )
  `;

  await client.query(theSQL);
};

const cleanup = async () => {
  const theSQL = `
    DELETE FROM avg_speedlimits
      WHERE tmc NOT IN (
        SELECT tmc FROM inrix_shapefile
      )
  `;

  await client.query(theSQL);
};

const finishUp = async state => {
  await client.query(
    `CLUSTER "${state}".avg_speedlimits USING avg_speedlimits_pkey;`
  );
  await client.query(`ANALYZE VERBOSE "${state}".avg_speedlimits;`);
};

const doIt = async () => {
  await client.connect();

  for (let i = 0; i < states.length; ++i) {
    const state = states[i];

    if (state === 'ny' || state === 'nj') {
      continue;
    }

    await backfillSpeedlimits(state);

    console.log(state);
  }

  await cleanup();

  for (let i = 0; i < states.length; ++i) {
    const state = states[i];

    await finishUp(state);
  }

  await client.end();
};

doIt();
