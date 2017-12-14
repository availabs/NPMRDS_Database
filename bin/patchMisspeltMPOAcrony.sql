BEGIN;

ALTER TABLE us.mpo_acronymns
 RENAME TO mpo_acronyms;

UPDATE us.mpo_acronyms
 SET mpo_acrony = 'A/GFTC'
   WHERE mpo_acrony = 'A-GFTC'
;

REFRESH MATERIALIZED VIEW tmc_attributes;

UPDATE top_level_travel_time_reliability
  SET geography_name = 'A/GFTC'
    WHERE geography_name = 'A-GFTC'
;

UPDATE top_level_freight_reliability
  SET geography_name = 'A/GFTC'
    WHERE geography_name = 'A-GFTC'
;

UPDATE top_level_total_excessive_delay
  SET geography_name = 'A/GFTC'
    WHERE geography_name = 'A-GFTC'
;

COMMIT;
