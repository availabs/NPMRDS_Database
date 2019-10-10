#!/usr/bin/env node

/* eslint no-continue: 0 */

const { join, isAbsolute } = require('path');
const { execSync } = require('child_process');
const { existsSync, readdirSync, unlinkSync } = require('fs');
const { fileSync: tmpFileSync, dirSync: tmpDirSync } = require('tmp');

const { padStart } = require('lodash');

const yargs = require('yargs');
const { sync: mkdirpSync } = require('mkdirp');
const { sync: rimrafSync } = require('rimraf');

const YEARS = require('./YEARS');
const REGIONS = require('./REGIONS');
const TABLES = require('./TABLES');

const getDataFileName = require('./getDataFileName');

const yargsSpec = {
  years: {
    alias: 'year',
    type: 'array',
    demand: false,
    default: YEARS
  },
  regions: {
    alias: 'region',
    type: 'array',
    demand: false,
    default: REGIONS
  },
  tables: {
    alias: 'table',
    type: 'array',
    demand: false,
    default: TABLES
  },
  downloadDir: {
    type: 'string',
    demand: true
  },
  overwrite: {
    type: 'boolean',
    default: false
  }
};

const {
  argv: { years, regions, tables, downloadDir, overwrite }
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

const urlPath =
  'https://www.dot.ny.gov/divisions/engineering/technical-services/highway-data-services/hdsb/repository';

// Sed program for cleaning up the downloaded CSVs
const sedProgram =
  // Trim whitespace from the columns.
  's/ *, */,/g; ' +
  // Remove Windows line endings.
  's/\r//; ' +
  // Fix the columns here either side of an '/' are many whitespaces apart.
  's# */ *# / #g; ' +
  // Delete the "row selected" lines from the CSV
  '/rows selected/d; ' +
  // Some CSVs had a line with ---,---,
  //   So we delete rows that have no alpha-numeric characters
  '/[A-Za-Z0-9]/!d';

const getURLDocumentName = (table, region, year) => {
  switch (table) {
    case 'average_weekday_speed':
      return `SC_Speed_AVGWD_R${padStart(region, 2, '0')}_${year}.zip`;
    case 'average_weekday_vehicle_classification':
      return `SC_CLASS_AVGWD_R${padStart(region, 2, '0')}_${year}.zip`;
    case 'average_weekday_volume':
      return `SC_Volume_AVGWD_R${padStart(region, 2, '0')}_${year}.zip`;
    case 'continuous_vehicle_classification':
      return `CC_CLASS_R${region}_${year}.zip`;
    case 'continuous_volume':
      return `CC_VOL_R${region}_${year}.zip`;
    case 'short_count_speed':
      return `SC_Speed_Data_R${padStart(region, 2, '0')}_${year}.zip`;
    case 'short_count_vehicle_classification':
      return `SC_Class_Data_R${padStart(region, 2, '0')}_${year}.zip`;
    case 'short_count_volume':
      return `SC_Volume_Data_R${padStart(region, 2, '0')}_${year}.zip`;
    default:
      throw new Error('Unrecognized table name');
  }
};

// https://www.dot.ny.gov/divisions/engineering/technical-services/highway-data-services/hdsb
for (let i = 0; i < years.length; ++i) {
  const year = years[i];

  for (let j = 0; j < regions.length; j += 1) {
    const region = regions[j];

    for (let k = 0; k < tables.length; ++k) {
      const table = tables[k];

      const outputFileName = getDataFileName(table, region, year);
      const outputFilePath = join(downloadDirAbsPath, outputFileName);

      if (!overwrite && existsSync(outputFilePath)) {
        console.warn(
          `${outputFileName} already exists. Skipping ${year}, ${region}, ${table}...`
        );
        continue;
      }

      const urlDocumentName = getURLDocumentName(table, region, year);
      const url = `${urlPath}/${urlDocumentName}`;

      const { name: tmpDirName } = tmpDirSync();

      const zipFilePath = join(tmpDirName, urlDocumentName);

      try {
        // Download the archive
        execSync(`curl -k -o '${zipFilePath}' '${url}'`, {
          stdio: [null, null, null]
        });

        // Extract the archive
        execSync(`unzip ${zipFilePath}`, {
          cwd: tmpDirName,
          stdio: [null, null, null]
        });

        // Delete the archive
        execSync(`rm -f ${zipFilePath}`, { cwd: tmpDirName });

        // Get the name of the extracted CSV.
        const dotCSVFileName = readdirSync(tmpDirName).filter(f =>
          f.match(/csv$/i)
        )[0];

        // Clean the extracted CSV (in place)
        execSync(`sed -i '${sedProgram}' '${dotCSVFileName}'`, {
          cwd: tmpDirName
        });

        // Remove duplicate rows to fix the problem of the header showing up at the beginning and the end of a file.
        // https://stackoverflow.com/a/20639730/3970755
        // Put the cleaned output into a temporary file
        const { name: tmpFileName } = tmpFileSync({ dir: tmpDirName });
        execSync(
          `cat -n '${dotCSVFileName}' | sort -uk2 | sort -nk1 | cut -f2- > ${tmpFileName}`,
          { cwd: tmpDirName }
        );

        // Move the cleaned CSV to the output dir with the canonical name
        execSync(`mv ${tmpFileName} '${outputFilePath}'`, {
          cwd: tmpDirName
        });

        // Compress the CSV
        execSync(`gzip -f -9 '${outputFilePath}'`, { cwd: downloadDirAbsPath });
      } catch (err) {
        // If we encountered an error, remove the output file if it exists
        if (existsSync(outputFilePath)) {
          unlinkSync(outputFilePath);
        }
      } finally {
        // Delete the tmp work dir
        rimrafSync(tmpDirName);
      }
    }
  }
}
