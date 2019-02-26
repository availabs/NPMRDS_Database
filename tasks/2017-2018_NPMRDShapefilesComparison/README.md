# 2017-2018 NPMRDS Shapefile Comparison

## Changes in tmc length

question: Did the TMC lengths change, and if so by how much?

Query:
```
psql -hares.availabs.org -p5432 -Unpmrds_ninja -dnpmrds_test -c 'COPY (select tmc, a.miles as miles_2017, b.miles as miles_2018 from ny.npmrds_shapefile_2017 as a inner join ny.npmrds_shapefile_2018 as b using (tmc) where a.miles <> b.miles order by ABS(a.miles - b.miles) / LEAST(a.miles, b.miles) desc) TO STDOUT WITH CSV HEADER' > npmrds_shapefile_tmc_lengths.csv
```

### Top 10 TMC length changes (by %)
```
tmc        miles_2017     miles_2018
104+04203  0.0041631857   0.20955736975
120+05152  0.55674220229  0.01344646844
104-04202  0.00747509313  0.25269294457
104-04209  0.01918172277  0.48741583982
120-05883  0.00941998436  0.21923832993
120P05157  0.0079535488   0.16737249256
120N05157  0.00810267784  0.16755890386
120-05151  0.55743813781  0.02904288054
120+05192  0.00505795994  0.0862462948
120+19316  1.85172286226  0.11204561872
```

See [npmrds_shapefile_tmc_lengths.csv.gz](npmrds_shapefile_tmc_lengths.csv.gz) for the full output of the query.

## Relocated TMCs

question: Are there any TMCs that do not occupy the same space?

```
npmrds_test=# select tmc, st_distance(geography(a.wkb_geometry), geography(b.wkb_geometry)) * 3.28084 as dist_ft from ny.npmrds_shapefile_2017 a inner join ny.npmrds_shapefile_2018 b using (tmc) where st_distance(geography(a.wkb_geometry), geography(b.wkb_geometry)) > 0 order by dist_ft desc;
    tmc    |     dist_ft      
-----------+------------------
 104+04331 | 1759.47058494807
 104N04203 |  1153.8489828254
 120P06527 | 955.102869067228
 104P04203 | 930.823223756159
 120-27969 | 914.745681073042
 120+27970 | 903.326413434003
 120+27969 | 809.585471956603
 104-04247 | 759.579242472545
 120-05160 |  752.03001949475
 120-05161 |  752.03001949475
 120-05215 | 608.916455023384
 104+04203 | 342.150603448819
 120-06397 |  240.41529328384
 120+06527 | 232.304114635175
 104P04158 | 178.171131495439
 120P05151 | 60.6040648527158
 120-05148 | 54.7994028329772
 120N05151 | 41.9857811663796
 104-04202 | 41.9769678097984
 120N04986 | 15.7454054907296
 120-04987 | 11.0626840154232
 120-04986 | 10.4562075524464
 120P04986 | 9.73345339217916
 120N04988 | 7.97503545533236
 120N30176 | 7.06872699129112
 120N05191 |   5.659229429783
 120-04988 | 4.03142072611832
 120-05191 |  4.0159915327112
 120P12473 | 2.62318785953256
 120-05190 | 1.03350073189092
(30 rows)
```

For an visual example, see the PNG in [geoviz.tar.gz](geoviz.tar.gz).

## How does the change in tmc lengths affect year-to-year comparisons?

### Experiment 1

#### Setup
  For this experiment, in the Massive Data Downloader, I requested
  * TMC 104+04203, while selecting both the 2017 and 2018 conflation year dropdown selector.
    * (I other words, even though the tmc_code was the same, I requested "two" segments.)
  * For the date range I selected 5/21/2018.
  * For the times of day I selected 5:00PM to 7:00PM.

#### Result
  The downloaded apparently treated these "two" segments as identical
    and returned data for only a single segment.

#### Conclusion
  Even though the TMC length changed from 2017 to 2018
    the downloaded does not distinguish between 2017 and 2018 _"versions"_
    of the TMC in the data.

  See [inquiry-1.tar.gz](inquiry-1.tar.gz) for the data.

### Experiment 2

#### Setup
  * TMC 104+04203, while selecting both the 2017 and 2018 conflation year dropdown selector.
    * (I other words, even though the tmc_code was the same, I requested "two" segments.)
  * For the date ranges I selected
    * 5/23/2017
    * 5/23/2018
  * For the times of day I selected 5:00PM to 7:00PM.

#### Result
  The downloaded apparently treated these "two" segments as identical
    and returned data for only a single segment.

  However, in the data, the TMC length difference is evident.
  The following data subset shows 6:55PM on both 2017-05-23 and 2018-05-23.

    tmc_code   measurement_tstamp   speed  average_speed  reference_speed  travel_time_seconds  data_density
    104+04203  2017-05-23 18:55:00  36.00  38.00          60.00            0.42                 A
    104+04203  2018-05-23 18:55:00  37.00  38.00          60.00            20.39                A

  Notice that even though the speeds are nearly equal,
    the travel times reflect the major change in TMC length from 2017 to 2018.

#### Conclusion
  Even though the TMC length changed from 2017 to 2018
    _INRIX does not distinguish between 2017 and 2018 versions of the TMC in the data_.
  
  *Year-to-year comparisons for some TMCs are invalid.*

  See [inquiry-2.tar.gz](inquiry-2.tar.gz) for the data.
