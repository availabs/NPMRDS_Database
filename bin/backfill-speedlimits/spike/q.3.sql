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
    LIMIT 100
;

COMMIT;


BEGIN;

DROP TABLE IF EXISTS spike_buffered_linestrings;
CREATE TABLE IF NOT EXISTS spike_buffered_linestrings AS
  SELECT DISTINCT
      tmc,
      ST_Buffer(Geography(wkb_geometry), 10) AS geography_line_buff,
      f_system
    FROM inrix_shapefile
;


CREATE INDEX IF NOT EXISTS spike_endpt_geographies_gix ON spike_buffered_linestrings USING GIST (geography_line_buff);

COMMIT;


BEGIN;

DROP TABLE IF EXISTS spike_backfill_factors;
CREATE TABLE IF NOT EXISTS spike_backfill_factors AS
  SELECT
      t.tmc AS tmc,
      a.tmc AS adj_tmc,
      ABS(
        CAST(overlay(t.tmc placing '0' from 4 for 1) AS BIGINT) -
        CAST(overlay(a.tmc placing '0' from 4 for 1) AS BIGINT)
      ) AS tmc_id_diff,
      ABS(t.f_system - a.f_system) AS f_system_diff,
      ST_Length(ST_Intersection(t.geography_line_buff, a.geography_line_buff)) AS overlap_length
    FROM spike_buffered_linestrings AS t
      INNER JOIN spike_buffered_linestrings AS a ON (t.geography_line_buff && a.geography_line_buff)
    WHERE (
      (t.tmc <> a.tmc)
      AND
      (t.tmc IN (SELECT tmc FROM spike_know_speedlimit_tmcs_sample))
      AND
      (a.tmc NOT IN (SELECT tmc FROM spike_know_speedlimit_tmcs_sample))
      AND
      (a.tmc NOT IN (SELECT tmc FROM spike_null_speedlimt_tmcs))
    )
;

DROP TABLE IF EXISTS spike_backfilled_speedlimts;
CREATE TABLE spike_backfilled_speedlimts
  AS
    SELECT 
        s.*,
        a.avg_speedlimit tmc_avg_speedlimt,
        b.avg_speedlimit AS adj_avg_speedlimit
      FROM spike_backfill_factors s
        INNER JOIN tmc_attributes AS a USING (tmc)
        INNER JOIN tmc_attributes AS b ON (b.tmc = s.adj_tmc)
 ; 

--  SELECT
    --  avg(ABS(tmc_avg_speedlimt - adj_avg_speedlimit)) AS avg_diff,
    --  percentile_disc(array[0, 0.25, 0.5, 0.75, 0.8, 0.9, 0.95, 1]) WITHIN GROUP (ORDER BY ABS(tmc_avg_speedlimt - adj_speedlimit)) AS diff_dist
  --  FROM spike_backfilled_speedlimts
--  ;
