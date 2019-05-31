-- https://stackoverflow.com/a/9981540

CREATE FUNCTION pg_temp.tmp_create_pm3_authoritative_geolevel_mview ()
  RETURNS VOID AS
$func$
BEGIN

DROP MATERIALIZED VIEW IF EXISTS pm3_authoritative_geolevel_mview ;

EXECUTE 'CREATE MATERIALIZED VIEW pm3_authoritative_geolevel_mview AS
  WITH cte_tmc_metadata AS (' || (
    SELECT
        string_agg('
          SELECT
              tmc,
              state,
              state_code,
              county_code,
              mpo_code,
              ua_code,
              conflation_year AS year
            FROM public.' || table_name || '
          ',
          ' UNION ALL '
        )
      FROM information_schema.tables
      WHERE (
        (table_schema = 'public')
        AND
        (table_name LIKE 'tmc_metadata_%')
      )
  ) || '), cte_tmc_level_pm3 AS (
      SELECT
          split_part(tmc_year, ''_'', 1) AS tmc,
          split_part(tmc_year, ''_'', 2)::INTEGER AS year,
          (
            GREATEST(
              (lottr_amp)::TEXT::DOUBLE PRECISION,
              (lottr_midd)::TEXT::DOUBLE PRECISION,
              (lottr_pmp)::TEXT::DOUBLE PRECISION,
              (lottr_we)::TEXT::DOUBLE PRECISION
            )
          ) AS lottr,
          (
            GREATEST(
              (tttr_amp)::TEXT::DOUBLE PRECISION,
              (tttr_midd)::TEXT::DOUBLE PRECISION,
              (tttr_pmp)::TEXT::DOUBLE PRECISION,
              (tttr_we)::TEXT::DOUBLE PRECISION,
              (tttr_ovn)::TEXT::DOUBLE PRECISION
            )
          ) AS tttr,
          (
            (phed_all_xdelay_phrs)::TEXT::DOUBLE PRECISION
          ) AS phed,
          (
            (tmc_metadata_directionalaadt)::TEXT::DOUBLE PRECISION
          ) AS dir_aadt,
          (
            (tmc_metadata_fsystem)::TEXT::INTEGER
          ) AS f_system,
          (
            (tmc_metadata_miles)::TEXT::DOUBLE PRECISION
          ) AS miles,
          (
            (tmc_metadata_avgvehicleoccupancy)::TEXT::DOUBLE PRECISION
          ) AS occ_fac,
          (
            (tmc_metadata_nhspct)::TEXT::DOUBLE PRECISION
          ) AS nhs_pct
        FROM crosstab(''
          SELECT *
            FROM (
              SELECT
                  (tmc || ''''_'''' || year)::VARCHAR AS tmc_year,
                  LOWER(measure) || ''''_'''' || attribute AS measure,
                  value
                FROM pm3_authoritative_view
                WHERE (
                  (
                    ( measure = ''''LOTTR'''' )
                    AND
                    ( attribute = ANY(ARRAY[''''amp'''',''''midd'''',''''pmp'''',''''we'''']) )
                  )
                  OR
                  (
                    ( measure = ''''TTTR'''' )
                    AND
                    ( attribute = ANY(ARRAY[''''amp'''',''''midd'''',''''ovn'''',''''pmp'''',''''we'''']) )
                  )
                  OR (
                    ( measure = ''''PHED'''' )
                    AND
                    ( attribute = ANY(ARRAY[''''all_xdelay_phrs'''']) )
                  )
                  OR (
                    ( measure = ''''TMC_METADATA'''' )
                    AND
                    ( attribute = ANY(ARRAY[''''avgVehicleOccupancy'''',''''directionalAadt'''',''''fSystem'''',''''miles'''',''''nhsPct'''']) )
                  )
                )
            ) AS sub_data RIGHT OUTER JOIN (
              -- Guarantee returned measure cols match pivot table definition provided below
              SELECT
                  tmc || ''''_'''' || year AS tmc_year,
                  measure
                FROM (
                    SELECT DISTINCT
                        tmc,
                        year
                      FROM pm3_authoritative_view
                  ) AS sub_all_tmcs
                    CROSS JOIN UNNEST(
                      ARRAY[
                        ''''lottr_amp'''',
                        ''''lottr_midd'''',
                        ''''lottr_pmp'''',
                        ''''lottr_we'''',
                        ''''phed_all_xdelay_phrs'''',
                        ''''tmc_metadata_avgVehicleOccupancy'''',
                        ''''tmc_metadata_directionalAadt'''',
                        ''''tmc_metadata_fSystem'''',
                        ''''tmc_metadata_miles'''',
                        ''''tmc_metadata_nhsPct'''',
                        ''''tttr_amp'''',
                        ''''tttr_midd'''',
                        ''''tttr_ovn'''',
                        ''''tttr_pmp'''',
                        ''''tttr_we''''
                      ]) AS measures(measure)
          ) AS sub_col_filler USING (tmc_year, measure)
        ORDER BY 1,2
    '') AS pvt(
      tmc_year VARCHAR,
      lottr_amp JSONB,
      lottr_midd JSONB,
      lottr_pmp JSONB,
      lottr_we JSONB,
      phed_all_xdelay_phrs JSONB,
      tmc_metadata_avgVehicleOccupancy JSONB,
      tmc_metadata_directionalAadt JSONB,
      tmc_metadata_fSystem JSONB,
      tmc_metadata_miles JSONB,
      tmc_metadata_nhsPct JSONB,
      tttr_amp JSONB,
      tttr_midd JSONB,
      tttr_ovn JSONB,
      tttr_pmp JSONB,
      tttr_we JSONB
    )
  )
    SELECT
        ''STATE'' AS geolevel,
        state_code AS geocode,
        ARRAY[state]::TEXT[] AS states,
        ARRAY[state_code]::TEXT[] AS state_codes,
        year,
        ROUND(
          SUM(
            (miles * nhs_pct / 100)
            * (ROUND(lottr::NUMERIC, 2) < 1.50)::INT
            * (f_system = 1)::INT
            * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
            * occ_fac::NUMERIC
          )::NUMERIC
          /
          NULLIF(
            SUM(
              (miles * nhs_pct / 100)
              * (lottr IS NOT NULL)::INT
              * (f_system = 1)::INT
              * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
              * occ_fac::NUMERIC
            )::NUMERIC
            , 0
          )::NUMERIC
          *
          100 -- To percent
          , 1 -- to nearest 1/10th
        )::DOUBLE PRECISION AS lottr_interstate,
        ROUND(
          SUM(
            (miles * nhs_pct / 100)
            * (ROUND(lottr::NUMERIC, 2) < 1.50)::INT
            * (f_system <> 1)::INT
            * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
            * occ_fac::NUMERIC
          )::NUMERIC
          /
          NULLIF(
            SUM(
              (miles * nhs_pct / 100)
              * (lottr IS NOT NULL)::INT
              * (f_system <> 1)::INT
              * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
              * occ_fac::NUMERIC
            )
            , 0
          )::NUMERIC
          *
          100 -- To percent
          , 1 -- to nearest 1/10th
        )::DOUBLE PRECISION AS lottr_noninterstate,
        ROUND(
          SUM(
            (miles * nhs_pct / 100)
            * ROUND((tttr::NUMERIC), 2)::NUMERIC
            * (f_system = 1)::INT
          )::NUMERIC
          /
          NULLIF(
            SUM(
              (miles * nhs_pct / 100)
              * (tttr IS NOT NULL)::INT
              * (f_system = 1)::INT
            )
            , 0
          )::NUMERIC
          , 2 -- to nearest 1/100th
        )::DOUBLE PRECISION AS tttr_interstate,
        ROUND(
          SUM(
            ROUND(phed::NUMERIC, 3)
            * (NULLIF(nhs_pct, 0) IS NOT NULL)::INT
          )
          , 1 -- to nearest 1/10th
        )::DOUBLE PRECISION AS phed
      FROM cte_tmc_metadata
        INNER JOIN cte_tmc_level_pm3 USING (tmc, year)
      WHERE (
        (state_code IS NOT NULL)
      )
      GROUP BY state, state_code, year

  UNION ALL

  SELECT
      ''COUNTY'' AS geolevel,
      county_code AS geocode,
      ARRAY[state]::TEXT[] AS states,
      ARRAY[state_code]::TEXT[] AS state_codes,
      year,
      ROUND(
        SUM(
          (miles * nhs_pct / 100)
          * (ROUND(lottr::NUMERIC, 2) < 1.50)::INT
          * (f_system = 1)::INT
          * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
          * occ_fac::NUMERIC
        )::NUMERIC
        /
        NULLIF(
          SUM(
            (miles * nhs_pct / 100)
            * (lottr IS NOT NULL)::INT
            * (f_system = 1)::INT
            * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
            * occ_fac::NUMERIC
          )::NUMERIC
          , 0
        )::NUMERIC
        *
        100 -- To percent
        , 1 -- to nearest 1/10th
      )::DOUBLE PRECISION AS lottr_interstate,
      ROUND(
        SUM(
          (miles * nhs_pct / 100)
          * (ROUND(lottr::NUMERIC, 2) < 1.50)::INT
          * (f_system <> 1)::INT
          * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
          * occ_fac::NUMERIC
        )::NUMERIC
        /
        NULLIF(
          SUM(
            (miles * nhs_pct / 100)
            * (lottr IS NOT NULL)::INT
            * (f_system <> 1)::INT
            * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
            * occ_fac::NUMERIC
          )
          , 0
        )::NUMERIC
        *
        100 -- To percent
        , 1 -- to nearest 1/10th
      )::DOUBLE PRECISION AS lottr_noninterstate,
      ROUND(
        SUM(
          (miles * nhs_pct / 100)
          * ROUND((tttr::NUMERIC), 2)::NUMERIC
          * (f_system = 1)::INT
        )::NUMERIC
        /
        NULLIF(
          SUM(
            (miles * nhs_pct / 100)
            * (tttr IS NOT NULL)::INT
            * (f_system = 1)::INT
          )
          , 0
        )::NUMERIC
        , 2 -- to nearest 1/100th
      )::DOUBLE PRECISION AS tttr_interstate,
      ROUND(
        SUM(
          ROUND(phed::NUMERIC, 3)
          * (NULLIF(nhs_pct, 0) IS NOT NULL)::INT
        )
        , 1 -- to nearest 1/10th
      )::DOUBLE PRECISION AS phed
    FROM cte_tmc_metadata
      INNER JOIN cte_tmc_level_pm3 USING (tmc, year)
    WHERE (
      (county_code IS NOT NULL)
    )
    GROUP BY county_code, state, state_code, year

  UNION ALL

  SELECT
      ''MPO'' AS geolevel,
      mpo_code AS geocode,
      ARRAY[state]::TEXT[] AS states,
      ARRAY[state_code]::TEXT[] AS state_codes,
      year,
      ROUND(
        SUM(
          (miles * nhs_pct / 100)
          * (ROUND(lottr::NUMERIC, 2) < 1.50)::INT
          * (f_system = 1)::INT
          * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
          * occ_fac::NUMERIC
        )::NUMERIC
        /
        NULLIF(
          SUM(
            (miles * nhs_pct / 100)
            * (lottr IS NOT NULL)::INT
            * (f_system = 1)::INT
            * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
            * occ_fac::NUMERIC
          )::NUMERIC
          , 0
        )::NUMERIC
        *
        100 -- To percent
        , 1 -- to nearest 1/10th
      )::DOUBLE PRECISION AS lottr_interstate,
      ROUND(
        SUM(
          (miles * nhs_pct / 100)
          * (ROUND(lottr::NUMERIC, 2) < 1.50)::INT
          * (f_system <> 1)::INT
          * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
          * occ_fac::NUMERIC
        )::NUMERIC
        /
        NULLIF(
          SUM(
            (miles * nhs_pct / 100)
            * (lottr IS NOT NULL)::INT
            * (f_system <> 1)::INT
            * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
            * occ_fac::NUMERIC
          )
          , 0
        )::NUMERIC
        *
        100 -- To percent
        , 1 -- to nearest 1/10th
      )::DOUBLE PRECISION AS lottr_noninterstate,
      ROUND(
        SUM(
          (miles * nhs_pct / 100)
          * ROUND((tttr::NUMERIC), 2)::NUMERIC
          * (f_system = 1)::INT
        )::NUMERIC
        /
        NULLIF(
          SUM(
            (miles * nhs_pct / 100)
            * (tttr IS NOT NULL)::INT
            * (f_system = 1)::INT
          )
          , 0
        )::NUMERIC
        , 2 -- to nearest 1/100th
      )::DOUBLE PRECISION AS tttr_interstate,
      ROUND(
        SUM(
          ROUND(phed::NUMERIC, 3)
          * (NULLIF(nhs_pct, 0) IS NOT NULL)::INT
        )
        , 1 -- to nearest 1/10th
      )::DOUBLE PRECISION AS phed
    FROM cte_tmc_metadata
      INNER JOIN cte_tmc_level_pm3 USING (tmc, year)
    WHERE (
      (mpo_code IS NOT NULL)
    )
    GROUP BY mpo_code, state, state_code, year

  UNION ALL

  SELECT
      ''UA'' AS geolevel,
      ua_code AS geocode,
      array_agg(DISTINCT state ORDER BY state)::TEXT[] AS states,
      array_agg(DISTINCT state_code ORDER BY state_code)::TEXT[] AS state_codes,
      year,
      ROUND(
        SUM(
          (miles * nhs_pct / 100)
          * (ROUND(lottr::NUMERIC, 2) < 1.50)::INT
          * (f_system = 1)::INT
          * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
          * occ_fac::NUMERIC
        )::NUMERIC
        /
        NULLIF(
          SUM(
            (miles * nhs_pct / 100)
            * (lottr IS NOT NULL)::INT
            * (f_system = 1)::INT
            * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
            * occ_fac::NUMERIC
          )::NUMERIC
          , 0
        )::NUMERIC
        *
        100 -- To percent
        , 1 -- to nearest 1/10th
      )::DOUBLE PRECISION AS lottr_interstate,
      ROUND(
        SUM(
          (miles * nhs_pct / 100)
          * (ROUND(lottr::NUMERIC, 2) < 1.50)::INT
          * (f_system <> 1)::INT
          * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
          * occ_fac::NUMERIC
        )::NUMERIC
        /
        NULLIF(
          SUM(
            (miles * nhs_pct / 100)
            * (lottr IS NOT NULL)::INT
            * (f_system <> 1)::INT
            * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
            * occ_fac::NUMERIC
          )
          , 0
        )::NUMERIC
        *
        100 -- To percent
        , 1 -- to nearest 1/10th
      )::DOUBLE PRECISION AS lottr_noninterstate,
      ROUND(
        SUM(
          (miles * nhs_pct / 100)
          * ROUND((tttr::NUMERIC), 2)::NUMERIC
          * (f_system = 1)::INT
        )::NUMERIC
        /
        NULLIF(
          SUM(
            (miles * nhs_pct / 100)
            * (tttr IS NOT NULL)::INT
            * (f_system = 1)::INT
          )
          , 0
        )::NUMERIC
        , 2 -- to nearest 1/100th
      )::DOUBLE PRECISION AS tttr_interstate,
      ROUND(
        SUM(
          ROUND(phed::NUMERIC, 3)
          * (NULLIF(nhs_pct, 0) IS NOT NULL)::INT
        )
        , 1 -- to nearest 1/10th
      )::DOUBLE PRECISION AS phed
    FROM cte_tmc_metadata
      INNER JOIN cte_tmc_level_pm3 USING (tmc, year)
    WHERE (
      (ua_code IS NOT NULL)
      AND
      (ua_code <> ''99998'')
      AND
      (ua_code <> ''99999'')
    )
    GROUP BY ua_code, year

  UNION ALL

  SELECT
    ''UA'' AS geolevel,
    ua_code AS geocode,
    array_agg(DISTINCT state ORDER BY state)::TEXT[] AS states,
    array_agg(DISTINCT state_code ORDER BY state_code)::TEXT[] AS state_codes,
    year,
    ROUND(
      SUM(
        (miles * nhs_pct / 100)
        * (ROUND(lottr::NUMERIC, 2) < 1.50)::INT
        * (f_system = 1)::INT
        * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
        * occ_fac::NUMERIC
      )::NUMERIC
      /
      NULLIF(
        SUM(
          (miles * nhs_pct / 100)
          * (lottr IS NOT NULL)::INT
          * (f_system = 1)::INT
          * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
          * occ_fac::NUMERIC
        )::NUMERIC
        , 0
      )::NUMERIC
      *
      100 -- To percent
      , 1 -- to nearest 1/10th
    )::DOUBLE PRECISION AS lottr_interstate,
    ROUND(
      SUM(
        (miles * nhs_pct / 100)
        * (ROUND(lottr::NUMERIC, 2) < 1.50)::INT
        * (f_system <> 1)::INT
        * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
        * occ_fac::NUMERIC
      )::NUMERIC
      /
      NULLIF(
        SUM(
          (miles * nhs_pct / 100)
          * (lottr IS NOT NULL)::INT
          * (f_system <> 1)::INT
          * ROUND(dir_aadt::NUMERIC, 0)::NUMERIC
          * occ_fac::NUMERIC
        )
        , 0
      )::NUMERIC
      *
      100 -- To percent
      , 1 -- to nearest 1/10th
    )::DOUBLE PRECISION AS lottr_noninterstate,
    ROUND(
      SUM(
        (miles * nhs_pct / 100)
        * ROUND((tttr::NUMERIC), 2)::NUMERIC
        * (f_system = 1)::INT
      )::NUMERIC
      /
      NULLIF(
        SUM(
          (miles * nhs_pct / 100)
          * (tttr IS NOT NULL)::INT
          * (f_system = 1)::INT
        )
        , 0
      )::NUMERIC
      , 2 -- to nearest 1/100th
    )::DOUBLE PRECISION AS tttr_interstate,
    ROUND(
      SUM(
        ROUND(phed::NUMERIC, 3)
        * (NULLIF(nhs_pct, 0) IS NOT NULL)::INT
      )
      , 1 -- to nearest 1/10th
    )::DOUBLE PRECISION AS phed
  FROM cte_tmc_metadata
    INNER JOIN cte_tmc_level_pm3 USING (tmc, year)
  WHERE (
    (ua_code IS NOT NULL)
    AND
    (
      (ua_code = ''99998'')
      OR
      (ua_code = ''99999'')
    )
  )
  GROUP BY ua_code, state, state_code, year
  ;
';


END;
$func$ LANGUAGE plpgsql;

SELECT pg_temp.tmp_create_pm3_authoritative_geolevel_mview();



