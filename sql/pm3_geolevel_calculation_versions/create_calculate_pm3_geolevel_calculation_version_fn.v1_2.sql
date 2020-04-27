/*
From
  FHWA Computation Procedure for Travel Time Based and
    Percent Non-Single Occupancy Vehicle (non-SOV) Travel Performance Measures

    FHWA HIF-18-024

    May 2018


    2.3.1 Interstate Travel Time Reliability Measure

      2.3.1.1 Step 1: Obtain Interstate Reporting Segment Data
      The data records in the Travel_Time_Metric_Dataset must meet the criteria below to be considered
      as data for the reporting segments on the mainline highway of the Interstate System for a State.

        SELECT * FROM Travel_Time_Metric_Dataset
        WHERE
          (([F_System] =1) AND
          ([Facility_Type] IN (1, 2, 6)) AND
          ([NHS] IN (1, 2, 3, 4, 5, 6, 7, 8, 9)) AND
          ([Urban_Code] > 0))

    2.3.2 Non-Interstate Travel Time Reliability Measure

      2.3.2.1 Step 1: Get non-Interstate NHS Data
      The data records in the Travel_Time_Metric_Dataset must meet the criteria below to be considered
      as data for the reporting segments on the mainline highway of the non-Interstate NHS for a State.

        SELECT * FROM Travel_Time_Metric_Dataset
          WHERE
            (([F_System] IN (2, 3, 4, 5, 6, 7)) AND
            ([Facility_Type] IN (1, 2, 6)) AND
            ([NHS] IN (1, 2, 3, 4, 5, 6, 7, 8, 9)) AND
            ([Urban_Code] > 0))

    2.3.3 Truck Travel Time Reliability (TTTR) Index (referred to as the “Freight Reliability Measure”)

      2.3.3.1 Step 1: Obtain Interstate Reporting Segment Data
      As provided in 23 CFR 490.603, the Freight Reliability Measure is applicable to the Interstate System.
      The data records in the Travel_Time_Metric_Dataset must meet the criteria below to be considered
      as data for the reporting segments on the mainline highway of the Interstate System for a State.

        SELECT * FROM Travel_Time_Metric_Dataset
          WHERE
            (([F_System] =1) AND
            ([Facility_Type] IN (1, 2, 6)) AND
            ([NHS] IN (1, 2, 3, 4, 5, 6, 7, 8, 9)) AND
            ([Urban_Code] > 0))

    2.3.4 PHED Measure

      2.3.4.1 Step 1: Obtaining Dataset for an Applicable Urbanized Area
      The total number of reporting segments on the NHS located within the applicable urbanized area
      (denoted as “U” in the equation) is determined by by applying the following criteria.

        SELECT * FROM Travel_Time_Metric_Dataset(S)
          WHERE
            ([State_Code] IN (##, …)) AND
            ([F_System] IN (1, 2, 3, 4, 5, 6, 7)) AND
            ([Facility_Type] IN (1, 2, 6)) AND
            ([NHS] IN (1, 2, 3, 4, 5, 6, 7, 8, 9)) AND
            ([Urban_Code] = #####)

NOTE:
        1. The is_nhs_interstate criteria is the same for LOTTR and TTTR.
        2. The PHED inclusion criteria = is_nhs_interstate OR is_nhs_noninterstate

*/

BEGIN;

DROP FUNCTION IF EXISTS pm3.calculate_pm3_geolevel_calculation_version_v1_2 (TEXT);

CREATE FUNCTION pm3.calculate_pm3_geolevel_calculation_version_v1_2 (p_version_id TEXT)
  RETURNS TABLE (
    pm3calc_ver_id       INTEGER,
    geolevel             TEXT,
    geocode              TEXT,
    states               TEXT[],
    state_codes          TEXT[],
    lottr_interstate     DOUBLE PRECISION,
    lottr_noninterstate  DOUBLE PRECISION,
    tttr_interstate      DOUBLE PRECISION,
    phed                 DOUBLE PRECISION,
    interstate_tmcs      INTEGER,
    interstate_miles     DOUBLE PRECISION,
    noninterstate_tmcs   INTEGER,
    noninterstate_miles  DOUBLE PRECISION

  )
AS $calculate_pm3_geolevel_calculation_version$
BEGIN
  IF NOT EXISTS (
      SELECT a.pm3calc_ver_id
         FROM pm3.pm3_calculation_versions_view AS a
         WHERE ( a.version_id = p_version_id )
    ) THEN

      RAISE EXCEPTION 'version_id DOES NOT EXIST';

  END IF;

  CREATE TEMPORARY TABLE tmp_pm3_run_tmc_metadata_snapshot (
      tmc          VARCHAR,
      state        CHAR(2),
      state_code   CHAR(2),
      county_code  CHAR(5),
      ua_code      VARCHAR,
      mpo_code     VARCHAR,

      PRIMARY KEY(tmc)
    ) WITH (fillfactor=100)
    ON COMMIT DROP
  ;

  CREATE TEMPORARY TABLE tmp_tmc_level_pm3_measures (
      tmc                   VARCHAR,
      lottr                 DOUBLE PRECISION,
      tttr                  DOUBLE PRECISION,
      phed                  DOUBLE PRECISION,
      dir_aadt              DOUBLE PRECISION,
      f_system              DOUBLE PRECISION,
      miles                 DOUBLE PRECISION,
      occ_fac               DOUBLE PRECISION,
      nhs_pct               DOUBLE PRECISION,
      isprimary             BOOLEAN,
      is_nhs_interstate     BOOLEAN,
      is_nhs_noninterstate  BOOLEAN,

      PRIMARY KEY(tmc)
    ) WITH (fillfactor=100)
    ON COMMIT DROP
  ;

  -- Create a snapshot of the tmc_metadata tables that were in use during the pm3 calculator run.
  EXECUTE (
    SELECT
        'INSERT INTO tmp_pm3_run_tmc_metadata_snapshot (tmc, state, state_code, county_code, ua_code, mpo_code)'
        || string_agg(
            '
              SELECT tmc, state, state_code, county_code, ua_code, mpo_code FROM '
            || '"' || state || '"'
            || '.tmc_metadata_' || year || '_v' || tmc_metadata_table_name
            , '
              UNION ALL'
        )
        || ' ;' AS sql
      FROM (
        SELECT DISTINCT
            year,
            (meta).key AS state,
            REGEXP_REPLACE(
              (meta).value->>'tmc_metadata_version_timestamp',
              '[^0-9]',
              '',
              'ig'
            ) AS tmc_metadata_table_name
          FROM (
            SELECT
                year,
                jsonb_each(data_provenance_metadata) AS meta
              FROM pm3.pm3_calculator_data_provenances AS a
                INNER JOIN pm3.pm3_calculation_versions_view AS b
                  ON ( a.id = ANY(b.pm3calc_ids) )
              WHERE ( b.version_id = p_version_id )
          ) AS t
          ORDER BY 1,2,3
      ) AS t
  ) ;

  CLUSTER tmp_pm3_run_tmc_metadata_snapshot
    USING tmp_pm3_run_tmc_metadata_snapshot_pkey;

  -- Create a summary view of the TMC-level FHWA pm3 measure calculations
  --   because these TMC-level values are reused for different geography levels.
  INSERT INTO tmp_tmc_level_pm3_measures
    WITH cte_pm3_calculations AS (
      SELECT
          tmc,
          measure,
          measure_data
        FROM pm3.pm3_calculation_versions_view AS pcvv
          INNER JOIN pm3.pm3_calculator_output AS pco
          ON (
            ( pcvv.version_id = p_version_id )
            AND
            ( pco.pm3calc_id = ANY(pcvv.pm3calc_ids) )
          )
        WHERE ( measure = ANY(ARRAY['LOTTR', 'TTTR', 'PHED', 'TMC_METADATA']) )
    )
    SELECT
        *
      FROM (
          SELECT
              tmc,
              GREATEST(
                NULLIF(measure_data->'amp', 'null'::JSONB),
                NULLIF(measure_data->'midd', 'null'::JSONB),
                NULLIF(measure_data->'pmp', 'null'::JSONB),
                NULLIF(measure_data->'we', 'null'::JSONB)
              )::DOUBLE PRECISION AS lottr
            FROM cte_pm3_calculations
            WHERE ( measure = 'LOTTR' )
        ) AS t_lottr
        FULL OUTER JOIN (
          SELECT
              tmc,
              GREATEST(
                NULLIF(measure_data->'amp', 'null'::JSONB),
                NULLIF(measure_data->'midd', 'null'::JSONB),
                NULLIF(measure_data->'pmp', 'null'::JSONB),
                NULLIF(measure_data->'we', 'null'::JSONB),
                NULLIF(measure_data->'ovn', 'null'::JSONB)
              )::DOUBLE PRECISION AS tttr
            FROM cte_pm3_calculations
            WHERE ( measure = 'TTTR' )
        ) AS t_tttr USING (tmc)
        FULL OUTER JOIN (
          SELECT
              tmc,
              NULLIF(
                measure_data->'all_xdelay_phrs',
                'null'::JSONB
              )::DOUBLE PRECISION AS phed
            FROM cte_pm3_calculations
            WHERE ( measure = 'PHED' )
        ) AS t_phed USING (tmc)
        FULL OUTER JOIN (
          SELECT
              tmc,
              NULLIF(
                measure_data->'directionalAadt',
                'null'::JSONB
              )::DOUBLE PRECISION AS dir_aadt,
              NULLIF(
                measure_data->'fSystem',
                'null'::JSONB
              )::INTEGER AS f_system,
              NULLIF(
                measure_data->'miles',
                'null'::JSONB
              )::DOUBLE PRECISION AS miles,
              NULLIF(
                measure_data->'avgVehicleOccupancy',
                'null'::JSONB
              )::DOUBLE PRECISION AS occ_fac,
              COALESCE(
                NULLIF(
                  measure_data->'nhsPct',
                  'null'::JSONB
                ),
                '0'::JSONB
              )::DOUBLE PRECISION AS nhs_pct,
              COALESCE(
                NULLIF(
                  measure_data->'isprimary',
                  'null'::JSONB
                )::INTEGER::BOOLEAN,
                false
              ) AS isprimary,

              -- FHWA HIF-18-024
              --   SELECT * FROM Travel_Time_Metric_Dataset
              --   WHERE
              --     (([F_System] =1) AND
              --     ([Facility_Type] IN (1, 2, 6)) AND
              --     ([NHS] IN (1, 2, 3, 4, 5, 6, 7, 8, 9)) AND
              --     ([Urban_Code] > 0))
              COALESCE(
                (
                  (
                    NULLIF(
                      measure_data->'fSystem',
                      'null'::JSONB
                    )::INTEGER = 1
                  )
                  AND
                  (
                    NULLIF(
                      measure_data->'faciltype',
                      'null'::JSONB
                    )::INTEGER IN (1,2,6)
                  )
                  AND
                  (
                    NULLIF(
                      measure_data->'nhs',
                      'null'::JSONB
                    )::INTEGER IN (1,2,3,4,5,6,7,8,9)
                  )
                ),
                false
              )::BOOLEAN AS is_nhs_interstate,

              -- FHWA HIF-18-024
              --   SELECT * FROM Travel_Time_Metric_Dataset
              --     WHERE
              --       (([F_System] IN (2, 3, 4, 5, 6, 7)) AND
              --       ([Facility_Type] IN (1, 2, 6)) AND
              --       ([NHS] IN (1, 2, 3, 4, 5, 6, 7, 8, 9)) AND
              --       ([Urban_Code] > 0))
              COALESCE(
                (
                  (
                    NULLIF(
                      measure_data->'fSystem',
                      'null'::JSONB
                    )::INTEGER IN (2,3,4,5,6,7)
                  )
                  AND
                  (
                    NULLIF(
                      measure_data->'faciltype',
                      'null'::JSONB
                    )::INTEGER IN (1,2,6)
                  )
                  AND
                  (
                    NULLIF(
                      measure_data->'nhs',
                      'null'::JSONB
                    )::INTEGER IN (1,2,3,4,5,6,7,8,9)
                  )
                ),
                false
              )::BOOLEAN AS is_nhs_noninterstate

            FROM cte_pm3_calculations
            WHERE ( measure = 'TMC_METADATA' )
        ) AS t_tmc_metadata USING (tmc)
  ;

  CLUSTER tmp_tmc_level_pm3_measures
    USING tmp_tmc_level_pm3_measures_pkey;

  CREATE FUNCTION pg_temp.calculate_for_geolevel_fn (p_geolevel TEXT, p_cross_state BOOLEAN DEFAULT FALSE)
    RETURNS TABLE (
      geolevel             TEXT,
      geocode              TEXT,
      states               TEXT[],
      state_codes          TEXT[],
      lottr_interstate     DOUBLE PRECISION,
      lottr_noninterstate  DOUBLE PRECISION,
      tttr_interstate      DOUBLE PRECISION,
      phed                 DOUBLE PRECISION,
      interstate_tmcs      INTEGER,
      interstate_miles     DOUBLE PRECISION,
      noninterstate_tmcs   INTEGER,
      noninterstate_miles  DOUBLE PRECISION
    )
  AS $calculate_for_geolevel_fn$
    SELECT
        p_geolevel AS geolevel,
        (
          CASE p_geolevel
            WHEN 'STATE' THEN state_code
            WHEN 'COUNTY' THEN county_code
            WHEN 'UA' THEN ua_code
            WHEN 'MPO' THEN mpo_code
          END
        )::TEXT AS geocode,
        ARRAY_AGG(
          DISTINCT state ORDER BY state
        )::TEXT[] AS states,
        ARRAY_AGG(
          DISTINCT state_code ORDER BY state_code
        )::TEXT[] AS state_codes,

        -- LOTTR Interstate
        ROUND(
          SUM(
            (ROUND(lottr::NUMERIC, 2) < 1.50)::INTEGER
            * (miles * nhs_pct / 100)
            * ( is_nhs_interstate AND isprimary )::INTEGER
            * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
            * occ_fac::NUMERIC
          )::NUMERIC
          /
          NULLIF(
            SUM(
              (lottr IS NOT NULL)::INTEGER
              * (miles * nhs_pct / 100)
              * ( is_nhs_interstate AND isprimary )::INTEGER
              * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
              * occ_fac::NUMERIC
            )::NUMERIC
            , 0
          )::NUMERIC
          *
          100 -- To percent
          , 1 -- to nearest 1/10th
        )::DOUBLE PRECISION AS lottr_interstate,

        -- LOTTR Noninterstate
        ROUND(
          SUM(
            (ROUND(lottr::NUMERIC, 2) < 1.50)::INTEGER
            * (miles * nhs_pct / 100)
            * ( is_nhs_noninterstate AND isprimary )::INTEGER
            * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
            * occ_fac::NUMERIC
          )::NUMERIC
          /
          NULLIF(
            SUM(
              (miles * nhs_pct / 100)
              * (lottr IS NOT NULL)::INTEGER
              * ( is_nhs_noninterstate AND isprimary )::INTEGER
              * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
              * occ_fac::NUMERIC
            )
            , 0
          )::NUMERIC
          *
          100 -- To percent
          , 1 -- to nearest 1/10th
        )::DOUBLE PRECISION AS lottr_noninterstate,

        -- TTTR interstate
        ROUND(
          SUM(
            ROUND((tttr::NUMERIC), 2)::NUMERIC
            * (miles * nhs_pct / 100)
            * ( is_nhs_interstate AND isprimary )::INTEGER
          )::NUMERIC
          /
          NULLIF(
            SUM(
              (tttr IS NOT NULL)::INTEGER
              * (miles * nhs_pct / 100)
              * ( is_nhs_interstate AND isprimary )::INTEGER
            )
            , 0
          )::NUMERIC
          , 2 -- to nearest 1/100th
        )::DOUBLE PRECISION AS tttr_interstate,

        ROUND(
          -- if (all_xdelay_phrs > 0 && nhsPct > 0 && +isprimary) {
          --   total_phed += _.round(xdelayPHrs * +nhsPct / 100, 3);
          -- }
          SUM(
            ROUND(phed::NUMERIC, 3)
            * (nhs_pct::NUMERIC / 100::NUMERIC)
            * (
                (is_nhs_interstate OR is_nhs_noninterstate)
                AND isprimary
              )::INTEGER
          )
          , 1 -- to nearest 1/10th
        )::DOUBLE PRECISION AS phed,

        COALESCE(
          SUM(
            -- NOTE: if nhs_pct or f_system is null, not included in sum.
            ( is_nhs_interstate AND isprimary )::INTEGER -- Converting BOOLEAN to INTEGER yields 0 or 1
          ),
          0
        )::INTEGER AS interstate_tmcs,

        ROUND(
          -- NOTE: if nhs_pct or f_system is null, not included in sum.
          COALESCE(
            SUM(
              (miles::NUMERIC * nhs_pct::NUMERIC / 100)
              * ( is_nhs_interstate AND isprimary )::INTEGER
            ),
            0
          )::NUMERIC
          , 2
        )::DOUBLE PRECISION AS interstate_miles,

        COALESCE(
          SUM(
            -- NOTE: if nhs_pct or f_system is null, not included in sum.
            ( is_nhs_noninterstate AND isprimary )::INTEGER -- Converting BOOLEAN to INTEGER yields 0 or 1
          ),
          0
        )::INTEGER AS noninterstate_tmcs,

        ROUND(
          COALESCE(
            SUM(
              -- NOTE: if nhs_pct or f_system is null, not included in sum.
              (miles::NUMERIC * nhs_pct::NUMERIC / 100)
              * ( is_nhs_noninterstate AND isprimary )::INTEGER
            ),
            0
          )::NUMERIC
          , 2
        )::DOUBLE PRECISION AS noninterstate_miles

      FROM tmp_pm3_run_tmc_metadata_snapshot
        INNER JOIN tmp_tmc_level_pm3_measures USING (tmc)
      WHERE (
        CASE p_geolevel
          WHEN 'STATE' THEN ( state_code IS NOT NULL )
          WHEN 'COUNTY' THEN ( county_code IS NOT NULL )
          WHEN 'UA' THEN (
            ( ua_code IS NOT NULL )
            AND
            -- IF cross_state aggregations, we cannot include the
            --   99998 (Small Urban Sections) or 99999 (Rural Area Sections)
            --   UA codes because all states have them and they are not cross-state.
            (
              ( NOT p_cross_state )
              OR
              ( ua_code NOT IN ('99998', '99999') )
            )
          )
          WHEN 'MPO' THEN ( mpo_code IS NOT NULL )
          ELSE false
        END
      )
      GROUP BY
        geolevel,
        geocode,
        CASE
          -- If cross_state, group by (geolevel, geocode)
          WHEN p_cross_state THEN 'cross_state'
          -- If not cross_state, then group by (geolevel, geocode, state)
          ELSE state
        END
      HAVING (
        ( p_geolevel <> 'MPO' )
        OR
        ( COUNT(1) > 50 )
      )
  ;
  $calculate_for_geolevel_fn$ LANGUAGE SQL;

  CREATE TEMPORARY TABLE tmp_result (
    pm3calc_ver_id       INTEGER,
    geolevel             TEXT,
    geocode              TEXT,
    states               TEXT[],
    state_codes          TEXT[],
    lottr_interstate     DOUBLE PRECISION,
    lottr_noninterstate  DOUBLE PRECISION,
    tttr_interstate      DOUBLE PRECISION,
    phed                 DOUBLE PRECISION,
    interstate_tmcs      INTEGER,
    interstate_miles     DOUBLE PRECISION,
    noninterstate_tmcs   INTEGER,
    noninterstate_miles  DOUBLE PRECISION
  ) ON COMMIT DROP;

  INSERT INTO tmp_result (
      geolevel,
      geocode,
      states,
      state_codes,
      lottr_interstate,
      lottr_noninterstate,
      tttr_interstate,
      phed,
      interstate_tmcs,
      interstate_miles,
      noninterstate_tmcs,
      noninterstate_miles
    )
    SELECT
        t.geolevel,
        t.geocode,
        t.states,
        t.state_codes,
        t.lottr_interstate,
        t.lottr_noninterstate,
        t.tttr_interstate,
        t.phed,
        t.interstate_tmcs,
        t.interstate_miles,
        t.noninterstate_tmcs,
        t.noninterstate_miles
      FROM (
        SELECT * FROM pg_temp.calculate_for_geolevel_fn('STATE')
        UNION
        SELECT * FROM pg_temp.calculate_for_geolevel_fn('COUNTY')
        UNION
        SELECT * FROM pg_temp.calculate_for_geolevel_fn('UA', false)
        UNION
        SELECT * FROM pg_temp.calculate_for_geolevel_fn('UA', true)
        UNION
        SELECT * FROM pg_temp.calculate_for_geolevel_fn('MPO', false)
        UNION
        SELECT * FROM pg_temp.calculate_for_geolevel_fn('MPO', true)
      ) AS t
    ;

  UPDATE tmp_result
    SET pm3calc_ver_id = (
      SELECT pcvv.pm3calc_ver_id
        FROM pm3.pm3_calculation_versions_view AS pcvv
        WHERE ( pcvv.version_id = p_version_id )
    )
  ;

  DROP FUNCTION pg_temp.calculate_for_geolevel_fn (TEXT, BOOLEAN);

  RETURN QUERY (SELECT * FROM tmp_result) ;

END;
$calculate_pm3_geolevel_calculation_version$ LANGUAGE plpgsql;

COMMIT;
