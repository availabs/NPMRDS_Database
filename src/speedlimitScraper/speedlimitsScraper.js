#!/usr/bin/env node
'use strict'


const argv = require('minimist')(process.argv.slice(2), { boolean: true })


if (!argv.state) {
  console.error('The state argument is required. Specify with --state=<state>.')
  process.exit(1)
}

const { promisify } = require('util')

const {
  stat,
  existsSync,
  createWriteStream,
} = require('fs')

const {
  join
} = require('path')


const mkdirp = require('mkdirp')

const statAsync = promisify(stat)
const mkdirpAsync = promisify(mkdirp)

const request = require('request')

const { Client } = require('pg')

const envFile = require('node-env-file')
envFile(join(__dirname, '../../config/postgres.env'))

const hereURL = `${require('../../config/here_credentials').url}&linkAttributes=length,speedLimit`

const dataDir = join(__dirname, './data/')


const DELAY_MILLISECS = 1000


async function getLinkInfoForTMCFromHERE (tmc, filePath) {
  return new Promise((resolve, reject) => {
    request
      .get(`${hereURL}&tmcCodes=${tmc.replace(/\+/, '%2B')}`)
      .on('error', reject)
      .pipe(createWriteStream(filePath))
      .on('error', reject)
      .on('finish', resolve)
  })
}

async function getCountiesInState (db, state) {
  const query = {
    text: `
      SELECT DISTINCT county
        FROM inrix_shapefile AS i
          INNER JOIN state_abbreviations AS a
            ON (i.state = a.state_name)
        WHERE (a.abbreviation = $1)
        ORDER BY county;
    `,
    values: [state],
    rowMode: 'array'
  }

  const { rows } = await db.query(query)

  return rows.map(row => row[0])
}


async function getInrixTMCsForCountyInState (db, state, county) {
  const query = {
    name: 'getInrixTMCsForCountyInState',
    text: `
      SELECT DISTINCT i.tmc
        FROM inrix_shapefile AS i
          INNER JOIN state_abbreviations AS a
            ON (i.state = a.state_name)
        WHERE (a.abbreviation = $1)
          AND (i.county = $2)
        ORDER BY i.tmc;
    `,
    values: [state, county],
    rowMode: 'array',
  }

  const { rows } = await db.query(query)

  return rows.map(row => row[0])
}




(async () => {

  try {
    const db = new Client({
      host     : process.env.NPMRDS_POSTGRES_NETLOC,
      port     : process.env.NPMRDS_POSTGRES_PORT || undefined,
      user     : process.env.NPMRDS_POSTGRES_USER,
      password : process.env.NPMRDS_POSTGRES_PASSWORD || undefined,
      database : process.env.NPMRDS_POSTGRES_DB,
    })

    await db.connect()


    const state = argv.state.toLowerCase()
    const overwrite = argv.overwrite

    const stateDataDir = join(dataDir, state)


    const counties = await getCountiesInState(db, state)

    for (let i = 0; i < counties.length; ++i) {

      const county = counties[i]

      const countyDataDir = join(stateDataDir, county)

      await mkdirpAsync(countyDataDir)

      const inrixTMCs = await getInrixTMCsForCountyInState(db, state, county)

      const tmcs = Array.from(new Set(inrixTMCs)).sort()

      for (let j = 0; j < tmcs.length; ++j) {
        const tmc = tmcs[j]

        const tmcDataPath = join(countyDataDir, tmc)

        let fileExistsWithData
        try {
          const fstat= await statAsync(tmcDataPath)
          fileExistsWithData = !!fstat.size
          if (!fileExistsWithData) {
            console.log(tmcDataPath)
          }
        } catch (err) {
          if (err.code = 'ENOENT') {
            fileExistsWithData = false
          } else {
            throw err
          }
        }

        if (fileExistsWithData && !overwrite) {
          continue
        }

        console.time(tmc)
        await getLinkInfoForTMCFromHERE(tmc, tmcDataPath)
        console.timeEnd(tmc)

        await new Promise(resolve => setTimeout(resolve, DELAY_MILLISECS))
      }
    }

    return await db.end()

  } catch (err) {
    console.error(err)
    process.exit(1)
  }

})()
