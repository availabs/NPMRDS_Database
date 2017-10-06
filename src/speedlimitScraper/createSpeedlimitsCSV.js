#!/usr/bin/env node
'use strict'

const METERS_PER_SEC_TO_MILES_PER_HOUR = 2.23694

const argv = require('minimist')(process.argv.slice(2))

if (!argv.state) {
  console.error('The state argument is required. Specify with --state=<state>.')
  process.exit(1)
}

const { promisify } = require('util')

const {
  readdir,
  readFile,
  createWriteStream,
} = require('fs')

const {
  join
} = require('path')


const readdirAsync = promisify(readdir)
const readFileAsync = promisify(readFile)

const dataDir = join(__dirname, './data')
const outDir = join(__dirname, './parsed-speedlimit-data')


async function getTMCInfo (tmcDataPath) {
  let str
  try {
    str = await readFileAsync(tmcDataPath, 'utf8')
    return JSON.parse(str).response
  } catch (err) {
    console.error(`ERROR: ${tmcDataPath}`)
    console.error(err)
    // console.error(str)
    return null
  }
}


  /*
    {
      "response": {
        "metaInfo": {
          "mapVersion": "8.30.73.154",
          "moduleVersion": "7.2.201732-150722",
          "interfaceVersion": "2.6.34",
          "timestamp": "2017-08-18T07:21:16Z"
        },
        "link": [
          {
            "linkId": "+1114870855",
            "shape": [
              "42.5586963,-73.808223",
              "42.5587392,-73.8082981",
              "42.5587821,-73.8084161",
              "42.5588036,-73.8085449"
            ],
            "length": 30,
            "speedLimit": 24.7222233
          }
        ]
      }
    }
  */


(async () => {

  try {
    const state = argv.state.toLowerCase()

    const stateDataDir = join(dataDir, state)
    const outStream = createWriteStream(join(outDir, `${state}_avg_speedlimits.csv`))

    outStream.write('tmc,avg_speedlimit\n')

    console.time(state)

    const counties = await readdirAsync(stateDataDir)

    for (let i = 0; i < counties.length; ++i) {
      const county = counties[i]
      const countyDataDir = join(stateDataDir, county)

      const tmcs = await readdirAsync(countyDataDir)

      for (let j = 0; j < tmcs.length; ++j) {
        const tmc = tmcs[j]

        const tmcDataPath = join(countyDataDir, tmc)
        
        const d = await getTMCInfo(tmcDataPath)
        const linkArr = (d && Array.isArray(d.link)) ? d.link : null

        let avgSpeedlimit = null

        if (linkArr) {
          let numerator = 0
          let denomenator = 0

          for (let k = 0; k < linkArr.length; ++k) {
            const linkInfo = linkArr[k]

            if (linkInfo && linkInfo.length && linkInfo.speedLimit) {
              const sl = (linkInfo.speedLimit * METERS_PER_SEC_TO_MILES_PER_HOUR)
              const multOf5 = Math.round(sl /5) * 5 

              numerator += (linkInfo.length * multOf5)
              denomenator += linkInfo.length
            }
          }

          avgSpeedlimit = (numerator) ? (numerator / denomenator).toFixed(3) : null
        }

        outStream.write(`${tmc},${avgSpeedlimit || ''}\n`)
      }
    }

    outStream.end()
    console.timeEnd(state)

  } catch (err) {
    console.error(err)
    process.exit(1)
  }

})().catch(console.error.bind(console))

