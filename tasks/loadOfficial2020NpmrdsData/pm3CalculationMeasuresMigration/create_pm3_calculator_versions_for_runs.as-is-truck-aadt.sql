-- SELECT
--     *
--   FROM pm3._admin_pm3_calculator_metadata_view
--   WHERE ( timestamp BETWEEN '20210503T173614' and '20210504T065711' )
--   ORDER BY 2
-- ;

 --  id  |    timestamp    | states | year |                                     measures
 -- -----+-----------------+--------+------+-----------------------------------------------------------------------------------
 --  515 | 20210503T173614 | ["ny"] | 2020 | ["LOTTR", "TTTR", "PHED"]
 --  516 | 20210503T173615 | ["ny"] | 2020 | ["PHED_RIS", "PHED_FREEFLOW_RIS", "TED_RIS", "TED_FREEFLOW_RIS", "EMISSIONS_RIS"]
 --  517 | 20210503T173616 | ["ny"] | 2020 | ["PHED", "PHED_FREEFLOW", "TED", "TED_FREEFLOW", "EMISSIONS"]
 --  518 | 20210503T173617 | ["ny"] | 2020 | ["PTI", "TTI", "PERCENT_BINS_REPORTING", "SPEED_PERCENTILES", "FREEFLOW"]
 --  519 | 20210504T065709 | ["nj"] | 2020 | ["LOTTR", "TTTR", "PHED"]
 --  520 | 20210504T065710 | ["nj"] | 2020 | ["PHED", "PHED_FREEFLOW", "TED", "TED_FREEFLOW", "EMISSIONS"]
 --  521 | 20210504T065711 | ["nj"] | 2020 | ["PTI", "TTI", "PERCENT_BINS_REPORTING", "SPEED_PERCENTILES", "FREEFLOW"]
 -- (7 rows)

-- 2020 FHWA (as-is-truck-aadt)

-- SELECT
--     *
--   FROM pm3._admin_pm3_calculator_metadata_view
--   WHERE (
--     ( timestamp BETWEEN '20210503T173614' and '20210504T065711' )
--     AND
--     ( measures = '["LOTTR", "TTTR", "PHED"]' )
--   )
--   ORDER BY 2
-- ;
--
--  id  |    timestamp    | states | year |         measures
-- -----+-----------------+--------+------+---------------------------
--  515 | 20210503T173614 | ["ny"] | 2020 | ["LOTTR", "TTTR", "PHED"]
--  519 | 20210504T065709 | ["nj"] | 2020 | ["LOTTR", "TTTR", "PHED"]
-- (2 rows)

-- SELECT
--     *
--   FROM pm3._admin_pm3_calculator_metadata_view
--   WHERE (
--     ( timestamp BETWEEN '20210503T173614' and '20210504T065711' )
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
--  517 | 20210503T173616 | ["ny"] | 2020 | ["PHED", "PHED_FREEFLOW", "TED", "TED_FREEFLOW", "EMISSIONS"]
--  518 | 20210503T173617 | ["ny"] | 2020 | ["PTI", "TTI", "PERCENT_BINS_REPORTING", "SPEED_PERCENTILES", "FREEFLOW"]
--  520 | 20210504T065710 | ["nj"] | 2020 | ["PHED", "PHED_FREEFLOW", "TED", "TED_FREEFLOW", "EMISSIONS"]
--  521 | 20210504T065711 | ["nj"] | 2020 | ["PTI", "TTI", "PERCENT_BINS_REPORTING", "SPEED_PERCENTILES", "FREEFLOW"]
-- (4 rows)

-- SELECT
--     *
--   FROM pm3._admin_pm3_calculator_metadata_view
--   WHERE (
--     ( timestamp BETWEEN '20210503T173614' and '20210504T065711' )
--     AND
--     ( measures = '["PHED_RIS", "PHED_FREEFLOW_RIS", "TED_RIS", "TED_FREEFLOW_RIS", "EMISSIONS_RIS"]' )
--   )
--   ORDER BY 2
-- ;
--
--  id  |    timestamp    | states | year |                                     measures
-- -----+-----------------+--------+------+-----------------------------------------------------------------------------------
--  516 | 20210503T173615 | ["ny"] | 2020 | ["PHED_RIS", "PHED_FREEFLOW_RIS", "TED_RIS", "TED_FREEFLOW_RIS", "EMISSIONS_RIS"]
-- (1 row)

/*
BEGIN;

INSERT INTO pm3.pm3_calculation_versions (
    year, measure_class, major_version, minor_version, fix_version, prerelease_label, pm3calc_ids
  )
  VALUES (
    2020, 'FHWA', 1, 2, 0, 'as-is-truck-aadt',
    ARRAY[515,519]
  )
;

INSERT INTO pm3.pm3_calculation_versions (
    year, measure_class, major_version, minor_version, fix_version, prerelease_label, pm3calc_ids
  )
  VALUES (
    2020, 'AUX', 1, 2, 0, 'as-is-truck-aadt',
    ARRAY[517,518,520,521]
  )
;

INSERT INTO pm3.pm3_calculation_versions (
    year, measure_class, major_version, minor_version, fix_version, prerelease_label, pm3calc_ids
  )
  VALUES (
    2020, 'RIS', 1, 2, 0, 'as-is-truck-aadt',
    ARRAY[516]
  )
;

COMMIT;
*/
