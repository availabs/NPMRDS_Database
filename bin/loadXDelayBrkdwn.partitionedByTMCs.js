#!/usr/bin/env node

const { execSync } = require('child_process')
const { readFileSync } = require('fs')
const { join } = require('path')

const MAKE_DIR = join(__dirname, '../')

const STATE = 'ny'
const MONTH = '00'
const YEARS = [2016, 2017]

const NUM_PARTITIONS = 10

const percentilePartitionPts =
  Array.from(Array(NUM_PARTITIONS).keys())
    .map(i => (i)/(NUM_PARTITIONS))

const q = `
  SELECT
      ARRAY_TO_JSON(
        PERCENTILE_DISC(array[${percentilePartitionPts}])
           WITHIN GROUP (ORDER BY tmc)
      )
    FROM inrix_shapefile
  ;
`

const tmcPartitionPts = JSON.parse(
  execSync(`psql -t -d npmrds_test -c "${q}"`, { encoding: 'utf8' })
)

const createAndLoadSQL =
  readFileSync('../sql/excessive_delay_brkdwn/createStateExcessiveDelayBrkdwnYrMoTable.step-1.sql', 'utf8')
    .replace(/__STATE__/g, STATE)
    .replace(/__MONTH__/g, MONTH)

const alterAndOptimize =
  readFileSync('../sql/excessive_delay_brkdwn/createStateExcessiveDelayBrkdwnYrMoTable.step-2.sql', 'utf8')
    .replace(/__STATE__/g, STATE)
    .replace(/__MONTH__/g, MONTH)


YEARS.forEach(yr => {
  const output =
    execSync(
      `STATE=${STATE} YEAR=${yr} MONTH=${MONTH} make db/drop-state-excessive-delay-brkdwn-yrmo-table`,
      { cwd: MAKE_DIR, encoding: 'utf8' }
    )
})


YEARS.forEach(yr => {
  const startDate = `${yr}0101`
  const endDate = `${yr+1}0101`

  tmcPartitionPts.forEach((startTMC, i) => {
    let sql =
      createAndLoadSQL
        .replace(/__YEAR__/g, yr)
        .replace(/__START_DATE__/g, startDate)
        .replace(/__END_DATE__/g, endDate)
        .replace(/__START_TMC__/g, startTMC)

    const endTMC = tmcPartitionPts[i + 1]

    if (endTMC) {
      sql = sql.replace(/__END_TMC__/g, endTMC)
    }

    const output = execSync(`psql -t npmrds_test -c "${sql}"`, { encoding: 'utf8' })
    console.log(output)
  })

  const sql =
    alterAndOptimize
      .replace(/__YEAR__/g, yr)
      .replace(/__START_DATE__/g, startDate)
      .replace(/__END_DATE__/g, endDate)

  const output = execSync(`psql -t npmrds_test -c "${sql}"`, { encoding: 'utf8' })
  console.log(output)
})
