/*
  NOTE: __STATE__ replaced with 2 character state abbreviation for intrastate,
          a string not matching any state abbreviation for interstate. 
  LOTTR
  Time binning the NPMRDS data
    WITH framing for 15min averages

  Time Bins:
    AM_PEAK
      => epoch = (6*12) = 72
      => 15 min bin = (72 / 3) = 24
    MIDDAY
      => epoch = (10*12) = 120
      => 15 min bin = (120 / 3) = 40
    PM_PEAK
      => epoch = (16*12) = 192
      => 15 min bin = (192 / 3) = 64
    WEEKEND
      => epoch = (20*12) = 240
      => 15 min bin = (240 / 3) = 80
*/

BEGIN;

DROP TABLE IF EXISTS "__STATE__".top_level_travel_time_reliability_y__YEAR__m__MONTH__ CASCADE;

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

CREATE TEMPORARY TABLE tmp_tmc_lottr_data
  ON COMMIT DROP
  AS
    SELECT tmc::VARCHAR(9), 
           GREATEST(
             ((data->'AM_PEAK')->1)::TEXT::REAL / NULLIF(((data->'AM_PEAK')->0)::TEXT::REAL, 0),
             ((data->'MIDDAY')->1)::TEXT::REAL  / NULLIF(((data->'MIDDAY')->0)::TEXT::REAL, 0),
             ((data->'PM_PEAK')->1)::TEXT::REAL / NULLIF(((data->'PM_PEAK')->0)::TEXT::REAL, 0),
             ((data->'WEEKEND')->1)::TEXT::REAL / NULLIF(((data->'WEEKEND')->0)::TEXT::REAL, 0)
           )::REAL AS max_lottr,
           CASE WHEN (is_interstate = true) THEN 'INTERSTATE'::functional_class_type
             ELSE 'NONINTERSTATE'::functional_class_type
           END AS functional_class,
           miles::REAL,
           aadt::INT
      FROM lottr_percentiles
        LEFT OUTER JOIN tmc_attributes USING (state, tmc)
      WHERE (
        (state IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states))
        AND
        (year = '__YEAR__')
        AND
        (month = '__MONTH__')
      )
;


CREATE TABLE "__STATE__".top_level_travel_time_reliability_y__YEAR__m__MONTH__ AS

  -- State Level. Should be empty set when schema is interstate.
  SELECT ARRAY['__STATE__']::VARCHAR(2)[] AS states,
         __YEAR__::SMALLINT AS year,
         __MONTH__::SMALLINT AS month,
         'STATE'::geography_level_type AS geography_level,
         '__STATE__'::VARCHAR AS geography_name,
         functional_class::functional_class_type,
         ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
         ROUND(passing_mi::NUMERIC, 4)::REAL AS passing_mi,
         ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
         included_tmcs_ct::INTEGER,
         excluded_tmcs_ct::INTEGER,
         ARRAY[
           ROUND(lottr_quartiles[1]::NUMERIC, 3),
           ROUND(lottr_quartiles[2]::NUMERIC, 3),
           ROUND(lottr_quartiles[3]::NUMERIC, 3),
           ROUND(lottr_quartiles[4]::NUMERIC, 3),
           ROUND(lottr_quartiles[5]::NUMERIC, 3)
         ]::REAL[5] AS lottr_quartiles,
         ROUND(lottr_mean::NUMERIC, 3)::REAL AS lottr_mean,
         ROUND(lottr_stddev::NUMERIC, 3)::REAL AS lottr_stddev,
         ROUND(
           (passing.weighted_sum / NULLIF(passing_and_failing.weighted_sum, 0))::NUMERIC,
           3
         )::REAL AS ttr
    FROM (
      SELECT functional_class,
             SUM(tmp_tmc_lottr_data.miles * tmp_tmc_lottr_data. aadt)::REAL AS weighted_sum,
             SUM(tmp_tmc_lottr_data.miles) AS passing_mi
        FROM tmp_tmc_lottr_data
        WHERE (
          (max_lottr < 1.5)
          AND (tmp_tmc_lottr_data.miles IS NOT NULL)
          AND (tmp_tmc_lottr_data.aadt IS NOT NULL)
          AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
        )
        GROUP BY functional_class
    ) AS passing 
    FULL OUTER JOIN (
      SELECT functional_class,
             SUM(tmp_tmc_lottr_data.miles * tmp_tmc_lottr_data. aadt)::REAL AS weighted_sum,
             SUM(tmp_tmc_lottr_data.miles) AS included_mi,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY max_lottr) AS lottr_quartiles,
             AVG(max_lottr) AS lottr_mean,
             STDDEV_POP(max_lottr) AS lottr_stddev,
             COUNT(tmp_tmc_lottr_data.tmc) AS included_tmcs_ct
        FROM tmp_tmc_lottr_data
        WHERE (
          (tmp_tmc_lottr_data.miles IS NOT NULL)
          AND (tmp_tmc_lottr_data.aadt IS NOT NULL)
          AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
        )
        GROUP BY functional_class
    ) AS passing_and_failing USING (functional_class)
    FULL OUTER JOIN (
      SELECT functional_class,
             SUM(tmp_tmc_lottr_data.miles) AS excluded_mi,
             COUNT(tmp_tmc_lottr_data.tmc) AS excluded_tmcs_ct
        FROM tmp_tmc_lottr_data
        WHERE (
          (
            (tmp_tmc_lottr_data.miles IS NULL)
            OR 
            (tmp_tmc_lottr_data.aadt IS NULL)
          ) 
          AND
          ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
        )
        GROUP BY functional_class
    ) AS excluded USING (functional_class)

  UNION ALL -- Region Level. Should be empty set when schema is interstate.

  SELECT ARRAY['__STATE__']::VARCHAR(2)[] AS states,
         __YEAR__::SMALLINT AS year,
         __MONTH__::SMALLINT AS month,
         'REGION'::geography_level_type AS geography_level,
         geography_name::VARCHAR,
         functional_class::functional_class_type,
         ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
         ROUND(passing_mi::NUMERIC, 3)::REAL AS passing_mi,
         ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
         included_tmcs_ct::INTEGER,
         excluded_tmcs_ct::INTEGER,
         ARRAY[
           ROUND(lottr_quartiles[1]::NUMERIC, 3),
           ROUND(lottr_quartiles[2]::NUMERIC, 3),
           ROUND(lottr_quartiles[3]::NUMERIC, 3),
           ROUND(lottr_quartiles[4]::NUMERIC, 3),
           ROUND(lottr_quartiles[5]::NUMERIC, 3)
         ]::REAL[5] AS lottr_quartiles,
         ROUND(lottr_mean::NUMERIC, 3)::REAL AS lottr_mean,
         ROUND(lottr_stddev::NUMERIC, 3)::REAL AS lottr_stddev,
         ROUND((passing.weighted_sum / NULLIF(passing_and_failing.weighted_sum, 0))::NUMERIC, 3)::REAL AS ttr
    FROM (
      -- Passing
      SELECT region_name AS geography_name,
             functional_class,
             SUM(tmp_tmc_lottr_data.miles * tmp_tmc_lottr_data. aadt)::REAL AS weighted_sum,
             SUM(tmp_tmc_lottr_data.miles) AS passing_mi
        FROM tmp_tmc_lottr_data
          INNER JOIN tmc_attributes AS geo_partitions USING (tmc)
        WHERE (
          (max_lottr < 1.5)
          AND (tmp_tmc_lottr_data.miles IS NOT NULL)
          AND (tmp_tmc_lottr_data.aadt IS NOT NULL)
          AND (region_name IS NOT NULL)
          AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
        )
        GROUP BY geography_name, functional_class
    ) AS passing 
    FULL OUTER JOIN (
      -- Total
      SELECT region_name AS geography_name,
             functional_class,
             SUM(tmp_tmc_lottr_data.miles * tmp_tmc_lottr_data. aadt)::REAL AS weighted_sum,
             SUM(tmp_tmc_lottr_data.miles) AS included_mi,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY max_lottr) AS lottr_quartiles,
             AVG(max_lottr) AS lottr_mean,
             STDDEV_POP(max_lottr) AS lottr_stddev,
             COUNT(tmp_tmc_lottr_data.tmc) AS included_tmcs_ct
        FROM tmp_tmc_lottr_data
          INNER JOIN tmc_attributes AS geo_partitions USING (tmc)
        WHERE (
          (tmp_tmc_lottr_data.miles IS NOT NULL)
          AND (tmp_tmc_lottr_data.aadt IS NOT NULL)
          AND (region_name IS NOT NULL)
          AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
        )
        GROUP BY geography_name, functional_class
    ) AS passing_and_failing USING (geography_name, functional_class)
    FULL OUTER JOIN (
      SELECT region_name AS geography_name,
             functional_class,
             SUM(tmp_tmc_lottr_data.miles) AS excluded_mi,
             COUNT(tmp_tmc_lottr_data.tmc) AS excluded_tmcs_ct
        FROM tmp_tmc_lottr_data
          INNER JOIN tmc_attributes AS geo_partitions USING (tmc)
        WHERE (
          (
            (tmp_tmc_lottr_data.miles IS NULL)
            OR
            (tmp_tmc_lottr_data.aadt IS NULL)
          )
          AND (region_name IS NOT NULL)
          AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
        )
        GROUP BY geography_name, functional_class
    ) AS excluded USING (geography_name, functional_class)

  UNION ALL -- County Level. Should be empty set when schema is interstate.

  SELECT ARRAY['__STATE__']::VARCHAR(2)[] AS states,
         __YEAR__::SMALLINT AS year,
         __MONTH__::SMALLINT AS month,
         'COUNTY'::geography_level_type AS geography_level,
         geography_name::VARCHAR,
         functional_class::functional_class_type,
         ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
         ROUND(passing_mi::NUMERIC, 3)::REAL AS passing_mi,
         ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
         included_tmcs_ct::INTEGER,
         excluded_tmcs_ct::INTEGER,
         ARRAY[
           ROUND(lottr_quartiles[1]::NUMERIC, 3),
           ROUND(lottr_quartiles[2]::NUMERIC, 3),
           ROUND(lottr_quartiles[3]::NUMERIC, 3),
           ROUND(lottr_quartiles[4]::NUMERIC, 3),
           ROUND(lottr_quartiles[5]::NUMERIC, 3)
         ]::REAL[5] AS lottr_quartiles,
         ROUND(lottr_mean::NUMERIC, 3)::REAL AS lottr_mean,
         ROUND(lottr_stddev::NUMERIC, 3)::REAL AS lottr_stddev,
         ROUND((passing.weighted_sum / NULLIF(passing_and_failing.weighted_sum, 0))::NUMERIC, 3)::REAL AS ttr
    FROM (
      -- Passing
      SELECT county AS geography_name,
             functional_class,
             SUM(tmp_tmc_lottr_data.miles * tmp_tmc_lottr_data. aadt)::REAL AS weighted_sum,
             SUM(tmp_tmc_lottr_data.miles) AS passing_mi
        FROM tmp_tmc_lottr_data
          INNER JOIN tmc_attributes AS geo_partitions USING (tmc)
        WHERE (
          (max_lottr < 1.5)
          AND ((tmp_tmc_lottr_data.miles IS NOT NULL) AND (tmp_tmc_lottr_data.aadt IS NOT NULL))
          AND (county IS NOT NULL)
          AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
        )
        GROUP BY geography_name, functional_class
    ) AS passing 
    FULL OUTER JOIN (
      -- Total
      SELECT county AS geography_name,
             functional_class,
             SUM(tmp_tmc_lottr_data.miles * tmp_tmc_lottr_data. aadt)::REAL AS weighted_sum,
             SUM(tmp_tmc_lottr_data.miles) AS included_mi,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY max_lottr) AS lottr_quartiles,
             AVG(max_lottr) AS lottr_mean,
             STDDEV_POP(max_lottr) AS lottr_stddev,
             COUNT(tmp_tmc_lottr_data.tmc) AS included_tmcs_ct
        FROM tmp_tmc_lottr_data
          INNER JOIN tmc_attributes AS geo_partitions USING (tmc)
        WHERE (
          (tmp_tmc_lottr_data.miles IS NOT NULL)
          AND (tmp_tmc_lottr_data.aadt IS NOT NULL)
          AND (county IS NOT NULL)
          AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
        )
        GROUP BY geography_name, functional_class
    ) AS passing_and_failing USING (geography_name, functional_class)
    FULL OUTER JOIN (
      SELECT county AS geography_name,
             functional_class,
             SUM(tmp_tmc_lottr_data.miles) AS excluded_mi,
             COUNT(tmp_tmc_lottr_data.tmc) AS excluded_tmcs_ct
        FROM tmp_tmc_lottr_data
          INNER JOIN tmc_attributes AS geo_partitions USING (tmc)
        WHERE (
          (
            (tmp_tmc_lottr_data.miles IS NULL)
            OR
            (tmp_tmc_lottr_data.aadt IS NULL)
          )
          AND (county IS NOT NULL)
          AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
        )
        GROUP BY geography_name, functional_class
    ) AS excluded USING (geography_name, functional_class)

  UNION ALL -- MPO Level. Should be empty set when schema is interstate.

  SELECT ARRAY['__STATE__']::VARCHAR(2)[] AS states,
         __YEAR__::SMALLINT AS year,
         __MONTH__::SMALLINT AS month,
         'MPO'::geography_level_type AS geography_level,
         geography_name::VARCHAR,
         functional_class::functional_class_type,
         ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
         ROUND(passing_mi::NUMERIC, 3)::REAL AS passing_mi,
         ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
         included_tmcs_ct::INTEGER,
         excluded_tmcs_ct::INTEGER,
         ARRAY[
           ROUND(lottr_quartiles[1]::NUMERIC, 3),
           ROUND(lottr_quartiles[2]::NUMERIC, 3),
           ROUND(lottr_quartiles[3]::NUMERIC, 3),
           ROUND(lottr_quartiles[4]::NUMERIC, 3),
           ROUND(lottr_quartiles[5]::NUMERIC, 3)
         ]::REAL[5] AS lottr_quartiles,
         ROUND(lottr_mean::NUMERIC, 3)::REAL AS lottr_mean,
         ROUND(lottr_stddev::NUMERIC, 3)::REAL AS lottr_stddev,
         ROUND((passing.weighted_sum / NULLIF(passing_and_failing.weighted_sum, 0))::NUMERIC, 3)::REAL AS ttr
    FROM (
      SELECT mpo_acrony AS geography_name,
             functional_class,
             SUM(tmp_tmc_lottr_data.miles * tmp_tmc_lottr_data. aadt)::REAL AS weighted_sum,
             SUM(tmp_tmc_lottr_data.miles) AS passing_mi
        FROM tmp_tmc_lottr_data
          INNER JOIN tmc_attributes AS geo_partitions USING (tmc)
        WHERE (
          (max_lottr < 1.5)
          AND (tmp_tmc_lottr_data.miles IS NOT NULL)
          AND (tmp_tmc_lottr_data.aadt IS NOT NULL)
          AND (mpo_acrony IS NOT NULL)
          AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
        )
        GROUP BY geography_name, functional_class
    ) AS passing 
    FULL OUTER JOIN (
      SELECT mpo_acrony AS geography_name,
             functional_class,
             SUM(tmp_tmc_lottr_data.miles * tmp_tmc_lottr_data. aadt)::REAL AS weighted_sum,
             SUM(tmp_tmc_lottr_data.miles) AS included_mi,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY max_lottr) AS lottr_quartiles,
             AVG(max_lottr) AS lottr_mean,
             STDDEV_POP(max_lottr) AS lottr_stddev,
             COUNT(tmp_tmc_lottr_data.tmc) AS included_tmcs_ct
        FROM tmp_tmc_lottr_data
          INNER JOIN tmc_attributes AS geo_partitions USING (tmc)
        WHERE (
          (tmp_tmc_lottr_data.miles IS NOT NULL)
          AND (tmp_tmc_lottr_data.aadt IS NOT NULL)
          AND (mpo_acrony IS NOT NULL)
          AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
        )
        GROUP BY geography_name, functional_class
    ) AS passing_and_failing USING (geography_name, functional_class)
    FULL OUTER JOIN (
      SELECT mpo_acrony AS geography_name,
             functional_class,
             SUM(tmp_tmc_lottr_data.miles) AS excluded_mi,
             COUNT(tmp_tmc_lottr_data.tmc) AS excluded_tmcs_ct
        FROM tmp_tmc_lottr_data
          INNER JOIN tmc_attributes AS geo_partitions USING (tmc)
        WHERE (
          (
            (tmp_tmc_lottr_data.miles IS NULL)
            OR
            (tmp_tmc_lottr_data.aadt IS NULL)
          )
          AND (mpo_acrony IS NOT NULL)
          AND ('__STATE__' IN (SELECT DISTINCT UNNEST(states) FROM tmp_relevant_states)) -- filter
        )
        GROUP BY geography_name, functional_class
    ) AS excluded USING (geography_name, functional_class)

  UNION ALL -- UA Level. Should be nonempty set when schema is interstate.

  SELECT states,
         __YEAR__::SMALLINT AS year,
         __MONTH__::SMALLINT AS month,
         'UA'::geography_level_type AS geography_level,
         geography_name::VARCHAR,
         functional_class::functional_class_type,
         ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
         ROUND(passing_mi::NUMERIC, 3)::REAL AS passing_mi,
         ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
         included_tmcs_ct::INTEGER,
         excluded_tmcs_ct::INTEGER,
         ARRAY[
           ROUND(lottr_quartiles[1]::NUMERIC, 3),
           ROUND(lottr_quartiles[2]::NUMERIC, 3),
           ROUND(lottr_quartiles[3]::NUMERIC, 3),
           ROUND(lottr_quartiles[4]::NUMERIC, 3),
           ROUND(lottr_quartiles[5]::NUMERIC, 3)
         ]::REAL[5] AS lottr_quartiles,
         ROUND(lottr_mean::NUMERIC, 3)::REAL AS lottr_mean,
         ROUND(lottr_stddev::NUMERIC, 3)::REAL AS lottr_stddev,
         ROUND((passing.weighted_sum / NULLIF(passing_and_failing.weighted_sum, 0))::NUMERIC, 3)::REAL AS ttr
    FROM (
      SELECT ua_name AS geography_name,
             functional_class,
             SUM(tmp_tmc_lottr_data.miles * tmp_tmc_lottr_data. aadt)::REAL AS weighted_sum,
             SUM(tmp_tmc_lottr_data.miles) AS passing_mi,
             tmp_relevant_states.states
        FROM tmp_tmc_lottr_data
          INNER JOIN tmc_attributes AS geo_partitions USING (tmc)
          INNER JOIN tmp_relevant_states ON (geo_partitions.state = ANY(tmp_relevant_states.states))
          INNER JOIN geography_level_attributes_view ON (
            (geo_partitions.ua_name = geography_level_attributes_view.geography_level_name)
            AND
            (tmp_relevant_states.states = geography_level_attributes_view.states)
          )
        WHERE (
          (max_lottr < 1.5)
          AND ((tmp_tmc_lottr_data.miles IS NOT NULL) AND (tmp_tmc_lottr_data.aadt IS NOT NULL))
          AND (ua_name IS NOT NULL)
        )
        GROUP BY geography_name, functional_class, tmp_relevant_states.states
    ) AS passing 
    FULL OUTER JOIN (
      SELECT ua_name AS geography_name,
             functional_class,
             SUM(tmp_tmc_lottr_data.miles * tmp_tmc_lottr_data. aadt)::REAL AS weighted_sum,
             SUM(tmp_tmc_lottr_data.miles) AS included_mi,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY max_lottr) AS lottr_quartiles,
             AVG(max_lottr) AS lottr_mean,
             STDDEV_POP(max_lottr) AS lottr_stddev,
             COUNT(tmp_tmc_lottr_data.tmc) AS included_tmcs_ct,
             tmp_relevant_states.states
        FROM tmp_tmc_lottr_data
          INNER JOIN tmc_attributes AS geo_partitions USING (tmc)
          INNER JOIN tmp_relevant_states ON (geo_partitions.state = ANY(tmp_relevant_states.states))
          INNER JOIN geography_level_attributes_view ON (
            (geo_partitions.ua_name = geography_level_attributes_view.geography_level_name)
            AND
            (tmp_relevant_states.states = geography_level_attributes_view.states)
          )
        WHERE (
          (tmp_tmc_lottr_data.miles IS NOT NULL)
          AND (tmp_tmc_lottr_data.aadt IS NOT NULL)
          AND (ua_name IS NOT NULL)
        )
        GROUP BY geography_name, functional_class, tmp_relevant_states.states
    ) AS passing_and_failing USING (geography_name, functional_class, states)
    FULL OUTER JOIN (
      SELECT ua_name AS geography_name,
             functional_class,
             SUM(tmp_tmc_lottr_data.miles) AS excluded_mi,
             COUNT(tmp_tmc_lottr_data.tmc) AS excluded_tmcs_ct,
             tmp_relevant_states.states
        FROM tmp_tmc_lottr_data
          INNER JOIN tmc_attributes AS geo_partitions USING (tmc)
          INNER JOIN tmp_relevant_states ON (geo_partitions.state = ANY(tmp_relevant_states.states))
          INNER JOIN geography_level_attributes_view ON (
            (geo_partitions.ua_name = geography_level_attributes_view.geography_level_name)
            AND
            (tmp_relevant_states.states = geography_level_attributes_view.states)
          )
        WHERE (
          (
            (tmp_tmc_lottr_data.miles IS NULL)
            OR
            (tmp_tmc_lottr_data.aadt IS NULL)
          )
          AND (ua_name IS NOT NULL)
        )
        GROUP BY geography_name, functional_class, tmp_relevant_states.states
    ) AS excluded USING (geography_name, functional_class, states)
  ;
  

ALTER TABLE "__STATE__".top_level_travel_time_reliability_y__YEAR__m__MONTH__
  ADD CONSTRAINT state_check CHECK (
    (states = ARRAY['__STATE__']::VARCHAR(2)[]) OR (ARRAY_LENGTH(states, 1) > 1)
  ),
  ADD CONSTRAINT date_range 
    CHECK ((year = __YEAR__) AND (month = __MONTH__)),
  INHERIT "__STATE__".top_level_travel_time_reliability,
  SET (fillfactor = 100, autovacuum_enabled=false);


CREATE UNIQUE INDEX top_level_travel_time_reliability_y__YEAR__m__MONTH___idx
  ON "__STATE__".top_level_travel_time_reliability_y__YEAR__m__MONTH__ 
    (geography_level, geography_name, functional_class, states)
  WITH (fillfactor = 100);

ALTER TABLE "__STATE__".top_level_travel_time_reliability_y__YEAR__m__MONTH__
  ADD CONSTRAINT top_level_travel_time_reliability_y__YEAR__m__MONTH___pkey
    PRIMARY KEY USING INDEX top_level_travel_time_reliability_y__YEAR__m__MONTH___idx;


CLUSTER VERBOSE "__STATE__".top_level_travel_time_reliability_y__YEAR__m__MONTH__
  USING top_level_travel_time_reliability_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".top_level_travel_time_reliability_y__YEAR__m__MONTH__;
