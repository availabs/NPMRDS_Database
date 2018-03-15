#!/usr/bin/env node

const { execSync } = require('child_process');
const { env } = process;
const { join } = require('path');
const { openSync } = require('fs');

const { sync: mkdirpSync } = require('mkdirp');

const envFile = require('node-env-file');

const configPath = join(__dirname, '../../config/postgres.env.ares');
envFile(configPath);

const states = ['nj', 'ny'];

const ROOT_DIR = join(__dirname, '../../');
const DATA_DIR = join(__dirname, '../../data/csv/speedlimits/');

mkdirpSync(DATA_DIR);

states.forEach(state => {
  const outF = join(DATA_DIR, `${state}_avg_speedlimits.csv`);

  const out = execSync(
    `psql -c "COPY (SELECT tmc, avg_speedlimit FROM avg_speedlimits WHERE state = '${state}' ORDER BY tmc) TO STDOUT CSV HEADER;"`,
    { encoding: 'utf8', stdio: [0, openSync(outF, 'w'), 'pipe'] }
  );

  console.log(state);
});
