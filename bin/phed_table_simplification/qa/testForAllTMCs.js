#!/usr/bin/env node

const { env } = process;
const { fork } = require('child_process');
const { Client } = require('pg');
const { join } = require('path');
const envFile = require('node-env-file');
const minimist = require('minimist');

const argv = minimist(process.argv.slice(2));

const configPath = join(__dirname, '../../../config/postgres.env')
envFile(configPath);

const { YEAR, MONTH } = Object.assign({}, argv, env);

if (!(Number.isFinite(+YEAR) && Number.isFinite(+MONTH))) {
  console.error(
    'USAGE: specify YEAR and MONTH through env or command line args.'
  );
  process.exit(1);
}

const client = new Client();

const getPHEDForTMCs = async () => {
  const q = `
    SELECT
        tmc,
        phed_am_peak,
        phed_pm_peak_1,
        phed_pm_peak_2
      FROM phed
      WHERE (
        (year = $1)
        AND
        (month = $2)
      )`;

  const result = await client.query(q, [YEAR, MONTH]);

  return result.rows.reduce(
    (acc, { tmc, phed_am_peak, phed_pm_peak_1, phed_pm_peak_2 }) => {
      acc[tmc] = { phed_am_peak, phed_pm_peak_1, phed_pm_peak_2 };
      return acc;
    },
    {}
  );
};

const getJSCalculationForTMC = async tmc =>
  new Promise((resolve, reject) => {
    try {
      const subprocess = fork('./testForTmc.js', {
        env: { TMC: tmc, YEAR, MONTH },
        silent: true
      });

      subprocess.stdout.setEncoding('utf8');

      let d = '';

      subprocess.stdout.on('data', chunk => (d = `${d}${chunk}`));

      subprocess.stdout.on('end', () => resolve(JSON.parse(d)));
    } catch (err) {
      reject(err);
    }
  });

const getComparisons = async phedForTMCs => {
  const tmcs = Object.keys(phedForTMCs);
  const comparisons = [];

  for (let i = 0; i < tmcs.length; ++i) {
    const tmc = tmcs[i];
    const d = await getJSCalculationForTMC(tmc);

    const db_am_peak = phedForTMCs[tmc] && phedForTMCs[tmc].phed_am_peak;
    const db_pm_peak_1 = phedForTMCs[tmc] && phedForTMCs[tmc].phed_pm_peak_1;
    const db_pm_peak_2 = phedForTMCs[tmc] && phedForTMCs[tmc].phed_pm_peak_2;

    const js_am_peak = d && d.phed_am_peak;
    const js_pm_peak_1 = d && d.phed_pm_peak_1;
    const js_pm_peak_2 = d && d.phed_pm_peak_2;

    const phed_am_peak_pct_diff =
      db_am_peak - js_am_peak === 0
        ? 0
        : (db_am_peak - js_am_peak) / db_am_peak * 100;
    const phed_pm_peak_1_pct_diff =
      db_pm_peak_1 - js_pm_peak_1 === 0
        ? 0
        : (db_pm_peak_1 - js_pm_peak_1) / db_pm_peak_1 * 100;
    const phed_pm_peak_2_pct_diff =
      db_pm_peak_2 - js_pm_peak_2 === 0
        ? 0
        : (db_pm_peak_2 - js_pm_peak_2) / db_pm_peak_2 * 100;

    comparisons.push({
      tmc,
      db_am_peak,
      db_pm_peak_1,
      db_pm_peak_2,
      js_am_peak,
      js_pm_peak_1,
      js_pm_peak_2,
      phed_am_peak_pct_diff,
      phed_pm_peak_1_pct_diff,
      phed_pm_peak_2_pct_diff
    });
  }

  return comparisons;
};

const comparisonsComparator = (a, b) => {
  const aMaxDiff = Math.max(
    Math.abs(a.phed_am_peak_pct_diff),
    Math.abs(a.phed_pm_peak_1_pct_diff),
    Math.abs(a.phed_pm_peak_2_pct_diff)
  );
  const bMaxDiff = Math.max(
    Math.abs(b.phed_am_peak_pct_diff),
    Math.abs(b.phed_pm_peak_1_pct_diff),
    Math.abs(b.phed_pm_peak_2_pct_diff)
  );

  return bMaxDiff - aMaxDiff;
};

const doIt = async () => {
  await client.connect();

  const phedForTMCs = await getPHEDForTMCs();
  const comparisons = await getComparisons(phedForTMCs);

  comparisons.sort(comparisonsComparator);

  console.log(JSON.stringify(comparisons, null, 4));

  client.end();
};

doIt();
