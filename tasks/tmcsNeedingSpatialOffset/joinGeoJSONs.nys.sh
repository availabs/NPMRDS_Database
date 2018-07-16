#!/bin/bash

set -e

mkdir -p merged

jq -s '.[0].features=([.[].features]|flatten)|.[0]' $(find ./geojson -type f -name 'ny.*.geojson' | sort) |
  GZIP=-9 gzip > "./merged/nys.geojson.gz"
