#!/bin/bash

# https://github.com/mapbox/tippecanoe#filtering-features-by-attributes
# https://www.mapbox.com/mapbox-gl-js/style-spec/#expressions

set -e
set -a

if [[ -z "$YEAR" ]]; then
  echo "ERROR: You must specify the YEAR as an ENV variable."
  exit 1
fi

OUTPUT_FILE_PATH=${1:-$OUTPUT_FILE_PATH}

# source the database connection config.
pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

if [ "$PG_ENV" = "production" ]; then
	. ../../config/postgres.env.prod
else
	. ../../config/postgres.env.dev
fi

popd >/dev/null


NPMRDS_SHAPEFILE_VERSION="$(
  psql -c "
    COPY (
      SELECT MAX(npmrds_shapefile_version)
        FROM npmrds_shapefile
        WHERE (conflation_year = ${YEAR})
    ) TO STDOUT
  "
)"

LAYER_NAME="tmc_metadata_${YEAR}_shpver${NPMRDS_SHAPEFILE_VERSION}"

if [[ -z "$OUTPUT_FILE_PATH" ]]; then
  OUTPUT_FILE_PATH="${LAYER_NAME}_$(date +%Y%m%dT%H%M%S).mbtiles"
fi

OUTPUT_FILE_PATH="$(realpath "$OUTPUT_FILE_PATH")"


SQL="
  SELECT
      row_to_json(fc)::json
    FROM (
      SELECT
          'FeatureCollection' AS type,
          array_to_json(
            array_agg(f)
          ) As features
        FROM (
          SELECT
              'Feature' As type,
              ST_AsGeoJSON(shp.wkb_geometry)::json AS geometry,
              row_to_json(props) As properties
            FROM (
                SELECT
                    tmc,
                    f_system
                  FROM npmrds_shapefile
                  WHERE (conflation_year = ${YEAR})
            ) AS props
              INNER JOIN npmrds_shapefile AS shp USING (tmc)
            WHERE (shp.conflation_year = ${YEAR})
        ) As f
    )  As fc;
"

# NOTE: For whatever reason, [ "==", "is_interstate", true ] always evaluates to true
#       Need to state the above as [ "!=", "is_interstate", false ]
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

# tippecanoe \
  # --generate-ids \
  # --force -o "$OUTPUT_FILE_PATH" \
   # -z16 -d16 --drop-densest-as-needed \
  # -j "$FILTER" \
  # <( psql -t -c "$SQL" )

tippecanoe \
  --layer="$LAYER_NAME" \
  --generate-ids \
  --force -o "$OUTPUT_FILE_PATH" \
  <( psql -t -c "$SQL" )

echo "$OUTPUT_FILE_PATH"
