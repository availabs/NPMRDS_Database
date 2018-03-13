#!/usr/bin/env node

const { execSync } = require('child_process');
const { join } = require('path');

const states = require('./states.json');

const ROOT_DIR = join(__dirname, '../../');

states.forEach(STATE => {
  const out = execSync(`make db/upload-inrix-shapefile-for-state`, {
    cwd: ROOT_DIR,
    env: {
      STATE
    },
    encoding: 'utf8'
  });

  console.log(out);
});
