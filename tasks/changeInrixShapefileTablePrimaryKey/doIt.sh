#!/bin/bash

set -e
set -a

pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null

. ../../config/postgres.env.prod

TABLES="$(
  psql -t \
    -c "
      SELECT table_schema || ' ' || table_name
        FROM information_schema.tables
        WHERE (
          (table_name LIKE 'inrix_shapefile_%')
          AND
          (table_type <> 'VIEW')
        )
        ORDER BY 1;
    "
)"

while read -r table_schema table_name; do
  if [[ ! "$table_schema" > 'cn' ]]; then
    continue
  fi

  echo '=========='
  echo "schema: $table_schema"
  echo "name: $table_name"

	# SQL="
		# BEGIN;

		# CREATE UNIQUE INDEX ${table_name}_unqidx
			# ON \"${table_schema}\".${table_name} (tmc);
		
		# ALTER TABLE \"${table_schema}\".${table_name} DROP CONSTRAINT ${table_name}_pkey,
				# ADD CONSTRAINT ${table_name}_pkey PRIMARY KEY USING INDEX ${table_name}_unqidx;

		# CLUSTER \"${table_schema}\".${table_name} USING ${table_name}_wkb_geometry_geom_idx;

		# COMMIT;
	# "
	# psql -v ON_ERROR_STOP=1 -c "$SQL"

  SET_FILLFACTOR="ALTER TABLE \"${table_schema}\".${table_name} SET ( fillfactor = 100);"
  psql -v ON_ERROR_STOP=1 -c "$SET_FILLFACTOR"

  CLUSTER="CLUSTER \"${table_schema}\".${table_name} USING ${table_name}_wkb_geometry_geom_idx;"
	psql -v ON_ERROR_STOP=1 -c "$CLUSTER"

  VACUUM="VACUUM ANALYZE \"${table_schema}\".${table_name};"
	psql -v ON_ERROR_STOP=1 -c "$VACUUM"

done <<< "$TABLES"

popd >/dev/null
