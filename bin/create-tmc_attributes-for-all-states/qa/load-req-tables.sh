#!/bin/bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"

cd ../../../

# ===== In the Makefile =====
#
#   db/create-root-tmc-attributes: \
#  	    db/create-enum-types \
#  	    db/create-root-npmrds-table \
#  	    db/create-root-tmc-date-ranges-table \
#  	    db/create-state-abbreviations-table \
#  	    db/create-root-occupancy-factor-table \
#  	    db/create-root-average-speedlimits-table \
#  	    db/create-root-region-to-county-table \
#  	    db/create-root-regions-table

# make db/upload-mpo-boundaries-shapefile
# make db/create-mpo-boundaries-view

# make db/upload-urban-area-boundaries-shapefile
make db/load-fips-codes-table

