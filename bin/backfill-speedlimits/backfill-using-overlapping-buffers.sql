-- Based on suggestion by @dvad
-- Uses the following 3 critera to match TMCs for backfilling speedlimits:
--   a) overlapping buffers of line strings
--   b) levenshtein distance
--   c) federal highway class

BEGIN;

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

DROP TABLE IF EXISTS backfilled_avg_speedlimit_tmcs;
DROP TABLE IF EXISTS tmp_buffered_linestrings;
DROP TABLE IF EXISTS tmp_other_tmcs;
DROP TABLE IF EXISTS tmp_backfill_pairings;
DROP TABLE IF EXISTS tmp_backfill_speedlimits;

CREATE TABLE IF NOT EXISTS backfilled_avg_speedlimit_tmcs AS
  SELECT tmc
    FROM tmc_attributes
    WHERE (NULLIF(avg_speedlimit, 0) IS NULL)
;

-- get create a 12 meter buffer around all TMCs' shapes
CREATE TABLE IF NOT EXISTS tmp_buffered_linestrings AS
  SELECT DISTINCT
      tmc,
      ST_Buffer(Geography(wkb_geometry), 12) AS line_buff,
      f_system
    FROM inrix_shapefile
;

CREATE INDEX IF NOT EXISTS tmp_buffered_linestrings_gix
  ON tmp_buffered_linestrings USING GIST (line_buff);

CREATE TABLE IF NOT EXISTS tmp_other_tmcs AS
  SELECT
      tmc,
      other_tmc,
      rank,
      dist
    FROM (
      SELECT
          tmc,
          other_tmc,
          RANK() OVER (
            PARTITION BY tmc ORDER BY dist
          ) AS rank,
          dist
        FROM (
          SELECT
              this.tmc AS tmc,
              other.tmc AS other_tmc,
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
            FROM tmp_buffered_linestrings AS this
              INNER JOIN tmp_buffered_linestrings AS other ON (this.line_buff && other.line_buff)
            WHERE (
              -- not same TMC
              (this.tmc <> other.tmc) 
              AND
              -- this TMC needing speedlimit
              (this.tmc IN (SELECT tmc FROM backfilled_avg_speedlimit_tmcs))
              AND
              -- other TMC has a known speedlimit
              (other.tmc NOT IN (SELECT tmc FROM backfilled_avg_speedlimit_tmcs))
            )
          ) AS sub_adjacents
    ) AS sub_ranked
    WHERE (sub_ranked.rank = 1)
;

CREATE TABLE tmp_backfill_pairings
  AS
    SELECT 
        a.tmc,
        b.tmc AS other_tmc,
        a.avg_speedlimit tmc_avg_speedlimt,
        b.avg_speedlimit AS other_speedlimit
      FROM tmp_other_tmcs s
        INNER JOIN tmc_attributes AS a USING (tmc)
        INNER JOIN tmc_attributes AS b ON (b.tmc = s.other_tmc)
; 

CREATE TABLE tmp_backfill_speedlimits
  AS
    SELECT 
        tmc,
        AVG(other_speedlimit) AS avg_speedlimit
      FROM tmp_backfill_pairings
      GROUP BY tmc
; 


UPDATE tmc_attributes
  SET (avg_speedlimit) = (
    SELECT
        tmp_backfill_speedlimits.avg_speedlimit
      FROM tmp_backfill_speedlimits
      WHERE (
        (tmc_attributes.tmc = tmp_backfill_speedlimits.tmc)
      )
  )
  WHERE (tmc_attributes.avg_speedlimit IS NULL)
;

--  DROP TABLE IF EXISTS backfilled_avg_speedlimit_tmcs; --keep around
DROP TABLE IF EXISTS tmp_buffered_linestrings;
DROP TABLE IF EXISTS tmp_other_tmcs;
DROP TABLE IF EXISTS tmp_backfill_pairings;
DROP TABLE IF EXISTS tmp_backfill_speedlimits;

COMMIT;
