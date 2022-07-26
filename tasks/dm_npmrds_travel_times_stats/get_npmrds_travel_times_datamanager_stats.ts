import { writeFileSync, mkdirSync } from "fs";
import { join } from "path";

import _ from "lodash";
import pgFormat from "pg-format";

import { Client } from "pg";

import { getConnectedPgClient } from "../../src/utils/PostgreSQL";

const states = ["ny", "nj", "ct", "pa"];
const years = _.range(2022, 2016);

const dataDir = join(__dirname, "data");
mkdirSync(dataDir, { recursive: true });

async function getPercentageEpochsReporting(
  db: Client,
  state: string,
  year: number,
  month: number
) {
  const mm = `0${month}`.slice(-2);

  const startOfMonth = `${year}-${mm}-01T00:00:00 America/New_York`;

  const sql = pgFormat(
    `
      WITH cte_expected_num_epochs AS (
        SELECT
            COUNT(1) AS expected_num_epochs
          FROM generate_series(
            -- Because we're using "with time zone", handles Daylight Savings.
            CAST(%L as TIMESTAMP WITH TIME ZONE),
            CAST(%L as TIMESTAMP WITH TIME ZONE)
              + '1 month'::INTERVAL
              - '5 minutes'::INTERVAL,
            '5 minutes'::INTERVAL
          ) AS t
      )
        SELECT
            func_class AS frc,
            AVG(pct_epochs_reporting) AS avg_pct_epochs_reporting,
            stddev_pop(pct_epochs_reporting) AS stddev_pct_epochs_reporting,
            var_pop(pct_epochs_reporting) AS var_pct_epochs_reporting,
            MIN(pct_epochs_reporting) AS min_pct_epochs_reporting,
            MAX(pct_epochs_reporting) AS max_pct_epochs_reporting,
            percentile_cont(ARRAY[0.25, 0.5, 0.75])
              WITHIN GROUP (ORDER BY pct_epochs_reporting ASC) AS quartiles_pct_epochs_reporting,
            COUNT(DISTINCT tmc)::INTEGER AS total_tmcs,
            SUM(b.miles) AS total_miles
          FROM (
              SELECT
                  tmc,
                  (
                    (
                      COUNT(1)::DOUBLE PRECISION
                      / COUNT(DISTINCT tmc)::DOUBLE PRECISION
                    )
                    / ( SELECT expected_num_epochs FROM cte_expected_num_epochs )::DOUBLE PRECISION
                  ) AS pct_epochs_reporting
                FROM %I.%I AS a
                GROUP BY tmc
            ) AS a
            INNER JOIN %I.%I AS b
              USING (tmc)
          WHERE (
            ( b.state = 'ny' )
            OR
            ( b.is_nhs )
          )
          GROUP BY 1
        ;
    `,
    startOfMonth,
    startOfMonth,
    state,
    `npmrds_y${year}m${mm}`,
    state,
    `mdd_tmc_shapes_${year}`
  );

  const { rows } = await db.query(sql);

  const pctEpochReportingByFRC = rows.reduce((acc, row) => {
    const { frc } = row;
    const stats = _.omit(row, ["frc"]);

    acc[frc] = stats;

    return acc;
  }, {});

  return pctEpochReportingByFRC;
}

async function main() {
  const db = await getConnectedPgClient("production");

  for (const state of states) {
    for (const year of years) {
      const maxMonth = year === 2022 ? 5 : 12;
      const months = _.range(1, maxMonth + 1);
      for (const month of months) {
        console.log(state, year, month);

        try {
          const pctEpochReportingByFRC = await getPercentageEpochsReporting(
            db,
            state,
            year,
            month
          );

          const timestamp = new Date().toISOString().replace(/[^0-9a-z]/gi, "");

          const mm = `0${month}`.slice(-2);
          const outFileName = `npmrds_travel_time_stats.${state}.${year}${mm}.${timestamp}.json`;
          const outFilePath = join(dataDir, outFileName);

          writeFileSync(
            outFilePath,
            JSON.stringify(pctEpochReportingByFRC, null, 4)
          );
        } catch (err) {
          console.error(err);
        }
      }
    }
  }

  await db.end();
}

main();
