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
    YEAR: 'year',
    geographyType: 'geographyTypes'
  }
};

const cliArgs = process.argv.slice(2);

let { year, geographyTypes } = require('minimist')(cliArgs, minimistOptions);

if (!year) {
  console.error(`
    USAGE:
      --year is a required parameter
  `);

  process.exit(1);
}

const dataDir = join(__dirname, '../data/shapefiles/');

const stateCodes = {
  us: 'us',
  36: 'ny'
};

const shapefileURLs = {
  core_based_statistical_area: `https://www2.census.gov/geo/tiger/TIGER${year}/CSA/tl_${year}_us_csa.zip`,
  cbsa_metro: `https://www2.census.gov/geo/tiger/TIGER${year}/METDIV/tl_${year}_us_metdiv.zip`,
  cbsa_metro_micro: `https://www2.census.gov/geo/tiger/TIGER${year}/CBSA/tl_${year}_us_cbsa.zip`,
  cbsa_new_england: `https://www2.census.gov/geo/tiger/TIGER${year}/NECTA/tl_${year}_us_necta.zip`,
  cbsa_new_england_div: `https://www2.census.gov/geo/tiger/TIGER${year}/NECTADIV/tl_${year}_us_nectadiv.zip`,
  census_block: `https://www2.census.gov/geo/tiger/TIGER${year}/TABBLOCK/tl_${year}_36_tabblock10.zip`,
  census_block_group: `https://www2.census.gov/geo/tiger/TIGER${year}/BG/tl_${year}_36_bg.zip`,
  census_place: `https://www2.census.gov/geo/tiger/TIGER${year}/PLACE/tl_${year}_36_place.zip`,
  census_tract: `https://www2.census.gov/geo/tiger/TIGER${year}/TRACT/tl_${year}_36_tract.zip`,
  county: `https://www2.census.gov/geo/tiger/TIGER${year}/COUNTY/tl_${year}_us_county.zip`,
  county_subdivision: `https://www2.census.gov/geo/tiger/TIGER${year}/COUSUB/tl_${year}_36_cousub.zip`,
  puma: `https://www2.census.gov/geo/tiger/TIGER${year}/PUMA/tl_${year}_36_puma10.zip`,
  state: `https://www2.census.gov/geo/tiger/TIGER${year}/STATE/tl_${year}_us_state.zip`,
  urban_area: `https://www2.census.gov/geo/tiger/TIGER${year}/UAC/tl_${year}_us_uac10.zip`,
  zip_code: `https://www2.census.gov/geo/tiger/TIGER${year}/ZCTA5/tl_${year}_us_zcta510.zip`
};

geographyTypes = geographyTypes
  ? geographyTypes.split(',').map(g => g.trim().toLowerCase())
  : Object.keys(shapefileURLs);

if (!geographyTypes.every(g => shapefileURLs[g])) {
  geographyTypes.forEach(geoType => {
    if (!shapefileURLs[geoType]) {
      console.error(`ERROR: ${geoType} is not a recognized geography type.`);
    }
  });
  process.exit(1);
}

geographyTypes.forEach(geoType => {
  const url = shapefileURLs[geoType];
  const { pathname } = parse(url);
  const filename = basename(pathname);

  const stateCode = filename
    .replace(new RegExp(`tl_${year}_`), '')
    .replace(/_.*/, '');
  const state = stateCodes[stateCode];

  const downloadDir = join(dataDir, `${geoType}_boundaries`, state, `${year}`);
  const filepath = join(downloadDir, filename);

  mkdirpSync(downloadDir);
  console.log(`Downloading ${geoType}`);
  execSync(`curl -o '${filepath}' '${url}'`);
});
