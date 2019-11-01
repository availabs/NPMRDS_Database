/*
REQUIRED VARIABLES:
  STATE
  YEAR
  TMC_METADATA_VERSION
*/

BEGIN;

\set tbl_name :"STATE"'.tmc_metadata_':YEAR'_v':TMC_METADATA_VERSION
\set idx_name 'tmc_metadata_':YEAR'_v':TMC_METADATA_VERSION'_pkey'
\set tmc_ident_tbl :"STATE"'.tmc_identification_':YEAR


CREATE TEMPORARY TABLE tmp_tmc2mpo
  ON COMMIT DROP
  AS
    SELECT DISTINCT ON (tmc)
        tmc,
        mpo_id AS mpo_code,
        mpo_name,
        mpo_acrony
      FROM (
          SELECT
              tmc,
              wkb_geometry
            FROM public.npmrds_shapefile_:YEAR AS shp
              INNER JOIN state_abbreviations AS abbr
              ON (UPPER(shp.state) = UPPER(abbr.state_name))
            WHERE ( abbr.abbreviation = :'STATE')
        ) AS state_shp
        INNER JOIN mpo_boundaries_view AS mpob
          ON (
            ST_Contains(
              mpob.wkb_geometry,
              ST_ClosestPoint(
                state_shp.wkb_geometry,
                ST_Centroid(state_shp.wkb_geometry)
              )
            )
          )
      ORDER BY tmc, mpo_id
;


CREATE TEMPORARY TABLE tmp_speed_reduction_factor
  ON COMMIT DROP
  AS
    SELECT DISTINCT
        tmc,

        avg_free_flow_travel_time,
        avg_peak_period_travel_time,
        (
          avg_free_flow_travel_time
          /
          avg_peak_period_travel_time
        )::REAL AS speed_reduction_factor,

        CASE
          WHEN (
            (tmc_ident.f_system = 0)
            OR
            (tmc_ident.f_system = 1)
          ) THEN 'FREEWAY'::traffic_dist_functional_class_type
          ELSE 'NONFREEWAY'::traffic_dist_functional_class_type
        END AS functional_class,

        (
          tmc_ident.miles
          /
          (
            avg_free_flow_travel_time
            /
            (60 * 60)
          )
        )::REAL AS avg_free_flow_speed_mph,

        (
          tmc_ident.miles
          /
          (
            avg_peak_period_travel_time
            /
            (60 * 60)
          )
        )::REAL AS avg_peak_period_speed_mph

      FROM (
          SELECT
              tmc,
              AVG(travel_time_all_vehicles)::REAL AS avg_peak_period_travel_time
            FROM :"STATE".npmrds
            WHERE (
              ( /* Peak hours */
                (epoch BETWEEN (12 * 6) AND ((12 * 10) - 1)) /* 6am til 10am */
                OR
                (epoch BETWEEN (12 * (3+12)) AND ((12 * (7+12)) - 1)) /* 3am til 7pm */
              )
              AND
              (travel_time_all_vehicles > 0)
              AND
              (
                npmrds.date >= ('01/01/'||:'YEAR')::DATE
                AND
                npmrds.date < ('01/01/'||(:YEAR + 1)::TEXT)::DATE
              )
            )
         GROUP BY tmc
        ) AS peak NATURAL FULL OUTER JOIN (
          SELECT
              tmc,
              AVG(travel_time_all_vehicles)::REAL AS avg_free_flow_travel_time
            FROM :"STATE".npmrds
            WHERE (
              ( /* Free flow hours */
                (epoch BETWEEN (12 * 0) AND ((12 * 5) - 1)) /* midnight til 5am */
                OR
                (epoch BETWEEN (12 * (10+12)) AND ((12 * (12+12)) - 1)) /* 10pm til midnight */
              )
              AND
              (travel_time_all_vehicles > 0)
              /* Latest 12 months of data. */
              AND
              (
                npmrds.date >= ('01/01/'||:'YEAR')::DATE
                AND
                npmrds.date < ('01/01/'||(:YEAR + 1)::TEXT)::DATE
              )
            )
            GROUP BY tmc
        ) AS free_flow
        FULL OUTER JOIN :tmc_ident_tbl AS tmc_ident
          USING (tmc)
;

ALTER TABLE tmp_speed_reduction_factor ADD PRIMARY KEY (tmc);


CREATE TEMPORARY TABLE tmp_directionality_factors
  ON COMMIT DROP
  AS
    SELECT DISTINCT
        tmc,
        avg_am_peak_travel_time,
        avg_pm_peak_travel_time,
        (
          tmc_ident.miles
          /
          (
            avg_am_peak_travel_time
            /
            (60*60)
          )
        )::REAL AS avg_am_peak_speed_mph,
        (
          tmc_ident.miles
          /
          (
            avg_pm_peak_travel_time
            /
            (60*60)
          )
        )::REAL AS avg_pm_peak_speed_mph
      FROM (
          SELECT
              tmc,
              AVG(travel_time_all_vehicles)::REAL AS avg_am_peak_travel_time
            FROM npmrds
            WHERE (
              (npmrds.state = :'STATE')
              AND
              (
                epoch BETWEEN (12 * 6) AND ((12 * 10) - 1)
              )
              AND
              (travel_time_all_vehicles > 0)
              AND
              (
                npmrds.date >= ('01/01/'||:'YEAR')::DATE
                AND
                npmrds.date < ('01/01/'||(:YEAR + 1)::TEXT)::DATE
              )
            )
            GROUP BY tmc
        ) AS am_peak NATURAL FULL OUTER JOIN (
          SELECT
              tmc,
              AVG(travel_time_all_vehicles)::REAL AS avg_pm_peak_travel_time
            FROM npmrds
            WHERE (
              (npmrds.state = :'STATE')
              AND
              (epoch BETWEEN (12 * (3+12)) AND ((12 * (7+12)) - 1))
              AND
              (travel_time_all_vehicles > 0)
              AND
              (
                npmrds.date >= ('01/01/'||:'YEAR')::DATE
                AND
                date < ('01/01/'||(:YEAR + 1)::TEXT)::DATE
              )
            )
            GROUP BY tmc
        ) AS pm_peak
        FULL OUTER JOIN :tmc_ident_tbl AS tmc_ident
          USING (tmc)
;

ALTER TABLE tmp_directionality_factors ADD PRIMARY KEY (tmc);


CREATE TEMPORARY TABLE tmp_traffic_distribution_factors
  ON COMMIT DROP
  AS
    SELECT DISTINCT
        tmc,
        CASE functional_class
          WHEN 'FREEWAY' THEN
            CASE
              WHEN (speed_reduction_factor IS NULL)
                THEN NULL::traffic_dist_congestion_level_type
              WHEN (speed_reduction_factor < 0.75)
                THEN 'SEVERE_CONGESTION'::traffic_dist_congestion_level_type
              WHEN (speed_reduction_factor < 0.9)
                THEN 'MODERATE_CONGESTION'::traffic_dist_congestion_level_type
              ELSE 'NO2LOW_CONGESTION'::traffic_dist_congestion_level_type
            END
          ELSE
            CASE
              WHEN (speed_reduction_factor IS NULL)
                THEN NULL::traffic_dist_congestion_level_type
              WHEN (speed_reduction_factor < 0.65)
                THEN 'SEVERE_CONGESTION'::traffic_dist_congestion_level_type
              WHEN (speed_reduction_factor < 0.8)
                THEN 'MODERATE_CONGESTION'::traffic_dist_congestion_level_type
              ELSE 'NO2LOW_CONGESTION'::traffic_dist_congestion_level_type
            END
        END AS congestion_level,
        CASE
          WHEN (
              (avg_am_peak_speed_mph IS NULL)
              OR
              (avg_pm_peak_speed_mph IS NULL)
            ) THEN NULL::traffic_dist_directionality_type
          WHEN (
              (avg_am_peak_speed_mph - avg_pm_peak_speed_mph)
              >
              6
            ) THEN 'PM_PEAK'::traffic_dist_directionality_type
          WHEN (
              (avg_pm_peak_speed_mph - avg_am_peak_speed_mph)
              >
              6
            ) THEN 'AM_PEAK'::traffic_dist_directionality_type
          ELSE 'EVEN_DIST'::traffic_dist_directionality_type
        END AS directionality
      FROM tmp_speed_reduction_factor
        NATURAL FULL OUTER JOIN tmp_directionality_factors
;

ALTER TABLE tmp_traffic_distribution_factors ADD PRIMARY KEY (tmc);

CREATE TABLE :tbl_name (
  LIKE :"STATE".tmc_metadata_:YEAR INCLUDING ALL,
  PRIMARY KEY (tmc)
) WITH (fillfactor=100, autovacuum_enabled=false) ;

INSERT INTO :tbl_name (
    tmc,
    roadnumber,
    roadname,
    firstname,
    tmclinear,
    country,
    state_name,
    county_name,
    zip,
    direction,
    startlat,
    startlong,
    endlat,
    endlong,
    miles,
    frc,
    border_set,
    f_system,
    ua_code,
    faciltype,
    structype,
    thrulanes,
    route_numb,
    route_sign,
    route_qual,
    altrtename,
    aadt,
    aadt_singl,
    aadt_combi,
    nhs,
    nhs_pct,
    strhnt_typ,
    strhnt_pct,
    truck,
    type,
    road_order,
    isprimary,
    timezone_name,
    active_start_date,
    active_end_date,
    state,
    state_code,
    county_code,
    is_interstate,
    is_controlled_access,
    avg_speedlimit,
    avg_vehicle_occupancy,
    mpo_code,
    mpo_acrony,
    mpo_name,
    ua_name,
    congestion_level,
    directionality,
    bounding_box
  )
  SELECT
      tmc_identification.tmc,
      tmc_identification.route_numb AS roadnumber,
      tmc_identification.road AS roadname,
      tmc_identification.intersection AS firstname,
      tmc_identification.tmclinear,
      tmc_identification.country,
      tmc_identification.state AS state_name,
      INITCAP(tmc_identification.county) AS county_name,
      tmc_identification.zip,
      substring(
        substring(
          direction FROM 'NORTH|NB|EAST|EB|SOUTH|SB|WEST|WB'
        )
        FROM 1 FOR 1
      ) AS direction,
      tmc_identification.start_latitude AS startlat,
      tmc_identification.start_longitude AS startlong,
      tmc_identification.end_latitude AS endlat,
      tmc_identification.end_longitude AS endlong,
      tmc_identification.miles,
      tmc_identification.frc,
      tmc_identification.border_set,
      tmc_identification.f_system,
      LPAD(
        tmc_identification.urban_code::TEXT,
        5,
        '0'
      ) AS ua_code,
      tmc_identification.faciltype,
      tmc_identification.structype,
      tmc_identification.thrulanes,
      tmc_identification.route_numb,
      tmc_identification.route_sign,
      tmc_identification.route_qual,
      tmc_identification.altrtename,
      tmc_identification.aadt,
      tmc_identification.aadt_singl,
      tmc_identification.aadt_combi,
      tmc_identification.nhs,
      tmc_identification.nhs_pct,
      tmc_identification.strhnt_typ,
      tmc_identification.strhnt_pct,
      tmc_identification.truck,

      tmc_identification.type,
      tmc_identification.road_order,
      tmc_identification.isprimary,
      tmc_identification.timezone_name,
      tmc_identification.active_start_date,
      tmc_identification.active_end_date,

      LOWER(tmc_identification.state) AS state,

      fips_codes_states.state_code AS state_code,

      (fips_codes_counties.state_code || fips_codes_counties.county_code) AS county_code,

      (frc = 1) AS is_interstate,
      ((f_system = 1) OR (f_system = 2)) AS is_controlled_access,

      avg_speedlimits.avg_speedlimit,

      (
        (
          (
            1.55
            *
            (
              tmc_identification.aadt
              -
              (
                tmc_identification.aadt_singl
                +
                tmc_identification.aadt_combi
              )
            )
          ) -- cars
          + (10.25 * tmc_identification.aadt_singl) -- buses
          + (1.11 * tmc_identification.aadt_combi) -- combination trucks
        ) / NULLIF(tmc_identification.aadt, 0)
      ) AS avg_vehicle_occupancy,

      tmp_tmc2mpo.mpo_code,
      tmp_tmc2mpo.mpo_acrony,
      tmp_tmc2mpo.mpo_name,

      urban_area_boundaries.name10 AS ua_name,

      traffic_dist_factors.congestion_level,
      traffic_dist_factors.directionality,

      ST_Envelope(
        ST_SetSRID(
          ST_MakeLine(
            ST_MakePoint(
              tmc_identification.start_longitude,
              tmc_identification.start_latitude
            ),
            ST_MakePoint(
              tmc_identification.end_longitude,
              tmc_identification.end_latitude
            )
          ),
          4326
        )
      ) AS bounding_box

  FROM :tmc_ident_tbl AS tmc_identification
    LEFT OUTER JOIN (
      SELECT
          tmc,
          MAX(avg_speedlimit) AS avg_speedlimit
        FROM avg_speedlimits
        WHERE (state = :'STATE')
        GROUP BY tmc
    ) AS avg_speedlimits
      USING (tmc)
    LEFT OUTER JOIN tmp_tmc2mpo
      USING (tmc)
    LEFT OUTER JOIN urban_area_boundaries
      ON (
        lpad(
          tmc_identification.urban_code::TEXT,
          5,
          '0'
        )
        =
        urban_area_boundaries.geoid10
      )
    LEFT OUTER JOIN tmp_traffic_distribution_factors AS traffic_dist_factors
      USING (tmc)
    LEFT OUTER JOIN (
        SELECT DISTINCT
            state,
            state_code
          FROM fips_codes
      ) AS fips_codes_states ON (
        LOWER(tmc_identification.state) = LOWER(fips_codes_states.state)
      )
    LEFT OUTER JOIN fips_codes AS fips_codes_counties
      ON (
        (LOWER(tmc_identification.state) = LOWER(fips_codes_counties.state))
        AND
        (
          LOWER(
            regexp_replace(tmc_identification.county, '[^\w]+','')
          )
          =
          LOWER(
            regexp_replace(fips_codes_counties.county, '[^\w]+','')
          )
      )
    )
  WHERE (
    (LOWER(tmc_identification.state) = LOWER(:'STATE'))
  )
;

CLUSTER VERBOSE :tbl_name
  USING :idx_name;

COMMIT;

ANALYZE :tbl_name;
