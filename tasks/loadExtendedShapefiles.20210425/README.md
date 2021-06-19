# Load NPMRDS Extended Shapefiles for NY

## Years

* 2018
* 2019
* 2020

## Backup the existing tables

```SQL
begin;
-- Essentially... Had to rename this table after typo. Also, a couple of rollbacks on this one.
create table ny.npmrds_shapefile_2018_backup_20210425 AS select * from ny.npmrds_shapefile_2018;

create table ny.npmrds_shapefile_2019_backup_20210425 as select * from ny.npmrds_shapefile_2019;

create table ny.npmrds_shapefile_2020_backup_20210425 as select * from ny.npmrds_shapefile_2020;
commit;
```

## Load the new Extended Shapefiles

On saturn, in ~/code/NPMRDS_Database
```sh
./run upload_zipped_state_npmrds_shapefile --shpZipPath data/shape_tmc_1802_usa_ny.zip --state ny --year 2018 --pg_env production
./run upload_zipped_state_npmrds_shapefile --shpZipPath data/shape_tmc_1902_usa_ny.zip --state ny --year 2019 --pg_env production
./run upload_zipped_state_npmrds_shapefile --shpZipPath data/shape_tmc_2002_usa_ny.zip --state ny --year 2020 --pg_env production
 ```

## Initial Data investigations

### 2018 Extended Shapefile Completeness

```
npmrds_production=# select count(1) from tmc_identification_2018 where tmc in (select tmc from ny.tmc_identification_2018 except select tmc from ny.npmrds_shapefile_2018_backup_20210425 ) and aadt is not null;
 count 
-------
    41
(1 row)

npmrds_production=# select count(1) from tmc_identification_2018 where tmc in (select tmc from ny.tmc_identification_2018 except select tmc from ny.npmrds_shapefile_2018) and aadt is not null;
 count 
-------
   900
(1 row)
```

### 2019 Extended Shapefile Completeness

```
npmrds_production=# select count(1) from tmc_identification_2019 where tmc in (select tmc from ny.tmc_identification_2019 except select tmc from ny.npmrds_shapefile_2019_backup_20210425 ) and aadt is not null;
 count 
-------
     0
(1 row)

npmrds_production=# select count(1) from tmc_identification_2019 where tmc in (select tmc from ny.tmc_identification_2019 except select tmc from ny.npmrds_shapefile_2019 ) and aadt is not null;
 count 
-------
    17
(1 row)
```

### 2020 Extended Shapefile Completeness

```
npmrds_production=# select count(1) from tmc_identification_2020 where tmc in (select tmc from ny.tmc_identification_2020 except select tmc from ny.npmrds_shapefile_2020_backup_20210425 ) and aadt is not null;
 count 
-------
    26
(1 row)

npmrds_production=# select count(1) from tmc_identification_2020 where tmc in (select tmc from ny.tmc_identification_2020 except select tmc from ny.npmrds_shapefile_2020 ) and aadt is not null;
 count 
-------
    16
(1 row)
```
