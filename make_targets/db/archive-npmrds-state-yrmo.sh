#!/bin/bash

set -e
set -a

if [[ -z "$STATE" ]]; then
  echo "ERROR: You must specify the STATE as an ENV variable."
  exit 1
fi

if [[ -z "$YEAR" ]]; then
  echo "ERROR: You must specify the YEAR as an ENV variable."
  exit 1
fi

if [[ -z "$MONTH" ]]; then
  echo "ERROR: You must specify the YEAR as an ENV variable."
  exit 1
fi

# To lowercase
STATE="${STATE,,}"

ARCHIVE_DIRECTORY_PATH=${1:-$ARCHIVE_DIRECTORY_PATH}

if [[ -z "$ARCHIVE_DIRECTORY_PATH" ]]; then
  echo "ERROR: You must specify the ARCHIVE_DIRECTORY_PATH either as the 1st cli argument or as an ENV variable."
  exit 1
fi

# Get the DB Connection Creds
pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

if [ "$PG_ENV" = "production" ]; then
	. ../../config/postgres.env.prod
else
	. ../../config/postgres.env.dev
fi

popd >/dev/null


# Create the state yrmo work dir
ARCHIVE_DIRECTORY_PATH="$(realpath "$ARCHIVE_DIRECTORY_PATH")"

TIMESTAMP="$( date +'%Y%m%dT%H%M%S' )"

STATE_YRMO_DIR_NAME="${STATE}.${YEAR}${MONTH}.npmrds_db_table.${TIMESTAMP}"

STATE_YRMO_DIR_PATH="$ARCHIVE_DIRECTORY_PATH/$STATE_YRMO_DIR_NAME"

mkdir -p "$STATE_YRMO_DIR_PATH"


# Change directory to the state yrmo work dir
pushd "$STATE_YRMO_DIR_PATH" >/dev/null

FULL_TABLE_NAME="\"${STATE}\".npmrds_y${YEAR}m${MONTH}"

SQL="COPY $FULL_TABLE_NAME TO STDOUT CSV HEADER;"

# NOTE: Same naming schema as the download-ETL process for toolchain reusability.
CSV_NAME="${STATE}.${YEAR}${MONTH}.npmrds.csv.gz"

psql -c "$SQL" | GZIP=-9 gzip > "$CSV_NAME"

echo "STATE=$STATE
YEAR=$YEAR
MONTH=$MONTH
TIMESTAMP=$TIMESTAMP
" > METADATA

popd >/dev/null

# Change directory to the state yrmo work dir
pushd "$ARCHIVE_DIRECTORY_PATH" >/dev/null

# Create the tar archive
echo "CREATE TAR"
tar zcf "${STATE_YRMO_DIR_NAME}.tar.gz" "$STATE_YRMO_DIR_NAME"

# Verify the tar archive's integrity
echo "VERIFY TAR TAR"
tar zdf "${STATE_YRMO_DIR_NAME}.tar.gz"

# Remove the state yrmo work dir
rm -rf "$STATE_YRMO_DIR_NAME"

echo "${STATE_YRMO_DIR_PATH}.tar.gz"

popd >/dev/null
