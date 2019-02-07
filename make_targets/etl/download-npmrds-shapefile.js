#!/usr/bin/env node

const { existsSync, createWriteStream } = require('fs');
const { join, dirname } = require('path');

const request = require('request');

// === Get env params ===

// DOWNLOAD_FILE_PATH is optional
const DOWNLOAD_FILE_PATH = process.argv[2];

// COUNTRY & YEAR are required
const COUNTRY = process.env.COUNTRY && process.env.COUNTRY.toUpperCase();
const YEAR = process.env.YEAR && process.env.YEAR.toUpperCase();

// === Validate env params ===
if (!COUNTRY) {
  console.error('ERROR: COUNTRY env variable must be set.');
  process.exit(1);
}

if (!COUNTRY.match(/USA|CANADA/)) {
  console.error('ERROR: COUNTRY env variable must be either USA or CANADA.');
}

if (!YEAR) {
  console.error('ERROR: YEAR env variable must be set.');
  process.exit(1);
}

const country = {
  USA: 'USA',
  CANADA: 'Canada'
}[COUNTRY];

const url = `http://www.cattlab.umd.edu/shapefiles/NPMRDS/${YEAR}/${country}.zip`;

try {
  const outfilePath =
    DOWNLOAD_FILE_PATH || join(process.cwd(), `${country}.zip`);
  const downloadDir = dirname(DOWNLOAD_FILE_PATH);

  if (!existsSync(downloadDir)) {
    console.error(`The download directory does not exist: ${downloadDir}`);
    process.exit(1);
  }

  const outfileStream = createWriteStream(outfilePath);

  request(url)
    .pipe(outfileStream)
    .on('close', () => console.log(outfilePath))
    .on('error', err => {
      console.error(err);
      process.exit(1);
    });
} catch (err) {
  console.error(err);
}
