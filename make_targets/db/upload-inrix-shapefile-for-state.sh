#!/bin/bash

set -e
set -a

if [[ -z "$SCHEMA" ]]; then
  echo "ERROR: You must specify the SCHEMA as an ENV variable."
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

if [ "$PG_ENV" = "production" ]; then
	. ../../config/postgres.env.prod
else
	. ../../config/postgres.env.dev
fi

. ../../bin/stateAbbreviations.sh;

echo "PGHOST: $PGHOST"
echo "PGPORT: $PGPORT"

if ! [[ -d "${DATA_DIR}" ]]; then
  echo "ERROR: DATA_DIR ${DATA_DIR} directory found."
  exit 1
fi

cd "${DATA_DIR}" || exit

# Get the last update date from the shapefile.
SHP_VERSION_DATE="$(ogrinfo -ro -so -al . | grep 'DBF_DATE_LAST_UPDATE' | sed 's/.*=//g; s/-//g')"
if [ -z "${SHP_VERSION_DATE}" ]; then SHP_VERSION_DATE='00000000'; fi;

LATEST_FILE_VERSION="inrix_shapefile_${SHP_VERSION_DATE}"

FULL_TABLE_NAME="\"${SCHEMA}\".${LATEST_FILE_VERSION}"

echo "FULL_TABLE_NAME: $FULL_TABLE_NAME"


LATEST_PGDB_VERSION=$(
  psql -t \
    -c "
      SELECT table_name
        FROM information_schema.tables
        WHERE (
          (table_schema='${SCHEMA}')
          AND
          (table_name LIKE 'inrix_shapefile_%')
        )
        ORDER BY table_name DESC LIMIT 1;
    " |
  tr -d " \t\n\r")

echo "LATEST VERSION IN DATABASE: ${LATEST_PGDB_VERSION}";\

if [ -z "${LATEST_PGDB_VERSION}" ] || [[ "${LATEST_FILE_VERSION}" > "${LATEST_PGDB_VERSION}" ]]; then

  psql -c "
		BEGIN;
    DROP TABLE IF EXISTS ${FULL_TABLE_NAME};
    CREATE TABLE IF NOT EXISTS ${FULL_TABLE_NAME} (
      LIKE public.inrix_shapefile INCLUDING ALL
    );
		ALTER TABLE ${FULL_TABLE_NAME}
			ALTER COLUMN ogc_fid DROP NOT NULL;
		COMMIT;
  "

  ogr2ogr -append -update -t_srs EPSG:4326 -f \
    PostgreSQL "PG:host=${PGHOST} port=${PGPORT} user=${PGUSER} dbname=${PGDATABASE} password=${PGPASSWORD}" \
    "$PWD" -nlt PROMOTE_TO_MULTI -nln "${SCHEMA}.${LATEST_FILE_VERSION}";

  # Which table for this schema currently inherits public.inrix_shapefile
  #   We need this info to uninherit that table.
	CUR_DEFAULT="$(psql -t -c "
		SELECT c.relname
			FROM pg_inherits 
				JOIN pg_class AS c ON (inhrelid=c.oid)
				JOIN pg_class as p ON (inhparent=p.oid)
				JOIN pg_namespace pn ON pn.oid = p.relnamespace
				JOIN pg_namespace cn ON cn.oid = c.relnamespace
			WHERE (
				(p.relname = 'inrix_shapefile')
				AND
				(c.relname <> '${LATEST_FILE_VERSION}')
				AND
				(pn.nspname = 'public')
				AND
				(cn.nspname = '${SCHEMA}')
			);
	" | sed '/^$/d; s/^\s*//g')"

  # If 
	if ! [[ -z "$CUR_DEFAULT" ]]; then
		UNINHERIT_OLD="ALTER TABLE \"${SCHEMA}\".${CUR_DEFAULT} NO INHERIT public.inrix_shapefile;"
	fi

	psql \
		-c 'BEGIN;' \
		-c "$UNINHERIT_OLD" \
    -c "ALTER TABLE ${FULL_TABLE_NAME} INHERIT public.inrix_shapefile;" \
    -c "CREATE INDEX ${LATEST_FILE_VERSION}_gix ON ${FULL_TABLE_NAME} USING GIST (wkb_geometry);" \
    -c "CLUSTER ${FULL_TABLE_NAME} USING ${LATEST_FILE_VERSION}_gix;" \
		-c 'COMMIT;' \
    -c "VACUUM ANALYZE ${FULL_TABLE_NAME};" \

	STATES_IN_SHAPEFILE="$(psql -t -c "
		SELECT DISTINCT state
      FROM ${FULL_TABLE_NAME}
      ORDER BY state;
	" | sed '/^$/d; s/^\s*//g')"


  while read -r state_name; do
    state="${STATE_ABBREVIATIONS[${state_name,,}]}";

    # If we have a 2 char code for the state
    #   and the state is not the same as the SCHEMA name
    if [[ ! -z "$state" && "$SCHEMA" != "$state" ]]; then
      echo "=== Creating view for ${state_name} (${state})  ==="
      VIEW_NAME="\"${state}\".${LATEST_FILE_VERSION}"

      # If the state specific view does not exist
      if ! psql -c "\d $VIEW_NAME" > /dev/null 2>&1; then
        CREATE_VIEW_SQL="
          CREATE VIEW $VIEW_NAME
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

else
  echo "INRIX Shapefile in the database is the latest.";
fi;

popd >/dev/null
