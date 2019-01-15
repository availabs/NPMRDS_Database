#!/bin/bash

set -e
set -a

if [[ -z "$STATE" ]]; then
  echo "ERROR: You must specify the STATE as an ENV variable."
  exit 1
fi

DATA_DIR=${1:-$DATA_DIR}

if [[ -z "$DATA_DIR" ]]; then
  echo "ERROR: You must specify the DATA_DIR either as the 1st cli argument or as an ENV variable."
  exit 1
fi

pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

if [ "$PG_ENV" = "production" ]; then
	. ../../config/postgres.env.prod
else
	. ../../config/postgres.env.dev
fi

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

LATEST_PGDB_VERSION=$(
  psql -t \
    -c "
      SELECT table_name
        FROM information_schema.tables
        WHERE (
          (table_schema='${STATE}')
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
    DROP TABLE IF EXISTS \"${STATE}\".${LATEST_FILE_VERSION};
    CREATE TABLE IF NOT EXISTS \"${STATE}\".${LATEST_FILE_VERSION} ()
			INHERITS (public.inrix_shapefile);
		ALTER TABLE \"${STATE}\".${LATEST_FILE_VERSION}
			ALTER COLUMN ogc_fid DROP NOT NULL;
		COMMIT;
  "

  ogr2ogr -append -update -t_srs EPSG:4326 -f \
    PostgreSQL "PG:host=${PGHOST} port=${PGPORT} user=${PGUSER} dbname=${PGDATABASE} password=${PGPASSWORD}" \
    "$PWD" -nlt PROMOTE_TO_MULTI -nln "${STATE}.${LATEST_FILE_VERSION}";

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
				(cn.nspname = '${STATE}')
				AND
				(c.relname <> '${LATEST_FILE_VERSION}')
			);
	" | sed '/^$/d; s/^\s*//g')"

	if ! [[ -z "$CUR_DEFAULT" ]]; then
		UNINHERIT_OLD="ALTER TABLE \"${STATE}\".${CUR_DEFAULT} NO INHERIT public.inrix_shapefile;"
	fi

	psql \
		-c 'BEGIN;' \
		-c "$UNINHERIT_OLD" \
		-c 'COMMIT;'

else
  echo "INRIX Shapefile in the database is the latest.";
fi;

popd >/dev/null
