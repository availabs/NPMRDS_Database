#!/bin/bash

set -e
set -a

cd "$( dirname "${BASH_SOURCE[0]}")"

source ../../config/postgres.env.local

mkdir -p ./geojson

export GZIP=-9

DIRECTIONS=('{N,E}' '{S,W}')
REQUIRES_OFFSET=(true false)

while read s; do

  # psql -t -A --quiet -v STATE="'${s}'" -f ./createMapBoxGeoJSON.sql > "./geojson/${s}.geojson"

  for dir in ${DIRECTIONS[@]}
  do
    [ "$dir" == "${DIRECTIONS[0]}" ] && DNAME='NE' || DNAME='SW'

    for reqoffset in ${REQUIRES_OFFSET[@]}
    do
      [ "$reqoffset" == "${REQUIRES_OFFSET[0]}" ] && ROFF='offset' || ROFF='no-offset'
      
      psql -t -A --quiet \
        -v STATE="'${s}'" \
        -v DIRECTIONS="'${dir}'" \
        -v REQUIRES_OFFSET="${reqoffset}" \
        -f ./createMapBoxGeoJSON.sql \
      | gzip > "./geojson/${s}.${DNAME}.${ROFF}.geojson.gz"
    done
  done
done < ./states
