#!/bin/bash

# https://github.com/mapbox/tippecanoe#filtering-features-by-attributes
# https://www.mapbox.com/mapbox-gl-js/style-spec/#expressions

# NOTE: For whatever reason, [ "==", "is_interstate", true ] always evaluates to true
#       Need to state the above as [ "!=", "is_interstate", false ]

set -e


pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

mkdir -p ./mbtiles

FILTER='
  {
    "*": [
      "all",
      [ "any",
        [ ">=", "$zoom", 8 ],
        [ "==", "f_system", 1 ]
      ]
    ]
  }
'

tippecanoe \
  --force -o ./mbtiles/tmcsAttrs.mbtiles \
   -z16 -d16 --drop-densest-as-needed \
  -j "$FILTER" \
  ./geojson/tmcsAttrs.geojson.gz

# No filtering
# tippecanoe \
  # --force -o ./mbtiles/tmcsAttrsNoFiltering.mbtiles \
   # -z16 -d16 --drop-densest-as-needed \
  # ./geojson/tmcsAttrs.geojson.gz


popd >/dev/null
