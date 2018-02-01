--  BEGIN;

--  DROP TABLE IF EXISTS spike_null_speedlimt_tmcs;
--  CREATE TABLE IF NOT EXISTS spike_null_speedlimt_tmcs AS
  --  SELECT tmc
    --  FROM ny.tmc_attributes
    --  WHERE (avg_speedlimit IS NULL)
--  ;

--  COMMIT;


--  BEGIN;

--  DROP TABLE IF EXISTS spike_known_speedlimit_tmcs_sample;
--  CREATE TABLE IF NOT EXISTS spike_known_speedlimit_tmcs_sample AS
  --  SELECT tmc
    --  FROM ny.tmc_attributes
    --  WHERE (avg_speedlimit IS NOT NULL)
    --  ORDER BY RANDOM()
    --  LIMIT 250
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


BEGIN;
-- -- https://boundlessgeo.com/2011/09/indexed-nearest-neighbour-search-in-postgis/

DROP TABLE IF EXISTS spike_nearest_neighbors;
CREATE TABLE IF NOT EXISTS spike_nearest_neighbors AS
  SELECT *
    FROM (
      SELECT
          this.tmc AS tmc,
          this.path_num AS this_path_num,
          this.start_pt AS this_pt,
          this_attrs.avg_speedlimit AS this_avg_speedlimit,
          other.tmc AS neighbor_tmc,
          other.path_num AS neighbor_path_num,
          other.end_pt AS neighbor_pt,
          other_attrs.avg_speedlimit AS neighbor_avg_speedlimit,
          'START' AS neighbor_type,
          (this.end_pt <-> other.start_pt) AS dist,
          RANK() OVER (
            PARTITION BY this.tmc, this.path_num
            ORDER BY (
              LEAST(
                (
                  -- how similar are the TMC ids?
                  levenshtein(
                    overlay(this.tmc placing 'X' from 4 for 1),
                    overlay(other.tmc placing 'X' from 4 for 1)
                  )
                ),
                5 -- cap diff at 5
              ) +
              -- Distance [0, 25]
              (50 * (this.start_pt <-> other.end_pt)) +
              -- Weight of road type weight [0, 5]
              (5 * ABS(this_attrs.f_system - other_attrs.f_system))
            )
          ) AS rank
        FROM spike_known_speedlimit_tmcs_sample
          INNER JOIN spike_geo_dumps_pts AS this USING (tmc)
          INNER JOIN tmc_attributes AS this_attrs USING (tmc)
          CROSS JOIN spike_geo_dumps_pts AS other
          INNER JOIN tmc_attributes AS other_attrs ON (other.tmc = other_attrs.tmc)
        WHERE (
          NOT (
            (this.tmc = other.tmc)
            AND
            (this.path_num = other.path_num)
          )
          AND (ABS(this_attrs.f_system - other_attrs.f_system) <= 2)
          --  AND (other_attrs.avg_speedlimit IS NOT NULL)
          AND ((this.end_pt <-> other.start_pt) <= 0.25)
        )

      UNION

      SELECT
          this.tmc AS tmc,
          this.path_num AS this_path_num,
          this.end_pt AS this_pt,
          this_attrs.avg_speedlimit AS this_avg_speedlimit,
          other.tmc AS neighbor_tmc,
          other.path_num AS neighbor_path_num,
          other.start_pt AS neighbor_pt,
          other_attrs.avg_speedlimit AS neighbor_avg_speedlimit,
          'END' AS neighbor_type,
          (this.end_pt <-> other.start_pt) AS dist,
          RANK() OVER (
            PARTITION BY this.tmc, this.path_num
            ORDER BY (
              LEAST(
                (
                  -- how similar are the TMC ids?
                  levenshtein(
                    overlay(this.tmc placing 'X' from 4 for 1),
                    overlay(other.tmc placing 'X' from 4 for 1)
                  )
                ),
                5 -- cap diff at 5
              ) +
              -- Distance [0, 25]
              (50 * (this.start_pt <-> other.end_pt)) +
              -- Weight of road type weight [0, 5]
              (5 * ABS(this_attrs.f_system - other_attrs.f_system))
            )
          ) AS rank
        FROM spike_known_speedlimit_tmcs_sample
          INNER JOIN spike_geo_dumps_pts AS this USING (tmc)
          INNER JOIN tmc_attributes AS this_attrs USING (tmc)
          CROSS JOIN spike_geo_dumps_pts AS other
          INNER JOIN tmc_attributes AS other_attrs ON (other.tmc = other_attrs.tmc)
        WHERE (
          NOT (
            (this.tmc = other.tmc)
            AND
            (this.path_num = other.path_num)
          )
          AND (ABS(this_attrs.f_system - other_attrs.f_system) <= 2)
          --  AND (other_attrs.avg_speedlimit IS NOT NULL)
          AND ((this.end_pt <-> other.start_pt) <= 0.25)
        )
    ) AS sub_neighbors
    WHERE rank = 1
;

COMMIT;


BEGIN;

DROP TABLE IF EXISTS spike_backfilled_speedlimts;
CREATE TABLE IF NOT EXISTS spike_backfilled_speedlimts AS
  SELECT
      tmc,
      this_avg_speedlimit,
      AVG(neighbor_avg_speedlimit) AS neighbours_avg_speedlimt
    FROM spike_nearest_neighbors
    WHERE (rank = 1)
    GROUP BY tmc, this_avg_speedlimit
;

COMMIT;


SELECT
    ROUND(
      AVG(avg_speedlimit)::NUMERIC,
      3
    ) AS avg,
    ROUND(
      MIN(avg_speedlimit)::NUMERIC,
      3
    ) AS min,
    ROUND(
      percentile_disc(0.25) WITHIN GROUP (ORDER BY avg_speedlimit)::NUMERIC,
      3
    ) AS "25th_pctl",
    ROUND(
      percentile_disc(0.50) WITHIN GROUP (ORDER BY avg_speedlimit)::NUMERIC,
      3
    ) AS "50th_pctl",
    ROUND(
      percentile_disc(0.75) WITHIN GROUP (ORDER BY avg_speedlimit)::NUMERIC,
      3
    ) AS "75th_pctl",
    ROUND(
      percentile_disc(0.80) WITHIN GROUP (ORDER BY avg_speedlimit)::NUMERIC,
      3
    ) AS "80th_pctl",
    ROUND(
      percentile_disc(0.90) WITHIN GROUP (ORDER BY avg_speedlimit)::NUMERIC,
      3
    ) AS "90th_pctl",
    ROUND(
      percentile_disc(0.95) WITHIN GROUP (ORDER BY avg_speedlimit)::NUMERIC,
      3
    ) AS "95th_pctl",
    ROUND(
      MAX(avg_speedlimit)::NUMERIC,
      3
    ) AS max
  FROM (
    SELECT 
        ABS(this_avg_speedlimit - neighbours_avg_speedlimt) AS avg_speedlimit
      FROM spike_backfilled_speedlimts
  ) AS t
;
