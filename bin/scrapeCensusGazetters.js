#!/usr/bin/env node

const { parse } = require('url');

const { join, basename } = require('path');

const { execSync } = require('child_process');
const { sync: mkdirpSync } = require('mkdirp');

const minimistOptions = {
  //treat all double hyphenated arguments without equal signs as boolean
  boolean: true,
  // an object mapping string names to strings or arrays of string argument names to use as aliases
  alias: {
    //
    geographyType: 'geographyTypes'
  }
};

// NOTE: Gazeteer versions after 2010 do not contain populations
const VERSION = '2010';

const dataDir = join(__dirname, '../data/tsvs/');

const schema = 'us';

const cliArgs = process.argv.slice(2);

let { geographyTypes } = require('minimist')(cliArgs, minimistOptions);

const tsvURLs = {
  county:
    'https://www2.census.gov/geo/docs/maps-data/data/gazetteer/Gaz_counties_national.zip',
  urban_area:
    'https://www2.census.gov/geo/docs/maps-data/data/gazetteer/Gaz_ua.zip'
};

// Aliases
tsvURLs.cbsa = tsvURLs.core_based_statistical_area;
tsvURLs.ua = tsvURLs.urban_area;

geographyTypes = geographyTypes
  ? geographyTypes.split(',').map(g => g.trim().toLowerCase())
  : Object.keys(tsvURLs);

if (!geographyTypes.every(g => tsvURLs[g])) {
  geographyTypes.forEach(geoType => {
    if (!tsvURLs[geoType]) {
      console.error(`ERROR: ${geoType} is not a recognized geography type.`);
    }
  });
  process.exit(1);
}

geographyTypes.forEach(geoType => {
  const url = tsvURLs[geoType];
  const { pathname } = parse(url);
  const filename = basename(pathname);

  const downloadDir = join(dataDir, `${geoType}_populations`, schema, VERSION);
  const filepath = join(downloadDir, filename);

  mkdirpSync(downloadDir);
  console.log(`Downloading ${geoType}`);
  execSync(`curl -o '${filepath}' '${url}'`);
});
