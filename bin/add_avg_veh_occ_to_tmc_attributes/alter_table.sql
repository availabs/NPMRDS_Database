-- https://www.fhwa.dot.gov/policyinformation/tmguide/tmg_2013/hpms-requirements.cfm

BEGIN;

ALTER TABLE tmc_attributes
  ADD COLUMN IF NOT EXISTS avg_vehicle_occupancy REAL;

UPDATE tmc_attributes SET avg_vehicle_occupancy =
    (
        (1.55 * (aadt - (aadt_singl + aadt_combi))) -- cars
      + (10.25 * aadt_singl) -- buses
      + (1.11 * aadt_combi) -- combination trucks
    ) / aadt
; 

COMMIT;
