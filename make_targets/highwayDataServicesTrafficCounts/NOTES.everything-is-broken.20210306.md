The CSV schemas changed.
Cannot load without significant code changes.


```
./load-highway-services-csvs --years 2018 --years 2019 --dataDir ../highwayDataServicesTrafficCounts/highway_data_service_counts_scrape.1615068673 --table average_weekday_speed --table average_weekday_vehicle_classification --table average_weekday_volume --table short_count_speed --table short_count_vehicle_classification --table short_count_volume
psql:/dev/fd/63:19: ERROR:  new row for relation "average_weekday_speed_r03_2018" violates check constraint "average_weekday_speed_r03_2018_rg_check"
DETAIL:  Failing row contains (33_9986, 339986_04032018, 3, 3, 3, 9986, 339986, 14, 30, null, null, 145ft W of Lynwood Ave      , null, Speed Statistics, 30, 2018, 4, 3, 0, Y, 1301, 3250, 5188, 3851, 1113, 185, 27, 1, 0, 0, 0, 0, 0, 0, 0, null, 14916, 25.55043, 27.9, 33.9, 0, 0, null, 297375).
CONTEXT:  COPY average_weekday_speed_r03_2018, line 618: ""33_9986","339986_04032018","3",3,3,"9986","339986",14,30,,,"145ft W of Lynwood Ave      ",,"Speed S..."
child_process.js:669
    throw err;
    ^

Error: Command failed: 
          PGOPTIONS='--client-min-messages=error' psql -q -v ON_ERROR_STOP=1 -f <(
            sed '
              s/__REGION__/03/g;
              s/__YEAR__/2018/g;
              s#__CSV_GZ_PATH__#/home/paul/AVAIL/NPMRDS_Database/make_targets/highwayDataServicesTrafficCounts/highway_data_service_counts_scrape.1615068673/average_weekday_speed_R03_2018.csv.gz#g;
            ' '/home/paul/AVAIL/NPMRDS_Database/sql/highway_data_services/loaders/load_average_weekday_speed_table.sql'
          )
        
psql:/dev/fd/63:19: ERROR:  new row for relation "average_weekday_speed_r03_2018" violates check constraint "average_weekday_speed_r03_2018_rg_check"
DETAIL:  Failing row contains (33_9986, 339986_04032018, 3, 3, 3, 9986, 339986, 14, 30, null, null, 145ft W of Lynwood Ave      , null, Speed Statistics, 30, 2018, 4, 3, 0, Y, 1301, 3250, 5188, 3851, 1113, 185, 27, 1, 0, 0, 0, 0, 0, 0, 0, null, 14916, 25.55043, 27.9, 33.9, 0, 0, null, 297375).
CONTEXT:  COPY average_weekday_speed_r03_2018, line 618: ""33_9986","339986_04032018","3",3,3,"9986","339986",14,30,,,"145ft W of Lynwood Ave      ",,"Speed S..."

    at checkExecSyncError (child_process.js:629:11)
    at execSync (child_process.js:666:13)
    at Object.<anonymous> (/home/paul/AVAIL/NPMRDS_Database/make_targets/db/load-highway-services-csvs:133:9)
    at Module._compile (internal/modules/cjs/loader.js:778:30)
    at Object.Module._extensions..js (internal/modules/cjs/loader.js:789:10)
    at Module.load (internal/modules/cjs/loader.js:653:32)
    at tryModuleLoad (internal/modules/cjs/loader.js:593:12)
    at Function.Module._load (internal/modules/cjs/loader.js:585:3)
    at Function.Module.runMain (internal/modules/cjs/loader.js:831:12)
    at startup (internal/bootstrap/node.js:283:19)
```

```
npmrds_production=# \d average_weekday_speed_r03_2015 
           Table "highway_data_services_data.average_weekday_speed_r03_2015"
            Column             |         Type         | Collation | Nullable | Default 
-------------------------------+----------------------+-----------+----------+---------
 rc_station                    | character varying    |           |          | 
 count_id                      | character varying    |           |          | 
 rg                            | character varying(2) |           |          | 
 region_code                   | character varying    |           |          | 
 county_code                   | character varying    |           |          | 
 stat                          | character varying(4) |           |          | 
 rcsta                         | character varying(6) |           |          | 
 functional_class              | smallint             |           |          | 
 factor_group                  | smallint             |           |          | 
 latitude                      | double precision     |           |          | 
 longitude                     | double precision     |           |          | 
 specific_recorder_placement   | character varying    |           |          | 
 channel_notes                 | character varying    |           |          | 
 data_type                     | character varying    |           |          | 
 speed_limit                   | smallint             |           |          | 
 year                          | smallint             |           |          | 
 month                         | smallint             |           |          | 
 day_of_first_data             | smallint             |           |          | 
 federal_direction             | smallint             |           |          | 
 full_count                    | character(1)         |           |          | 
 avg_wkday_bin_1               | integer              |           |          | 
 avg_wkday_bin_2               | integer              |           |          | 
 avg_wkday_bin_3               | integer              |           |          | 
 avg_wkday_bin_4               | integer              |           |          | 
 avg_wkday_bin_5               | integer              |           |          | 
 avg_wkday_bin_6               | integer              |           |          | 
 avg_wkday_bin_7               | integer              |           |          | 
 avg_wkday_bin_8               | integer              |           |          | 
 avg_wkday_bin_9               | integer              |           |          | 
 avg_wkday_bin_10              | integer              |           |          | 
 avg_wkday_bin_11              | integer              |           |          | 
 avg_wkday_bin_12              | integer              |           |          | 
 avg_wkday_bin_13              | integer              |           |          | 
 avg_wkday_bin_14              | integer              |           |          | 
 avg_wkday_bin_15              | integer              |           |          | 
 avg_wkday_unclassified        | integer              |           |          | 
 avg_wkday_totals              | integer              |           |          | 
 avg_speed                     | double precision     |           |          | 
 fiftyth_percentile_speed      | double precision     |           |          | 
 eightyfiveth_percentile_speed | double precision     |           |          | 
 percentile_exceeding_55       | double precision     |           |          | 
 percentile_exceeding_65       | double precision     |           |          | 
 flag_field                    | character varying    |           |          | 
 batch_id                      | character varying    |           |          | 
Indexes:
    "average_weekday_speed_r03_2015_rcsta_idx" btree (rcsta) WITH (fillfactor='100') CLUSTER
Check constraints:
    "average_weekday_speed_r03_2015_rg_check" CHECK (rg::text = '03'::text)
    "average_weekday_speed_r03_2015_year_check" CHECK (year = 2015)
Inherits: average_weekday_speed
```

```
➜  highway_data_service_counts_scrape.1615068673 git:(master) ✗ zcat continuous_vehicle_classification_R01_2018.csv.gz |sed 's/"//g'|awk 'NR==1\'|tr ',' '\n'|nl
     1  RC_STATION
     2  REGION
     3  REGION_CODE
     4  COUNTY_CODE
     5  STATION
     6  RCSTA
     7  FUNCTIONAL_CLASS
     8  FACTOR_GROUP
     9  YEAR
    10  MONTH
    11  DAY
    12  DAY_OF_WEEK
    13  FEDERAL_DIRECTION
    14  LANE_CODE
    15  LANES_IN_DIRECTION
    16  DATA_INTERVAL
    17  CLASS_F1
    18  CLASS_F2
    19  CLASS_F3
    20  CLASS_F4
    21  CLASS_F5
    22  CLASS_F6
    23  CLASS_F7
    24  CLASS_F8
    25  CLASS_F9
    26  CLASS_F10
    27  CLASS_F11
    28  CLASS_F12
    29  CLASS_F13
    30  UNCLASSIFIED
    31  TOTAL
➜  highway_data_service_counts_scrape.1615068673 git:(master) ✗ zcat ../../../highway_services_data/continuous_vehicle_classification_R01_2015.csv.gz |awk 'NR==1'|tr ',' '\n'|nl -ba
     1  RC
     2  Station
     3  Region
     4  DOTID
     5  CCID
     6  FC
     7  Route
     8  Roadname
     9  County
    10  County FIPS
    11  Begin Desc
    12  End Desc
    13  Station ID
    14  ROAD
    15  One-Way
    16  YEAR
    17  MONTH
    18  DAY
    19  DOW
    20  Hour
    21  F1
    22  F2
    23  F3
    24  F4
    25  F5
    26  F6
    27  F7
    28  F8
    29  F9
    30  F10
    31  F11
    32  F12
    33  F13
```
