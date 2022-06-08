# Tegola Experiments (Performance)

**TL;DR:** Performance is poor using the npmrds_production database on pluto.
It is very fast using a Docker container with the latest PostgreSQL & PostGIS.

See:

- [NYS RIS using ST_AsBinary on pluto](http://saturn.availabs.org/tegola_performance_experiments/binary_nys_ris_pluto/)
- [NYS RIS using ST_AsBinary in docker](http://saturn.availabs.org/tegola_performance_experiments/binary_nys_ris_docker/)
- [NYS RIS using ST_AsMVTGeom in docker](http://saturn.availabs.org/tegola_performance_experiments/mvt_nys_ris_docker/)
- [AVAIL Conflation Map using ST_AsBinary on pluto](http://saturn.availabs.org/tegola_performance_experiments/binary_conflation_pluto/)

## Slow performance using npmrds_production database on pluto

The tile providers that use the npmrds_production database on pluto are very slow.
I am not sure of the exact reason. It could be any combination of the following reasons:

- Older version of PostgreSQL and PostGIS
- General undiagnosed performance issues we've been having lately on pluto
- Latency communicating between tile server and db on separate machines

Additionally, the PostGIS version is too old to support the faster Tegola MVT provider.

See:

- [Fix SQL parsing for MVT provider #744](https://github.com/go-spatial/tegola/pull/744)
- [Allow using mvt_postgis provider for PostGIS version lower than 3.0 #772](https://github.com/go-spatial/tegola/issues/772)
- [Running into unable to convert geometry field (geometry) into bytes #779](https://github.com/go-spatial/tegola/issues/779)

```sql
npmrds_production=# select version();
                                                              version
-----------------------------------------------------------------------------------------------
 PostgreSQL 11.5 (Ubuntu 11.5-3.pgdg18.04+1) on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 7.4.0-1ubuntu1~18.04.1) 7.4.0, 64-bit
(1 row)

npmrds_production=# select PostGIS_Version();
            postgis_version
---------------------------------------
 2.5 USE_GEOS=1 USE_PROJ=1 USE_STATS=1
(1 row)
```

## Fast performance using Docker container with latest PostgreSQL and PostGIS

Performance is very impressive.

```sql
tegola=# select version();
                                                           version
----------------------------------------------------------------------------------------------
 PostgreSQL 14.3 (Debian 14.3-1.pgdg110+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
(1 row)

tegola=# select PostGIS_Version();
            postgis_version
---------------------------------------
 3.3 USE_GEOS=1 USE_PROJ=1 USE_STATS=1
(1 row)
```
