--  BEGIN;

--  DROP TABLE IF EXISTS spike_null_speedlimt_tmcs;
--  CREATE TABLE IF NOT EXISTS spike_null_speedlimt_tmcs AS
  --  SELECT tmc
    --  FROM ny.tmc_attributes
    --  WHERE (avg_speedlimit IS NULL)
--  ;

--  COMMIT;


BEGIN;

DROP TABLE IF EXISTS spike_know_speedlimit_tmcs_sample;
CREATE TABLE IF NOT EXISTS spike_know_speedlimit_tmcs_sample AS
  SELECT tmc
    FROM ny.tmc_attributes
    WHERE (avg_speedlimit IS NOT NULL)
    ORDER BY RANDOM()
    LIMIT 1000
;

COMMIT;


BEGIN;

DROP TABLE IF EXISTS spike_buffered_linestrings;
CREATE TABLE IF NOT EXISTS spike_buffered_linestrings AS
  SELECT DISTINCT
      tmc,
      ST_Buffer(Geography(wkb_geometry), 12) AS line_buff,
      f_system
    FROM inrix_shapefile
;


CREATE INDEX IF NOT EXISTS spike_endpt_geographies_gix ON spike_buffered_linestrings USING GIST (line_buff);

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
              t.tmc AS tmc,
              a.tmc AS adj_tmc,
              (
                LEAST(
                  (
                    levenshtein(
                      overlay(t.tmc placing 'X' from 4 for 1),
                      overlay(a.tmc placing 'X' from 4 for 1)
                    )
                  ),
                  5
                ) +
                (2 * ABS(t.f_system - a.f_system)) -
                GREATEST(
                  ST_Length(ST_Intersection(t.line_buff, a.line_buff)),
                  25
                )
              ) AS dist
            FROM spike_buffered_linestrings AS t
              INNER JOIN spike_buffered_linestrings AS a ON (t.line_buff && a.line_buff)
            WHERE (
              (t.tmc <> a.tmc)
              AND
              (t.tmc IN (SELECT tmc FROM spike_know_speedlimit_tmcs_sample))
              AND
              (a.tmc NOT IN (SELECT tmc FROM spike_know_speedlimit_tmcs_sample))
              AND
              (a.tmc NOT IN (SELECT tmc FROM spike_null_speedlimt_tmcs))
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
    avg(ABS(tmc_avg_speedlimt - adj_speedlimit)) AS avg_diff,
    percentile_disc(array[0, 0.25, 0.5, 0.75, 0.8, 0.9, 0.95, 1]) WITHIN GROUP (ORDER BY ABS(tmc_avg_speedlimt - adj_speedlimit)) AS diff_dist
  FROM spike_backfilled_speedlimts
;
