#!/usr/bin/env node

const { env } = process;
const { execSync } = require('child_process');
const { openSync } = require('fs');
const { join } = require('path');

const envFile = require('node-env-file');
const { sync: mkdirpSync } = require('mkdirp');

const configPath = join(__dirname, '../../config/postgres.env.local');
envFile(configPath);

const states = require('./states.no-nynj.json');

const DATA_DIR = join(__dirname, './data/csv/speedlimits/');

mkdirpSync(DATA_DIR);

states.forEach(state => {
  const outF = join(DATA_DIR, `${state}.inrix.avg_speedlimits.backfilled.csv`);

  const out = execSync(
    `psql -c "COPY (SELECT tmc, avg_speedlimit FROM avg_speedlimits WHERE state = '${state}' ORDER BY tmc) TO STDOUT CSV HEADER;"`,
    { encoding: 'utf8', stdio: [0, openSync(outF, 'w'), 'pipe'] }
  );

  console.log(state);
});
