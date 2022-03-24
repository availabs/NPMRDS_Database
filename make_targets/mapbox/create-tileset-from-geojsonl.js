#!/usr/bin/env node

const { spawnSync } = require("child_process");
const { createReadStream, createWriteStream } = require("fs");
const { pipeline } = require("stream");
const { promisify } = require("util");
const { join } = require("path");

const split = require("split2");
const through = require("through2");

const pipelineAsync = promisify(pipeline);

const inputGeoJsonlFile = join(__dirname, "./combined.geojsonl");
const outputGeoJsonlFile = join(__dirname, "./transformed.geojsonl");
const mbtilesOutputFile = "npmrdsx_northeast_2021.mbtiles";

const tippecanoeDetails = {
  1: { layer: "interstate" },
  2: { minzoom: 7, layer: "highway" },
  3: { minzoom: 8, layer: "arterial" },
  4: { minzoom: 9, layer: "arterial" },
  5: { minzoom: 10, layer: "collector" },
  6: { minzoom: 11, layer: "collector" },
  7: { minzoom: 12, layer: "local" },
};

async function createTransformedGeoJSONL() {
  const rs = createReadStream(inputGeoJsonlFile);
  const ws = createWriteStream(outputGeoJsonlFile);

  await pipelineAsync(
    rs,
    split(JSON.parse),
    through.obj((feature, _enc, cb) => {
      const n = feature.properties.func_class;

      feature.tippecanoe = tippecanoeDetails[+n];

      cb(null, `${JSON.stringify(feature)}\n`);
    }),
    ws
  );
}

function generateTileSet() {
  console.log("generateTileSet");

  spawnSync("tippecanoe", [
    "--no-feature-limit",
    "--no-tile-size-limit",
    "--generate-ids",
    "--read-parallel",
    "--force",
    "-o",
    mbtilesOutputFile,
    outputGeoJsonlFile,
  ]);
}

async function main() {
  await createTransformedGeoJSONL();
  generateTileSet();
}

main();
