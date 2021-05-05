# 2020 transposed Truck AADT values

The *FHWA_2020:1.2.0:as-is-truck-aadt*  version was run using the
  TMC Truck AADT values as they are found in the TMC_Identification file.

The *FHWA_2020:1.2.2* version was run using the following modification
  to the pm3\_calculator\_2 code:

```sh
avail@saturn:~/code/pm3_calculator_2$ git status -uno
On branch 2020_transposed_truck_aadt
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   src/storage/daos/TmcMetadataDao.js

no changes added to commit (use "git add" and/or "git commit -a")
avail@saturn:~/code/pm3_calculator_2$ git diff
diff --git a/src/storage/daos/TmcMetadataDao.js b/src/storage/daos/TmcMetadataDao.js
index 9b837bb..f46f6c2 100644
--- a/src/storage/daos/TmcMetadataDao.js
+++ b/src/storage/daos/TmcMetadataDao.js
@@ -214,7 +214,7 @@ const getMetadataForTmcs = async ({ year, tmcs, columns }) => {

   const sql = `
     SELECT ${selectClauseElems}
-      FROM tmc_metadata_${year}
+      FROM tmc_metadata_${year}_with_transposed_truck_aadt
         ${risJoinClause}
       WHERE (
         tmc = ANY($1)
```

The tmc_metadata_2020_with_transposed_truck_aadt VIEW is simply
  tmc_metadata_2020 with the Truck AADT columns swapped.

```sh
npmrds_production=# \d+ public.tmc_metadata_2020_with_transposed_truck_aadt
                                 View "public.tmc_metadata_2020_with_transposed_truck_aadt"
        Column         |                   Type                    | Collation | Nullable | Default | Storage  | Description
-----------------------+-------------------------------------------+-----------+----------+---------+----------+-------------
 tmc                   | character varying                         |           |          |         | extended |
 roadnumber            | character varying                         |           |          |         | extended |
 roadname              | character varying                         |           |          |         | extended |
 firstname             | character varying                         |           |          |         | extended |
 tmclinear             | integer                                   |           |          |         | plain    |
 country               | character varying                         |           |          |         | extended |
 state_name            | character varying                         |           |          |         | extended |
 county_name           | character varying                         |           |          |         | extended |
 zip                   | character varying                         |           |          |         | extended |
 direction             | character varying                         |           |          |         | extended |
 startlat              | double precision                          |           |          |         | plain    |
 startlong             | double precision                          |           |          |         | plain    |
 endlat                | double precision                          |           |          |         | plain    |
 endlong               | double precision                          |           |          |         | plain    |
 miles                 | double precision                          |           |          |         | plain    |
 frc                   | smallint                                  |           |          |         | plain    |
 border_set            | character varying                         |           |          |         | extended |
 f_system              | smallint                                  |           |          |         | plain    |
 faciltype             | smallint                                  |           |          |         | plain    |
 structype             | smallint                                  |           |          |         | plain    |
 thrulanes             | smallint                                  |           |          |         | plain    |
 route_numb            | integer                                   |           |          |         | plain    |
 route_sign            | smallint                                  |           |          |         | plain    |
 route_qual            | smallint                                  |           |          |         | plain    |
 altrtename            | character varying                         |           |          |         | extended |
 aadt                  | integer                                   |           |          |         | plain    |
 aadt_singl            | integer                                   |           |          |         | plain    |
 aadt_combi            | integer                                   |           |          |         | plain    |
 nhs                   | smallint                                  |           |          |         | plain    |
 nhs_pct               | smallint                                  |           |          |         | plain    |
 strhnt_typ            | smallint                                  |           |          |         | plain    |
 strhnt_pct            | smallint                                  |           |          |         | plain    |
 truck                 | smallint                                  |           |          |         | plain    |
 state                 | character(2)                              |           |          |         | extended |
 is_interstate         | boolean                                   |           |          |         | plain    |
 is_controlled_access  | boolean                                   |           |          |         | plain    |
 avg_speedlimit        | real                                      |           |          |         | plain    |
 mpo_code              | character varying                         |           |          |         | extended |
 mpo_acrony            | character varying                         |           |          |         | extended |
 mpo_name              | character varying                         |           |          |         | extended |
 ua_code               | character varying                         |           |          |         | extended |
 ua_name               | character varying                         |           |          |         | extended |
 congestion_level      | public.traffic_dist_congestion_level_type |           |          |         | plain    |
 directionality        | public.traffic_dist_directionality_type   |           |          |         | plain    |
 bounding_box          | public.box2d                              |           |          |         | plain    |
 avg_vehicle_occupancy | real                                      |           |          |         | plain    |
 state_code            | character(2)                              |           |          |         | extended |
 county_code           | character(5)                              |           |          |         | extended |
 type                  | character varying                         |           |          |         | extended |
 road_order            | real                                      |           |          |         | plain    |
 isprimary             | smallint                                  |           |          |         | plain    |
 timezone_name         | character varying                         |           |          |         | extended |
 active_start_date     | date                                      |           |          |         | plain    |
 active_end_date       | date                                      |           |          |         | plain    |
View definition:
 SELECT tmc_metadata_2020.tmc,
    tmc_metadata_2020.roadnumber,
    tmc_metadata_2020.roadname,
    tmc_metadata_2020.firstname,
    tmc_metadata_2020.tmclinear,
    tmc_metadata_2020.country,
    tmc_metadata_2020.state_name,
    tmc_metadata_2020.county_name,
    tmc_metadata_2020.zip,
    tmc_metadata_2020.direction,
    tmc_metadata_2020.startlat,
    tmc_metadata_2020.startlong,
    tmc_metadata_2020.endlat,
    tmc_metadata_2020.endlong,
    tmc_metadata_2020.miles,
    tmc_metadata_2020.frc,
    tmc_metadata_2020.border_set,
    tmc_metadata_2020.f_system,
    tmc_metadata_2020.faciltype,
    tmc_metadata_2020.structype,
    tmc_metadata_2020.thrulanes,
    tmc_metadata_2020.route_numb,
    tmc_metadata_2020.route_sign,
    tmc_metadata_2020.route_qual,
    tmc_metadata_2020.altrtename,
    tmc_metadata_2020.aadt,
    tmc_metadata_2020.aadt_combi AS aadt_singl,
    tmc_metadata_2020.aadt_singl AS aadt_combi,
    tmc_metadata_2020.nhs,
    tmc_metadata_2020.nhs_pct,
    tmc_metadata_2020.strhnt_typ,
    tmc_metadata_2020.strhnt_pct,
    tmc_metadata_2020.truck,
    tmc_metadata_2020.state,
    tmc_metadata_2020.is_interstate,
    tmc_metadata_2020.is_controlled_access,
    tmc_metadata_2020.avg_speedlimit,
    tmc_metadata_2020.mpo_code,
    tmc_metadata_2020.mpo_acrony,
    tmc_metadata_2020.mpo_name,
    tmc_metadata_2020.ua_code,
    tmc_metadata_2020.ua_name,
    tmc_metadata_2020.congestion_level,
    tmc_metadata_2020.directionality,
    tmc_metadata_2020.bounding_box,
    tmc_metadata_2020.avg_vehicle_occupancy,
    tmc_metadata_2020.state_code,
    tmc_metadata_2020.county_code,
    tmc_metadata_2020.type,
    tmc_metadata_2020.road_order,
    tmc_metadata_2020.isprimary,
    tmc_metadata_2020.timezone_name,
    tmc_metadata_2020.active_start_date,
    tmc_metadata_2020.active_end_date
   FROM public.tmc_metadata_2020;
```
