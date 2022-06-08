# Tegola_Experiments.ogr2ogr-issue

See [ogr2ogr from file to PostgreSQL 12 table fails](https://gis.stackexchange.com/questions/342246/ogr2ogr-from-file-to-postgresql-12-table-fails)

```console
ERROR 1: ERROR:  column s.consrc does not exist
LINE 1: ...nrelid = c.oid AND a.attnum = ANY (s.conkey) AND (s.consrc L...
                                                             ^
HINT:  Perhaps you meant to reference the column "s.conkey" or the column "s.conbin".

ERROR 1: ERROR:  column s.consrc does not exist
LINE 1: ...nrelid = c.oid AND a.attnum = ANY (s.conkey) AND (s.consrc L...
                                                             ^
HINT:  Perhaps you meant to reference the column "s.conkey" or the column "s.conbin".
```

The fix:

```sh
ogr2ogr \
    -f 'PGDUMP' \
    -t_srs 'EPSG:4326' \
    -lco SCHEMA=tergola_nys_ris \
    -lco GEOMETRY_NAME=wkb_geometry \
    -nln nys_roadway_inventory_system_v20210800 \
     -dim 2 \
    /vsistdout/ \
    ./data/nys-roadway-inventory-system-v20210800.gdb roadway_inventory_system \
  | sed \
      's/^ALTER TABLE "nys_roadway_inventory_system_v20210800"/ALTER TABLE "tergola_nys_ris"."nys_roadway_inventory_system_v20210800"/g' \
  | psql -v ON_ERROR_STOP=1
```
