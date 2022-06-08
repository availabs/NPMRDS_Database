# Tegola Experiments: PostgreSQL Foreign Data Wrapper Fail

**TL;DR**: The PostGIS_Version on pluto is too old to support the Tegola
mvt_postgis provider. The alternative providers are too slow. Tried to use
newer PostgreSQL & PostGIS versions is a Docker container and connect to the
pluto npmrds_production database via Foreign Data Wrappers. Experiment failed.

Current PostGIS_Version on pluto

```sql
npmrds_production=# select PostGIS_Version();
            postgis_version
---------------------------------------
 2.5 USE_GEOS=1 USE_PROJ=1 USE_STATS=1
(1 row)
```

See

- [Fix SQL parsing for MVT provider #744](https://github.com/go-spatial/tegola/pull/744)
- [Allow using mvt_postgis provider for PostGIS version lower than 3.0 #772](https://github.com/go-spatial/tegola/issues/772)
- [Running into unable to convert geometry field (geometry) into bytes #779](https://github.com/go-spatial/tegola/issues/779)

```console
psql -hlocalhost -p5433 -Upostgres

Password for user postgres:
psql (14.3 (Ubuntu 14.3-1.pgdg18.04+1))
Type "help" for help.

postgres=# \l
                                    List of databases
       Name       |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
------------------+----------+----------+------------+------------+-----------------------
 postgres         | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0        | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                  |          |          |            |            | postgres=CTc/postgres
 template1        | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                  |          |          |            |            | postgres=CTc/postgres
 template_postgis | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
(4 rows)

postgres=# create database tegola_test;
CREATE DATABASE
postgres=# \connect tegola_test
You are now connected to database "tegola_test" as user "postgres".
tegola_test=# CREATE EXTENSION IF NOT EXISTS postgres_fdw;
CREATE EXTENSION
tegola_test=# select * from pg_extension;
  oid  |   extname    | extowner | extnamespace | extrelocatable | extversion | extconfig | extcondition
-------+--------------+----------+--------------+----------------+------------+-----------+--------------
 13743 | plpgsql      |       10 |           11 | f              | 1.0        |           |
 19607 | postgres_fdw |       10 |         2200 | t              | 1.1        |           |
(2 rows)

tegola_test=# CREATE SERVER foreigndb_fdw FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'pluto.availabs.org', port '5432', dbname 'npmrds_production');
CREATE SERVER
tegola_test=# \des
             List of foreign servers
     Name      |  Owner   | Foreign-data wrapper
---------------+----------+----------------------
 foreigndb_fdw | postgres | postgres_fdw
(1 row)

tegola_test=# create user mapping for postgres server foreigndb_fdw options (user 'tegola', password 'tegola');
CREATE USER MAPPING
tegola_test=# import foreign schema tegola from serv

tegola_test=# import foreign schema tegola limit to ( conflation_map_2021_v0_6_0 ) from server foreigndb_fdw int^C
tegola_test=# create schema tegola;
CREATE SCHEMA
tegola_test=# set search_path TO tegola ;
SET
tegola_test=# \d
Did not find any relations.
tegola_test=# import foreign schema tegola limit to ( conflation_map_2021_v0_6_0 ) from server foreigndb_fdw into tegola ;
ERROR:  type "public.geometry" does not exist
LINE 10:   wkb_geometry public.geometry(LineString,4326) OPTIONS (col...
                        ^
QUERY:  CREATE FOREIGN TABLE conflation_map_2021_v0_6_0 (
  id integer OPTIONS (column_name 'id'),
  year smallint OPTIONS (column_name 'year'),
  dir smallint OPTIONS (column_name 'dir'),
  n smallint OPTIONS (column_name 'n'),
  osm integer OPTIONS (column_name 'osm'),
  osm_fwd integer OPTIONS (column_name 'osm_fwd'),
  ris text OPTIONS (column_name 'ris') COLLATE pg_catalog."default",
  tmc text OPTIONS (column_name 'tmc') COLLATE pg_catalog."default",
  wkb_geometry public.geometry(LineString,4326) OPTIONS (column_name 'wkb_geometry')
) SERVER foreigndb_fdw
OPTIONS (schema_name 'tegola', table_name 'conflation_map_2021_v0_6_0');
CONTEXT:  importing foreign table "conflation_map_2021_v0_6_0"
tegola_test=# set search_path TO public ;
SET
tegola_test=# \d
Did not find any relations.
tegola_test=# \q
```
