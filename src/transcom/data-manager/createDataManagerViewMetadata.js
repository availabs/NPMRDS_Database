#!/usr/bin/env node

/*
 * TODO: Add
 *            * https://github.com/olistic/inquirer-prompt-suggest
 *            * https://www.npmjs.com/package/fuzzy
 */

const { readFileSync, writeFileSync } = require("fs");

const inquirer = require("inquirer");

let defaults = {};

if (process.argv.length === 3) {
  defaults = JSON.parse(readFileSync(process.argv[2], { encoding: "utf8" }));
}

const questions = [
  {
    type: "input",
    name: "source_name",
    message: "Data Source Name?",
    default: defaults.source_name,
    filter(val) {
      return val.toUpperCase().replace(/ /g, "_");
    },
  },
  {
    type: "input",
    name: "version",
    message: "Version?",
    default: defaults.version,
  },
  {
    type: "input",
    name: "data_type",
    message: "Data Type?",
    default: defaults.data_type,
  },
  {
    type: "input",
    name: "interval_version",
    message: "Interval Version?",
    default: defaults.interval_version && `${defaults.interval_version}`,
  },
  {
    type: "input",
    name: "geography_version",
    message: "Geography Version?",
    default: defaults.geography_version,
  },
  {
    type: "input",
    name: "source_url",
    message: "Source URL?",
    default: defaults.source_url,
  },
  {
    type: "input",
    name: "publisher",
    message: "Publisher?",
    default: defaults.publisher,
  },

  {
    type: "input",
    name: "data_table",
    message: "Data Table?",
    default: defaults.data_table,
  },
  {
    type: "input",
    name: "download_url",
    message: "Download URL?",
    default: defaults.download_url,
  },
  {
    type: "input",
    name: "tiles_url",
    message: "Tiles URL?",
    default: defaults.tiles_url,
  },
  {
    type: "input",
    name: "start_date",
    message: "Start Date?",
    default: defaults.start_date,
  },
  {
    type: "input",
    name: "end_date",
    message: "End Date?",
    default: defaults.end_date,
  },
  {
    type: "input",
    name: "last_updated",
    message: "Last Updated?",
    default: defaults.last_updated,
  },
];

inquirer.prompt(questions).then((answers) => {
  Object.keys(answers).forEach((k) => {
    if (typeof answers[k] === "string" && answers[k].trim() === "") {
      answers[k] = null;
    }
  });

  const cleanedName = answers.source_name
    .replace(/[^0-1a-z]/gi, "_")
    .replace(/_{1,}/g, "_");

  const fileName = `${cleanedName}.view.json`;

  const d = JSON.stringify(answers, null, 4);

  writeFileSync(fileName, d);

  console.log(d);

  console.log("Data Source Metadata written to", fileName);
});
