#!/usr/bin/env node

const { env } = process;
const { execSync } = require('child_process');
const { join } = require('path');
const envFile = require('node-env-file');

const configPath = join(__dirname, '../../config/postgres.env');

envFile(configPath);

const states = require('./states.json');

const sqlFile = join(__dirname, './backfill-using-overlapping-buffers.sql');

states.forEach(state => {
  console.log(`=== ${state} ===`);

  const out = execSync(`sed 's\/__STATE__\/${state}\/g' ${sqlFile} | psql`, {
    encoding: 'utf8'
  });

  console.log(out);
});
