# Transcom Events Onto Road Network QA

Three mapping versions:

- 0.0.0: the original mapping logic
- 0.0.1: mapping logic that still used description to get direction and incorrect SRID
- 0.0.2: the latest logic that uses transcom_event_expanded.direction and correct SRID

## TL;DR: QA Results

Version 0.0.2 performs the best.

### QA Results

NOTE: Deviance is defined as the distance in meters between the TRANSCOM Event Point
and the ConflationMap Node to which the event is mapped.

| Version | Avg Dev | Min Dev | 25% Dev | 50% Dev | 75% Dev | Max Dev  |
| ------- | ------- | ------- | ------- | ------- | ------- | -------- |
| 0.0.0   | 189.83  | 0.07    | 16.80   | 52.29   | 167.19  | 48869.03 |
| 0.0.1   | 22.29   | 0.13    | 3.98    | 7.55    | 16.65   | 1105.87  |
| 0.0.2   | 19.98   | 0.13    | 3.98    | 7.50    | 16.60   | 1105.87  |

### Versions 0.0.1 vs 0.0.2 changes

#### TRANSCOM Events lat/lon SRID

We had assumed the TRANSCOM Event lat/lon coords were in 4326.
However, the TRANSCOM EventsExpanded include a point_datum property.
This property informs us that the coords are in fact in NAD83.

```sql
npmrds_production=# select point_datum, count(1) from _transcom_admin.transcom_events_expanded group by 1;
 point_datum |  count
-------------+---------
 NAD83       | 1798446
             |      26
(2 rows)
```

The fix applied in the new database tables.

```sql
public.ST_Transform(
  public.ST_SetSRID(
    public.ST_MakePoint(
      a.point_long,
      a.point_lat
    ),
    4269 -- NAD83 -- EPSG:4269
  ),
  4326  -- EPSG:4326
) AS point_geom,
```

Looks like the effect was minimal.

```sql
npmrds_production=# \d+ _transcom_admin.qa_transcom_event_point_srid_impact
                        Materialized view "_transcom_admin.qa_transcom_event_point_srid_impact"
     Column      |            Type
-----------------+-----------------------------+
 event_id        | text                        |
 point_4326      | public.geometry(Point,4326) |
 point_4269      | public.geometry             |
 distance_meters | double precision            |
View definition:
 SELECT a.event_id,
    a.point_geom AS point_4326,
    b.point_geom AS point_4269,
    public.st_distance(public.geography(a.point_geom), public.geography(b.point_geom)) AS distance_meters
   FROM _transcom_historical_events a
     JOIN transcom_event_meta b USING (event_id);

npmrds_production=# select avg(a.distance_meters) from _transcom_admin.qa_transcom_event_point_srid_impact as a inner join transcom._transcom_historical_events as b using (event_id) inner join transcom.transcom_event_meta as c using (event_id) where (round(b.longitude::numeric, 7) = round(c.point_long::numeric, 7)) and (round(b.latitude::numeric, 7) = round(c.point_lat::numeric, 7)) ;
         avg
---------------------
 2.0409884307574e-08
(1 row)

Time: 15115.731 ms (00:15.116)
npmrds_production=# select max(a.distance_meters) from _transcom_admin.qa_transcom_event_point_srid_impact as a inner join transcom._transcom_historical_events as b using (event_id) inner join transcom.transcom_event_meta as c using (event_id) where (round(b.longitude::numeric, 7) = round(c.point_long::numeric, 7)) and (round(b.latitude::numeric, 7) = round(c.point_lat::numeric, 7)) ;
    max
------------
 0.00603406
(1 row)
```

#### Event roadway direction

Version 0.0.1 used used the TRANSCOM Event _description_ to get the direction.

```sql
COALESCE(d.direction, ''NONE'') =
  CASE
    WHEN a.description ILIKE '%northbound%'  THEN 'N'
    WHEN a.description ILIKE '%southbound%'  THEN 'S'
    WHEN a.description ILIKE '%eastbound%'   THEN 'E'
    WHEN a.description ILIKE '%westbound%'   THEN 'W'
    ELSE 'NONE'
  END
`
```

Version 0.0.2 uses the newly available TRANSCOM Events _direction_ property.

```sh
COALESCE(d.direction, 'NONE') =
  CASE
    WHEN a.direction = 'northbound'  THEN 'N'
    WHEN a.direction = 'southbound'  THEN 'S'
    WHEN a.direction = 'eastbound'   THEN 'E'
    WHEN a.direction = 'westbound'   THEN 'W'
    ELSE 'NONE'
  END
```

Version 0.0.1 algorithm was error prone

Consider:

```sql
npmrds_production=# select description, direction from _transcom_admin.transcom_events_expanded where event_id = 'ORI193869607';
-[ RECORD 1 ]---------------------------------------------------------------------------------------------------------------
description | NYSDOT - Region 3: Disabled tractor trailer on I-690 eastbound at I-81 Southbound (Syracuse) right lane closed
direction   | eastbound
```

Version 0.0.1 assigns 'S' to the above description.

#### QA Details

See the SQL files in [./sql/](./sql/) for further details on how the versions were compared.

The QA Results table was populated using the following queries:

```sql
npmrds_production=# select avg(old_event_to_node_dist_meters) as v0_event_to_node_dist_meters_avg, percentile_cont(ARRAY[0, 0.25, 0.5, 0.75, 1]::DOUBLE PRECISION[]) within group (order by old_event_to_node_dist_meters::DOUBLE PRECISION) as v0_event_to_node_dist_meters_quartiles, avg(new_event_to_node_dist_meters) as v1_event_to_node_dist_meters_avg, percentile_cont(ARRAY[0, 0.25, 0.5, 0.75, 1]::DOUBLE PRECISION[]) within group (order by new_event_to_node_dist_meters::DOUBLE PRECISION) as v1_event_to_node_dist_meters_quartiles from _transcom_admin.qa_transcom_events_mapping_comparison_v0_v2;
-[ RECORD 1 ]--------------------------+----------------------------------------------------------------
v0_event_to_node_dist_meters_avg       | 189.830547702174
v0_event_to_node_dist_meters_quartiles | {0.06611451,16.8025672,52.29117873,167.19281539,48869.03299883}
v1_event_to_node_dist_meters_avg       | 22.9733381367339
v1_event_to_node_dist_meters_quartiles | {0.01095224,4.18516836,8.22310345,19.80017747,1105.87086738}

npmrds_production=# select avg(old_event_to_node_dist_meters) as v1_event_to_node_dist_meters_avg, percentile_cont(ARRAY[0, 0.25, 0.5, 0.75, 1]::DOUBLE PRECISION[]) within group (order by old_event_to_node_dist_meters::DOUBLE PRECISION) as v1_event_to_node_dist_meters_quartiles, avg(new_event_to_node_dist_meters) as v2_event_to_node_dist_meters_avg, percentile_cont(ARRAY[0, 0.25, 0.5, 0.75, 1]::DOUBLE PRECISION[]) within group (order by new_event_to_node_dist_meters::DOUBLE PRECISION) as v2_event_to_node_dist_meters_quartiles from _transcom_admin.qa_transcom_events_mapping_comparison_v1_v2 where ( transcom_event_modified_timestamp_difference < '2 hours' );
-[ RECORD 1 ]--------------------------+-------------------------------------------------------------
v1_event_to_node_dist_meters_avg       | 20.0285972250791
v1_event_to_node_dist_meters_quartiles | {0.12913377,3.97932845,7.54962759,16.65425892,1105.87086738}
v2_event_to_node_dist_meters_avg       | 19.9786201316115
v2_event_to_node_dist_meters_quartiles | {0.12913377,3.97932845,7.49492701,16.60284006,1105.87086738}
```
