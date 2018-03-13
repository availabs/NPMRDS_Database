#!/usr/bin/env node

const { execSync } = require('child_process');
const { join } = require('path');

const states = require('./states.json');

const ROOT_DIR = join(__dirname, '../../');

states.forEach(STATE => {
  if (STATE === 'ny' || STATE === 'nj') {
    return;
  }

  const out = execSync(`make db/load-state-tmc-attributes`, {
    cwd: ROOT_DIR,
    env: {
      STATE
    },
    encoding: 'utf8'
  });

  console.log(out);
});
