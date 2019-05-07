#!/usr/bin/env node

// TODO:
//   1. Extract the downloaded shapefile
//   2. Get the DBF_DATE_LAST_UPDATE
//   3. Create a directory with the DBF_DATE_LAST_UPDATE in its name.
//   3. Create a new archive using the new directory.

/* eslint no-await-in-loop: 0, no-plusplus: 0 */

const { createWriteStream, existsSync, unlinkSync } = require('fs');
const { join, isAbsolute } = require('path');

const request = require('request');

const yargs = require('yargs');
const { sync: mkdirpSync } = require('mkdirp');

const yargsSpec = {
  years: {
    alias: 'year',
    type: 'array',
    demand: true
  },
  downloadDir: {
    type: 'string',
    demand: true
  }
};

const {
  argv: { years, downloadDir }
} = yargs
  .strict()
  .parserConfiguration({
    'camel-case-expansion': false,
    'flatten-duplicate-arrays': true
  })
  .wrap(yargs.terminalWidth() / 1.618)
  .option(yargsSpec);

const downloadDirAbsPath = isAbsolute(downloadDir)
  ? downloadDir
  : join(process.cwd(), downloadDir);

mkdirpSync(downloadDirAbsPath);

const now = new Date();
const yyyy = now.getFullYear();
const mm = `0${now.getMonth() + 1}`.slice(-2);
const dd = `0${now.getDate()}`.slice(-2);
const HH = `0${now.getHours()}`.slice(-2);
const MM = `0${now.getMinutes()}`.slice(-2);
const SS = `0${now.getSeconds()}`.slice(-2);

const downloadTimestamp = `${yyyy}${mm}${dd}T${HH}${MM}${SS}`;

const downloadUABoundariesForYear = async year => {
  const url = `https://www2.census.gov/geo/tiger/TIGER${year}/UAC/tl_${year}_us_uac10.zip`;

  const outfilePath = join(
    downloadDirAbsPath,
    `ua_boundaries.${year}.${downloadTimestamp}.zip`
  );

  try {
    const outfileStream = createWriteStream(outfilePath);

    await new Promise((resolve, reject) => {
      request(url)
        .pipe(outfileStream)
        .on('close', () => {
          resolve();
        })
        .on('error', reject);
    });
  } catch (err) {
    console.error(err);
    if (existsSync(outfilePath)) {
      unlinkSync(outfilePath);
    }
  }
};

(async () => {
  for (let i = 0; i < years.length; ++i) {
    await downloadUABoundariesForYear(years[i]);
  }
})();
