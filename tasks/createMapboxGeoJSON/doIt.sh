#!/bin/bash

# https://github.com/mapbox/tippecanoe#filtering-features-by-attributes
# https://www.mapbox.com/mapbox-gl-js/style-spec/#expressions

# NOTE: For whatever reason, [ "==", "is_interstate", true ] always evaluates to true
#       Need to state the above as [ "!=", "is_interstate", false ]

set -e

pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

mkdir -p ./geojson

export GZIP=-9

psql \
  -hares.availabs.org \
  -p5432 \
  -Unpmrds_ninja \
  -dnpmrds_test \
  --tuples-only \
  -f createMapBoxGeoJSON.sql |
gzip > ./geojson/tmcsAttrs.geojson.gz

popd >/dev/null
