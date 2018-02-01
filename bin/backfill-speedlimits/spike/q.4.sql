--  BEGIN;

--  DROP TABLE IF EXISTS spike_null_speedlimt_tmcs;
--  CREATE TABLE IF NOT EXISTS spike_null_speedlimt_tmcs AS
  --  SELECT tmc
    --  FROM ny.tmc_attributes
    --  WHERE (avg_speedlimit IS NULL)
--  ;

--  COMMIT;


BEGIN;

DROP TABLE IF EXISTS spike_known_speedlimit_tmcs_sample;
CREATE TABLE IF NOT EXISTS spike_known_speedlimit_tmcs_sample AS
  SELECT tmc
    FROM ny.tmc_attributes
    WHERE (avg_speedlimit IS NOT NULL)
    ORDER BY RANDOM()
    LIMIT 100
;

COMMIT;


--  BEGIN;

--  DROP TABLE IF EXISTS spike_known_speedlimit_tmcs_sample;
--  CREATE TABLE IF NOT EXISTS spike_known_speedlimit_tmcs_sample AS
  --  SELECT tmc
    --  FROM ny.tmc_attributes
      --  INNER JOIN inrix_shapefile USING (tmc)
    --  WHERE (avg_speedlimit IS NOT NULL)
    --  ORDER BY ST_NumGeometries(wkb_geometry) DESC, RANDOM()
    --  LIMIT 100
--  ;

--  COMMIT;


--  BEGIN;

--  DROP TABLE IF EXISTS spike_geo_dumps;
--  CREATE TABLE IF NOT EXISTS spike_geo_dumps AS
  --  SELECT
      --  tmc,
      --  ST_Dump(wkb_geometry) AS multiline_dump
    --  FROM inrix_shapefile
  --  ;

--  COMMIT;


--  BEGIN;

--  DROP TABLE IF EXISTS spike_geo_dumps_pts;
--  CREATE TABLE IF NOT EXISTS spike_geo_dumps_pts AS
  --  SELECT
      --  tmc,
      --  (multiline_dump).path AS path_num,
      --  ST_StartPoint((multiline_dump).geom) AS start_pt,
      --  ST_EndPoint((multiline_dump).geom) AS end_pt
    --  FROM spike_geo_dumps
  --  ;

--  COMMIT;


--  BEGIN;

--  DROP TABLE IF EXISTS spike_buffered_geo_dumps_pts;
--  CREATE TABLE IF NOT EXISTS spike_buffered_geo_dumps_pts AS
  --  SELECT
      --  tmc,
      --  path_num,
      --  ST_Buffer(
        --  Geography(start_pt),
        --  buffer_sz
      --  ) AS buffered_geography_start_pt,
      --  ST_Buffer(
        --  Geography(end_pt),
        --  buffer_sz
      --  ) AS buffered_geography_end_pt,
      --  buffer_sz
    --  FROM spike_geo_dumps_pts
      --  CROSS JOIN generate_series(0, 9, 3) AS t(buffer_sz)
  --  ;

--  DROP INDEX IF EXISTS spike_buffered_geo_dumps_start_pts_idx;
--  CREATE INDEX IF NOT EXISTS spike_buffered_geo_dumps_start_pts_idx
  --  ON spike_buffered_geo_dumps_pts
  --  USING Gist (buffered_geography_start_pt);

--  DROP INDEX IF EXISTS spike_buffered_geo_dumps_end_pts_idx;
--  CREATE INDEX IF NOT EXISTS spike_buffered_geo_dumps_end_pts_idx
  --  ON spike_buffered_geo_dumps_pts
  --  USING Gist (buffered_geography_end_pt);


--  COMMIT;

--  BEGIN;

--  DROP TABLE IF EXISTS spike_buffered_geo_dumps_pts;
--  CREATE TABLE IF NOT EXISTS spike_buffered_geo_dumps_pts AS
  --  SELECT
      --  tmc,
      --  path_num,
      --  ST_Buffer(
        --  Geography(start_pt),
        --  buffer_sz
      --  ) AS buffered_geography_start_pt,
      --  ST_Buffer(
        --  Geography(end_pt),
        --  buffer_sz
      --  ) AS buffered_geography_end_pt,
      --  buffer_sz
    --  FROM spike_geo_dumps_pts
      --  CROSS JOIN generate_series(0, 9, 3) AS t(buffer_sz)
  --  ;

--  COMMIT;


--  BEGIN;

--  -- -- https://boundlessgeo.com/2011/09/indexed-nearest-neighbour-search-in-postgis/

--  DROP TABLE IF EXISTS spike_nearest_neighbors;
--  CREATE TABLE IF NOT EXISTS spike_nearest_neighbors AS
  --  SELECT *
    --  FROM (
      --  SELECT
          --  this.tmc AS tmc,
          --  this.path_num AS this_path_num,
          --  this.start_pt AS this_pt,
          --  this_attrs.avg_speedlimit AS this_avg_speedlimit,
          --  other.tmc AS neighbor_tmc,
          --  other.path_num AS neighbor_path_num,
          --  other.end_pt AS neighbor_pt,
          --  other_attrs.avg_speedlimit AS neighbor_avg_speedlimit,
          --  'START' AS neighbor_type,
          --  (this.end_pt <-> other.start_pt) AS dist,
          --  RANK() OVER (
            --  PARTITION BY this.tmc, this.path_num
            --  ORDER BY (this.start_pt <-> other.end_pt)
          --  ) AS rank
        --  FROM spike_known_speedlimit_tmcs_sample
          --  INNER JOIN spike_geo_dumps_pts AS this USING (tmc)
          --  INNER JOIN tmc_attributes AS this_attrs USING (tmc)
          --  CROSS JOIN spike_geo_dumps_pts AS other
          --  INNER JOIN tmc_attributes AS other_attrs ON (other.tmc = other_attrs.tmc)
        --  WHERE (
          --  NOT (
            --  (this.tmc = other.tmc)
            --  AND
            --  (this.path_num = other.path_num)
          --  )
          --  AND (ABS(this_attrs.f_system - other_attrs.f_system) <= 1)
          --  --  AND (other_attrs.avg_speedlimit IS NOT NULL)
          --  AND ((this.end_pt <-> other.start_pt) <= 0.25)
        --  )

      --  UNION

      --  SELECT
          --  this.tmc AS tmc,
          --  this.path_num AS this_path_num,
          --  this.end_pt AS this_pt,
          --  this_attrs.avg_speedlimit AS this_avg_speedlimit,
          --  other.tmc AS neighbor_tmc,
          --  other.path_num AS neighbor_path_num,
          --  other.start_pt AS neighbor_pt,
          --  other_attrs.avg_speedlimit AS neighbor_avg_speedlimit,
          --  'END' AS neighbor_type,
          --  (this.end_pt <-> other.start_pt) AS dist,
          --  RANK() OVER (
            --  PARTITION BY this.tmc, this.path_num
            --  ORDER BY (this.end_pt <-> other.start_pt)
          --  ) AS rank
        --  FROM spike_known_speedlimit_tmcs_sample
          --  INNER JOIN spike_geo_dumps_pts AS this USING (tmc)
          --  INNER JOIN tmc_attributes AS this_attrs USING (tmc)
          --  CROSS JOIN spike_geo_dumps_pts AS other
          --  INNER JOIN tmc_attributes AS other_attrs ON (other.tmc = other_attrs.tmc)
        --  WHERE (
          --  NOT (
            --  (this.tmc = other.tmc)
            --  AND
            --  (this.path_num = other.path_num)
          --  )
          --  AND (ABS(this_attrs.f_system - other_attrs.f_system) <= 1)
          --  --  AND (other_attrs.avg_speedlimit IS NOT NULL)
          --  AND ((this.end_pt <-> other.start_pt) <= 0.25)
        --  )
    --  ) AS sub_neighbors
    --  WHERE rank <= 5
--  ;

--  COMMIT;


--  BEGIN;

--  DROP TABLE IF EXISTS spike_line_overlaps;
--  CREATE TABLE IF NOT EXISTS spike_line_overlaps AS
  --  SELECT *
    --  FROM (
      --  SELECT
          --  this_attrs.tmc AS tmc,
          --  this_attrs.avg_speedlimit AS this_avg_speedlimit,
          --  other_attrs.tmc AS neighbor_tmc,
          --  other_attrs.avg_speedlimit AS neighbor_avg_speedlimit,
          --  ST_Area(
            --  ST_Intersection(
              --  ST_envelope(this_shp.wkb_geometry),
              --  ST_envelope(other_shp.wkb_geometry)
            --  )
          --  ) AS area,
          --  RANK() OVER (
            --  PARTITION BY this_attrs.tmc
            --  ORDER BY ST_Area(
              --  ST_Intersection(
                --  ST_envelope(this_shp.wkb_geometry),
                --  ST_envelope(other_shp.wkb_geometry)
              --  )
            --  )
          --  ) AS rank
        --  FROM spike_known_speedlimit_tmcs_sample
          --  INNER JOIN tmc_attributes AS this_attrs USING (tmc)
          --  INNER JOIN inrix_shapefile AS this_shp USING (tmc)
          --  CROSS JOIN tmc_attributes AS other_attrs
          --  INNER JOIN inrix_shapefile AS other_shp ON (other_attrs.tmc = other_shp.tmc)
        --  WHERE (
          --  (this_attrs.tmc <> other_attrs.tmc)
          --  AND (ABS(this_attrs.f_system - other_attrs.f_system) <= 0)
          --  AND (other_attrs.avg_speedlimit IS NOT NULL)
          --  AND (this_shp.wkb_geometry && other_shp.wkb_geometry)
        --  )
    --  ) AS t
    --  WHERE rank <= 5
--  ;

--  COMMIT;



--  --  BEGIN;

--  DROP TABLE IF EXISTS spike_backfilled_speedlimts_nn;
--  CREATE TABLE IF NOT EXISTS spike_backfilled_speedlimts_nn AS
  --  SELECT
      --  tmc,
      --  this_avg_speedlimit,
      --  AVG(neighbor_avg_speedlimit)
    --  FROM spike_nearest_neighbors
    --  WHERE (rank = 1)
    --  GROUP BY tmc, this_avg_speedlimit
--  ;

--  COMMIT;



--  BEGIN;

--  DROP TABLE IF EXISTS spike_backfilled_speedlimts_bb;
--  CREATE TABLE IF NOT EXISTS spike_backfilled_speedlimts_bb AS
  --  SELECT
      --  tmc,
      --  this_avg_speedlimit,
      --  AVG(neighbor_avg_speedlimit)
    --  FROM spike_line_overlaps
    --  WHERE (rank = 1)
    --  GROUP BY tmc, this_avg_speedlimit
--  ;

--  COMMIT;

--  BEGIN;

--  DROP TABLE IF EXISTS spike_backfilled_speedlimts_qa;
--  CREATE TABLE IF NOT EXISTS spike_backfilled_speedlimts_qa AS
  --  SELECT
      --  spike_nearest_neighbors.*,
      --  this_shp.wkb_geometry AS this_shp,
      --  other_shp.wkb_geometry AS other_shp
    --  FROM spike_nearest_neighbors
      --  INNER JOIN inrix_shapefile AS this_shp USING (tmc)
      --  INNER JOIN inrix_shapefile AS other_shp ON (neighbor_tmc = other_shp.tmc)
--  ;

--  COMMIT;


BEGIN;

DROP TABLE IF EXISTS spike_pt_dumps;
CREATE TABLE IF NOT EXISTS spike_pt_dumps AS
  SELECT
      tmc,
      (ST_DumpPoints(wkb_geometry)).geom AS pt
    FROM inrix_shapefile
  ;

DROP INDEX IF EXISTS spike_pt_dumps_idx;
CREATE INDEX IF NOT EXISTS spike_pt_dumps_idx
  ON spike_pt_dumps
  USING Gist (pt);


CLUSTER spike_pt_dumps USING spike_pt_dumps_idx;

COMMIT;

BEGIN;

-- -- https://boundlessgeo.com/2011/09/indexed-nearest-neighbour-search-in-postgis/

DROP TABLE IF EXISTS spike_nearest_neighbors_2;
CREATE TABLE IF NOT EXISTS spike_nearest_neighbors_2 AS
  SELECT *
    FROM (
      SELECT
          this.tmc AS tmc,
          this.pt AS this_pt,
          this_attrs.avg_speedlimit AS this_avg_speedlimit,
          other.tmc AS neighbor_tmc,
          other.pt AS neighbor_pt,
          other_attrs.avg_speedlimit AS neighbor_avg_speedlimit,
          (this.pt <-> other.pt) AS dist,
          RANK() OVER (
            PARTITION BY this.tmc
            ORDER BY (this.pt <-> other.pt)
          ) AS rank
        FROM spike_known_speedlimit_tmcs_sample
          INNER JOIN spike_pt_dumps AS this USING (tmc)
          INNER JOIN tmc_attributes AS this_attrs USING (tmc)
          CROSS JOIN spike_pt_dumps AS other
          INNER JOIN tmc_attributes AS other_attrs ON (other.tmc = other_attrs.tmc)
        WHERE (
          (this.tmc <> other.tmc)
          AND ((this_attrs.f_system - other_attrs.f_system) = 0)
          --  AND (other_attrs.avg_speedlimit IS NOT NULL)
          AND ((this.pt <-> other.pt) <= 0.1)
        )
    ) AS sub_neighbors
    WHERE rank = 1
;

COMMIT;
