/*
  NOTE: __STATE__ replaced with 2 character state abbreviation for intrastate,
          a string not matching any state abbreviation for interstate. 
*/

BEGIN;

DROP TABLE IF EXISTS "__STATE__".top_level_freight_reliability_y__YEAR__m__MONTH__ CASCADE;

CREATE TEMPORARY TABLE tmp_relevant_states
  ON COMMIT DROP
  AS
    SELECT
        states::VARCHAR(2)[]
      FROM geography_level_attributes_view
      WHERE (ARRAY['__STATE__']::VARCHAR(2)[] = states) -- intrastate schema
    UNION
    SELECT
        states
      FROM geography_level_attributes_view
      WHERE (
        ('__STATE__' NOT IN (SELECT state FROM state_codes))
        AND
        (array_length(states, 1) > 1) -- interstate schema
      )
;

CREATE TEMPORARY TABLE tmp_tmc_data AS
  SELECT tmc::VARCHAR(9), 
         GREATEST(
           ((data->'AM_PEAK')->1)::TEXT::REAL / NULLIF(((data->'AM_PEAK')->0)::TEXT::REAL, 0),
           ((data->'MIDDAY')->1)::TEXT::REAL  / NULLIF(((data->'MIDDAY')->0)::TEXT::REAL, 0),
           ((data->'PM_PEAK')->1)::TEXT::REAL / NULLIF(((data->'PM_PEAK')->0)::TEXT::REAL, 0),
           ((data->'WEEKEND')->1)::TEXT::REAL / NULLIF(((data->'WEEKEND')->0)::TEXT::REAL, 0),
           ((data->'OVERNIGHT')->1)::TEXT::REAL / NULLIF(((data->'OVERNIGHT')->0)::TEXT::REAL, 0)
         )::REAL AS tttr_for_tmc,
         CASE WHEN (is_interstate = true) THEN 'INTERSTATE'::functional_class_type
           ELSE 'NONINTERSTATE'::functional_class_type
         END AS functional_class,
         miles::REAL
    FROM tttr_percentiles
      LEFT OUTER JOIN tmc_attributes USING (state, tmc)
    WHERE (
      (state IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states))
      AND
      (year = '__YEAR__')
      AND
      (month = '__MONTH__')
    )
;

CREATE TABLE "__STATE__".top_level_freight_reliability_y__YEAR__m__MONTH__ AS

  -- State Level
  SELECT ARRAY['__STATE__']::VARCHAR(2)[] AS states,
       __YEAR__::SMALLINT AS year,
       __MONTH__::SMALLINT AS month,
       'STATE'::geography_level_type AS geography_level,
       '__STATE__'::VARCHAR AS geography_name,
       functional_class::functional_class_type,
       ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
       ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
       included_tmcs_ct::INTEGER,
       excluded_tmcs_ct::INTEGER,
       ARRAY[
         ROUND(tttr_quartiles[1]::NUMERIC, 3),
         ROUND(tttr_quartiles[2]::NUMERIC, 3),
         ROUND(tttr_quartiles[3]::NUMERIC, 3),
         ROUND(tttr_quartiles[4]::NUMERIC, 3),
         ROUND(tttr_quartiles[5]::NUMERIC, 3)
       ]::REAL[5] AS tttr_quartiles,
       ROUND(tttr_mean::NUMERIC, 3)::REAL AS tttr_mean,
       ROUND(tttr_stddev::NUMERIC, 3)::REAL AS tttr_stddev,
       ROUND((weighted_total / included_mi)::NUMERIC, 3)::REAL AS fr
  FROM (
    SELECT functional_class,
           SUM(tmp_tmc_data.miles * tttr_for_tmc)::REAL AS weighted_total,
           SUM(tmp_tmc_data.miles) AS included_mi,
           PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
             WITHIN GROUP (ORDER BY tttr_for_tmc) AS tttr_quartiles,
           AVG(tttr_for_tmc) AS tttr_mean,
           STDDEV_POP(tttr_for_tmc) AS tttr_stddev,
           COUNT(tmp_tmc_data.tmc) AS included_tmcs_ct
      FROM tmp_tmc_data
      WHERE (
        (tttr_for_tmc IS NOT NULL)
        AND (tmp_tmc_data.miles IS NOT NULL)
        AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
      )
      GROUP BY functional_class
  ) AS measure_calculation
  FULL OUTER JOIN (
    -- The summary stats for excluded TMCs.
    SELECT functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct
      FROM tmp_tmc_data
      WHERE (
        (
          (tttr_for_tmc IS NULL)
          OR (tmp_tmc_data.miles IS NULL)
        )
        AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
      )
      GROUP BY functional_class
  ) AS excluded
  USING (functional_class)

  UNION ALL -- Region Level

  SELECT ARRAY['__STATE__']::VARCHAR(2)[] AS states,
       __YEAR__::SMALLINT AS year,
       __MONTH__::SMALLINT AS month,
       'REGION'::geography_level_type AS geography_level,
       geography_name::VARCHAR,
       functional_class::functional_class_type,
       ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
       ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
       included_tmcs_ct::INTEGER,
       excluded_tmcs_ct::INTEGER,
       ARRAY[
         ROUND(tttr_quartiles[1]::NUMERIC, 3),
         ROUND(tttr_quartiles[2]::NUMERIC, 3),
         ROUND(tttr_quartiles[3]::NUMERIC, 3),
         ROUND(tttr_quartiles[4]::NUMERIC, 3),
         ROUND(tttr_quartiles[5]::NUMERIC, 3)
       ]::REAL[5] AS tttr_quartiles,
       ROUND(tttr_mean::NUMERIC, 3)::REAL AS tttr_mean,
       ROUND(tttr_stddev::NUMERIC, 3)::REAL AS tttr_stddev,
       ROUND((weighted_total / included_mi)::NUMERIC, 3)::REAL AS fr
  FROM (
    SELECT region_name AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles * tttr_for_tmc)::REAL AS weighted_total,
           SUM(tmp_tmc_data.miles) AS included_mi,
           PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
             WITHIN GROUP (ORDER BY tttr_for_tmc) AS tttr_quartiles,
           AVG(tttr_for_tmc) AS tttr_mean,
           STDDEV_POP(tttr_for_tmc) AS tttr_stddev,
           COUNT(tmp_tmc_data.tmc) AS included_tmcs_ct
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes USING (tmc)
      WHERE (
        (tttr_for_tmc IS NOT NULL)
        AND (tmp_tmc_data.miles IS NOT NULL)
        AND (region_name IS NOT NULL)
        AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
      )
      GROUP BY geography_name, functional_class
  ) AS measure_calculation
  FULL OUTER JOIN (
    SELECT region_name AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes USING (tmc)
      WHERE (
        (
          (tttr_for_tmc IS NULL)
          OR
          (tmp_tmc_data.miles IS NULL)
        )
        AND (region_name IS NOT NULL)
        AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
      )
      GROUP BY geography_name, functional_class
  ) AS excluded
  USING (geography_name, functional_class)

  UNION ALL -- County Level

  SELECT ARRAY['__STATE__']::VARCHAR(2)[] AS states,
       __YEAR__::SMALLINT AS year,
       __MONTH__::SMALLINT AS month,
       'COUNTY'::geography_level_type AS geography_level,
       geography_name::VARCHAR,
       functional_class::functional_class_type,
       ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
       ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
       included_tmcs_ct::INTEGER,
       excluded_tmcs_ct::INTEGER,
       ARRAY[
         ROUND(tttr_quartiles[1]::NUMERIC, 3),
         ROUND(tttr_quartiles[2]::NUMERIC, 3),
         ROUND(tttr_quartiles[3]::NUMERIC, 3),
         ROUND(tttr_quartiles[4]::NUMERIC, 3),
         ROUND(tttr_quartiles[5]::NUMERIC, 3)
       ]::REAL[5] AS tttr_quartiles,
       ROUND(tttr_mean::NUMERIC, 3)::REAL AS tttr_mean,
       ROUND(tttr_stddev::NUMERIC, 3)::REAL AS tttr_stddev,
       ROUND((weighted_total / included_mi)::NUMERIC, 3)::REAL AS fr
  FROM (
    SELECT county AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles * tttr_for_tmc)::REAL AS weighted_total,
           SUM(tmp_tmc_data.miles) AS included_mi,
           PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
             WITHIN GROUP (ORDER BY tttr_for_tmc) AS tttr_quartiles,
           AVG(tttr_for_tmc) AS tttr_mean,
           STDDEV_POP(tttr_for_tmc) AS tttr_stddev,
           COUNT(tmp_tmc_data.tmc) AS included_tmcs_ct
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes USING (tmc)
      WHERE (
        (tttr_for_tmc IS NOT NULL)
        AND (tmp_tmc_data.miles IS NOT NULL)
        AND (county IS NOT NULL)
        AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
      )
      GROUP BY geography_name, functional_class
  ) AS measure_calculation
  FULL OUTER JOIN (
    SELECT county AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes USING (tmc)
      WHERE (
        (
          (tttr_for_tmc IS NULL)
          OR
          (tmp_tmc_data.miles IS NULL)
        )
        AND (county IS NOT NULL)
        AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
      )
      GROUP BY geography_name, functional_class
  ) AS excluded
  USING (geography_name, functional_class)

  UNION ALL -- MPO Level

  SELECT ARRAY['__STATE__']::VARCHAR(2)[] AS states,
       __YEAR__::SMALLINT AS year,
       __MONTH__::SMALLINT AS month,
       'MPO'::geography_level_type AS geography_level,
       geography_name::VARCHAR,
       functional_class::functional_class_type,
       ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
       ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
       included_tmcs_ct::INTEGER,
       excluded_tmcs_ct::INTEGER,
       ARRAY[
         ROUND(tttr_quartiles[1]::NUMERIC, 3),
         ROUND(tttr_quartiles[2]::NUMERIC, 3),
         ROUND(tttr_quartiles[3]::NUMERIC, 3),
         ROUND(tttr_quartiles[4]::NUMERIC, 3),
         ROUND(tttr_quartiles[5]::NUMERIC, 3)
       ]::REAL[5] AS tttr_quartiles,
       ROUND(tttr_mean::NUMERIC, 3)::REAL AS tttr_mean,
       ROUND(tttr_stddev::NUMERIC, 3)::REAL AS tttr_stddev,
       ROUND((weighted_total / included_mi)::NUMERIC, 3)::REAL AS fr
  FROM (
    SELECT mpo_acrony AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles * tttr_for_tmc)::REAL AS weighted_total,
           SUM(tmp_tmc_data.miles) AS included_mi,
           PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
             WITHIN GROUP (ORDER BY tttr_for_tmc) AS tttr_quartiles,
           AVG(tttr_for_tmc) AS tttr_mean,
           STDDEV_POP(tttr_for_tmc) AS tttr_stddev,
           COUNT(tmp_tmc_data.tmc) AS included_tmcs_ct
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes USING (tmc)
      WHERE (
        (tttr_for_tmc IS NOT NULL)
        AND (tmp_tmc_data.miles IS NOT NULL)
        AND (mpo_acrony IS NOT NULL)
        AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
      )
      GROUP BY geography_name, functional_class
  ) AS measure_calculation
  FULL OUTER JOIN (
    SELECT mpo_acrony AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes USING (tmc)
      WHERE (
        (
          (tttr_for_tmc IS NULL)
          OR
          (tmp_tmc_data.miles IS NULL)
        )
        AND (mpo_acrony IS NOT NULL)
        AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
      )
      GROUP BY geography_name, functional_class
  ) AS excluded
  USING (geography_name, functional_class)

  UNION ALL -- UA Level

  SELECT states,
       __YEAR__::SMALLINT AS year,
       __MONTH__::SMALLINT AS month,
       'UA'::geography_level_type AS geography_level,
       geography_name::VARCHAR,
       functional_class::functional_class_type,
       ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
       ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
       included_tmcs_ct::INTEGER,
       excluded_tmcs_ct::INTEGER,
       ARRAY[
         ROUND(tttr_quartiles[1]::NUMERIC, 3),
         ROUND(tttr_quartiles[2]::NUMERIC, 3),
         ROUND(tttr_quartiles[3]::NUMERIC, 3),
         ROUND(tttr_quartiles[4]::NUMERIC, 3),
         ROUND(tttr_quartiles[5]::NUMERIC, 3)
       ]::REAL[5] AS tttr_quartiles,
       ROUND(tttr_mean::NUMERIC, 3)::REAL AS tttr_mean,
       ROUND(tttr_stddev::NUMERIC, 3)::REAL AS tttr_stddev,
       ROUND((weighted_total / included_mi)::NUMERIC, 3)::REAL AS fr
  FROM (
    SELECT ua_name AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles * tttr_for_tmc)::REAL AS weighted_total,
           SUM(tmp_tmc_data.miles) AS included_mi,
           PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
             WITHIN GROUP (ORDER BY tttr_for_tmc) AS tttr_quartiles,
           AVG(tttr_for_tmc) AS tttr_mean,
           STDDEV_POP(tttr_for_tmc) AS tttr_stddev,
           COUNT(tmp_tmc_data.tmc) AS included_tmcs_ct,
           tmp_relevant_states.states
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes USING (tmc)
        INNER JOIN tmp_relevant_states ON (tmc_attributes.state = ANY(tmp_relevant_states.states))
        INNER JOIN geography_level_attributes_view ON (
          (tmc_attributes.ua_name = geography_level_attributes_view.geography_level_name)
          AND
          (tmp_relevant_states.states = geography_level_attributes_view.states)
        )
      WHERE ((tttr_for_tmc IS NOT NULL) AND (tmp_tmc_data.miles IS NOT NULL))
        AND (ua_name IS NOT NULL)
      GROUP BY geography_name, functional_class, tmp_relevant_states.states
  ) AS measure_calculation
  FULL OUTER JOIN (
    SELECT ua_name AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct,
           tmp_relevant_states.states
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes USING (tmc)
        INNER JOIN tmp_relevant_states ON (tmc_attributes.state = ANY(tmp_relevant_states.states))
        INNER JOIN geography_level_attributes_view ON (
          (tmc_attributes.ua_name = geography_level_attributes_view.geography_level_name)
          AND
          (tmp_relevant_states.states = geography_level_attributes_view.states)
        )
      WHERE (
        (
          (tttr_for_tmc IS NULL)
          OR
          (tmp_tmc_data.miles IS NULL)
        )
        AND (ua_name IS NOT NULL)
        AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
      )
      GROUP BY geography_name, functional_class, tmp_relevant_states.states
  ) AS excluded USING (geography_name, functional_class, states)
;
  

DROP TABLE tmp_tmc_data;


ALTER TABLE "__STATE__".top_level_freight_reliability_y__YEAR__m__MONTH__
  ADD CONSTRAINT state_check CHECK (
    (states = ARRAY['__STATE__']::VARCHAR(2)[]) OR (ARRAY_LENGTH(states, 1) > 1)
  ),
  ADD CONSTRAINT date_range 
    CHECK ((year = __YEAR__) AND (month = __MONTH__)),
  INHERIT "__STATE__".top_level_freight_reliability,
  SET (fillfactor = 100);


CREATE UNIQUE INDEX top_level_freight_reliability_y__YEAR__m__MONTH___idx
  ON "__STATE__".top_level_freight_reliability_y__YEAR__m__MONTH__ 
    (geography_level, geography_name, functional_class)
  WITH (fillfactor = 100);

ALTER TABLE "__STATE__".top_level_freight_reliability_y__YEAR__m__MONTH__
  ADD CONSTRAINT top_level_freight_reliability_y__YEAR__m__MONTH___pkey
    PRIMARY KEY USING INDEX top_level_freight_reliability_y__YEAR__m__MONTH___idx;


CLUSTER VERBOSE "__STATE__".top_level_freight_reliability_y__YEAR__m__MONTH__
  USING top_level_freight_reliability_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".top_level_freight_reliability_y__YEAR__m__MONTH__;
