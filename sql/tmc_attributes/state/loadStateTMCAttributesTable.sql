BEGIN;

/* Using DELETE because TRUNCATE locks the table. */
DELETE FROM "__STATE__".tmc_attributes;


-- Time: 150482.927 ms
CREATE TEMPORARY TABLE tmp_tmc_to_cbsa
  ON COMMIT DROP
  AS
    SELECT
        tmc,
        cbsa_code,
        cbsa_name
      FROM (
        SELECT
            ROW_NUMBER() OVER (PARTITION BY tmc ORDER BY intersection_len DESC, cbsa_code) AS row_num,
            sub_tmc_cbsa_intersections.*
          FROM (
            SELECT
                tmc,
                geoid AS cbsa_code,
                name AS cbsa_name,
                ST_Length(
                  ST_Intersection(
                    sub_tmc_shp.wkb_geometry,
                    cbsa_shp.wkb_geometry
                  )
                ) AS intersection_len
              FROM inrix_shapefile AS sub_tmc_shp
                INNER JOIN state_abbreviations
                  ON (sub_tmc_shp.state = state_abbreviations.state_name)
                INNER JOIN core_based_statistical_area_boundaries AS cbsa_shp
                ON (
                  ST_Intersects(
                    sub_tmc_shp.wkb_geometry,
                    cbsa_shp.wkb_geometry
                  )
                )
              WHERE (state_abbreviations.abbreviation = '__STATE__')
            ) AS sub_tmc_cbsa_intersections
        ) AS sub_ranked_tmc_to_cbsa
      WHERE sub_ranked_tmc_to_cbsa.row_num = 1
;

ALTER TABLE tmp_tmc_to_cbsa ADD PRIMARY KEY (tmc);


CREATE TEMPORARY TABLE tmp_tmc_to_mpo
  ON COMMIT DROP
  AS
    SELECT
        tmc,
        mpo_code,
        mpo_acrony,
        mpo_name
      FROM (
        SELECT
            ROW_NUMBER() OVER (PARTITION BY tmc ORDER BY intersection_len DESC, mpo_code) AS row_num,
            sub_tmc_mpo_intersections.*
          FROM (
            SELECT
                tmc,
                mpo_id AS mpo_code,
                mpo_acrony,
                mpo_name,
                ST_Length(
                  ST_Intersection(
                    sub_tmc_shp.wkb_geometry,
                    sub_mpo_shp.wkb_geometry
                  )
                ) AS intersection_len
              FROM inrix_shapefile AS sub_tmc_shp
                INNER JOIN state_abbreviations
                  ON (sub_tmc_shp.state = state_abbreviations.state_name)
                INNER JOIN mpo_boundaries_view AS sub_mpo_shp
                ON (
                  ST_Intersects(
                    sub_tmc_shp.wkb_geometry,
                    sub_mpo_shp.wkb_geometry
                  )
                )
              WHERE (state_abbreviations.abbreviation = '__STATE__')
            ) AS sub_tmc_mpo_intersections
        ) AS sub_ranked_tmc_to_mpo
      WHERE sub_ranked_tmc_to_mpo.row_num = 1
;

ALTER TABLE tmp_tmc_to_mpo ADD PRIMARY KEY (tmc);



/* TMC to UA */
CREATE TEMPORARY TABLE tmp_tmc_to_ua
  ON COMMIT DROP
  AS
    SELECT
        tmc,
        ua_code,
        ua_name
      FROM (
        SELECT
            ROW_NUMBER() OVER (PARTITION BY tmc ORDER BY intersection_len DESC, ua_code) AS row_num,
            sub_tmc_ua_intersections.*
          FROM (
            SELECT
                tmc,
                geoid10 AS ua_code,
                name10 AS ua_name,
                ST_Length(
                  ST_Intersection(
                    sub_tmc_shp.wkb_geometry,
                    ua_shp.wkb_geometry
                  )
                ) AS intersection_len
              FROM inrix_shapefile AS sub_tmc_shp
                INNER JOIN state_abbreviations
                  ON (sub_tmc_shp.state = state_abbreviations.state_name)
                INNER JOIN urban_area_boundaries AS ua_shp
                  ON (sub_tmc_shp.wkb_geometry && ua_shp.wkb_geometry)
              WHERE (state_abbreviations.abbreviation = '__STATE__')
            ) AS sub_tmc_ua_intersections
        ) AS sub_ranked_tmc_to_ua
      WHERE sub_ranked_tmc_to_ua.row_num = 1
;

ALTER TABLE tmp_tmc_to_ua ADD PRIMARY KEY (tmc);



CREATE TEMPORARY TABLE tmp_speed_reduction_factor
  ON COMMIT DROP
  AS
    SELECT
        tmc,

        avg_free_flow_travel_time,
        avg_peak_period_travel_time,
        (avg_free_flow_travel_time / avg_peak_period_travel_time)::REAL AS speed_reduction_factor,

        CASE 
          WHEN ((f_system = 0) OR (f_system = 1)) THEN 'FREEWAY'::traffic_dist_functional_class_type
          ELSE 'NONFREEWAY'::traffic_dist_functional_class_type
        END AS functional_class,

        (miles / (avg_free_flow_travel_time / (60 * 60)))::REAL AS avg_free_flow_speed_mph,
        (miles / (avg_peak_period_travel_time / (60 * 60)))::REAL AS avg_peak_period_speed_mph

      FROM (
          SELECT 
              tmc,
              AVG(travel_time_all_vehicles)::REAL AS avg_peak_period_travel_time
            FROM "__STATE__".npmrds
              INNER JOIN "__STATE__".tmc_date_ranges USING (tmc)
            WHERE (
              ( /* Peak hours */
                   (epoch BETWEEN (12 * 6) AND ((12 * 10) - 1)) /* 6am til 10am */
                OR (epoch BETWEEN (12 * (3+12)) AND ((12 * (7+12)) - 1)) /* 3am til 7pm */
              )
              AND (travel_time_all_vehicles > 0)
              /* Latest 12 months of data. */
              AND (npmrds.date >= date_trunc('month', tmc_date_ranges.last_date - INTERVAL '1 year' + INTERVAL '1 MONTH'))
            )
         GROUP BY tmc
        ) AS peak NATURAL FULL OUTER JOIN (
          SELECT 
              tmc,
              AVG(travel_time_all_vehicles)::REAL AS avg_free_flow_travel_time
            FROM "__STATE__".npmrds
              INNER JOIN "__STATE__".tmc_date_ranges USING (tmc)
            WHERE (
              ( /* Free flow hours */
                   (epoch BETWEEN (12 * 0) AND ((12 * 5) - 1)) /* midnight til 5am */
                OR (epoch BETWEEN (12 * (10+12)) AND ((12 * (12+12)) - 1)) /* 10pm til midnight */
              )
              AND (travel_time_all_vehicles > 0)
              /* Latest 12 months of data. */
              AND (npmrds.date >= date_trunc('month', tmc_date_ranges.last_date - INTERVAL '1 year' + INTERVAL '1 MONTH'))
            )
            GROUP BY tmc
        ) AS free_flow FULL OUTER JOIN inrix_shapefile USING (tmc)
;

ALTER TABLE tmp_speed_reduction_factor ADD PRIMARY KEY (tmc);
    

CREATE TEMPORARY TABLE tmp_directionality_factors
  ON COMMIT DROP
  AS
    SELECT
        tmc,
        avg_am_peak_travel_time, 
        avg_pm_peak_travel_time,
        (miles / ((avg_am_peak_travel_time / (60*60))))::REAL AS avg_am_peak_speed_mph, 
        (miles / ((avg_pm_peak_travel_time / (60*60))))::REAL AS avg_pm_peak_speed_mph
      FROM (
          SELECT 
              tmc,
              AVG(travel_time_all_vehicles)::REAL AS avg_am_peak_travel_time
            FROM "__STATE__".npmrds
              INNER JOIN "__STATE__".tmc_date_ranges USING (tmc)
            WHERE (
              (epoch BETWEEN (12 * 6) AND ((12 * 10) - 1))
              AND (travel_time_all_vehicles > 0)
              AND (npmrds.date >= date_trunc('month', tmc_date_ranges.last_date - INTERVAL '1 year' + INTERVAL '1 MONTH'))
            )
            GROUP BY tmc
        ) AS am_peak NATURAL FULL OUTER JOIN (
          SELECT 
              tmc,
              AVG(travel_time_all_vehicles)::REAL AS avg_pm_peak_travel_time
            FROM "__STATE__".npmrds
              INNER JOIN "__STATE__".tmc_date_ranges USING (tmc)
            WHERE (
              (epoch BETWEEN (12 * (3+12)) AND ((12 * (7+12)) - 1))
              AND (travel_time_all_vehicles > 0)
              AND (npmrds.date >= date_trunc('month', tmc_date_ranges.last_date - INTERVAL '1 year' + INTERVAL '1 MONTH'))
            )
            GROUP BY tmc
        ) AS pm_peak FULL OUTER JOIN inrix_shapefile USING (tmc)
;

ALTER TABLE tmp_directionality_factors ADD PRIMARY KEY (tmc);
    

CREATE TEMPORARY TABLE tmp_traffic_distribution_factors
  ON COMMIT DROP
  AS
    SELECT 
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
          WHEN ((avg_am_peak_speed_mph IS NULL) OR (avg_pm_peak_speed_mph IS NULL))
            THEN NULL::traffic_dist_directionality_type
          WHEN (avg_am_peak_speed_mph - avg_pm_peak_speed_mph) > 6
            THEN 'PM_PEAK'::traffic_dist_directionality_type
          WHEN (avg_pm_peak_speed_mph - avg_am_peak_speed_mph) > 6
            THEN 'AM_PEAK'::traffic_dist_directionality_type
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
        ST_Extent(inrix_shapefile.wkb_geometry) AS bounding_box
      FROM inrix_shapefile
      GROUP BY tmc
;

ALTER TABLE tmp_bounding_boxes ADD PRIMARY KEY (tmc);


INSERT INTO "__STATE__".tmc_attributes (
    tmc,
    tmctype,
    roadnumber,
    roadname,
    firstname,
    tmclinear,
    country,
    statename,
    county,
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
    urban_code,
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
    admin_level_1,
    admin_level_2,
    admin_level_3,
    distance,
    length,
    road_number,
    road_name,
    latitude,
    longitude,
    road_direction,
    occupancy_factor,
    state,
    is_interstate,
    is_controlled_access,
    avg_speedlimit,
    cbsa_code,
    cbsa_name,
    mpo_code,
    mpo_acrony,
    mpo_name,
    ua_code,
    ua_name,
    region_code,
    region_name,
    congestion_level,
    directionality,
    bounding_box
  ) 
  SELECT
      inrix_shapefile.tmc,
      inrix_shapefile.tmctype,
      inrix_shapefile.roadnumber,
      inrix_shapefile.roadname,
      inrix_shapefile.firstname,
      inrix_shapefile.tmclinear,
      inrix_shapefile.country,
      inrix_shapefile.state AS statename,
      inrix_shapefile.county,
      inrix_shapefile.zip,
      inrix_shapefile.direction,
      inrix_shapefile.startlat,
      inrix_shapefile.startlong,
      inrix_shapefile.endlat,
      inrix_shapefile.endlong,
      inrix_shapefile.miles,
      inrix_shapefile.frc,
      inrix_shapefile.border_set,
      inrix_shapefile.f_system,
      inrix_shapefile.urban_code,
      inrix_shapefile.faciltype,
      inrix_shapefile.structype,
      inrix_shapefile.thrulanes,
      inrix_shapefile.route_numb,
      inrix_shapefile.route_sign,
      inrix_shapefile.route_qual,
      inrix_shapefile.altrtename,
      inrix_shapefile.aadt,
      inrix_shapefile.aadt_singl,
      inrix_shapefile.aadt_combi,
      inrix_shapefile.nhs,
      inrix_shapefile.nhs_pct,
      inrix_shapefile.strhnt_typ,
      inrix_shapefile.strhnt_pct,
      inrix_shapefile.truck,

      -- HERE backwards compatibility
      'USA'::VARCHAR AS admin_level_1,
      inrix_shapefile.state AS admin_level_2,
      inrix_shapefile.county AS admin_level_3,

      inrix_shapefile.miles AS distance,
      inrix_shapefile.miles AS length,

      inrix_shapefile.roadnumber AS road_number,
      inrix_shapefile.roadname AS road_name,

      inrix_shapefile.startlat AS latitude,
      inrix_shapefile.startlong AS longitude,

      CASE inrix_shapefile.direction
        WHEN 'N' THEN 'Northbound'
        WHEN 'E' THEN 'Eastbound'
        WHEN 'S' THEN 'Southbound'
        WHEN 'W' THEN 'Westbound'
        ELSE NULL
      END AS road_direction,

      -- Make it easy to get the occupancy_factor
      occupancy_factor.occupancy_factor,

      state_abbreviations.abbreviation AS state,

      (f_system = 1) AS is_interstate,
      ((f_system = 1) OR (f_system = 2)) AS is_controlled_access,

      avg_speedlimit,

      tmp_tmc_to_cbsa.cbsa_code,
      tmp_tmc_to_cbsa.cbsa_name,

      tmp_tmc_to_mpo.mpo_code,
      tmp_tmc_to_mpo.mpo_acrony,
      tmp_tmc_to_mpo.mpo_name,

      tmp_tmc_to_ua.ua_code,
      tmp_tmc_to_ua.ua_name,

      regions.id AS region_code,
      regions.name AS region_name,

      traffic_dist_factors.congestion_level,
      traffic_dist_factors.directionality,

      tmp_bounding_boxes.bounding_box AS bounding_box

  FROM inrix_shapefile
    LEFT OUTER JOIN state_abbreviations
      ON (inrix_shapefile.state = state_abbreviations.state_name)
    LEFT OUTER JOIN occupancy_factor
      ON (
        (state_abbreviations.abbreviation = occupancy_factor.state)
        AND (inrix_shapefile.county = occupancy_factor.geography_level_name)
        AND (occupancy_factor.geography_level = 'COUNTY')
      )
    LEFT OUTER JOIN avg_speedlimits
      USING (tmc)
    LEFT OUTER JOIN tmp_tmc_to_cbsa
      USING (tmc)
    LEFT OUTER JOIN tmp_tmc_to_mpo
      USING (tmc)
    LEFT OUTER JOIN tmp_tmc_to_ua AS tmp_tmc_to_ua
      USING (tmc)
    LEFT OUTER JOIN region_to_county AS r_to_c
      ON (
        (inrix_shapefile.county = r_to_c.county)
        AND
        (state_abbreviations.abbreviation = r_to_c.state)
      )
    LEFT OUTER JOIN regions
      ON (r_to_c.region_id = regions.id)
    LEFT OUTER JOIN tmp_traffic_distribution_factors AS traffic_dist_factors
      USING (tmc)
    LEFT OUTER JOIN tmp_bounding_boxes
      USING (tmc)
  WHERE (state_abbreviations.abbreviation = '__STATE__')
;

CLUSTER VERBOSE "__STATE__".tmc_attributes USING tmc_attributes_pkey;

COMMIT;

ANALYZE "__STATE__".tmc_attributes;
ANALYZE tmc_attributes;
