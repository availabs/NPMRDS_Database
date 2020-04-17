# NYS Continuous Counts (COVID-19 Pandemic)

## Schema

### Database Tables
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

### CSVs

Question: Do all the files have a common schema?
```
$ ls 
 CAD_020011_03012020.CSV   CAD_410131_03012020.CSV   CAD_730041_03012020.CSV   Class_Data_Selected_Sites_032620.zip
 CAD_150578_03012020.CSV   CAD_520076_03012020.CSV   CAD_840008_03012020.CSV  'Field Definitions_SC Formats.pdf'
 CAD_180395_03012020.CSV   CAD_630001_03012020.CSV   CAD_910108_03012020.CSV   Freight_Samples_Locations.xlsx
$ head -1 -q *.CSV | sort -u
Count_ID,Region,Region_Code,County_Code,Station,RCSTA,Functional_Class,Factor_Group,Latitude,Longitude,Specific_Recorder_Placement,Channel_Notes,Data_Type,Blank,Year,Month,Day,Day_of_week,Federal_Direction,Lane_Code,Total_Number_of_Lanes_in_direction,Data_Collection_Interval,Data_Interval,Class_F1,Class_F2,Class_F3,Class_F4,Class_F5,Class_F6,Class_F7,Class_F8,Class_F9,Class_F10,Class_F11,Class_F12,Class_F13,Unclassified,Total,Flag_Field
```
Answer: Yes.

#### The CSV Columns
```
head -1 CAD_020011_03012020.CSV | tr ',' '\n' | nl
     1  Count_ID
     2  Region
     3  Region_Code
     4  County_Code
     5  Station
     6  RCSTA
     7  Functional_Class
     8  Factor_Group
     9  Latitude
    10  Longitude
    11  Specific_Recorder_Placement
    12  Channel_Notes
    13  Data_Type
    14  Blank
    15  Year
    16  Month
    17  Day
    18  Day_of_week
    19  Federal_Direction
    20  Lane_Code
    21  Total_Number_of_Lanes_in_direction
    22  Data_Collection_Interval
    23  Data_Interval
    24  Class_F1
    25  Class_F2
    26  Class_F3
    27  Class_F4
    28  Class_F5
    29  Class_F6
    30  Class_F7
    31  Class_F8
    32  Class_F9
    33  Class_F10
    34  Class_F11
    35  Class_F12
    36  Class_F13
    37  Unclassified
    38  Total
    39  Flag_Field
```

So, we have data for the highway_data_services.continuous_vehicle_classification tables.

## Loading

### Sample Row From CSV
```
$ paste <( head -1 CAD_020011_03012020.CSV | tr ',' '\n' | nl) <(head -2 CAD_020011_03012020.CSV | tail -1 | tr ',' '\n' ) | column -t
1   Count_ID                            020011_03012020
2   Region                              11
3   Region_Code                         0
4   County_Code                         2
5   Station                             0011
6   RCSTA                               020011
7   Functional_Class                    11
8   Factor_Group                        30
9   Latitude
10  Longitude
11  Specific_Recorder_Placement
12  Channel_Notes
13  Data_Type                           Class            Data
14  Blank
15  Year                                2020
16  Month                               03
17  Day                                 01
18  Day_of_week                         Sunday
19  Federal_Direction                   1
20  Lane_Code                           1
21  Total_Number_of_Lanes_in_direction  3
22  Data_Collection_Interval            60
23  Data_Interval                       1.1
24  Class_F1                            0
25  Class_F2                            150
26  Class_F3                            11
27  Class_F4                            3
28  Class_F5                            4
29  Class_F6                            1
30  Class_F7                            0
31  Class_F8                            0
32  Class_F9                            0
33  Class_F10                           0
34  Class_F11                           0
35  Class_F12                           0
36  Class_F13                           0
37  Unclassified
38  Total                               169
```

### Sample Row From Database

```
npmrds_production=# select * FROM continuous_vehicle_classification where station = '0011' and f1 is not null limit 1;;
-[ RECORD 1 ]-------------------
rc          | 02
station     | 0011
region      | 11
dotid       | 100236
ccid        | 0299
fc          | 11
route       | I278
roadname    | BKLYN / QUEENS EXP
county      | KINGS
county_fips | 047
begin_desc  | 92ND ST OVER
end_desc    | 
station_id  | 020011
road        | 99
one_way     | 
year        | 2010
month       | 1
day         | 1
dow         | 6
hour        | 0
f1          | 2
f2          | 908
f3          | 89
f4          | 8
f5          | 17
f6          | 2
f7          | 0
f8          | 0
f9          | 4
f10         | 0
f11         | 0
f12         | 0
f13         | 0
```

#### The Data_Interval Column

From 'Field Definitions_SC Formats.pdf':

> Data_Interval – Speed and Classification data only. The interval which the record applies. 1.1
> indicates the first 15 minutes of the first hour of the day, or 00:00 through 00:15. 1.2 represents
> 00:15‐00:30, 12.3 represents 11:30‐11:45, 23.4 represents 22:45‐23:00 and so on.

```
awk -F, '{ print $23 }' *.CSV | sort -nu
Data_Interval
1.1
2.1
3.1
4.1
5.1
6.1
7.1
8.1
9.1
10.1
11.1
12.1
13.1
14.1
15.1
16.1
17.1
18.1
19.1
20.1
21.1
22.1
23.1
24.1
```

```
npmrds_production=# select distinct hour from continuous_vehicle_classification order by 1;
 hour 
------
    0
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
(24 rows)
```

#### Federal_Direction column

```
npmrds_production=# select station_id, year, month, day, hour, count(1) from continuous_vehicle_classification group by 1,2,3,4,5 having count(1) > 1 order by 1,2,3,4,5;

 station_id | year | month | day | hour | count 
------------+------+-------+-----+------+-------
 010027     | 2010 |     1 |   1 |    0 |     2
 010027     | 2010 |     1 |   1 |    1 |     2
 010027     | 2010 |     1 |   1 |    2 |     2
 010027     | 2010 |     1 |   1 |    3 |     2
 010027     | 2010 |     1 |   1 |    4 |     2
 010027     | 2010 |     1 |   1 |    5 |     2
 010027     | 2010 |     1 |   1 |    6 |     2
 010027     | 2010 |     1 |   1 |    7 |     2
 010027     | 2010 |     1 |   1 |    8 |     2
 010027     | 2010 |     1 |   1 |    9 |     2
 010027     | 2010 |     1 |   1 |   10 |     2
 010027     | 2010 |     1 |   1 |   11 |     2
 010027     | 2010 |     1 |   1 |   12 |     2
 010027     | 2010 |     1 |   1 |   13 |     2
 010027     | 2010 |     1 |   1 |   14 |     2
 010027     | 2010 |     1 |   1 |   15 |     2
 010027     | 2010 |     1 |   1 |   16 |     2
 010027     | 2010 |     1 |   1 |   17 |     2
 010027     | 2010 |     1 |   1 |   18 |     2
 010027     | 2010 |     1 |   1 |   19 |     2
 010027     | 2010 |     1 |   1 |   20 |     2
 010027     | 2010 |     1 |   1 |   21 |     2
 010027     | 2010 |     1 |   1 |   22 |     2
 010027     | 2010 |     1 |   1 |   23 |     2
 ...

 npmrds_production=# select station_id, road, year, month, day, hour, count(1) from continuous_vehicle_classification group by 1,2,3,4,5,6 having count(1) > 1;
 station_id | road | year | month | day | hour | count 
------------+------+------+-------+-----+------+-------
(0 rows)
 ```

From https://www.dot.ny.gov/divisions/engineering/technical-services/highway-data-services/hdsb/repository/Field_Definitions_CC%20Formats.pdf

> Road  – The direction of the data for each record. 99 represents data traveling from the Begin
> Desc to the End Desc, or primary direction. ‐99 represents data traveling from the End Desc to
> the Begin Desc, or non‐primary direction.



