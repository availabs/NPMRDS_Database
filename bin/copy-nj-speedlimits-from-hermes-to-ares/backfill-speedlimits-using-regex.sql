BEGIN;

INSERT INTO nj.avg_speedlimits (tmc, avg_speedlimit)
  SELECT attr.tmc, spd.avg_speedlimit
    FROM nj.tmc_attributes attr
      INNER JOIN nj.avg_speedlimits spd
      ON (
        regexp_replace(regexp_replace(attr.tmc, '-', 'N'), '\+', 'P') = spd.tmc
      )
    WHERE (
      (attr.tmc LIKE '%-%')
      OR
      (attr.tmc LIKE '%+%')
    )
;

DELETE FROM nj.avg_speedlimits
  WHERE tmc NOT IN (
    SELECT tmc FROM nj.tmc_attributes
  )
;

UPDATE nj.avg_speedlimits SET state = 'nj';

COMMIT;

CLUSTER nj.avg_speedlimits USING avg_speedlimits_pkey;

ANALYZE VERBOSE nj.avg_speedlimits;
