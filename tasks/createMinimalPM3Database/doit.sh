#!/bin/bash

set -e
set -a

# PG_ENV=production
YEARS=2017,2018

THIS_DIR="$( realpath "$( dirname "${BASH_SOURCE[0]}" )" )"

MPO_SHAPEFILE_ZIP_PATH="${THIS_DIR}/data/MPOBoundary_061218.zip"

# Change CWD to the project root.
pushd "$( dirname "${BASH_SOURCE[0]}" )/../../" >/dev/null

export PG_ENV
export YEARS
export MPO_SHAPEFILE_ZIP_PATH

## Initialize the minimal database
# make db/initialize-minimal-database

## Load the mpo boundaries shapefile
# make db/upload-mpo-boundaries-shapefile

# Load the NPMRDS Shapefiles for NY & NJ
TAR_ARCHIVE_PATH="${THIS_DIR}/data/USA_conflationYear2018_shpVersion20181011_downloadTS20190311T150618.tar"

# for STATE in ny nj; do
#   export STATE
#   export TAR_ARCHIVE_PATH
#   make db/upload-state-npmrds-shapefile-from-country-tar
# done

DATA_DIR="${THIS_DIR}/data"
for STATE in ny nj; do
  export STATE
  #for YEAR in 2017 2018; do
  YEAR=2018
    export YEAR
    for MONTH in {01..12}; do
      export MONTH
      export DATA_FILE_PATH="${DATA_DIR}/${STATE}/${STATE}.${YEAR}${MONTH}.npmrds.csv.gz"
      if ! [ -f "$DATA_FILE_PATH" ]; then
        echo "Cannot find $DATA_FILE_PATH"
        exit 1
      fi
      #make db/upload-npmrds-state-yrmo
    done
  #done
done

popd >/dev/null
