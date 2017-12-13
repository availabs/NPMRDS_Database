#!/usr/bin/env node

const fs = require('fs');
const zlib = require('zlib');
const gzip = zlib.createGzip();

const request = require('request');
const csv = require('fast-csv');

const { parse } = require('url');

const { join, basename } = require('path');

const { execSync } = require('child_process');
const { sync: mkdirpSync } = require('mkdirp');

const minimistOptions = {
  // treat all double hyphenated arguments without equal signs as boolean
  boolean: true,
  // an object mapping string names to strings or arrays of string argument names to use as aliases
  alias: {
    //
    geographyType: 'geographyTypes'
  }
};

// NOTE: Gazeteer versions after 2010 do not contain populations
const dataDir = join(__dirname, '../data/csv/');

const SCHEMA = 'us';

const cliArgs = process.argv.slice(2);

let { year, geographyTypes } = require('minimist')(cliArgs, minimistOptions);

if (!year) {
  console.error(`
    USAGE:
      --year is a required parameter
  `);

  process.exit(1);
}

const csvURLs = {
  county: `https://api.census.gov/data/${year}/acs/acs1?get=B01001_001E&for=county:*&in=state:*`,
  urban_area: `https://api.census.gov/data/${year}/acs/acs1?get=B01001_001E&for=urban%20area:*`,
  state: `https://api.census.gov/data/${year}/acs/acs1?get=B01001_001E&for=state:*`
};

geographyTypes = geographyTypes
  ? geographyTypes.split(',').map(g => g.trim().toLowerCase())
  : Object.keys(csvURLs);

if (!geographyTypes.every(g => csvURLs[g])) {
  geographyTypes.forEach(geoType => {
    if (!csvURLs[geoType]) {
      console.error(`
        ERROR: ${geoType} is not a recognized geography type.
          The recognized geographyTypes are: ${Object.keys(csvURLs)}
      `);
    }
  });
  process.exit(1);
}

geographyTypes.forEach(geoType => {
  const url = csvURLs[geoType];
  const filename = `${geoType}_populations.${year}.us.gz`;

  const downloadDir = join(
    dataDir,
    `${geoType}_populations`,
    SCHEMA,
    `${year}`
  );

  mkdirpSync(downloadDir);

  const filepath = join(downloadDir, filename);

  const writableStream = fs.createWriteStream(filepath);

  // https://superuser.com/a/45651
  request({ url }, (err, resp, body) => {
    csv
      .write(JSON.parse(body), {
        headers: true,
        quoteColumns: true
      })
      .pipe(gzip)
      .pipe(writableStream);
  });
});
