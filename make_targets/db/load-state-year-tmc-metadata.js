#!/usr/bin/env node

const { execSync } = require('child_process');
const { Client } = require('pg');
const { join } = require('path');

const envFile = require('node-env-file');

const { PG_ENV, STATE, YEAR, NPMRDS_SHAPEFILE_VERSION } = process.env;

if (NPMRDS_SHAPEFILE_VERSION && !Number.isFinite(+NPMRDS_SHAPEFILE_VERSION)) {
  console.error(
    `ERROR: Invalid NPMRDS_SHAPEFILE_VERSION ${NPMRDS_SHAPEFILE_VERSION}`
  );
  process.exit(1);
}

const sqlFilePath = join(
  __dirname,
  '../../sql/tmc_metadata/state/loadStateTMCMetadataTableVersion.sql'
);

if (!(STATE && YEAR)) {
  console.error('STATE and YEAR are required ENV variables.');
  process.exit(1);
}

const dbConfigFileName =
  PG_ENV === 'production' ? 'postgres.env.prod' : 'postgres.env.dev';

const configPath = join(__dirname, '../../config', dbConfigFileName);
envFile(configPath);

const client = new Client();

const getTMCMetadataVersion = () => {
  const now = new Date();
  const yyyy = now.getFullYear();
  const mm = `0${now.getMonth() + 1}`.slice(-2);
  const dd = `0${now.getDate()}`.slice(-2);
  const HH = `0${now.getHours()}`.slice(-2);
  const MM = `0${now.getMinutes()}`.slice(-2);
  const SS = `0${now.getSeconds()}`.slice(-2);

  return `${yyyy}${mm}${dd}${HH}${MM}${SS}`;
};

const createTMCMetadataTable = tmcMetadataVersion => {
  const cmd = `
    psql \
      --quiet \
      --echo-queries \
      -v ON_ERROR_STOP=1 \
      -v STATE=${STATE} \
      -v YEAR=${YEAR} \
      -v TMC_METADATA_VERSION=${tmcMetadataVersion} \
      -f '${sqlFilePath}'
  `;

  const createTableSQL = execSync(cmd, { encoding: 'utf8' });

  return createTableSQL;
};

const doIt = async () => {
  try {
    await client.connect();

    const tmcMetadataVersion = getTMCMetadataVersion();

    createTMCMetadataTable(tmcMetadataVersion);
  } catch (err) {
    console.error(err);
  } finally {
    await client.end();
  }
};

doIt();
