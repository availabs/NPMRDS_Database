#!/bin/bash

set -e
set -a

if [[ -z "$STATE" ]]; then
  (>&2 echo "ERROR: You must specify the STATE as an ENV variable.")
  exit 1
fi

if [[ -z "$YEAR" ]]; then
  (>&2 echo "ERROR: You must specify the YEAR as an ENV variable.")
  exit 1
fi

if [[ -z "$NPMRDS_SHAPEFILE_VERSION" ]]; then
  (>&2 echo "ERROR: You must specify the NPMRDS_SHAPEFILE_VERSION as an ENV variable.")
  exit 1
fi

# Variables to store the new table's name and its parent table's name.
TABLE_NAME="npmrds_shapefile_${YEAR}_v${NPMRDS_SHAPEFILE_VERSION}"
FULL_TABLE_NAME="\"${STATE}\".${TABLE_NAME}"

# If the table already exists, exit.
if psql -c "\d $FULL_TABLE_NAME" > /dev/null 2>&1; then
  echo "$FULL_TABLE_NAME already exists. Skipping table creation and shapefile loading."
  exit
fi


DATA_DIR=${1:-$DATA_DIR}

if [[ -z "$DATA_DIR" ]]; then
  (>&2 echo "ERROR: You must specify the DATA_DIR either as the 1st cli argument or as an ENV variable.")
  exit 1
fi

DATA_DIR="$(realpath "$DATA_DIR")"

if ! [[ -d "${DATA_DIR}" ]]; then
  (>&2 echo "ERROR: DATA_DIR ${DATA_DIR} directory found.")
  exit 1
fi

pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

. ../../bin/stateAbbreviations.sh

# source the database connection config.
if [ "$PG_ENV" = "production" ]; then
	. ../../config/postgres.env.prod
else
	. ../../config/postgres.env.dev
fi

# Last chance to kill script... just in case
echo "PostgreSQL Server: ${PGHOST}:${PGPORT}"
sleep 3

PARENT_TABLE_NAME="npmrds_shapefile_${YEAR}"
FULL_PARENT_TABLE_NAME="\"${STATE}\".${PARENT_TABLE_NAME}"

# If the parent table does not exist, create it.
if ! psql -c "\d $FULL_PARENT_TABLE_NAME" > /dev/null 2>&1; then
  psql \
    -v STATE="$STATE" -v YEAR="$YEAR" \
    -c "BEGIN;" \
    -f ../../sql/npmrds_shapefile/state/createStateNPMRDSShapefileYearTable.sql \
    -c "COMMIT;"
fi

# Get the absolute paths to the required SQL scripts before changing directory.
CREATE_TABLE_SQL_FILE_PATH="$(
  realpath ../../sql/npmrds_shapefile/state/createStateNPMRDSShapefileYearVersionTable.sql
)"
OPTIMIZE_TABLE_SQL_FILE_PATH="$(
  realpath ../../sql/npmrds_shapefile/state/optimizeStateNPMRDSShapefileYearVersionTable.sql
)"

cd "${DATA_DIR}" || exit

# Create the table into which we will upload the data
psql \
  -v STATE="$STATE" -v YEAR="$YEAR" -v NPMRDS_SHAPEFILE_VERSION="$NPMRDS_SHAPEFILE_VERSION" \
  -c "BEGIN;" \
  -f "${CREATE_TABLE_SQL_FILE_PATH}" \
  -c "COMMIT;"

# Upload the data
ogr2ogr -append -update -t_srs EPSG:4326 -f \
  PostgreSQL "PG:host=${PGHOST} port=${PGPORT} user=${PGUSER} dbname=${PGDATABASE} password=${PGPASSWORD}" \
  "$PWD" -nlt PROMOTE_TO_MULTI -nln "${STATE}.${TABLE_NAME}";

# Create spatial index and cluster the table using it.
psql \
  -v STATE="$STATE" -v YEAR="$YEAR" -v NPMRDS_SHAPEFILE_VERSION="$NPMRDS_SHAPEFILE_VERSION" \
  -c "BEGIN;" \
  -f "${OPTIMIZE_TABLE_SQL_FILE_PATH}" \
  -c "COMMIT;" \
  -c "VACUUM ANALYZE ${FULL_TABLE_NAME};"

# Which table in this schema currently inherits public.npmrds_shapefile_:YEAR?
#   We need this info to potentially uninherit that table, and
#   set the newly created table as the default for the YEAR.
CUR_DEFAULT="$(psql -t -c "
  SELECT c.relname
    FROM pg_inherits 
      JOIN pg_class AS c ON (inhrelid=c.oid)
      JOIN pg_class as p ON (inhparent=p.oid)
      JOIN pg_namespace pn ON pn.oid = p.relnamespace
      JOIN pg_namespace cn ON cn.oid = c.relnamespace
    WHERE (
      (pn.nspname = '${STATE}')
      AND
      (p.relname = '${PARENT_TABLE_NAME}')
    );
" | sed '/^$/d; s/^\s*//g')"

# If the newly uploaded table is a newer version than the current default version,
#   set the newly uploaded table as the default for the given state/year.
if [ -z "${CUR_DEFAULT}" ] || [[ "${TABLE_NAME}" > "${CUR_DEFAULT}" ]]; then
  UNINHERIT_OLD="ALTER TABLE \"${STATE}\".${CUR_DEFAULT} NO INHERIT ${FULL_PARENT_TABLE_NAME};"
  INHERIT_NEW="ALTER TABLE ${FULL_TABLE_NAME} INHERIT ${FULL_PARENT_TABLE_NAME};"

  psql \
    -c 'BEGIN;' \
    -c "$UNINHERIT_OLD" \
    -c "$INHERIT_NEW" \
    -c 'COMMIT;'

  echo "$FULL_TABLE_NAME set as the default for $FULL_PARENT_TABLE_NAME"
fi

STATES_IN_SHAPEFILE="$(psql -t -c "
  SELECT DISTINCT state
    FROM ${FULL_TABLE_NAME}
    ORDER BY state;
" | sed '/^$/d; s/^\s*//g')"

echo "$STATES_IN_SHAPEFILE"

while read -r state_name; do
  state="${STATE_ABBREVIATIONS[${state_name,,}]}";

  # If we have a 2 char code for the state
  #   and the state is not the same as the STATE name
  if [[ ! -z "$state" && "$STATE" != "$state" ]]; then
    echo "=== Creating npmrds_shapefile VIEW for ${state_name} (${state})  ==="
    VIEW_FULL_NAME="\"${state}\".${TABLE_NAME}"

    # If the state specific view does not exist
    if ! psql -c "\d $VIEW_FULL_NAME" > /dev/null 2>&1; then
      CREATE_VIEW_SQL="
        CREATE OR REPLACE VIEW $VIEW_FULL_NAME
          AS SELECT * FROM ${FULL_TABLE_NAME} WHERE state = '${state_name}'
        ;
      "

      psql \
        -c 'BEGIN;' \
        -c "CREATE SCHEMA IF NOT EXISTS \"${state}\";" \
        -c  "$CREATE_VIEW_SQL" \
        -c 'COMMIT;'
    fi
  fi
done <<< "$STATES_IN_SHAPEFILE"


popd >/dev/null
