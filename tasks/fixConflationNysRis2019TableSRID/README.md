# Wrong SRID in conflation.nys_ris_2019

The fix:
https://github.com/availabs/NPMRDS_Database/commit/b3aba79caa845c7a1d74a4d8659fed1067eef39d

```
 npmrds_production=# \d conflation.nys_ris_2019
                                                         Table "conflation.nys_ris_2019"
            Column            |                 Type                  | Collation | Nullable |                      Default
------------------------------+---------------------------------------+-----------+----------+----------------------------------------------------
...
 shape                        | public.geometry(MultiLineString,4326) |           | not null |

create table conflation.nys_ris_2019_corrected as SELECT * FROM conflation.nys_ris_2019 LIMIT 10;

select public.UpdateGeometrySRID('conflation', 'nys_ris_2019_corrected', 'shape', 26918);

npmrds_production=# select public.ST_AsGeoJSON(shape) from conflation.nys_ris_2019 limit 1;
                                                                                                                                                         st_asgeojson
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 {"type":"MultiLineString","coordinates":[[[601077.98,4731065.27],[601111.47,4731110.41],[601120.26,4731125.53],[601124.51,4731137.48],[601127.24,4731152.18],[601126.27,4731167.71],[601083.96,4731283.61],[601079.62,4731300.54],[601079.8,4731316.2],[601087.63,4731346.41],[601088.26,4731359.31],[601087.92,4731360.3]]]}
(1 row)

npmrds_production=# select public.ST_AsGeoJSON(public.st_transform(shape, 4326)) from conflation.nys_ris_2019_corrected limit 1;
                                                                                                                                                                                                                                             st_asgeojson
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 {"type":"MultiLineString","coordinates":[[[-73.7653970540614,42.7254420210356],[-73.7649800247557,42.7258440260705],[-73.7648699831175,42.7259790002309],[-73.7648159485494,42.7260860314086],[-73.7647799843383,42.7262180221906],[-73.7647890552418,42.7263579731622],[-73.7652850375361,42.727407042114],[-73.7653350141426,42.7275600415377],[-73.765330019359,42.7277010114854],[-73.7652290036029,42.7279719739971],[-73.7652190060148,42.728088035221],[-73.7652229813176,42.728096993381]]]}
(1 row)
```

NOTE: Actual SRID found as follows

```sh
$ litecli roadwayinventorysystem2019.gpkg
Version: 1.5.0
Mail: https://groups.google.com/forum/#!forum/litecli-users
GitHub: https://github.com/dbcli/litecli
roadwayinventorysystem2019.gpkg> nopager;
Pager disabled.
Time: 0.000s
roadwayinventorysystem2019.gpkg> select * from gpkg_geometry_columns;
+------------------+-------------+--------------------+--------+---+---+
| table_name       | column_name | geometry_type_name | srs_id | z | m |
+------------------+-------------+--------------------+--------+---+---+
| RoadwayInventory | Shape       | MULTILINESTRING    | 26918  | 1 | 1 |
+------------------+-------------+--------------------+--------+---+---+
1 row in set
Time: 0.017s
```
