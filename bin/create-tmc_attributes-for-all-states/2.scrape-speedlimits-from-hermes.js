#!/usr/bin/env node

const { execSync } = require('child_process');
const { existsSync, openSync } = require('fs');
const { join } = require('path');
const { sync: mkdirpSync } = require('mkdirp');

const { PGPASSWORD } = process.env;

if (!PGPASSWORD) {
  console.error('PGPASSWORD environment variable is required.');
  process.exit(1);
}

const states = require('./s.json');

console.log(typeof states);

const ROOT_DIR = join(__dirname, '../../');
const DATA_DIR = join(__dirname, '../../data/csv/speedlimits/');

mkdirpSync(DATA_DIR);

states.forEach(state => {
  const outF = join(DATA_DIR, `${state}_avg_speedlimits.csv`);
  if (existsSync(outF)) {
    return;
  }

  const out = execSync(
    `psql -hpod2.rit.albany.edu -Unpmrds_user -dnpmrds_api -c "COPY (SELECT tmc, avg_speedlimit FROM avg_speedlimits WHERE state = '${state}' ORDER BY tmc) TO STDOUT CSV HEADER;"`,
    { encoding: 'utf8', stdio: [0, openSync(outF, 'w'), 'pipe'] }
  );

  console.log(state);
});
