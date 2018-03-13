#!/usr/bin/env node

const { env } = process;
const { execSync } = require('child_process');
const { Client } = require('pg');
const { join } = require('path');
const envFile = require('node-env-file');

const configPath = join(__dirname, '../../config/postgres.env');

envFile(configPath);

const client = new Client();

const doIt = async () => {
  await client.connect();

  const theSQL = `
    DELETE FROM avg_speedlimits
      WHERE (
        (avg_speedlimit = 0)
        OR
        (avg_speedlimit IS NULL)
      )
  `;

  await client.query(theSQL);

  await client.end();
};

doIt();
