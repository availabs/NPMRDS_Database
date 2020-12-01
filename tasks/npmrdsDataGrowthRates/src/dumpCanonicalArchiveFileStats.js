#!/usr/bin/env node

/* eslint-disable no-await-in-loop */

const {statSync, writeFileSync, readdirSync} = require('fs')
const {join, basename} = require('path')

const canonicalArchiveDir = '/home/paul/sysadmin/RIT_Storage/RIT.samba/Dr. Lawson/BACKUPS/INRIX-NPMRDS/canonical-archive/'

const outputFilePath = join(__dirname, '../base_data/canonicalArchiveFileStats.json')

const recursive = require('recursive-readdir');

(async () => {
  const states = readdirSync(canonicalArchiveDir).filter(s => /^[a-z]{2}$/.test(s)).sort()
  // const states = ['hi']

  const canonicalArchiveFileStats = []

  for (let i = 0; i < states.length; ++i) {
    const state = states[i]
    const dataDir = join(canonicalArchiveDir, state, '/npmrds')

    const files = await recursive(dataDir)

    files
      .filter(f => /npmrds\.csv\.gz$/.test(f))
      .sort()
      .forEach((f) => {
        const file = basename(f)

        const s = file.slice(0, 2)

        if (state !== s) {
          return
        }

        const year = file.slice(3, 7)
        const month = file.slice(7, 10)

        const stats = statSync(f)

        const size_bytes = stats.size

        canonicalArchiveFileStats.push({state, year, month, file, size_bytes})
      })

  }

  writeFileSync(outputFilePath, JSON.stringify(canonicalArchiveFileStats))
})()
