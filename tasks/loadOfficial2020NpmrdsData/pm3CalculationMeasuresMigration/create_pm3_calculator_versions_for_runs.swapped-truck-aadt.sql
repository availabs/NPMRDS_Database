-- SELECT
--     *
--   FROM pm3._admin_pm3_calculator_metadata_view
--   WHERE ( timestamp BETWEEN '20210504T113817' and '20210504T175239' )
--   ORDER BY 2
-- ;

--  id  |    timestamp    | states | year |                                     measures
-- -----+-----------------+--------+------+-----------------------------------------------------------------------------------
--  522 | 20210504T113817 | ["ny"] | 2020 | ["LOTTR", "TTTR", "PHED"]
--  523 | 20210504T113818 | ["ny"] | 2020 | ["PHED_RIS", "PHED_FREEFLOW_RIS", "TED_RIS", "TED_FREEFLOW_RIS", "EMISSIONS_RIS"]
--  524 | 20210504T113819 | ["ny"] | 2020 | ["PHED", "PHED_FREEFLOW", "TED", "TED_FREEFLOW", "EMISSIONS"]
--  525 | 20210504T113820 | ["ny"] | 2020 | ["PTI", "TTI", "PERCENT_BINS_REPORTING", "SPEED_PERCENTILES", "FREEFLOW"]
--  526 | 20210504T175237 | ["nj"] | 2020 | ["LOTTR", "TTTR", "PHED"]
--  527 | 20210504T175238 | ["nj"] | 2020 | ["PHED", "PHED_FREEFLOW", "TED", "TED_FREEFLOW", "EMISSIONS"]
--  528 | 20210504T175239 | ["nj"] | 2020 | ["PTI", "TTI", "PERCENT_BINS_REPORTING", "SPEED_PERCENTILES", "FREEFLOW"]
-- (7 rows)

-- 2020 FHWA (as-is-truck-aadt)

-- SELECT
--     *
--   FROM pm3._admin_pm3_calculator_metadata_view
--   WHERE (
--     ( timestamp BETWEEN '20210504T113817' and '20210504T175239' )
--     AND
--     ( measures = '["LOTTR", "TTTR", "PHED"]' )
--   )
--   ORDER BY 2
-- ;
--
--  id  |    timestamp    | states | year |         measures
-- -----+-----------------+--------+------+---------------------------
--  522 | 20210504T113817 | ["ny"] | 2020 | ["LOTTR", "TTTR", "PHED"]
--  526 | 20210504T175237 | ["nj"] | 2020 | ["LOTTR", "TTTR", "PHED"]
-- (2 rows)

-- SELECT
--     *
--   FROM pm3._admin_pm3_calculator_metadata_view
--   WHERE (
--     ( timestamp BETWEEN '20210504T113817' and '20210504T175239' )
--     AND
--     (
--       ( measures = '["PHED", "PHED_FREEFLOW", "TED", "TED_FREEFLOW", "EMISSIONS"]' )
--       OR
--       ( measures = '["PTI", "TTI", "PERCENT_BINS_REPORTING", "SPEED_PERCENTILES", "FREEFLOW"]' )
--     )
--   )
--   ORDER BY 2
-- ;
--
--  id  |    timestamp    | states | year |                                 measures
-- -----+-----------------+--------+------+---------------------------------------------------------------------------
--  524 | 20210504T113819 | ["ny"] | 2020 | ["PHED", "PHED_FREEFLOW", "TED", "TED_FREEFLOW", "EMISSIONS"]
--  525 | 20210504T113820 | ["ny"] | 2020 | ["PTI", "TTI", "PERCENT_BINS_REPORTING", "SPEED_PERCENTILES", "FREEFLOW"]
--  527 | 20210504T175238 | ["nj"] | 2020 | ["PHED", "PHED_FREEFLOW", "TED", "TED_FREEFLOW", "EMISSIONS"]
--  528 | 20210504T175239 | ["nj"] | 2020 | ["PTI", "TTI", "PERCENT_BINS_REPORTING", "SPEED_PERCENTILES", "FREEFLOW"]
-- (4 rows)

-- SELECT
--     *
--   FROM pm3._admin_pm3_calculator_metadata_view
--   WHERE (
--     ( timestamp BETWEEN '20210504T113817' and '20210504T175239' )
--     AND
--     ( measures = '["PHED_RIS", "PHED_FREEFLOW_RIS", "TED_RIS", "TED_FREEFLOW_RIS", "EMISSIONS_RIS"]' )
--   )
--   ORDER BY 2
-- ;
--
--  id  |    timestamp    | states | year |                                     measures
-- -----+-----------------+--------+------+-----------------------------------------------------------------------------------
--  523 | 20210504T113818 | ["ny"] | 2020 | ["PHED_RIS", "PHED_FREEFLOW_RIS", "TED_RIS", "TED_FREEFLOW_RIS", "EMISSIONS_RIS"]
-- (1 row)


/*
BEGIN;

INSERT INTO pm3.pm3_calculation_versions (
    year, measure_class, major_version, minor_version, fix_version, prerelease_label, pm3calc_ids
  )
  VALUES (
    2020, 'FHWA', 1, 2, 2, null,
    ARRAY[522,526]
  )
;

INSERT INTO pm3.pm3_calculation_versions (
    year, measure_class, major_version, minor_version, fix_version, prerelease_label, pm3calc_ids
  )
  VALUES (
    2020, 'AUX', 1, 2, 2, null,
    ARRAY[524,525,527,528]
  )
;

INSERT INTO pm3.pm3_calculation_versions (
    year, measure_class, major_version, minor_version, fix_version, prerelease_label, pm3calc_ids
  )
  VALUES (
    2020, 'RIS', 1, 2, 2, null,
    ARRAY[523]
  )
;

COMMIT;
*/
