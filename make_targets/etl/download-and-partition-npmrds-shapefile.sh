#!/bin/bash

set -e
set -a

if [[ -z "$COUNTRY" ]]; then
  echo "ERROR: You must specify the COUNTRY as an ENV variable."
  exit 1
fi

# To upper case
COUNTRY="${COUNTRY^^}"

if [[ -z "$YEAR" ]]; then
  echo "ERROR: You must specify the YEAR as an ENV variable."
  exit 1
fi

pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

PROJECT_ROOT="$(realpath ../../)"
ETL_DIR="${PROJECT_ROOT}/etl"
mkdir -p "$ETL_DIR";

WORK_DIR="$(mktemp -d -p "$ETL_DIR")";
SHP_ZIP_DIR="${WORK_DIR}/${COUNTRY}/${YEAR}/";

mkdir -p "$SHP_ZIP_DIR";

echo "$COUNTRY" > "${SHP_ZIP_DIR}COUNTRY"
echo "$YEAR" > "${SHP_ZIP_DIR}CONFLATION_YEAR"

if [[ "$COUNTRY" = 'USA' ]]; then
  SHP_ZIP_BASENAME='USA.zip'
elif [[ "$COUNTRY" = 'CANADA' ]]; then
  SHP_ZIP_BASENAME='Canada.zip'
else
  (>&2 echo 'ERROR: COUNTRY must be either USA or CANADA')
  exit 1
fi

SHP_ZIP_PATH="${SHP_ZIP_DIR}${SHP_ZIP_BASENAME}"

## The last line of output from download-npmrds-shapefile.js
##   is the location of the downloaded shapefile.
"${PROJECT_ROOT}/make_targets/etl/download-npmrds-shapefile.js" "${SHP_ZIP_PATH}"

DOWNLOAD_TIMESTAMP="$(date +%Y%m%dT%H%M%S)"
echo "$DOWNLOAD_TIMESTAMP" > "${SHP_ZIP_DIR}/DOWNLOAD_TIMESTAMP"

if ! PARTITIONER_OUTPUT="$("${PROJECT_ROOT}/make_targets/etl/partition-npmrds-shapefile.sh" "${SHP_ZIP_PATH}")"; then
  ( >&2 echo "ERROR: Partitioning failed.")
  ( >&2 echo "$PARTITIONER_OUTPUT")
  exit 1
fi

NPMRDS_SHAPEFILE_VERSION="$(
  cat "${SHP_ZIP_DIR}/NPMRDS_SHAPEFILE_VERSION"
)";

cd "${ETL_DIR}";

FINAL_DIR_NAME="${COUNTRY}_conflationYear${YEAR}_shpVersion${NPMRDS_SHAPEFILE_VERSION}_downloadTS${DOWNLOAD_TIMESTAMP}";
echo "FINAL_DIR_NAME=$FINAL_DIR_NAME"

mv "${WORK_DIR}" "${FINAL_DIR_NAME}";

tar --remove-files -cvf "${FINAL_DIR_NAME}.tar" "${FINAL_DIR_NAME}";
echo "Downloaded and partitioned shapefile archive: ${ETL_DIR}/${FINAL_DIR_NAME}.tar"

popd >/dev/null
