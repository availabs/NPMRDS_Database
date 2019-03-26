/*
REQUIRED VARIABLES:
  STATE
  YEAR
  NPMRDS_SHAPEFILE_VERSION
  TMC_METADATA_VERSION
*/

BEGIN;

\set tbl_name :"STATE"'.tmc_metadata_':YEAR'_shpver':NPMRDS_SHAPEFILE_VERSION'_v':TMC_METADATA_VERSION
\set idx_name 'tmc_metadata_':YEAR'_shpver':NPMRDS_SHAPEFILE_VERSION'_v':TMC_METADATA_VERSION'_pkey'

-- NOTE: May be a VIEW if STATE is a Canadian Province.
\set shp_tbl_name :"STATE"'.npmrds_shapefile_':YEAR'_v':NPMRDS_SHAPEFILE_VERSION

-- tmc -> mpo using spatial join
CREATE TEMPORARY TABLE tmp_tmc_to_mpo
  ON COMMIT DROP
  AS
    SELECT DISTINCT
        tmc,
        mpo_id AS mpo_code,
        mpo_acrony,
        mpo_name
      FROM :shp_tbl_name AS sub_tmc_shp
        INNER JOIN state_abbreviations
          ON (sub_tmc_shp.state = state_abbreviations.state_name)
        INNER JOIN mpo_boundaries_view AS sub_mpo_shp
        ON (
          ST_Contains(
            sub_mpo_shp.wkb_geometry,
            sub_tmc_shp.wkb_geometry
          )
        )
      WHERE (
        (state_abbreviations.abbreviation = :'STATE')
        AND
        (sub_tmc_shp.conflation_year = :YEAR)
      )
;

ALTER TABLE tmp_tmc_to_mpo ADD PRIMARY KEY (tmc);


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
            (sub_tmc_shp.f_system = 0)
            OR
            (sub_tmc_shp.f_system = 1)
          ) THEN 'FREEWAY'::traffic_dist_functional_class_type
          ELSE 'NONFREEWAY'::traffic_dist_functional_class_type
        END AS functional_class,

        (
          sub_tmc_shp.miles
          /
          (
            avg_free_flow_travel_time
            /
            (60 * 60)
          )
        )::REAL AS avg_free_flow_speed_mph,

        (
          sub_tmc_shp.miles
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
        FULL OUTER JOIN :shp_tbl_name AS sub_tmc_shp
          USING (tmc)
      WHERE (sub_tmc_shp.conflation_year = :YEAR)
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
          sub_tmc_shp.miles
          /
          (
            avg_am_peak_travel_time
            /
            (60*60)
          )
        )::REAL AS avg_am_peak_speed_mph, 
        (
          sub_tmc_shp.miles
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
        FULL OUTER JOIN :shp_tbl_name AS sub_tmc_shp
          USING (tmc)
      WHERE (sub_tmc_shp.conflation_year = :YEAR)
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
    

CREATE TEMPORARY TABLE tmp_bounding_boxes
  ON COMMIT DROP
  AS
    SELECT
        tmc,
        ST_Extent(npmrds_shapefile.wkb_geometry) AS bounding_box
      FROM :shp_tbl_name AS npmrds_shapefile
        INNER JOIN state_abbreviations
        ON (npmrds_shapefile.state = state_abbreviations.state_name)
      WHERE (
        (npmrds_shapefile.conflation_year = :YEAR)
        AND
        (state_abbreviations.abbreviation = :'STATE')
      )
      GROUP BY tmc
;

ALTER TABLE tmp_bounding_boxes ADD PRIMARY KEY (tmc);

CREATE TABLE :tbl_name (
  LIKE :"STATE".tmc_metadata_:YEAR INCLUDING ALL,
  PRIMARY KEY (tmc)
) WITH (fillfactor=100, autovacuum_enabled=false) ;

INSERT INTO :tbl_name (
    tmc,
    tmctype,
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
    bounding_box,
    conflation_year,
    npmrds_shapefile_version
  ) 
  SELECT
      npmrds_shapefile.tmc,
      npmrds_shapefile.tmctype,
      npmrds_shapefile.roadnumber,
      npmrds_shapefile.roadname,
      npmrds_shapefile.firstname,
      npmrds_shapefile.tmclinear,
      npmrds_shapefile.country,
      npmrds_shapefile.state AS state_name,
      npmrds_shapefile.county AS county_name,
      npmrds_shapefile.zip,
      npmrds_shapefile.direction,
      npmrds_shapefile.startlat,
      npmrds_shapefile.startlong,
      npmrds_shapefile.endlat,
      npmrds_shapefile.endlong,
      npmrds_shapefile.miles,
      npmrds_shapefile.frc,
      npmrds_shapefile.border_set,
      npmrds_shapefile.f_system,
      LPAD(npmrds_shapefile.urban_code::TEXT, 5, '0') AS ua_code,
      npmrds_shapefile.faciltype,
      npmrds_shapefile.structype,
      npmrds_shapefile.thrulanes,
      npmrds_shapefile.route_numb,
      npmrds_shapefile.route_sign,
      npmrds_shapefile.route_qual,
      npmrds_shapefile.altrtename,
      npmrds_shapefile.aadt,
      npmrds_shapefile.aadt_singl,
      npmrds_shapefile.aadt_combi,
      npmrds_shapefile.nhs,
      npmrds_shapefile.nhs_pct,
      npmrds_shapefile.strhnt_typ,
      npmrds_shapefile.strhnt_pct,
      npmrds_shapefile.truck,

      state_abbreviations.abbreviation AS state,

      fips_codes.state_code AS state_code,
      (fips_codes.state_code || fips_codes.county_code) AS county_code,

      (frc = 1) AS is_interstate,
      ((f_system = 1) OR (f_system = 2)) AS is_controlled_access,

      avg_speedlimits.avg_speedlimit,

      (
        (
          (
            1.55 
            * 
            (
              npmrds_shapefile.aadt
              -
              (
                npmrds_shapefile.aadt_singl
                +
                npmrds_shapefile.aadt_combi
              )
            )
          ) -- cars
          + (10.25 * npmrds_shapefile.aadt_singl) -- buses
          + (1.11 * npmrds_shapefile.aadt_combi) -- combination trucks
        ) / NULLIF(npmrds_shapefile.aadt, 0)
      ) AS avg_vehicle_occupancy,

      tmp_tmc_to_mpo.mpo_code,
      tmp_tmc_to_mpo.mpo_acrony,
      tmp_tmc_to_mpo.mpo_name,

      urban_area_boundaries.name10 AS ua_name,

      traffic_dist_factors.congestion_level,
      traffic_dist_factors.directionality,

      tmp_bounding_boxes.bounding_box AS bounding_box,

      npmrds_shapefile.conflation_year,
      npmrds_shapefile.npmrds_shapefile_version

  FROM :shp_tbl_name AS npmrds_shapefile
    LEFT OUTER JOIN state_abbreviations
      ON (npmrds_shapefile.state = state_abbreviations.state_name)
    LEFT OUTER JOIN (
      SELECT
          tmc,
          MAX(avg_speedlimit) AS avg_speedlimit
        FROM avg_speedlimits
        WHERE (state = :'STATE')
        GROUP BY tmc
    ) AS avg_speedlimits
      USING (tmc)
    LEFT OUTER JOIN tmp_tmc_to_mpo
      USING (tmc)
    LEFT OUTER JOIN urban_area_boundaries
      ON (
        lpad(
          npmrds_shapefile.urban_code::TEXT,
          5,
          '0'
        )
        =
        urban_area_boundaries.geoid10
      )
    LEFT OUTER JOIN tmp_traffic_distribution_factors AS traffic_dist_factors
      USING (tmc)
    LEFT OUTER JOIN tmp_bounding_boxes
      USING (tmc)
    LEFT OUTER JOIN fips_codes
      ON (
        (state_abbreviations.abbreviation = fips_codes.state)
        AND
        (npmrds_shapefile.county = fips_codes.county)
      )
  WHERE (
    (state_abbreviations.abbreviation = :'STATE')
    AND
    (npmrds_shapefile.conflation_year = :YEAR)
  )
;

CLUSTER VERBOSE :tbl_name
  USING :idx_name;

COMMIT;

ANALYZE :tbl_name;
