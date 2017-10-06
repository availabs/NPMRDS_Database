#!/usr/bin/env node
'use strict'


const argv = require('minimist')(process.argv.slice(2))


if (!argv.state) {
  console.error('The state argument is required. Specify with --state=<state>.')
  process.exit(1)
}

const { promisify } = require('util')

const {
  readdir,
  readFile,
  unlink,
} = require('fs')

const {
  join
} = require('path')


const readdirAsync = promisify(readdir)
const readFileAsync = promisify(readFile)
const unlinkAsync = promisify(unlink)


const { Client } = require('pg')

const envFile = require('node-env-file')
envFile(join(__dirname, '../../config/postgres.env'))

const dataDir = join(__dirname, './data')


(async () => {

  const db = new Client({
    host     : process.env.PGHOST || process.env.PGHOSTADDR,
    port     : process.env.PGPORT || undefined,
    user     : process.env.PGUSER,
    password : process.env.PGPASSWORD || undefined,
    database : process.env.PGDATABASE,
  })

  try {
    const state = argv.state.toLowerCase()

    const stateDataDir = join(dataDir, state)

    console.time(state)

    await db.connect()

    const inrixTMCs = (await db.query(`
      SELECT JSONB_OBJECT_AGG(tmc, 1) AS d
        FROM inrix_shapefile AS i
          INNER JOIN state_abbreviations AS s
            ON (i.state = s.state_name)
        WHERE (s.abbreviation = '${state}')
      ;
    `)).rows[0].d

    const counties = await readdirAsync(stateDataDir)

    for (let i = 0; i < counties.length; ++i) {
      const county = counties[i]
      const countyDataDir = join(stateDataDir, county)

      console.time(county)

      const tmcs = await readdirAsync(countyDataDir)

      const toDelete = tmcs.filter(t => !inrixTMCs[t])

      // console.log(`${county}: delete ${toDelete.length} out of ${tmcs.length}`)
      for (let j = 0; j < toDelete.length; ++j) {
        const toDeletePath = join(countyDataDir, toDelete[j])

        await unlinkAsync(toDeletePath)
      }

      console.timeEnd(county)
    }

    await db.end()

    console.timeEnd(state)

  } catch (err) {
    await db.end()

    console.error(err)
    process.exit(1)
  }

})().catch(console.error.bind(console))

