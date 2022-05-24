#!/usr/bin/env node

const { existsSync, readFileSync } = require("fs");
const { isAbsolute, join } = require("path");

if (process.argv.length !== 3) {
  console.error(
    "USAGE: ./generateTSTypeDef <path to ./analyzeSchema.js output>"
  );
  process.exit(1);
}

const analysisPath = isAbsolute(process.argv[2])
  ? process.argv[2]
  : join(process.cwd(), process.argv[2]);

if (!existsSync(analysisPath)) {
  console.error(`ERROR: file ${analysisPath} does not exist.`);
  process.exit(1);
}

const { schemaAnalysis } = JSON.parse(
  readFileSync(analysisPath, { encoding: "utf8" })
);

const aliases = schemaAnalysis.reduce((acc, { key, col }) => {
  acc[key] = col;
  return acc;
}, {});

console.log(JSON.stringify(aliases, null, 4));
