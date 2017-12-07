/*
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

CREATE TEMPORARY TABLE tmp_tmc_data AS
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
  FROM "__STATE__".lottr_percentiles_y__YEAR__m__MONTH__
    LEFT OUTER JOIN tmc_attributes USING (state, tmc);

DROP TABLE IF EXISTS "__STATE__".top_level_travel_time_reliability_y__YEAR__m__MONTH__ CASCADE;

-- State Level
CREATE TABLE "__STATE__".top_level_travel_time_reliability_y__YEAR__m__MONTH__ AS
SELECT '__STATE__'::VARCHAR(2) AS state,
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
       ROUND((passing.weighted_sum / NULLIF(passing_and_failing.weighted_sum, 0))::NUMERIC, 3)::REAL AS ttr
  FROM (
    SELECT functional_class,
           SUM(tmp_tmc_data.miles * tmp_tmc_data. aadt)::REAL AS weighted_sum,
           SUM(tmp_tmc_data.miles) AS passing_mi
      FROM tmp_tmc_data
      WHERE (max_lottr < 1.5)
        AND (tmp_tmc_data.miles IS NOT NULL)
        AND (tmp_tmc_data.aadt IS NOT NULL)
      GROUP BY functional_class
  ) AS passing 
  FULL OUTER JOIN (
    SELECT functional_class,
           SUM(tmp_tmc_data.miles * tmp_tmc_data. aadt)::REAL AS weighted_sum,
           SUM(tmp_tmc_data.miles) AS included_mi,
           PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
             WITHIN GROUP (ORDER BY max_lottr) AS lottr_quartiles,
           AVG(max_lottr) AS lottr_mean,
           STDDEV_POP(max_lottr) AS lottr_stddev,
           COUNT(tmp_tmc_data.tmc) AS included_tmcs_ct
      FROM tmp_tmc_data
      WHERE ((tmp_tmc_data.miles IS NOT NULL) AND (tmp_tmc_data.aadt IS NOT NULL))
      GROUP BY functional_class
  ) AS passing_and_failing
  USING (functional_class)
  FULL OUTER JOIN (
    SELECT functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct
      FROM tmp_tmc_data
      WHERE ((tmp_tmc_data.miles IS NULL) OR (tmp_tmc_data.aadt IS NULL))
      GROUP BY functional_class
  ) AS excluded
  USING (functional_class)

UNION ALL -- Region Level

SELECT '__STATE__'::VARCHAR(2) AS state,
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
           SUM(tmp_tmc_data.miles * tmp_tmc_data. aadt)::REAL AS weighted_sum,
           SUM(tmp_tmc_data.miles) AS passing_mi
      FROM tmp_tmc_data
      INNER JOIN tmc_attributes AS geo_partitions
        ON (
          (tmp_tmc_data.tmc = geo_partitions.tmc)
            AND
          (geo_partitions.state = '__STATE__')
        ) 
      WHERE (max_lottr < 1.5)
        AND ((tmp_tmc_data.miles IS NOT NULL) AND (tmp_tmc_data.aadt IS NOT NULL))
        AND (region_name IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS passing 
  FULL OUTER JOIN (
    -- Total
    SELECT region_name AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles * tmp_tmc_data. aadt)::REAL AS weighted_sum,
           SUM(tmp_tmc_data.miles) AS included_mi,
           PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
             WITHIN GROUP (ORDER BY max_lottr) AS lottr_quartiles,
           AVG(max_lottr) AS lottr_mean,
           STDDEV_POP(max_lottr) AS lottr_stddev,
           COUNT(tmp_tmc_data.tmc) AS included_tmcs_ct
      FROM tmp_tmc_data
      INNER JOIN tmc_attributes AS geo_partitions
        ON (
          (tmp_tmc_data.tmc = geo_partitions.tmc)
            AND
          (geo_partitions.state = '__STATE__')
        ) 
      WHERE ((tmp_tmc_data.miles IS NOT NULL) AND (tmp_tmc_data.aadt IS NOT NULL))
        AND (region_name IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS passing_and_failing
  USING (geography_name, functional_class)
  FULL OUTER JOIN (
    SELECT region_name AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct
      FROM tmp_tmc_data
      INNER JOIN tmc_attributes AS geo_partitions
        ON (
          (tmp_tmc_data.tmc = geo_partitions.tmc)
            AND
          (geo_partitions.state = '__STATE__')
        ) 
      WHERE ((tmp_tmc_data.miles IS NULL) OR  (tmp_tmc_data.aadt IS NULL))
        AND (region_name IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS excluded
  USING (geography_name, functional_class)

UNION ALL -- County Level

SELECT '__STATE__'::VARCHAR(2) AS state,
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
           SUM(tmp_tmc_data.miles * tmp_tmc_data. aadt)::REAL AS weighted_sum,
           SUM(tmp_tmc_data.miles) AS passing_mi
      FROM tmp_tmc_data
      INNER JOIN tmc_attributes AS geo_partitions
        ON (
          (tmp_tmc_data.tmc = geo_partitions.tmc)
            AND
          (geo_partitions.state = '__STATE__')
        ) 
      WHERE (max_lottr < 1.5)
        AND ((tmp_tmc_data.miles IS NOT NULL) AND (tmp_tmc_data.aadt IS NOT NULL))
        AND (county IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS passing 
  FULL OUTER JOIN (
    -- Total
    SELECT county AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles * tmp_tmc_data. aadt)::REAL AS weighted_sum,
           SUM(tmp_tmc_data.miles) AS included_mi,
           PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
             WITHIN GROUP (ORDER BY max_lottr) AS lottr_quartiles,
           AVG(max_lottr) AS lottr_mean,
           STDDEV_POP(max_lottr) AS lottr_stddev,
           COUNT(tmp_tmc_data.tmc) AS included_tmcs_ct
      FROM tmp_tmc_data
      INNER JOIN tmc_attributes AS geo_partitions
        ON (
          (tmp_tmc_data.tmc = geo_partitions.tmc)
            AND
          (geo_partitions.state = '__STATE__')
        ) 
      WHERE ((tmp_tmc_data.miles IS NOT NULL) AND (tmp_tmc_data.aadt IS NOT NULL))
        AND (county IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS passing_and_failing
  USING (geography_name, functional_class)
  FULL OUTER JOIN (
    SELECT county AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct
      FROM tmp_tmc_data
      INNER JOIN tmc_attributes AS geo_partitions
        ON (
          (tmp_tmc_data.tmc = geo_partitions.tmc)
            AND
          (geo_partitions.state = '__STATE__')
        ) 
      WHERE ((tmp_tmc_data.miles IS NULL) OR  (tmp_tmc_data.aadt IS NULL))
        AND (county IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS excluded
  USING (geography_name, functional_class)

UNION ALL -- MPO Level

SELECT '__STATE__'::VARCHAR(2) AS state,
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
           SUM(tmp_tmc_data.miles * tmp_tmc_data. aadt)::REAL AS weighted_sum,
           SUM(tmp_tmc_data.miles) AS passing_mi
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes AS geo_partitions
        ON (
          (tmp_tmc_data.tmc = geo_partitions.tmc)
            AND
          (geo_partitions.state = '__STATE__')
        ) 
      WHERE (max_lottr < 1.5)
        AND ((tmp_tmc_data.miles IS NOT NULL) AND (tmp_tmc_data.aadt IS NOT NULL))
        AND (mpo_acrony IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS passing 
  FULL OUTER JOIN (
    SELECT mpo_acrony AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles * tmp_tmc_data. aadt)::REAL AS weighted_sum,
           SUM(tmp_tmc_data.miles) AS included_mi,
           PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
             WITHIN GROUP (ORDER BY max_lottr) AS lottr_quartiles,
           AVG(max_lottr) AS lottr_mean,
           STDDEV_POP(max_lottr) AS lottr_stddev,
           COUNT(tmp_tmc_data.tmc) AS included_tmcs_ct
      FROM tmp_tmc_data
      INNER JOIN tmc_attributes AS geo_partitions
        ON (
          (tmp_tmc_data.tmc = geo_partitions.tmc)
            AND
          (geo_partitions.state = '__STATE__')
        ) 
      WHERE ((tmp_tmc_data.miles IS NOT NULL) AND (tmp_tmc_data.aadt IS NOT NULL))
        AND (mpo_acrony IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS passing_and_failing
  USING (geography_name, functional_class)
  FULL OUTER JOIN (
    SELECT mpo_acrony AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes AS geo_partitions
        ON (
          (tmp_tmc_data.tmc = geo_partitions.tmc)
            AND
          (geo_partitions.state = '__STATE__')
        ) 
      WHERE ((tmp_tmc_data.miles IS NULL) OR  (tmp_tmc_data.aadt IS NULL))
        AND (mpo_acrony IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS excluded
  USING (geography_name, functional_class)

UNION ALL -- CBSA Level

SELECT '__STATE__'::VARCHAR(2) AS state,
       __YEAR__::SMALLINT AS year,
       __MONTH__::SMALLINT AS month,
       'CBSA'::geography_level_type AS geography_level,
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
    SELECT cbsa_name AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles * tmp_tmc_data.aadt)::REAL AS weighted_sum,
           SUM(tmp_tmc_data.miles) AS passing_mi
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes AS geo_partitions
        ON (
          (tmp_tmc_data.tmc = geo_partitions.tmc)
            AND
          (geo_partitions.state = '__STATE__')
        ) 
      WHERE (max_lottr < 1.5)
        AND ((tmp_tmc_data.miles IS NOT NULL) AND (tmp_tmc_data.aadt IS NOT NULL))
        AND (cbsa_name IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS passing 
  FULL OUTER JOIN (
    SELECT cbsa_name AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles * tmp_tmc_data.aadt)::REAL AS weighted_sum,
           SUM(tmp_tmc_data.miles) AS included_mi,
           PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
             WITHIN GROUP (ORDER BY max_lottr) AS lottr_quartiles,
           AVG(max_lottr) AS lottr_mean,
           STDDEV_POP(max_lottr) AS lottr_stddev,
           COUNT(tmp_tmc_data.tmc) AS included_tmcs_ct
      FROM tmp_tmc_data
      INNER JOIN tmc_attributes AS geo_partitions
        ON (
          (tmp_tmc_data.tmc = geo_partitions.tmc)
            AND
          (geo_partitions.state = '__STATE__')
        ) 
      WHERE ((tmp_tmc_data.miles IS NOT NULL) AND (tmp_tmc_data.aadt IS NOT NULL))
        AND (cbsa_name IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS passing_and_failing
  USING (geography_name, functional_class)
  FULL OUTER JOIN (
    SELECT cbsa_name AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes AS geo_partitions
        ON (
          (tmp_tmc_data.tmc = geo_partitions.tmc)
            AND
          (geo_partitions.state = '__STATE__')
        ) 
      WHERE ((tmp_tmc_data.miles IS NULL) OR  (tmp_tmc_data.aadt IS NULL))
        AND (cbsa_name IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS excluded
  USING (geography_name, functional_class)

UNION ALL -- UA Level

SELECT '__STATE__'::VARCHAR(2) AS state,
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
           SUM(tmp_tmc_data.miles * tmp_tmc_data. aadt)::REAL AS weighted_sum,
           SUM(tmp_tmc_data.miles) AS passing_mi
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes AS geo_partitions
        ON (
          (tmp_tmc_data.tmc = geo_partitions.tmc)
            AND
          (geo_partitions.state = '__STATE__')
        ) 
      WHERE (max_lottr < 1.5)
        AND ((tmp_tmc_data.miles IS NOT NULL) AND (tmp_tmc_data.aadt IS NOT NULL))
        AND (ua_name IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS passing 
  FULL OUTER JOIN (
    SELECT ua_name AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles * tmp_tmc_data. aadt)::REAL AS weighted_sum,
           SUM(tmp_tmc_data.miles) AS included_mi,
           PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
             WITHIN GROUP (ORDER BY max_lottr) AS lottr_quartiles,
           AVG(max_lottr) AS lottr_mean,
           STDDEV_POP(max_lottr) AS lottr_stddev,
           COUNT(tmp_tmc_data.tmc) AS included_tmcs_ct
      FROM tmp_tmc_data
      INNER JOIN tmc_attributes AS geo_partitions
        ON (
          (tmp_tmc_data.tmc = geo_partitions.tmc)
            AND
          (geo_partitions.state = '__STATE__')
        ) 
      WHERE ((tmp_tmc_data.miles IS NOT NULL) AND (tmp_tmc_data.aadt IS NOT NULL))
        AND (ua_name IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS passing_and_failing
  USING (geography_name, functional_class)
  FULL OUTER JOIN (
    SELECT ua_name AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes AS geo_partitions
        ON (
          (tmp_tmc_data.tmc = geo_partitions.tmc)
            AND
          (geo_partitions.state = '__STATE__')
        ) 
      WHERE ((tmp_tmc_data.miles IS NULL) OR  (tmp_tmc_data.aadt IS NULL))
        AND (ua_name IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS excluded
  USING (geography_name, functional_class)
;
  

DROP TABLE tmp_tmc_data;


ALTER TABLE "__STATE__".top_level_travel_time_reliability_y__YEAR__m__MONTH__
  ADD CONSTRAINT state_check 
    CHECK (state = '__STATE__'),
  ADD CONSTRAINT date_range 
    CHECK ((year = __YEAR__) AND (month = __MONTH__)),
  INHERIT "__STATE__".top_level_travel_time_reliability,
  SET (fillfactor = 100);


CREATE UNIQUE INDEX top_level_travel_time_reliability_y__YEAR__m__MONTH___idx
  ON "__STATE__".top_level_travel_time_reliability_y__YEAR__m__MONTH__ 
    (geography_level, geography_name, functional_class)
  WITH (fillfactor = 100);

ALTER TABLE "__STATE__".top_level_travel_time_reliability_y__YEAR__m__MONTH__
  ADD CONSTRAINT top_level_travel_time_reliability_y__YEAR__m__MONTH___pkey
    PRIMARY KEY USING INDEX top_level_travel_time_reliability_y__YEAR__m__MONTH___idx;


CLUSTER VERBOSE "__STATE__".top_level_travel_time_reliability_y__YEAR__m__MONTH__
  USING top_level_travel_time_reliability_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".top_level_travel_time_reliability_y__YEAR__m__MONTH__;
