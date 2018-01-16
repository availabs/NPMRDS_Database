BEGIN;

UPDATE nj.tmc_attributes attr
  SET (avg_speedlimit) = (
    SELECT avg_speedlimit
      FROM nj.avg_speedlimits spd
    WHERE (attr.tmc = spd.tmc)
  )
;

COMMIT;

CLUSTER nj.tmc_attributes USING tmc_attributes_pkey;

ANALYZE VERBOSE nj.tmc_attributes;
