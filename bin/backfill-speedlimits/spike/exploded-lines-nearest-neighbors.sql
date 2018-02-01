BEGIN;

DROP TABLE IF EXISTS spike_null_speedlimt_tmcs;
CREATE TABLE IF NOT EXISTS spike_null_speedlimt_tmcs AS
  SELECT tmc
    FROM ny.tmc_attributes
    WHERE (avg_speedlimit IS NULL)
;

COMMIT;


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

BEGIN;

DROP TABLE IF EXISTS spike_pt_dumps;
CREATE TABLE IF NOT EXISTS spike_pt_dumps AS
  SELECT
      tmc,
      (ST_DumpPoints(wkb_geometry)).geom AS pt
    FROM inrix_shapefile
  ;

DROP INDEX IF EXISTS spike_pt_dumps_idx;
CREATE INDEX IF NOT EXISTS spike_pt_dumps_idx ON spike_pt_dumps USING Gist (pt);

CLUSTER spike_pt_dumps USING spike_pt_dumps_idx;

COMMIT;

BEGIN;
-- -- https://boundlessgeo.com/2011/09/indexed-nearest-neighbour-search-in-postgis/

DROP TABLE IF EXISTS spike_nearest_neighbors;
CREATE TABLE IF NOT EXISTS spike_nearest_neighbors AS
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
          AND (other_attrs.avg_speedlimit IS NOT NULL)
          AND ((this.pt <-> other.pt) <= 0.1)
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
