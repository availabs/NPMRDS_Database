BEGIN;

CREATE TABLE "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__ AS

  -- State Level
  SELECT '__STATE__'::VARCHAR(2) AS state,
         __YEAR__::SMALLINT AS year,
         __MONTH__::SMALLINT AS month,
         'STATE'::geography_level_type AS geography_level,
         '__STATE__'::VARCHAR AS geography_name,
         CASE WHEN (is_interstate = true) THEN 'INTERSTATE'::functional_class_type
           ELSE 'NONINTERSTATE'::functional_class_type
         END AS functional_class,
         total_excessive_delay::DOUBLE PRECISION,
         ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
         ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
         included_tmcs_ct::INTEGER,
         excluded_tmcs_ct::INTEGER,
         ARRAY[
           ROUND(xdelay_quartiles[1]::NUMERIC, 3),
           ROUND(xdelay_quartiles[2]::NUMERIC, 3),
           ROUND(xdelay_quartiles[3]::NUMERIC, 3),
           ROUND(xdelay_quartiles[4]::NUMERIC, 3),
           ROUND(xdelay_quartiles[5]::NUMERIC, 3)
         ]::DOUBLE PRECISION[5] AS xdelay_quartiles,
         ROUND(xdelay_mean::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_mean,
         ROUND(xdelay_stddev::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_stddev,
         ARRAY[
           ROUND(xdelay_per_mile_quartiles[1]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[2]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[3]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[4]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[5]::NUMERIC, 3)
         ]::DOUBLE PRECISION[5] AS xdelay_per_mile_quartiles,
         ROUND(xdelay_per_mile_mean::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_per_mile_mean,
         ROUND(xdelay_per_mile_stddev::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_per_mile_stddev
    FROM (
      SELECT is_interstate,
             ROUND(
               SUM(total_excessive_delay)::NUMERIC,
               3
             )AS total_excessive_delay,
             SUM(miles) AS included_mi,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY total_excessive_delay) AS xdelay_quartiles,
             AVG(total_excessive_delay) AS xdelay_mean,
             STDDEV_POP(total_excessive_delay) AS xdelay_stddev,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY total_excessive_delay / miles) AS xdelay_per_mile_quartiles,
             AVG(total_excessive_delay / miles) AS xdelay_per_mile_mean,
             STDDEV_POP(total_excessive_delay / miles) AS xdelay_per_mile_stddev,
             COUNT(tmc) AS included_tmcs_ct
        FROM "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__
          INNER JOIN tmc_attributes USING (tmc)
        WHERE (total_excessive_delay IS NOT NULL)
        GROUP BY is_interstate
    ) AS included
    FULL OUTER JOIN (
      SELECT is_interstate,
             SUM(miles) AS excluded_mi,
             COUNT(tmc) AS excluded_tmcs_ct
        FROM "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__
          INNER JOIN tmc_attributes USING (tmc)
        WHERE (total_excessive_delay IS NULL)
        GROUP BY is_interstate
    ) AS excluded
    USING (is_interstate)

  UNION ALL -- Region Level

  SELECT '__STATE__'::VARCHAR(2) AS state,
         __YEAR__::SMALLINT AS year,
         __MONTH__::SMALLINT AS month,
         'REGION'::geography_level_type AS geography_level,
         geography_name::VARCHAR,
         CASE WHEN (is_interstate = true) THEN 'INTERSTATE'::functional_class_type
           ELSE 'NONINTERSTATE'::functional_class_type
         END AS functional_class,
         total_excessive_delay::DOUBLE PRECISION,
         ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
         ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
         included_tmcs_ct::INTEGER,
         excluded_tmcs_ct::INTEGER,
         ARRAY[
           ROUND(xdelay_quartiles[1]::NUMERIC, 3),
           ROUND(xdelay_quartiles[2]::NUMERIC, 3),
           ROUND(xdelay_quartiles[3]::NUMERIC, 3),
           ROUND(xdelay_quartiles[4]::NUMERIC, 3),
           ROUND(xdelay_quartiles[5]::NUMERIC, 3)
         ]::DOUBLE PRECISION[5] AS xdelay_quartiles,
         ROUND(xdelay_mean::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_mean,
         ROUND(xdelay_stddev::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_stddev,
         ARRAY[
           ROUND(xdelay_per_mile_quartiles[1]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[2]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[3]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[4]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[5]::NUMERIC, 3)
         ]::DOUBLE PRECISION[5] AS xdelay_per_mile_quartiles,
         ROUND(xdelay_per_mile_mean::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_per_mile_mean,
         ROUND(xdelay_per_mile_stddev::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_per_mile_stddev
    FROM (
      SELECT region_name AS geography_name,
             is_interstate,
             ROUND(
               SUM(total_excessive_delay)::NUMERIC,
               3
             ) AS total_excessive_delay,
             SUM(miles) AS included_mi,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY total_excessive_delay) AS xdelay_quartiles,
             AVG(total_excessive_delay) AS xdelay_mean,
             STDDEV_POP(total_excessive_delay) AS xdelay_stddev,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY total_excessive_delay / miles) AS xdelay_per_mile_quartiles,
             AVG(total_excessive_delay / miles) AS xdelay_per_mile_mean,
             STDDEV_POP(total_excessive_delay / miles) AS xdelay_per_mile_stddev,
             COUNT(tmc) AS included_tmcs_ct
        FROM "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__
        INNER JOIN tmc_attributes USING(tmc)
        WHERE (miles IS NOT NULL)
          AND (region_name IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS included
    FULL OUTER JOIN (
      SELECT region_name AS geography_name,
             is_interstate,
             SUM(miles) AS excluded_mi,
             COUNT(tmc) AS excluded_tmcs_ct
        FROM "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__
        INNER JOIN tmc_attributes USING(tmc)
        WHERE (miles IS NULL)
          AND (region_name IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS excluded
    USING (geography_name, is_interstate)

  UNION ALL -- County Level

  SELECT '__STATE__'::VARCHAR(2) AS state,
         __YEAR__::SMALLINT AS year,
         __MONTH__::SMALLINT AS month,
         'COUNTY'::geography_level_type AS geography_level,
         geography_name::VARCHAR,
         CASE WHEN (is_interstate = true) THEN 'INTERSTATE'::functional_class_type
           ELSE 'NONINTERSTATE'::functional_class_type
         END AS functional_class,
         total_excessive_delay::DOUBLE PRECISION,
         ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
         ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
         included_tmcs_ct::INTEGER,
         excluded_tmcs_ct::INTEGER,
         ARRAY[
           ROUND(xdelay_quartiles[1]::NUMERIC, 3),
           ROUND(xdelay_quartiles[2]::NUMERIC, 3),
           ROUND(xdelay_quartiles[3]::NUMERIC, 3),
           ROUND(xdelay_quartiles[4]::NUMERIC, 3),
           ROUND(xdelay_quartiles[5]::NUMERIC, 3)
         ]::DOUBLE PRECISION[5] AS xdelay_quartiles,
         ROUND(xdelay_mean::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_mean,
         ROUND(xdelay_stddev::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_stddev,
         ARRAY[
           ROUND(xdelay_per_mile_quartiles[1]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[2]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[3]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[4]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[5]::NUMERIC, 3)
         ]::DOUBLE PRECISION[5] AS xdelay_per_mile_quartiles,
         ROUND(xdelay_per_mile_mean::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_per_mile_mean,
         ROUND(xdelay_per_mile_stddev::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_per_mile_stddev
    FROM (
      SELECT county AS geography_name,
             is_interstate,
             ROUND(
               SUM(total_excessive_delay)::NUMERIC,
               3
             ) AS total_excessive_delay,
             SUM(miles) AS included_mi,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY total_excessive_delay) AS xdelay_quartiles,
             AVG(total_excessive_delay) AS xdelay_mean,
             STDDEV_POP(total_excessive_delay) AS xdelay_stddev,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY total_excessive_delay / miles) AS xdelay_per_mile_quartiles,
             AVG(total_excessive_delay / miles) AS xdelay_per_mile_mean,
             STDDEV_POP(total_excessive_delay / miles) AS xdelay_per_mile_stddev,
             COUNT(tmc) AS included_tmcs_ct
        FROM "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__
        INNER JOIN tmc_attributes USING(tmc)
        WHERE (miles IS NOT NULL)
          AND (county IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS included
    FULL OUTER JOIN (
      SELECT county AS geography_name,
             is_interstate,
             SUM(miles) AS excluded_mi,
             COUNT(tmc) AS excluded_tmcs_ct
        FROM "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__
        INNER JOIN tmc_attributes USING(tmc)
        WHERE (miles IS NULL)
          AND (county IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS excluded
    USING (geography_name, is_interstate)

  UNION ALL -- MPO Level

  SELECT '__STATE__'::VARCHAR(2) AS state,
         __YEAR__::SMALLINT AS year,
         __MONTH__::SMALLINT AS month,
         'MPO'::geography_level_type AS geography_level,
         geography_name::VARCHAR,
         CASE WHEN (is_interstate = true) THEN 'INTERSTATE'::functional_class_type
           ELSE 'NONINTERSTATE'::functional_class_type
         END AS functional_class,
         total_excessive_delay::DOUBLE PRECISION,
         ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
         ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
         included_tmcs_ct::INTEGER,
         excluded_tmcs_ct::INTEGER,
         ARRAY[
           ROUND(xdelay_quartiles[1]::NUMERIC, 3),
           ROUND(xdelay_quartiles[2]::NUMERIC, 3),
           ROUND(xdelay_quartiles[3]::NUMERIC, 3),
           ROUND(xdelay_quartiles[4]::NUMERIC, 3),
           ROUND(xdelay_quartiles[5]::NUMERIC, 3)
         ]::DOUBLE PRECISION[5] AS xdelay_quartiles,
         ROUND(xdelay_mean::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_mean,
         ROUND(xdelay_stddev::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_stddev,
         ARRAY[
           ROUND(xdelay_per_mile_quartiles[1]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[2]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[3]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[4]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[5]::NUMERIC, 3)
         ]::DOUBLE PRECISION[5] AS xdelay_per_mile_quartiles,
         ROUND(xdelay_per_mile_mean::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_per_mile_mean,
         ROUND(xdelay_per_mile_stddev::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_per_mile_stddev
    FROM (
      SELECT mpo_name AS geography_name,
             is_interstate,
             ROUND(
               SUM(total_excessive_delay)::NUMERIC,
               3
             ) AS total_excessive_delay,
             SUM(miles) AS included_mi,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY total_excessive_delay) AS xdelay_quartiles,
             AVG(total_excessive_delay) AS xdelay_mean,
             STDDEV_POP(total_excessive_delay) AS xdelay_stddev,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY total_excessive_delay / miles) AS xdelay_per_mile_quartiles,
             AVG(total_excessive_delay / miles) AS xdelay_per_mile_mean,
             STDDEV_POP(total_excessive_delay / miles) AS xdelay_per_mile_stddev,
             COUNT(tmc) AS included_tmcs_ct
        FROM "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__
        INNER JOIN tmc_attributes USING(tmc)
        WHERE (miles IS NOT NULL)
          AND (mpo_name IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS included
    FULL OUTER JOIN (
      SELECT mpo_name AS geography_name,
             is_interstate,
             SUM(miles) AS excluded_mi,
             COUNT(tmc) AS excluded_tmcs_ct
        FROM "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__
          INNER JOIN tmc_attributes USING(tmc)
        WHERE (miles IS NULL)
          AND (mpo_name IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS excluded
    USING (geography_name, is_interstate)

  UNION ALL -- CBSA Level

  SELECT '__STATE__'::VARCHAR(2) AS state,
         __YEAR__::SMALLINT AS year,
         __MONTH__::SMALLINT AS month,
         'CBSA'::geography_level_type AS geography_level,
         geography_name::VARCHAR,
         CASE WHEN (is_interstate = true) THEN 'INTERSTATE'::functional_class_type
           ELSE 'NONINTERSTATE'::functional_class_type
         END AS functional_class,
         total_excessive_delay::DOUBLE PRECISION,
         ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
         ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
         included_tmcs_ct::INTEGER,
         excluded_tmcs_ct::INTEGER,
         ARRAY[
           ROUND(xdelay_quartiles[1]::NUMERIC, 3),
           ROUND(xdelay_quartiles[2]::NUMERIC, 3),
           ROUND(xdelay_quartiles[3]::NUMERIC, 3),
           ROUND(xdelay_quartiles[4]::NUMERIC, 3),
           ROUND(xdelay_quartiles[5]::NUMERIC, 3)
         ]::DOUBLE PRECISION[5] AS xdelay_quartiles,
         ROUND(xdelay_mean::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_mean,
         ROUND(xdelay_stddev::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_stddev,
         ARRAY[
           ROUND(xdelay_per_mile_quartiles[1]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[2]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[3]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[4]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[5]::NUMERIC, 3)
         ]::DOUBLE PRECISION[5] AS xdelay_per_mile_quartiles,
         ROUND(xdelay_per_mile_mean::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_per_mile_mean,
         ROUND(xdelay_per_mile_stddev::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_per_mile_stddev
    FROM (
      SELECT cbsa_name AS geography_name,
             is_interstate,
             ROUND(
               SUM(total_excessive_delay)::NUMERIC,
               3
             ) AS total_excessive_delay,
             SUM(miles) AS included_mi,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY total_excessive_delay) AS xdelay_quartiles,
             AVG(total_excessive_delay) AS xdelay_mean,
             STDDEV_POP(total_excessive_delay) AS xdelay_stddev,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY total_excessive_delay / miles) AS xdelay_per_mile_quartiles,
             AVG(total_excessive_delay / miles) AS xdelay_per_mile_mean,
             STDDEV_POP(total_excessive_delay / miles) AS xdelay_per_mile_stddev,
             COUNT(tmc) AS included_tmcs_ct
        FROM "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__
        INNER JOIN tmc_attributes USING(tmc)
        WHERE (miles IS NOT NULL)
          AND (cbsa_name IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS included
    FULL OUTER JOIN (
      SELECT cbsa_name AS geography_name,
             is_interstate,
             SUM(miles) AS excluded_mi,
             COUNT(tmc) AS excluded_tmcs_ct
        FROM "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__
          INNER JOIN tmc_attributes USING(tmc)
        WHERE (miles IS NULL)
          AND (cbsa_name IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS excluded
    USING (geography_name, is_interstate)

  UNION ALL -- UA Level

  SELECT '__STATE__'::VARCHAR(2) AS state,
         __YEAR__::SMALLINT AS year,
         __MONTH__::SMALLINT AS month,
         'UA'::geography_level_type AS geography_level,
         geography_name::VARCHAR,
         CASE WHEN (is_interstate = true) THEN 'INTERSTATE'::functional_class_type
           ELSE 'NONINTERSTATE'::functional_class_type
         END AS functional_class,
         total_excessive_delay::DOUBLE PRECISION,
         ROUND(included_mi::NUMERIC, 3)::REAL AS included_mi,
         ROUND(excluded_mi::NUMERIC, 3)::REAL AS excluded_mi,
         included_tmcs_ct::INTEGER,
         excluded_tmcs_ct::INTEGER,
         ARRAY[
           ROUND(xdelay_quartiles[1]::NUMERIC, 3),
           ROUND(xdelay_quartiles[2]::NUMERIC, 3),
           ROUND(xdelay_quartiles[3]::NUMERIC, 3),
           ROUND(xdelay_quartiles[4]::NUMERIC, 3),
           ROUND(xdelay_quartiles[5]::NUMERIC, 3)
         ]::DOUBLE PRECISION[5] AS xdelay_quartiles,
         ROUND(xdelay_mean::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_mean,
         ROUND(xdelay_stddev::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_stddev,
         ARRAY[
           ROUND(xdelay_per_mile_quartiles[1]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[2]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[3]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[4]::NUMERIC, 3),
           ROUND(xdelay_per_mile_quartiles[5]::NUMERIC, 3)
         ]::DOUBLE PRECISION[5] AS xdelay_per_mile_quartiles,
         ROUND(xdelay_per_mile_mean::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_per_mile_mean,
         ROUND(xdelay_per_mile_stddev::NUMERIC, 3)::DOUBLE PRECISION AS xdelay_per_mile_stddev
    FROM (
      SELECT ua_name AS geography_name,
             is_interstate,
             ROUND(
               SUM(total_excessive_delay)::NUMERIC,
               3
             ) AS total_excessive_delay,
             SUM(miles) AS included_mi,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY total_excessive_delay) AS xdelay_quartiles,
             AVG(total_excessive_delay) AS xdelay_mean,
             STDDEV_POP(total_excessive_delay) AS xdelay_stddev,
             PERCENTILE_DISC(array[0.0, 0.25, 0.50, 0.75, 1.0])
               WITHIN GROUP (ORDER BY total_excessive_delay / miles) AS xdelay_per_mile_quartiles,
             AVG(total_excessive_delay / miles) AS xdelay_per_mile_mean,
             STDDEV_POP(total_excessive_delay / miles) AS xdelay_per_mile_stddev,
             COUNT(tmc) AS included_tmcs_ct
        FROM "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__
          INNER JOIN tmc_attributes USING(tmc)
        WHERE (miles IS NOT NULL)
          AND (ua_name IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS included
    FULL OUTER JOIN (
      SELECT ua_name AS geography_name,
             is_interstate,
             SUM(miles) AS excluded_mi,
             COUNT(tmc) AS excluded_tmcs_ct
        FROM "__STATE__".total_excessive_delay_y__YEAR__m__MONTH__
          INNER JOIN tmc_attributes USING(tmc)
        WHERE (miles IS NULL)
          AND (ua_name IS NOT NULL)
        GROUP BY geography_name, is_interstate
    ) AS excluded
    USING (geography_name, is_interstate)
  ;
  

ALTER TABLE "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__
  ADD CONSTRAINT state_check 
    CHECK (state = '__STATE__'),
  ADD CONSTRAINT date_range 
    CHECK ((year = __YEAR__) AND (month = __MONTH__)),
  INHERIT "__STATE__".top_level_total_excessive_delay,
  SET (fillfactor = 100);


CREATE UNIQUE INDEX top_level_total_excessive_delay_y__YEAR__m__MONTH___idx
  ON "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__ 
    (geography_level, geography_name, functional_class)
  WITH (fillfactor = 100);

ALTER TABLE "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__
  ADD CONSTRAINT top_level_total_excessive_delay_y__YEAR__m__MONTH___pkey
    PRIMARY KEY USING INDEX top_level_total_excessive_delay_y__YEAR__m__MONTH___idx;


CLUSTER VERBOSE "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__
  USING top_level_total_excessive_delay_y__YEAR__m__MONTH___pkey;

COMMIT;

ANALYZE VERBOSE "__STATE__".top_level_total_excessive_delay_y__YEAR__m__MONTH__;
