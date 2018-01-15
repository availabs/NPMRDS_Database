#!/usr/bin/env node

const fs = require('fs');
const zlib = require('zlib');
const gzip = zlib.createGzip();

const request = require('request-promise-native');
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

const cliArgs = process.argv.slice(2);

let { year, geographyTypes } = require('minimist')(cliArgs, minimistOptions);

const API_KEY = require('../config/census_api_key.json');
const fipsToState = require('./fipsToStateCode.json');

if (!year) {
  console.error(`
    USAGE:
      --year is a required parameter
  `);

  process.exit(1);
}

// https://www.census.gov/data/developers/data-sets/acs-5year.2016.html
const csvURLs = {
  county: `https://api.census.gov/data/${year}/acs/acs5?get=B01001_001E&for=county:*&in=state:*`,
  county_subdivision: `https://api.census.gov/data/${year}/acs/acs5?key=${API_KEY}&get=NAME,B01001_001E&for=county%20subdivision:*&in=state:36`, //FIXME: Hardcoded for NY
  urban_area: `https://api.census.gov/data/${year}/acs/acs5?key=${API_KEY}&get=NAME,B01001_001E&for=urban%20area:*`,
  state: `https://api.census.gov/data/${year}/acs/acs5?get=B01001_001E&for=state:*`
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

function standardScraper({ geoType, writableStream }) {
  const url = csvURLs[geoType];

  request({ url }, (err, resp, body) => {
    csv
      .write(JSON.parse(body), {
        headers: true,
        quoteColumns: true
      })
      .pipe(gzip)
      .pipe(writableStream);
  });
}

async function urbanAreaScraper({ writableStream }) {
  // urban_area: `https://api.census.gov/data/${year}/acs/acs5?get=B01001_001E&for=urban%20area:*`,
  // https://superuser.com/a/45651

  const url = csvURLs.urban_area;

  let uaData = [];

  const d = JSON.parse(await request({ url }));

  // For each urban area, scrape request a by-state breakdown
  for (let i = 1; i < d.length; ++i) {
    console.log('%d/%d', i, d.length - 1);
    const [name, totalPop, uaCode] = d[i]; //FIXME: Use the schema

    const url2 = `https://api.census.gov/data/${year}/acs5?key=${API_KEY}&get=B01001_001E&for=state:*&in=urban%20area:${uaCode}`;

    const stateCodes = name
      .toLowerCase()
      .replace(/.*, /, '')
      .replace(/ .*/, '')
      .split('--')
      .sort();

    console.log(uaCode, ':', name, ':', stateCodes);

    uaData.push({
      ua_code: uaCode,
      pop: totalPop,
      states: `{${stateCodes}}`
    });

    if (stateCodes.length > 1) {
      try {
        const d2 = JSON.parse(await request({ url: url2 }));

        const schema2 = d2[0];

        for (let j = 1; j < d2.length; ++j) {
          const statePop = d2[j][0];
          const fipsCode = d2[j][2];

          console.log(`\t${fipsToState[fipsCode]}`);

          uaData.push({
            ua_code: uaCode,
            pop: statePop,
            states: `{${[fipsToState[fipsCode]]}}`
          });
        }
      } catch (err) {
        console.log(err.message.slice(0, 10));
      }
    }

    // throttle
    await new Promise(resolve => setTimeout(resolve, 250));
  }

  csv
    .write(uaData, {
      headers: true,
      quoteColumns: true
    })
    .pipe(gzip)
    .pipe(writableStream);
}

async function scrape() {
  for (let i = 0; i < geographyTypes.length; ++i) {
    const geoType = geographyTypes[i];

    const schema = geoType === 'county_subdivision' ? 'ny' : 'us'; //FIXME

    const filename = `${geoType}_populations.5-year-estimate.${year}.${schema}.gz`;

    const downloadDir = join(
      dataDir,
      `${geoType}_populations`,
      schema,
      `${year}`
    );

    mkdirpSync(downloadDir);

    const filepath = join(downloadDir, filename);

    const writableStream = fs.createWriteStream(filepath);

    if (geoType === 'urban_area') {
      await urbanAreaScraper({ writableStream });
    } else {
      await standardScraper({ geoType, writableStream });
    }
  }
}

scrape();
