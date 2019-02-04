#!/bin/bash

set -e
set -a

if [[ -z "$SCHEMA" ]]; then
  echo "ERROR: You must specify the SCHEMA as an ENV variable."
  exit 1
fi

if [[ -z "$YEAR" ]]; then
  echo "ERROR: You must specify the YEAR as an ENV variable."
  exit 1
fi

# To lowercase
SCHEMA="${SCHEMA,,}"

DATA_DIR=${1:-$DATA_DIR}

if [[ -z "$DATA_DIR" ]]; then
  echo "ERROR: You must specify the DATA_DIR either as the 1st cli argument or as an ENV variable."
  exit 1
fi

DATA_DIR="$(realpath "$DATA_DIR")"

pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

# source the database connection config.
if [ "$PG_ENV" = "production" ]; then
	. ../../config/postgres.env.prod
else
	. ../../config/postgres.env.dev
fi

echo "PostgreSQL Server: ${PGHOST}:${PGPORT}"


# Get the absolute paths to the required SQL scripts.
DROP_TABLE_SQL_FILE_PATH="$(
  realpath ../../sql/npmrds_shapefile/state/dropStateNPMRDSShapefileYearVersionTable.sql
)"
CREATE_TABLE_SQL_FILE_PATH="$(
  realpath ../../sql/npmrds_shapefile/state/createStateNPMRDSShapefileYearVersionTable.sql
)"
OPTIMIZE_TABLE_SQL_FILE_PATH="$(
  realpath ../../sql/npmrds_shapefile/state/optimizeStateNPMRDSShapefileYearVersionTable.sql
)"

# The stateAbbreviations associative array is used
#   to get state abbreviations from full state names.
. ../../bin/stateAbbreviations.sh;

# Change directory into the shapefile directory
if ! [[ -d "${DATA_DIR}" ]]; then
  echo "ERROR: DATA_DIR ${DATA_DIR} directory found."
  exit 1
fi

cd "${DATA_DIR}" || exit

# Get the last update date from the shapefile.
#   This information is preserved in the database for versioning.
SHP_VERSION_DATE="$(ogrinfo -ro -so -al . | grep 'DBF_DATE_LAST_UPDATE' | sed 's/.*=//g; s/-//g')"
if [ -z "${SHP_VERSION_DATE}" ]; then SHP_VERSION_DATE='00000000'; fi;

# Variables to store the new table's name and its parent table's name.
TABLE_NAME="npmrds_shapefile_${YEAR}_v${SHP_VERSION_DATE}"
FULL_TABLE_NAME="\"${SCHEMA}\".${TABLE_NAME}"

PARENT_TABLE_NAME="npmrds_shapefile_${YEAR}"
FULL_PARENT_TABLE_NAME="\"${SCHEMA}\".${PARENT_TABLE_NAME}"

LATEST_PGDB_VERSION=$(
  psql -t \
    -c "
      SELECT table_name
        FROM information_schema.tables
        WHERE (
          (table_schema='${SCHEMA}')
          AND
          (table_name LIKE 'npmrds_shapefile_${YEAR}_v%')
        )
        ORDER BY table_name DESC LIMIT 1;
    " |
  tr -d " \t\n\r")

if [ -z "${LATEST_PGDB_VERSION}" ] || [[ "${TABLE_NAME}" > "${LATEST_PGDB_VERSION}" ]]; then

  # Create the table into which we will upload the data
  psql \
    -v STATE="$SCHEMA" -v YEAR="$YEAR" -v NPMRDS_SHAPEFILE_VER="$TABLE_NAME" \
    -c "BEGIN;" \
    -f "${DROP_TABLE_SQL_FILE_PATH}" \
    -f "${CREATE_TABLE_SQL_FILE_PATH}" \
    -c "COMMIT;" \

  # Upload the data
  ogr2ogr -append -update -t_srs EPSG:4326 -f \
    PostgreSQL "PG:host=${PGHOST} port=${PGPORT} user=${PGUSER} dbname=${PGDATABASE} password=${PGPASSWORD}" \
    "$PWD" -nlt PROMOTE_TO_MULTI -nln "${SCHEMA}.${TABLE_NAME}";

  # Create spatial index and cluster the table using it.
  psql \
    -v STATE="$SCHEMA" -v YEAR="$YEAR" -v NPMRDS_SHAPEFILE_VER="$TABLE_NAME" \
    -c "BEGIN;" \
    -f "${OPTIMIZE_TABLE_SQL_FILE_PATH}" \
    -c "COMMIT;" \
    -c "VACUUM ANALYZE ${FULL_TABLE_NAME};" \

  # Which table in this schema currently inherits public.npmrds_shapefile_:YEAR?
  #   We need this info to uninherit that table, and
  #   set the newly created table as the default for the YEAR.
	CUR_DEFAULT="$(psql -t -c "
		SELECT c.relname
			FROM pg_inherits 
				JOIN pg_class AS c ON (inhrelid=c.oid)
				JOIN pg_class as p ON (inhparent=p.oid)
				JOIN pg_namespace pn ON pn.oid = p.relnamespace
				JOIN pg_namespace cn ON cn.oid = c.relnamespace
			WHERE (
				(pn.nspname = '${SCHEMA}')
				AND
				(p.relname = '${PARENT_TABLE_NAME}')
			);
	" | sed '/^$/d; s/^\s*//g')"

  # If there is a current default table for this state/year...
	if ! [[ -z "$CUR_DEFAULT" ]]; then
		UNINHERIT_OLD="ALTER TABLE \"${SCHEMA}\".${CUR_DEFAULT} NO INHERIT ${FULL_PARENT_TABLE_NAME};"
	fi

  # Set the newly uploaded table as the default for the given state/year.
	psql \
		-c 'BEGIN;' \
		-c "$UNINHERIT_OLD" \
    -c "ALTER TABLE ${FULL_TABLE_NAME} INHERIT ${FULL_PARENT_TABLE_NAME};" \
		-c 'COMMIT;' \

else
  echo "INRIX Shapefile in the database is the latest.";
fi;

popd >/dev/null
