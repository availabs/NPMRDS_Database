#!/usr/bin/env node

const { readFileSync, writeFileSync } = require("fs");

const inquirer = require("inquirer");

let defaults = {};

if (process.argv.length === 3) {
  defaults = JSON.parse(readFileSync(process.argv[2], { encoding: "utf8" }));
}

const questions = [
  {
    type: "input",
    name: "name",
    message: "Data Source Name?",
    default: defaults.name,
    filter(val) {
      return val.toUpperCase().replace(/ /g, "_");
    },
  },
  {
    type: "input",
    name: "update_interval",
    message: "Update Interval?",
    default: defaults.update_interval,
  },
  {
    type: "input",
    name: "category",
    message: "Category?",
    default: defaults.category && `${defaults.category}`,
    filter(val) {
      return val
        .toUpperCase()
        .split(/,/)
        .map((c) => c.trim().replace(/ /g, "_"));
    },
  },
  {
    type: "input",
    name: "description",
    message: "Description?",
    default: defaults.description,
  },
  {
    type: "input",
    name: "categories",
    message: "Categories?",
    default: defaults.categories,
    filter(val) {
      return val
        .split(/,,/) // Double comma to create 1st dimension array
        .map((x) => x.split(/,/).map((c) => c.trim().replace(/ /g, "_"))); // Single comma for 2nd dim
    },
  },
  {
    type: "input",
    name: "type",
    message: "Type?",
    default: defaults.type,
  },
  {
    type: "input",
    name: "display_name",
    message: "Display Name?",
    default: defaults.display_name,
  },
];

inquirer.prompt(questions).then((answers) => {
  Object.keys(answers).forEach((k) => {
    if (typeof answers[k] === "string" && answers[k].trim() === "") {
      answers[k] = null;
    }
  });

  const cleanedName = answers.name
    .replace(/[^0-1a-z]/gi, "_")
    .replace(/_{1,}/g, "_");

  const fileName = `${cleanedName}.source.json`;

  const d = JSON.stringify(answers, null, 4);

  writeFileSync(fileName, d);

  console.log(d);

  console.log("Data Source Metadata written to", fileName);
});
