#!/usr/bin/env node

/* eslint no-unused-expressions: 0, camelcase: 0 */

const { spawn } = require('child_process');

const yargs = require('yargs');

yargs
  .parserConfiguration({
    'camel-case-expansion': false,
    'flatten-duplicate-arrays': false
  })
  .option({
    pg_env: {
      type: 'string',
      demand: false,
      choices: ['production', 'development'],
      default: 'development'
    }
  })
  .command({
    command: 'create_geography_metadata',
    desc:
      'Create (or replace) the geography_metadata VIEW for the specified year',
    builder: {
      year: { type: 'number', demand: true }
    },
    handler: ({ year, pg_env }) => {
      spawn('make', ['db/create-geography-metadata-view'], {
        cwd: __dirname,
        stdio: 'inherit',
        env: { YEAR: year, PG_ENV: pg_env }
      });
    }
  })
  .command({
    command: 'download_urban_area_boundaries_shapefile',
    desc:
      'Download the TIGER Urban Area Shapefile from census.gov for the specified year',
    builder: {
      year: { type: 'number', demand: true }
    },
    handler: ({ year }) => {
      spawn('make', ['scraping/download-urban-area-boundaries-shapefile'], {
        cwd: __dirname,
        stdio: 'inherit',
        env: { YEAR: year }
      });
    }
  })
  .command({
    command: 'download_npmrds_data',
    desc:
      'Download and transform the NPMRDS Data from the RITIS Massive Data Downloader',
    builder: {
      downloadLinks: {
        type: 'array',
        desc: 'The download links.',
        demand: true
      }
    },
    handler: ({ downloadLinks }) => {
      spawn('make', ['etl/download-and-transform-npmrds-data'], {
        cwd: __dirname,
        stdio: 'inherit',
        env: { DOWNLOAD_LINKS: `${downloadLinks}` }
      });
    }
  })
  .command({
    command: 'create_pm3_tables',
    desc: 'Create the PM3 tables.',
    handler: ({ pg_env }) => {
      spawn('make', ['db/create_pm3_tables'], {
        cwd: __dirname,
        stdio: 'inherit',
        env: { PG_ENV: `${pg_env}` }
      });
    }
  })
  .demandCommand()
  .recommendCommands()
  .strict()
  .wrap(yargs.terminalWidth() / 1.618).argv;
