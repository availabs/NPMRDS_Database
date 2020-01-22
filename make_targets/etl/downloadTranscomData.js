#!/usr/bin/env node

/* eslint camelcase: 0, no-console: 0, no-plusplus: 0, no-await-in-loop: 0, global-require: 0 */

const { createReadStream, createWriteStream, mkdirSync } = require('fs');
const { createGzip } = require('zlib');
const { isAbsolute, join } = require('path');

const request = require('request');
const { dirSync: tmpDirSync } = require('tmp');
const { sync: rimrafSync } = require('rimraf');
const { pipe, through } = require('mississippi');
const split = require('split2');

const _ = require('lodash');

const yargs = require('yargs');

const envFile = require('node-env-file');

const TRANSCOM_URI =
  'https://eventsearch.xcmdata.org/HistoricalEventSearch/xcmEvent/getEventGridData';

const EVENT_TYPES = [
  'exit',
  'SIGINT',
  'SIGUSR1',
  'SIGUSR2',
  'uncaughtException',
  'SIGTERM'
];

const now = new Date();

const getNowTimestamp = transcomFormat => {
  const yyyy = now.getFullYear();
  const mm = `0${now.getMonth() + 1}`.slice(-2);
  const dd = `0${now.getDate()}`.slice(-2);
  const HH = `0${now.getHours()}`.slice(-2);
  const MM = `0${now.getMinutes()}`.slice(-2);
  const SS = `0${now.getSeconds()}`.slice(-2);

  return transcomFormat
    ? `${yyyy}-${mm}-${dd} ${HH}:${MM}:${SS}`
    : `${yyyy}${mm}${dd}T${HH}${MM}${SS}`;
};

const cliArgsSpec = {
  output_dir: {
    demand: false,
    type: 'string',
    default: join(__dirname, '../../data/transcom/')
  },
  start_timestamp: Object.assign({
    demand: false,
    type: 'string',
    describe:
      '"yyyy-mm-dd HH:MM:SS" format. (If not provided, the latest timestamp in the transcom_historical_events table is used.)'
  }),
  end_timestamp: {
    demand: false,
    type: 'string',
    describe:
      '"yyyy-mm-dd HH:MM:SS" format. (If not provided, the current time is used.)'
  },
  pg_env: {
    type: 'string',
    demand: false,
    choices: ['production', 'development'],
    describe:
      'The database used to check for the latest transcom_historical_events timestamp.',
    default: 'development'
  }
};

const { argv } = yargs
  .strict()
  .parserConfiguration({
    'camel-case-expansion': false,
    'flatten-duplicate-arrays': false
  })
  .wrap(yargs.terminalWidth() / 1.618)
  .option(cliArgsSpec);

const { output_dir, pg_env } = argv;
let { start_timestamp, end_timestamp } = argv;

if (_.isNil(start_timestamp)) {
  try {
    const configPath = join(
      __dirname,
      pg_env === 'production'
        ? '../../config/postgres.env.prod'
        : '../../config/postgres.env.dev'
    );
    envFile(configPath);

    const { PGDATABASE, PGHOST, PGPORT } = process.env;

    console.error(
      `Querying ${PGDATABASE} at ${PGHOST}:${PGPORT} for the most recent Transcom event timestamp.`
    );

    const Client = require('pg-native');
    const client = new Client();
    client.connectSync();

    const result =
      client.querySync(
        "SELECT to_char(MAX(creation), 'YYYY-MM-DD HH24:MI:SS') AS latest FROM transcom.transcom_historical_events;"
      ) || [];

    start_timestamp =
      (Array.isArray(result) && result.length === 1 && result[0].latest) ||
      null;
  } catch (err) {
    console.error();
    console.error(
      'Could not connect to retreive the latest event from the database, therefore --start_timestamp will be required.'
    );
    console.error();
    // console.error(err);
  }
}

if (_.isNil(end_timestamp)) {
  end_timestamp = getNowTimestamp(true);
}

const outputDir = isAbsolute(output_dir)
  ? output_dir
  : join(process.cwd(), output_dir);

console.log('Transcom Historical Events will be downloaded to', outputDir)

// Date format 'YYYY-MM-DD HH:MI:SS'
const timestampRE = /^\d{4}-\d{1,2}-\d{1,2} \d{2}:\d{2}:\d{2}$/;

if (!(start_timestamp && end_timestamp)) {
  console.error(
    'ERROR: The start_timestamp and end_timestamp env variables are required.'
  );
  process.exit(1);
}

if (!(start_timestamp.match(timestampRE) && end_timestamp.match(timestampRE))) {
  console.error(
    'ERROR: The start_timestamp and end_timestamp must be in "yyyy-mm-dd HH:MM:SS" format.'
  );
  process.exit(1);
}

const downloadTimestamp = getNowTimestamp();

const [startYearStr] = start_timestamp.split(/-/);
const [endYearStr] = end_timestamp.split(/-/);

const startYear = +startYearStr;
const endYear = +endYearStr;

const getPartitionedDateTimes = () => {
  const start = new Date(start_timestamp);
  const end = new Date(end_timestamp);

  const startMonth = start.getMonth() + 1;
  const startDate = start.getDate();
  const [, startTime] = start_timestamp.split(' ');

  const endMonth = end.getMonth() + 1;
  const endDate = end.getDate();
  const [, endTime] = end_timestamp.split(' ');

  const partitionedDateTimes = _.range(startYear, endYear + 1).reduce(
    (acc, year) => {
      const isStartYear = year === startYear;
      const isEndYear = year === endYear;

      const s_mm = isStartYear ? startMonth : 1;
      const e_mm = isEndYear ? endMonth : 12;

      for (let mm = s_mm; mm <= e_mm; ++mm) {
        const isStartMonth = isStartYear && mm === startMonth;
        const isEndMonth = isEndYear && mm === endMonth;

        const s_dd = isStartMonth ? startDate : 1;
        const s_time = isStartMonth ? startTime : '00:00:00';

        const e_dd = isEndMonth ? endDate : new Date(year, mm, 0).getDate();

        const e_time = isEndMonth ? endTime : '23:59:59';

        acc.push([
          `${year}-${_.padStart(mm, 2, '0')}-${_.padStart(
            s_dd,
            2,
            '0'
          )} ${s_time}`,
          `${year}-${_.padStart(mm, 2, '0')}-${_.padStart(
            e_dd,
            2,
            '0'
          )} ${e_time}`
        ]);
      }

      return acc;
    },
    []
  );

  return partitionedDateTimes;
};

const downloadDateRangeOfIncidents = (
  [startDateTime, endDateTime],
  outputStream
) =>
  new Promise((resolve, reject) => {
    const reqBody = {
      eventCategoryIds: '1,2,3,4,13',
      eventStatus: '',
      eventType: '',
      state: '',
      county: '',
      city: '',
      reportingOrg: '',
      facility: '',
      primaryLoc: '',
      secondaryLoc: '',
      eventDuration: null,
      startDateTime,
      endDateTime,
      orgID: '15',
      direction: '',
      iseventbyweekday: 1,
      tripIds: ''
    };

    const options = {
      method: 'POST',
      uri: TRANSCOM_URI,
      body: reqBody,
      json: true // Automatically stringifies the body to JSON
    };

    pipe(
      request(options),
      split(JSON.parse),
      through.obj(function fn({ data }, $, cb) {
        if (Array.isArray(data)) {
          for (let i = 0; i < data.length; ++i) {
            this.push(`${JSON.stringify(data[i])}\n`);
          }
        }
        return cb();
      }),
      outputStream,
      err => {
        if (err) {
          return reject(err);
        }

        return resolve();
      }
    );
  });

const createTmpDir = () => {
  const { name } = tmpDirSync({ unsafeCleanup: true });

  let cleanup = () => rimrafSync(name);

  // https://stackoverflow.com/a/49392671/3970755
  EVENT_TYPES.forEach(eventType => {
    process.on(eventType, () => {
      try {
        const f = cleanup;
        cleanup = _.noop;

        f();
      } catch (err) {
        //
      }
    });
  });

  return name;
};

const getOutputFilePath = () => {
  const startTimestamp = start_timestamp.replace(/-|:/g, '').replace(/ /, 'T');
  const endTimestamp = end_timestamp.replace(/-|:/g, '').replace(/ /, 'T');

  const outputFileName = `${startTimestamp}-${endTimestamp}.${downloadTimestamp}.ndjson.gz`;

  return join(outputDir, outputFileName);
};

const copyTmpOutputToOutputDir = tmpFilePath =>
  new Promise((resolve, reject) => {
    const outputFilePath = getOutputFilePath();
    pipe(
      createReadStream(tmpFilePath),
      createGzip({ level: 9 }),
      createWriteStream(outputFilePath),
      err => {
        if (err) {
          return reject(err);
        }

        return resolve(outputFilePath);
      }
    );
  });

(async () => {
  try {
    const tmpDir = createTmpDir();
    const partitionedDateTimes = getPartitionedDateTimes();

    const tmpFilePath = join(tmpDir, 'transcom_event.ndjson');

    for (let i = 0; i < partitionedDateTimes.length; ++i) {
      const dateRange = partitionedDateTimes[i];
      console.error('downloading', dateRange[0], '-', dateRange[1]);

      const outputFileStream = createWriteStream(tmpFilePath, { flags: 'a' });

      await downloadDateRangeOfIncidents(dateRange, outputFileStream);
    }

    mkdirSync(outputDir, { recursive: true });

    const outputFilePath = await copyTmpOutputToOutputDir(tmpFilePath);

    console.error('Transcom events written to', outputFilePath);
  } catch (err) {
    console.error(err);
  }
})();
