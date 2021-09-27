-- Requires STATE, YEAR, MONTH

\set npmrds_tbl_name :"STATE"'.npmrds_y':YEAR'm':MONTH
\set tbl_name :"STATE"'.npmrds_monthly_avg_tt_y':YEAR'm':MONTH

BEGIN;

INSERT INTO :tbl_name (
  tmc,
  hr_0,
  hr_1,
  hr_2,
  hr_3,
  hr_4,
  hr_5,
  hr_6,
  hr_7,
  hr_8,
  hr_9,
  hr_10,
  hr_11,
  hr_12,
  hr_13,
  hr_14,
  hr_15,
  hr_16,
  hr_17,
  hr_18,
  hr_19,
  hr_20,
  hr_21,
  hr_22,
  hr_23
)
  SELECT
      tmc,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER =  0 )::INTEGER, 0 )
      )::REAL AS hr_0,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER =  1 )::INTEGER, 0 )
      )::REAL AS hr_1,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER =  2 )::INTEGER, 0 )
      )::REAL AS hr_2,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER =  3 )::INTEGER, 0 )
      )::REAL AS hr_3,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER =  4 )::INTEGER, 0 )
      )::REAL AS hr_4,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER =  5 )::INTEGER, 0 )
      )::REAL AS hr_5,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER =  6 )::INTEGER, 0 )
      )::REAL AS hr_6,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER =  7 )::INTEGER, 0 )
      )::REAL AS hr_7,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER =  8 )::INTEGER, 0 )
      )::REAL AS hr_8,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER =  9 )::INTEGER, 0 )
      )::REAL AS hr_9,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER = 10 )::INTEGER, 0 )
      )::REAL AS hr_10,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER = 11 )::INTEGER, 0 )
      )::REAL AS hr_11,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER = 12 )::INTEGER, 0 )
      )::REAL AS hr_12,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER = 13 )::INTEGER, 0 )
      )::REAL AS hr_13,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER = 14 )::INTEGER, 0 )
      )::REAL AS hr_14,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER = 15 )::INTEGER, 0 )
      )::REAL AS hr_15,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER = 16 )::INTEGER, 0 )
      )::REAL AS hr_16,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER = 17 )::INTEGER, 0 )
      )::REAL AS hr_17,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER = 18 )::INTEGER, 0 )
      )::REAL AS hr_18,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER = 19 )::INTEGER, 0 )
      )::REAL AS hr_19,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER = 20 )::INTEGER, 0 )
      )::REAL AS hr_20,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER = 21 )::INTEGER, 0 )
      )::REAL AS hr_21,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER = 22 )::INTEGER, 0 )
      )::REAL AS hr_22,
      AVG(
        travel_time_all_vehicles::DOUBLE PRECISION
        * NULLIF( ( (epoch / 12)::INTEGER = 23 )::INTEGER, 0 )
      )::REAL AS hr_23

    FROM :npmrds_tbl_name

    WHERE (
      ( travel_time_all_vehicles IS NOT NULL )
      AND
      ( EXTRACT(DOW FROM date) IN (2, 3, 4, 5, 6) )
    )
    GROUP BY 1
;

CLUSTER :tbl_name ;

COMMIT ;

ANALYZE :tbl_name ;
