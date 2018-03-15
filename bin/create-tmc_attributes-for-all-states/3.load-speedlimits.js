#!/usr/bin/env node

const { execSync } = require('child_process');
const { join } = require('path');

const states = require('./states.no-nynj.json');

const ROOT_DIR = join(__dirname, '../../');

states.forEach(STATE => {
  const out = execSync(`make db/create-state-average-speedlimits-table`, {
    cwd: ROOT_DIR,
    env: {
      STATE
    },
    encoding: 'utf8'
  });

  console.log(out);
});
