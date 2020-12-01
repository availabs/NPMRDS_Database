#!/usr/bin/env node

/* eslint-disable no-await-in-loop */

const {statSync, writeFileSync, readdirSync} = require('fs')
const {join, basename} = require('path')

const coldStorageDir = '/home/paul/sysadmin/RIT_Storage/RIT.samba/Dr. Lawson/BACKUPS/INRIX-NPMRDS/cold-storage/npmrds'

const outputFilePath = join(__dirname, '../base_data/archivedETLFileStats.json')

const recursive = require('recursive-readdir');

(async () => {
  const states = readdirSync(coldStorageDir).filter(s => /^[a-z]{2}$/.test(s)).sort()

  const etlArchivesStats = []

  for (let i = 0; i < states.length; ++i) {
    const state = states[i]

    const dataDir = join(coldStorageDir, state)

    console.time(state)
    console.timeEnd(state)
    const files = await recursive(dataDir)

    // ny.201912.npmrds-etl.20200408114829.tar
    files
      .filter(f => /\d{6}\.npmrds-etl\.\d{14}.tar$/.test(basename(f)))
      .sort()
      .forEach((f) => {
        const file = basename(f)

        const [s, yrmo] = file.split('.')

        if (state !== s) {
          return
        }

        const year = yrmo.slice(0, 4)

        const month = yrmo.replace(new RegExp(year, 'g'), '')

        const stats = statSync(f)

        const size_bytes = stats.size

        etlArchivesStats.push({state, year, month, file, size_bytes})
      })

  }

  writeFileSync(outputFilePath, JSON.stringify(etlArchivesStats))
})()
