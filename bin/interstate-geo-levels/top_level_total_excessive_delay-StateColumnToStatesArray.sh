#!/bin/bash

# https://stackoverflow.com/a/14782402/3970755

set -e

source ../../config/postgres.env

export PGDATABASE
export PGUSER
export PGPASSWORD
export PGHOST
export PGPORT

# ROOT_RELATIONS=( top_level_travel_time_reliability top_level_freight_reliability top_level_total_excessive_delay urban_area_populations )
ROOT_RELATIONS=( top_level_travel_time_reliability top_level_freight_reliability top_level_total_excessive_delay)

for rel in "${ROOT_RELATIONS[@]}"
do

  SQL="
  WITH RECURSIVE cte_descendents (p_nspname, p_relname, c_nspname, c_relname) AS (
      SELECT
          pn.nspname AS p_nspname,
          p.relname AS p_relname,
          cn.nspname AS c_nspname,
          c.relname AS c_relname
        FROM pg_inherits 
          JOIN pg_class AS c ON (inhrelid=c.oid)
          JOIN pg_class as p ON (inhparent=p.oid)
          JOIN pg_namespace pn ON pn.oid = p.relnamespace
          JOIN pg_namespace cn ON cn.oid = c.relnamespace
        WHERE (
          (p.relname = '${rel}')
          AND
          (pn.nspname = 'public')
        )
    UNION
      SELECT
          pn.nspname AS p_nspname,
          p.relname AS p_relname,
          cn.nspname AS c_nspname,
          c.relname AS c_relname
        FROM pg_inherits 
          JOIN pg_class AS c ON (inhrelid=c.oid)
          JOIN pg_class as p ON (inhparent=p.oid)
          JOIN pg_namespace pn ON pn.oid = p.relnamespace
          JOIN pg_namespace cn ON cn.oid = c.relnamespace
          JOIN cte_descendents ON (
            (cte_descendents.c_nspname = pn.nspname)
            AND
            (cte_descendents.c_relname = p.relname)
          )
    )
    SELECT
       '\"' || c_nspname || '\".' || c_relname || ' \"' || p_nspname || '\".' || p_relname
      FROM cte_descendents
      ORDER BY c_relname
  ;
  "

  OUTPUT=$(psql -t -c "${SQL}" | sed '/^\s*$/d')

  echo "${OUTPUT}" |\
  while read -r line ; do
    arr=($line)
    psql\
      -c "BEGIN;"\
      -c "ALTER TABLE ${arr[0]} NO INHERIT ${arr[1]};"\
      -c "COMMIT;"
  done

  psql\
    -c "BEGIN;"\
    -c "ALTER TABLE public.${rel} RENAME COLUMN state TO states;"\
    -c "ALTER TABLE public.${rel} ALTER COLUMN states TYPE VARCHAR(2)[] USING ARRAY[states];"\
    -c "COMMIT;"

  echo "${OUTPUT}" |\
  while read -r line ; do
    arr=($line)

    # Get the state schema
    CN="$(echo "${arr[0]}" | sed 's/^"\(.*\)".*/\1/')"

    psql\
      -c "BEGIN;"\
      -c "ALTER TABLE ${arr[0]} DROP CONSTRAINT state_check;"\
      -c "ALTER TABLE ${arr[0]} RENAME COLUMN state TO states;"\
      -c "COMMIT;"

    psql\
      -c "BEGIN;"\
      -c "ALTER TABLE ${arr[0]} ALTER COLUMN states TYPE VARCHAR(2)[] USING ARRAY[states];"\
      -c "ALTER TABLE ${arr[0]} ADD CONSTRAINT state_check CHECK ((states = ARRAY['${CN}']::VARCHAR(2)[]) OR (ARRAY_LENGTH(states, 1) > 1));"\
      -c "COMMIT;"
  done

  echo "${OUTPUT}" |\
  while read -r line ; do
    arr=($line)
    psql\
      -c "BEGIN;"\
      -c "ALTER TABLE ${arr[0]} INHERIT ${arr[1]};"\
      -c "COMMIT;"
  done

done
