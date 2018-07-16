#!/bin/bash

# https://github.com/mapbox/tippecanoe#filtering-features-by-attributes
# https://www.mapbox.com/mapbox-gl-js/style-spec/#expressions

# NOTE: For whatever reason, [ "==", "is_interstate", true ] always evaluates to true
#       Need to state the above as [ "!=", "is_interstate", false ]

set -e


pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

cd ./merged


FILTER='
  {
    "*": [
      "all",
      [ "any",
        [ ">=", "$zoom", 9 ],
        [ "!=", "is_interstate", false ]
      ],
      [
        "attribute-filter",
        "requires_offset",
        [ ">=", "$zoom", 7 ]
      ]
    ]
  }
'

tippecanoe \
  --force -o ../mbtiles/us_tmcs_single_layer.mbtiles \
   -z16 -d16 --drop-densest-as-needed \
  -j "$FILTER" \
  ./us_tmcs_single_layer.geojson.gz


popd >/dev/null
