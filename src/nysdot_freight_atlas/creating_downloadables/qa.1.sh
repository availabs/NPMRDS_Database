#!/bin/bash

# For warnings such as
#    Warning 1: Value 1094582173677.55005 of field shape_area of feature 0 not
#    successfully written. Possibly due to too larger number with respect to field width.

ag \
    -l 'Possibly due to too larger number with respect to field width' \
    test_output/*.log \
  | sort \
  | while read -r f; do
      layer="$(
        echo "$f" \
          | sed 's#test_output/nysdot_freight_atlas.##' \
          | sed 's#.v2016.shp.log##' \
      )"

      fields="$(
        grep \
            -E 'of field .* of feature [0-9]{1,} not successfully written.' \
            $f \
          | sed 's/.*of field //' \
          | sed 's/ of feature.*//' \
          | sort -u \
          | sed 's/^/"/' \
          | sed 's/$/"/' \
          | jq -s -c '.' 
      )"

      echo '{"layer":"'$layer'","fields":'$fields'}'
    done
