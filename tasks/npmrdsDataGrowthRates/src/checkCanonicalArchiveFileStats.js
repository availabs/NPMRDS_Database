#!/usr/bin/env node

/* eslint-disable no-await-in-loop */

const stats = require('../base_data/canonicalArchiveFileStats.json')

const seen = new Set()

for (let i = 0; i < stats.length; ++i) {
  const {state, year, month} = stats[i]
  const k = `${state}|${year}|${month}`
  if (seen.has(k)) {
    console.error(k, 'is a dupe')
  }

  seen.add(k)
}
