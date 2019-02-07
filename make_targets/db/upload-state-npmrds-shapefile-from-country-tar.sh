#!/bin/bash

set -e
set -a

TAR_ARCHIVE_PATH="${1:-$TAR_ARCHIVE_PATH}"
STATE="${2:-$STATE}"
STATE="${STATE,,}"

if [[ -z "$TAR_ARCHIVE_PATH" ]]; then
  (>&2 echo "ERROR: You must specify the TAR_ARCHIVE_PATH either as the 1st cli argument or as an ENV variable.")
  exit 1
fi

if [[ -z "$STATE" ]]; then
  (>&2 echo "ERROR: You must specify the STATE either as the 2nd cli argument or as an ENV variable.")
  exit 1
fi

if [[ ! -f "$TAR_ARCHIVE_PATH" ]]; then
  (>&2 echo "ERROR: No file found at ${TAR_ARCHIVE_PATH}")
  exit 1
fi

STATE_SHP_ARCHIVE_PATH="$(
  tar tf "$TAR_ARCHIVE_PATH" | grep "states/${STATE}.zip" || echo ''
)"

if [ -z "$STATE_SHP_ARCHIVE_PATH" ]; then
  (>&2 echo "ERROR: ${STATE} was not found in ${TAR_ARCHIVE_PATH}")
  exit 1
fi


pushd "$( dirname "${BASH_SOURCE[0]}" )/" >/dev/null

LOADER_SCRIPT_PATH="$(readlink -f "./upload-npmrds-shapefile-for-state-year.sh")"

popd >/dev/null

WORK_DIR="$(mktemp -d)"

tar xOf "$TAR_ARCHIVE_PATH" "$STATE_SHP_ARCHIVE_PATH" > "${WORK_DIR}/${STATE}.zip"

cd "$WORK_DIR"

7za x "${STATE}.zip" -y > /dev/null && rm "${STATE}.zip" 

cd "$STATE"
DATA_DIR="$(pwd)"

if [ ! -f ./CONFLATION_YEAR ]; then
  (>&2 echo "ERROR: The ${DATA_DIR}/CONFLATION_YEAR file is missing")
  exit 1
fi

YEAR="$(cat ./CONFLATION_YEAR)"

if [ ! -f ./NPMRDS_SHAPEFILE_VERSION ]; then
  (>&2 echo "ERROR: The ${DATA_DIR}/NPMRDS_SHAPEFILE_VERSION file is missing")
  exit 1
fi

NPMRDS_SHAPEFILE_VERSION="$(cat ./NPMRDS_SHAPEFILE_VERSION)"

export STATE
export DATA_DIR
export YEAR
export NPMRDS_SHAPEFILE_VERSION
export PG_ENV

bash "$LOADER_SCRIPT_PATH"

rm -rf "$WORK_DIR"
