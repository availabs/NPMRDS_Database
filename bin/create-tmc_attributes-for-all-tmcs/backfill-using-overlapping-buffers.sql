-- Based on suggestion by @dvad
-- Uses the following 3 critera to match TMCs for backfilling speedlimits:
--   a) overlapping buffers of line strings
--   b) levenshtein distance
--   c) federal highway class

BEGIN;

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

DROP TABLE IF EXISTS tmp_backfilled_avg_speedlimit_tmcs;
DROP TABLE IF EXISTS tmp_buffered_linestrings;
DROP TABLE IF EXISTS tmp_other_tmcs;
DROP TABLE IF EXISTS tmp_backfill_pairings;
DROP TABLE IF EXISTS tmp_backfill_speedlimits;

DELETE FROM "__STATE__".avg_speedlimits
	WHERE (
		(avg_speedlimit = 0)
		OR
		(avg_speedlimit IS NULL)
	)
;

CREATE TEMPORARY TABLE tmp_backfilled_avg_speedlimit_tmcs AS
  SELECT tmc
    FROM inrix_shapefile AS t1
      INNER JOIN state_abbreviations AS t2
        ON (t1.state = t2.state_name)
    WHERE (
      (tmc NOT IN (SELECT tmc FROM "__STATE__".avg_speedlimits))
      AND
      (abbreviation = '__STATE__')
    )
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
              (this.tmc IN (SELECT tmc FROM tmp_backfilled_avg_speedlimit_tmcs))
              AND
              -- other TMC has a known speedlimit
              (other.tmc NOT IN (SELECT tmc FROM tmp_backfilled_avg_speedlimit_tmcs))
            )
          ) AS sub_adjacents
    ) AS sub_ranked
    WHERE (sub_ranked.rank = 1)
;

CREATE TABLE tmp_backfill_pairings
  AS
    SELECT 
        a.tmc,
        b.avg_speedlimit AS other_speedlimit
      FROM tmp_other_tmcs a
        INNER JOIN avg_speedlimits AS b ON (b.tmc = a.other_tmc)
; 

CREATE TABLE tmp_backfill_speedlimits
  AS
    SELECT 
        tmc,
        AVG(other_speedlimit) AS avg_speedlimit
      FROM tmp_backfill_pairings
      GROUP BY tmc
; 


INSERT INTO "__STATE__".avg_speedlimits (state, tmc, avg_speedlimit)
	SELECT
			'__STATE__',
			tmp_backfill_speedlimits.tmc,
			tmp_backfill_speedlimits.avg_speedlimit
		FROM tmp_backfill_speedlimits
;

DROP TABLE IF EXISTS tmp_backfilled_avg_speedlimit_tmcs;
DROP TABLE IF EXISTS tmp_buffered_linestrings;
DROP TABLE IF EXISTS tmp_other_tmcs;
DROP TABLE IF EXISTS tmp_backfill_pairings;
DROP TABLE IF EXISTS tmp_backfill_speedlimits;

COMMIT;
