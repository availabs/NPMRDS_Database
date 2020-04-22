# Loading the official 2017 Continuous Counts from [NYSDOT HDS](https://www.dot.ny.gov/divisions/engineering/technical-services/highway-data-services/hdsb)

## Problem: CSV file schema change

### Vehicle Classification

#### Database/Legacy CSV Schema
```
npmrds_production=# \d highway_data_services.continuous_vehicle_classification 
   Table "highway_data_services.continuous_vehicle_classification"
   Column    |         Type         | Collation | Nullable | Default 
-------------+----------------------+-----------+----------+---------
 rc          | character varying(2) |           |          | 
 station     | character varying(4) |           |          | 
 region      | smallint             |           |          | 
 dotid       | character varying    |           |          | 
 ccid        | character varying(4) |           |          | 
 fc          | smallint             |           |          | 
 route       | character varying    |           |          | 
 roadname    | character varying    |           |          | 
 county      | character varying    |           |          | 
 county_fips | character varying(3) |           |          | 
 begin_desc  | character varying    |           |          | 
 end_desc    | character varying    |           |          | 
 station_id  | character varying(6) |           |          | 
 road        | smallint             |           |          | 
 one_way     | character(1)         |           |          | 
 year        | smallint             |           |          | 
 month       | smallint             |           |          | 
 day         | smallint             |           |          | 
 dow         | smallint             |           |          | 
 hour        | smallint             |           |          | 
 f1          | integer              |           |          | 
 f2          | integer              |           |          | 
 f3          | integer              |           |          | 
 f4          | integer              |           |          | 
 f5          | integer              |           |          | 
 f6          | integer              |           |          | 
 f7          | integer              |           |          | 
 f8          | integer              |           |          | 
 f9          | integer              |           |          | 
 f10         | integer              |           |          | 
 f11         | integer              |           |          | 
 f12         | integer              |           |          | 
 f13         | integer              |           |          | 

npmrds_production=# select * from highway_data_services.continuous_vehicle_classification where year = 2015 limit 1;
-[ RECORD 1 ]----------------------------------
rc          | 11
station     | 0601
region      | 1
dotid       | 100495
ccid        | 1130
fc          | 11
route       | I87
roadname    | Adirondack Northway
county      | ALBANY
county_fips | 001
begin_desc  | EXIT 2 - RT 5
end_desc    | EXIT 4 - ALBANY SHAKER ROAD UNDER
station_id  | 110601
road        | 99
one_way     | 
year        | 2015
month       | 1
day         | 1
dow         | 5
hour        | 0
f1          | 1
f2          | 461
f3          | 72
f4          | 6
f5          | 7
f6          | 0
f7          | 0
f8          | 0
f9          | 3
f10         | 0
f11         | 0
f12         | 0
f13         | 0
```

### New 2017 CSV schema

```
paste <(head -1 base_data/continous_counts.2017/continuous_vehicle_classification_R04_2017.csv | tr , '\n' | nl) <(head -2 base_data/continous_counts.2017/continuous_vehicle_classification_R04_2017.csv | tail -1 | tr , '\n') | column
-t
1   RC_STATION          44_0469
2   RG                  04
3   REGION_CODE         4
4   COUNTY_CODE         4
5   STAT                0469
6   RCSTA               440469
7   FUNCTIONAL_CLASS    17
8   FACTOR_GROUP        40
9   YEAR                2017
10  MONTH               11
11  DAY                 3
12  DAY_OF_WEEK         Friday
13  FEDERAL_DIRECTION   5
14  LANE_CODE           1
15  LANES_IN_DIRECTION  1
16  DATA_INTERVAL       11
17  CLASS_F1            0
18  CLASS_F2            119
19  CLASS_F3            63
20  CLASS_F4            0
21  CLASS_F5            2
22  CLASS_F6            1
23  CLASS_F7            2
24  CLASS_F8            0
25  CLASS_F9            0
26  CLASS_F10           0
27  CLASS_F11           0
28  CLASS_F12           0
29  CLASS_F13           0
30  UNCLASSIFIED
31  TOTAL               187
```

Notice that for some files the header is missing columns.

```
$ head -1 base_data/continous_counts.2017/continuous_vehicle_classification_R*

==> continuous_vehicle_classification_R01_2017.csv <==
RC_STATION,RG,REGION_CODE,COUNTY_CODE,STAT,RCSTA,FUNCTIONAL_CLASS,FACTOR_GROUP,YEAR,MONTH,DAY,DAY_OF_WEEK

==> continuous_vehicle_classification_R02_2017.csv <==
RC_STATION,RG,REGION_CODE,COUNTY_CODE,STAT,RCSTA,FUNCTIONAL_CLASS,FACTOR_GROUP,YEAR,MONTH,DAY,DAY_OF_WEEK

==> continuous_vehicle_classification_R03_2017.csv <==
RC_STATION,RG,REGION_CODE,COUNTY_CODE,STAT,RCSTA,FUNCTIONAL_CLASS,FACTOR_GROUP,YEAR,MONTH,DAY,DAY_OF_WEEK

==> continuous_vehicle_classification_R04_2017.csv <==
RC_STATION,RG,REGION_CODE,COUNTY_CODE,STAT,RCSTA,FUNCTIONAL_CLASS,FACTOR_GROUP,YEAR,MONTH,DAY,DAY_OF_WEEK,FEDERAL_DIRECTION,LANE_CODE,LANES_IN_DIRECTION,DATA_INTERVAL,CLASS_F1,CLASS_F2,CLASS_F3,CLASS_F4,CLASS_F5,CLASS_F6,CLASS_F7,CLASS_F8,CLASS_F9,CLASS_F10,CLASS_F11,CLASS_F12,CLASS_F13,UNCLASSIFIED,TOTAL
```

We will need to strip out the header when doing the transform step.

#### The DATA_INTERVAL column

```
$ head -1 base_data/continous_counts.2017/continuous_vehicle_classification_R04_2017.csv|tr , '\n'|nl | grep DATA_INTERVAL
    16  DATA_INTERVAL

$ find base_data/continous_counts.2017/ -name 'continuous_vehicle_classification_R*' -exec sh -c "tail -n+2 {} | awk -F, '{ print \$16 }'" \; | sort -nu
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
```

#### The LANE_CODE column

```
$ head -1 base_data/continous_counts.2017/continuous_vehicle_classification_R04_2017.csv|tr , '\n'|nl | grep LANE_CODE
    14  LANE_CODE
$ find base_data/continous_counts.2017/ -name 'continuous_vehicle_classification_R*' -exec sh -c "tail -n+2 {} | awk -F, '{ print \$14 }'" \; | sort -nu
1
2
3
4
```

### Volume Classification

```
npmrds_production=# \d highway_data_services.continuous_volume 
           Table "highway_data_services.continuous_volume"
   Column    |         Type         | Collation | Nullable | Default 
-------------+----------------------+-----------+----------+---------
 rc          | character varying(2) |           |          | 
 station     | character varying(4) |           |          | 
 region      | smallint             |           |          | 
 dotid       | character varying    |           |          | 
 ccid        | character varying(4) |           |          | 
 fc          | smallint             |           |          | 
 route       | character varying    |           |          | 
 roadname    | character varying    |           |          | 
 county      | character varying    |           |          | 
 county_fips | character varying(3) |           |          | 
 begin_desc  | character varying    |           |          | 
 end_desc    | character varying    |           |          | 
 station_id  | character varying(6) |           |          | 
 road        | smallint             |           |          | 
 one_way     | character(1)         |           |          | 
 year        | smallint             |           |          | 
 month       | smallint             |           |          | 
 day         | smallint             |           |          | 
 dow         | smallint             |           |          | 
 i1          | integer              |           |          | 
 i2          | integer              |           |          | 
 i3          | integer              |           |          | 
 i4          | integer              |           |          | 
 i5          | integer              |           |          | 
 i6          | integer              |           |          | 
 i7          | integer              |           |          | 
 i8          | integer              |           |          | 
 i9          | integer              |           |          | 
 i10         | integer              |           |          | 
 i11         | integer              |           |          | 
 i12         | integer              |           |          | 
 i13         | integer              |           |          | 
 i14         | integer              |           |          | 
 i15         | integer              |           |          | 
 i16         | integer              |           |          | 
 i17         | integer              |           |          | 
 i18         | integer              |           |          | 
 i19         | integer              |           |          | 
 i20         | integer              |           |          | 
 i21         | integer              |           |          | 
 i22         | integer              |           |          | 
 i23         | integer              |           |          | 
 i24         | integer              |           |          |
```

```
$ head -1 -q base_data/continous_counts.2017/continuous_volume_R* | sort -u
RC_STATION,RG,REGION_CODE,COUNTY_CODE,STAT,RCSTA,FUNCTIONAL_CLASS,FACTOR_GROUP,YEAR,MONTH,DAY,DAY_OF_WEEK,FEDERAL_DIRECTION,LANES_IN_DIRECTION,INTERVAL_01,INTERVAL_02,INTERVAL_03,INTERVAL_04,INTERVAL_05,INTERVAL_06,INTERVAL_07,INTERVAL_08,INTERVAL_09,INTERVAL_10,INTERVAL_11,INTERVAL_12,INTERVAL_13,INTERVAL_14,INTERVAL_15,INTERVAL_16,INTERVAL_17,INTERVAL_18,INTERVAL_19,INTERVAL_20,INTERVAL_21,INTERVAL_22,INTERVAL_23,INTERVAL_24

$ paste <(head -1 base_data/continous_counts.2017/continuous_volume_R01_2017.csv | tr , '\n' | nl) <(head -2 base_data/continous_counts.2017/continuous_volume_R01_2017.csv | tail -1 | tr , '\n') | column -t
1   RC_STATION          18_0395
2   RG                  01
3   REGION_CODE         1
4   COUNTY_CODE         8
5   STAT                0395
6   RCSTA               180395
7   FUNCTIONAL_CLASS    4
8   FACTOR_GROUP        40
9   YEAR                2017
10  MONTH               9
11  DAY                 1
12  DAY_OF_WEEK         Friday
13  FEDERAL_DIRECTION   5
14  LANES_IN_DIRECTION  1
15  INTERVAL_01         30
16  INTERVAL_02         19
17  INTERVAL_03         26
18  INTERVAL_04         46
19  INTERVAL_05         79
20  INTERVAL_06         151
21  INTERVAL_07         293
22  INTERVAL_08         341
23  INTERVAL_09         385
24  INTERVAL_10         428
25  INTERVAL_11         516
26  INTERVAL_12         483
27  INTERVAL_13         522
28  INTERVAL_14         443
29  INTERVAL_15         620
30  INTERVAL_16         604
31  INTERVAL_17         537
32  INTERVAL_18         533
33  INTERVAL_19         446
34  INTERVAL_20         300
35  INTERVAL_21         213
36  INTERVAL_22         146
37  INTERVAL_23         159
38  INTERVAL_24         108
```


## Ensuring single entries for station/date/time/direction

```
$ find . -name 'continuous_volume*' -exec awk -F, 'NR>1{ print $1,$9,$10,$11,$13 }' {} \; | s
ort | uniq -D
$

$ find . -name 'continuous_vehicle*' -exec awk -F, 'NR>1{ print $1,$9,$10,$11,$13,$14,$16 }' {} \; | sort | uniq -D
$
```

