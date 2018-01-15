#!/bin/bash

set -e

source ../../config/postgres.env

export PGDATABASE
export PGUSER
export PGPASSWORD
export PGHOST
export PGPORT

mkdir -p csv

SQL="
	SELECT schemaname || '.' || tablename
		FROM pg_tables
		WHERE (
			(SUBSTRING(tablename FROM 'top_level_') <> '')
			AND
			(SUBSTRING(tablename FROM 'y201') <> '')
		)
		ORDER BY schemaname, tablename
;"

OUTPUT=$(psql --tuples-only -c "${SQL}" | sed '/^\s*$/d')

echo "${OUTPUT}" |\
while read -r line ; do
	psql -c "COPY ${line} TO STDOUT CSV HEADER;" > "./csv/${line};"
done
