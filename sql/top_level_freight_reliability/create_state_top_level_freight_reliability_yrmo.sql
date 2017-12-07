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
         ((data->'WEEKEND')->1)::TEXT::REAL / NULLIF(((data->'WEEKEND')->0)::TEXT::REAL, 0),
         ((data->'OVERNIGHT')->1)::TEXT::REAL / NULLIF(((data->'OVERNIGHT')->0)::TEXT::REAL, 0)
       )::REAL AS tttr_for_tmc,
       CASE WHEN (is_interstate = true) THEN 'INTERSTATE'::functional_class_type
         ELSE 'NONINTERSTATE'::functional_class_type
       END AS functional_class,
       miles::REAL
  FROM "__STATE__".tttr_percentiles_y__YEAR__m__MONTH__
    LEFT OUTER JOIN tmc_attributes USING (state, tmc);

DROP TABLE IF EXISTS "__STATE__".top_level_freight_reliability_y__YEAR__m__MONTH__ CASCADE;

-- State Level
CREATE TABLE "__STATE__".top_level_freight_reliability_y__YEAR__m__MONTH__ AS
SELECT '__STATE__'::VARCHAR(2) AS state,
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
      WHERE (tttr_for_tmc IS NOT NULL)
        AND (tmp_tmc_data.miles IS NOT NULL)
      GROUP BY functional_class
  ) AS measure_calculation
  FULL OUTER JOIN (
    -- The summary stats for excluded TMCs.
    SELECT functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct
      FROM tmp_tmc_data
      WHERE (tttr_for_tmc IS NULL)
        OR (tmp_tmc_data.miles IS NULL)
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
      INNER JOIN tmc_attributes AS tmc_attrs
        ON (
          (tmp_tmc_data.tmc = tmc_attrs.tmc)
            AND
          (tmc_attrs.state = '__STATE__')
        ) 
      WHERE ((tttr_for_tmc IS NOT NULL) AND (tmp_tmc_data.miles IS NOT NULL))
        AND (region_name IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS measure_calculation
  FULL OUTER JOIN (
    SELECT region_name AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct
      FROM tmp_tmc_data
      INNER JOIN tmc_attributes AS tmc_attrs
        ON (
          (tmp_tmc_data.tmc = tmc_attrs.tmc)
            AND
          (tmc_attrs.state = '__STATE__')
        ) 
      WHERE ((tttr_for_tmc IS NULL) OR  (tmp_tmc_data.miles IS NULL))
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
      INNER JOIN tmc_attributes AS tmc_attrs
        ON (
          (tmp_tmc_data.tmc = tmc_attrs.tmc)
            AND
          (tmc_attrs.state = '__STATE__')
        ) 
      WHERE ((tttr_for_tmc IS NOT NULL) AND (tmp_tmc_data.miles IS NOT NULL))
        AND (county IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS measure_calculation
  FULL OUTER JOIN (
    SELECT county AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct
      FROM tmp_tmc_data
      INNER JOIN tmc_attributes AS tmc_attrs
        ON (
          (tmp_tmc_data.tmc = tmc_attrs.tmc)
            AND
          (tmc_attrs.state = '__STATE__')
        ) 
      WHERE ((tttr_for_tmc IS NULL) OR (tmp_tmc_data.miles IS NULL))
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
      INNER JOIN tmc_attributes AS tmc_attrs
        ON (
          (tmp_tmc_data.tmc = tmc_attrs.tmc)
            AND
          (tmc_attrs.state = '__STATE__')
        ) 
      WHERE ((tttr_for_tmc IS NOT NULL) AND (tmp_tmc_data.miles IS NOT NULL))
        AND (mpo_acrony IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS measure_calculation
  FULL OUTER JOIN (
    SELECT mpo_acrony AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes AS tmc_attrs
        ON (
          (tmp_tmc_data.tmc = tmc_attrs.tmc)
            AND
          (tmc_attrs.state = '__STATE__')
        ) 
      WHERE ((tttr_for_tmc IS NULL) OR  (tmp_tmc_data.miles IS NULL))
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
    SELECT cbsa_name AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles * tttr_for_tmc)::REAL AS weighted_total,
           SUM(tmp_tmc_data.miles) AS included_mi,
           PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
             WITHIN GROUP (ORDER BY tttr_for_tmc) AS tttr_quartiles,
           AVG(tttr_for_tmc) AS tttr_mean,
           STDDEV_POP(tttr_for_tmc) AS tttr_stddev,
           COUNT(tmp_tmc_data.tmc) AS included_tmcs_ct
      FROM tmp_tmc_data
      INNER JOIN tmc_attributes AS tmc_attrs
        ON (
          (tmp_tmc_data.tmc = tmc_attrs.tmc)
            AND
          (tmc_attrs.state = '__STATE__')
        ) 
      WHERE ((tttr_for_tmc IS NOT NULL) AND (tmp_tmc_data.miles IS NOT NULL))
        AND (cbsa_name IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS measure_calculation
  FULL OUTER JOIN (
    SELECT cbsa_name AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes AS tmc_attrs
        ON (
          (tmp_tmc_data.tmc = tmc_attrs.tmc)
            AND
          (tmc_attrs.state = '__STATE__')
        ) 
      WHERE ((tttr_for_tmc IS NULL) OR (tmp_tmc_data.miles IS NULL))
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
           COUNT(tmp_tmc_data.tmc) AS included_tmcs_ct
      FROM tmp_tmc_data
      INNER JOIN tmc_attributes AS tmc_attrs
        ON (
          (tmp_tmc_data.tmc = tmc_attrs.tmc)
            AND
          (tmc_attrs.state = '__STATE__')
        ) 
      WHERE ((tttr_for_tmc IS NOT NULL) AND (tmp_tmc_data.miles IS NOT NULL))
        AND (ua_name IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS measure_calculation
  FULL OUTER JOIN (
    SELECT ua_name AS geography_name,
           functional_class,
           SUM(tmp_tmc_data.miles) AS excluded_mi,
           COUNT(tmp_tmc_data.tmc) AS excluded_tmcs_ct
      FROM tmp_tmc_data
        INNER JOIN tmc_attributes AS tmc_attrs
        ON (
          (tmp_tmc_data.tmc = tmc_attrs.tmc)
            AND
          (tmc_attrs.state = '__STATE__')
        ) 
      WHERE ((tttr_for_tmc IS NULL) OR (tmp_tmc_data.miles IS NULL))
        AND (ua_name IS NOT NULL)
      GROUP BY geography_name, functional_class
  ) AS excluded
  USING (geography_name, functional_class)
;
  

DROP TABLE tmp_tmc_data;


ALTER TABLE "__STATE__".top_level_freight_reliability_y__YEAR__m__MONTH__
  ADD CONSTRAINT state_check 
    CHECK (state = '__STATE__'),
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
