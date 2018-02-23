BEGIN;

CREATE OR REPLACE FUNCTION paginated_final_rule_measures_for_geography_fn (
    states          VARCHAR(2)[],
    geo_level_type  geography_level_type,
    geo_name        TEXT,
    sort_col        final_rule_measure_sort_column_type,
    sort_direction  TEXT,
    d_year          INT,
    d_month         INT,
    start_rank      INT,
    end_rank        INT
  )
  RETURNS TABLE (
    tmc            VARCHAR(9),
    lottr_am_peak  REAL,
    lottr_midday   REAL,
    lottr_pm_peak  REAL,
    lottr_weekend  REAL,
    tttr_am_peak   REAL,
    tttr_midday    REAL,
    tttr_pm_peak   REAL,
    tttr_weekend   REAL,
    tttr_overnight REAL,
    phed_am_peak   REAL,
    phed_pm1_peak  REAL,
    phed_pm2_peak  REAL
  )
  AS $body$
    WITH  cte_rankings AS (
      SELECT
          (rankings).tmc,
          (rankings).rank
        FROM (
          SELECT 
              CASE
                WHEN (
                  (sort_col IS NULL)
                  OR
                  (LOWER(sort_col::TEXT) = 'tmc')
                ) THEN tmc_lexographic_rankings_for_geography_fn (
                    states,
                    geo_level_type,
                    geo_name,
                    sort_direction,
                    start_rank,
                    end_rank
                ) ELSE final_rule_measure_rankings_for_geography_fn (
                    states,
                    geo_level_type,
                    geo_name,
                    sort_col,
                    sort_direction,
                    d_year,
                    d_month,
                    start_rank,
                    end_rank
                )
            END::tmc_ranking_type AS rankings
        ) AS sub_rankings
    ) SELECT 
        tmc,
        ROUND(lottr_am_peak::NUMERIC, 3)::REAL AS lottr_am_peak,
        ROUND(lottr_midday::NUMERIC, 3)::REAL AS lottr_midday,
        ROUND(lottr_pm_peak::NUMERIC, 3)::REAL AS lottr_pm_peak,
        ROUND(lottr_weekend::NUMERIC, 3)::REAL AS lottr_weekend,
        ROUND(tttr_am_peak::NUMERIC, 3)::REAL AS tttr_am_peak,
        ROUND(tttr_midday::NUMERIC, 3)::REAL AS tttr_midday,
        ROUND(tttr_pm_peak::NUMERIC, 3)::REAL AS tttr_pm_peak,
        ROUND(tttr_weekend::NUMERIC, 3)::REAL AS tttr_weekend,
        ROUND(tttr_overnight::NUMERIC, 3)::REAL AS tttr_overnight,
        ROUND(phed_am_peak::NUMERIC, 3)::REAL AS phed_am_peak,
        ROUND(phed_pm1_peak::NUMERIC, 3)::REAL AS phed_pm1_peak,
        ROUND(phed_pm2_peak::NUMERIC, 3)::REAL AS phed_pm2_peak
      FROM (
        SELECT *
          FROM lottr
            INNER JOIN cte_rankings USING (tmc)
          WHERE (
            (year = d_year)
            AND
            (month = COALESCE(d_month, 0))
          )
      ) AS sub_lottr
      FULL OUTER JOIN (
        SELECT *
          FROM tttr
            INNER JOIN cte_rankings USING (tmc)
          WHERE (
            (year = d_year)
            AND
            (month = COALESCE(d_month, 0))
          )
      ) AS sub_tttr USING (tmc, state, year, month, rank)
      FULL OUTER JOIN (
        SELECT *
          FROM phed
            INNER JOIN cte_rankings USING (tmc)
          WHERE (
            (year = d_year)
            AND
            (month = COALESCE(d_month, 0))
          )
      ) AS sub_phed USING (tmc, state, year, month, rank)
      ORDER BY rank

  $body$ LANGUAGE SQL
;

COMMIT;
