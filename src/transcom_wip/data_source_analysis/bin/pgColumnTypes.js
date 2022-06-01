#!/usr/bin/env node

/*
    USAGE: First and only CLI positional parameter is the output of ./analyzeSchema.js

        $ cat foo.ndjon | ./analyzeSchema.js > foo.schema-analysis.json
        $ ./pgColumnTypes foo.schema-analysis.json
*/

const { readFileSync } = require("fs");

const { schemaAnalysis } = JSON.parse(
  readFileSync(process.argv[2], { encoding: "utf8" })
);

const maxColNameLen = schemaAnalysis.reduce((max, { col }) => {
  return col.length > max ? col.length : max;
}, 0);

const padding = " ".repeat(maxColNameLen);

for (const {
  col,
  summary: { db_type },
} of schemaAnalysis) {
  const paddedCol = `${col}${padding}`.slice(0, maxColNameLen);

  const type =
    db_type !== null
      ? `${db_type},`
      : "TEXT, -- For all observed data, value was null";

  console.log(`${paddedCol}    ${type}`);
}
