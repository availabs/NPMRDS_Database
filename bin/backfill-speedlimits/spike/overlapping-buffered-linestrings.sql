-- Based on suggestion by @dvad
-- Uses the following 3 critera to match TMCs for backfilling speedlimits:
--   a) overlapping buffers of line strings
--   b) levenshtein distance
--   c) federal highway class

BEGIN;

DROP TABLE IF EXISTS spike_null_speedlimt_tmcs;
CREATE TABLE IF NOT EXISTS spike_null_speedlimt_tmcs AS
  SELECT tmc
    FROM ny.tmc_attributes
    WHERE (avg_speedlimit IS NULL)
;

COMMIT;

-- get a sample of 1000 TMCs with known speedlimits
BEGIN;

DROP TABLE IF EXISTS spike_known_speedlimit_tmcs_sample;
CREATE TABLE IF NOT EXISTS spike_known_speedlimit_tmcs_sample AS
  SELECT tmc
    FROM ny.tmc_attributes
    WHERE (avg_speedlimit IS NOT NULL)
    ORDER BY RANDOM()
    LIMIT 1000
;

COMMIT;

-- get create a 12 meter buffer around all TMCs' shapes
BEGIN;

DROP TABLE IF EXISTS spike_buffered_linestrings;
CREATE TABLE IF NOT EXISTS spike_buffered_linestrings AS
  SELECT DISTINCT
      tmc,
      ST_Buffer(Geography(wkb_geometry), 12) AS line_buff,
      f_system
    FROM inrix_shapefile
;


CREATE INDEX IF NOT EXISTS spike_endpt_geographies_gix
  ON spike_buffered_linestrings USING GIST (line_buff);

COMMIT;

BEGIN;

DROP TABLE IF EXISTS spike_adj_tmcs;
CREATE TABLE IF NOT EXISTS spike_adj_tmcs AS
  SELECT
      tmc,
      adj_tmc,
      rank,
      dist
    FROM (
      SELECT
          tmc,
          adj_tmc,
          RANK() OVER (
            PARTITION BY tmc ORDER BY dist
          ) AS rank,
          dist
        FROM (
          SELECT
              this.tmc AS tmc,
              other.tmc AS adj_tmc,
              (
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
                -- penalty for difference in FHWS road type
                (2 * ABS(this.f_system - other.f_system)) -
                GREATEST(
                  -- how long is the intersection of the buffered line strings?
                  ST_Length(ST_Intersection(this.line_buff, other.line_buff)),
                  25 -- cap at 25 meters
                )
              ) AS dist
            -- Join the buffered TMC shapes table with itself on bounding box intersection
            FROM spike_buffered_linestrings AS this
              INNER JOIN spike_buffered_linestrings AS other ON (this.line_buff && other.line_buff)
            WHERE (
              (this.tmc <> other.tmc) -- not same TMC
              AND
              -- this TMC is in sample
              (this.tmc IN (SELECT tmc FROM spike_known_speedlimit_tmcs_sample))
              AND
              -- other TMC not in sample
              (other.tmc NOT IN (SELECT tmc FROM spike_known_speedlimit_tmcs_sample))
              AND
              -- other TMC has known speedlimit
              (other.tmc NOT IN (SELECT tmc FROM spike_null_speedlimt_tmcs))
            )
          ) AS sub_adjacents
    ) AS sub_ranked
    WHERE (sub_ranked.rank = 1)
;

COMMIT;


DROP TABLE IF EXISTS spike_backfilled_speedlimts;
CREATE TABLE spike_backfilled_speedlimts
  AS
    SELECT 
        a.tmc,
        b.tmc AS adj_tmc,
        a.avg_speedlimit tmc_avg_speedlimt,
        b.avg_speedlimit AS adj_speedlimit
      FROM spike_adj_tmcs s
        INNER JOIN tmc_attributes AS a USING (tmc)
        INNER JOIN tmc_attributes AS b ON (b.tmc = s.adj_tmc)
 ; 

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
        ABS(tmc_avg_speedlimt - adj_speedlimit) AS avg_speedlimit
      FROM spike_backfilled_speedlimts
  ) AS t
;
