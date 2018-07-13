#!/bin/bash

set -e

DIRS=('NE' 'SW')
REQ_OFFSET=('offset' 'no-offset')

mkdir -p merged

for direction in ${DIRS[@]}
do
  for req_offset in ${REQ_OFFSET[@]}
  do
    echo '-------------------------'

    jq \
      -s '.[0].features=([.[].features]|flatten)|.[0]' \
      $(find ./geojson \( -not -name 'ny*' -a -not -name 'nj*' -a -name "*.${direction}.*" -a -name "*.${req_offset}.*" \) | sort) |\
    GZIP=-9 gzip > "./merged/${direction}.${req_offset}.geojson.gz"

  done

done

