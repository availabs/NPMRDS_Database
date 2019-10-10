BEGIN;

DROP MATERIALIZED VIEW IF EXISTS highway_data_services.station_location_data;

CREATE MATERIALIZED VIEW IF NOT EXISTS highway_data_services.station_location_data
WITH (fillfactor = 100)
AS
  SELECT 
      station_id,
      region,
      region_code,
      county_code,

      latitude,
      longitude,
      muni,
      
      tdv_route,

      begindesc,
      enddesc
  FROM (
    SELECT DISTINCT
        ROW_NUMBER() OVER (PARTITION BY d.rc_station ORDER BY COALESCE(s.count_yr, a.aadt_year) DESC) AS row_num,
        d.rc_station AS station_id,
        d.region,
        d.region_code,
        d.county_code,

        COALESCE(s.latitude, c.latitude) AS latitude,
        COALESCE(s.longitude, c.longitude) AS longitude,
        COALESCE(s.muni, c.muni, a.muni) AS muni,
        
        CASE
          WHEN CHAR_LENGTH(COALESCE(s.tdv_route, '')) > CHAR_LENGTH(COALESCE(c.tdv_route, ''))
            THEN
              CASE
                WHEN CHAR_LENGTH(COALESCE(s.tdv_route, '')) > CHAR_LENGTH(COALESCE(a.tdv_route, ''))
                  THEN s.tdv_route
                  ELSE a.tdv_route
              END
            ELSE 
              CASE
                WHEN CHAR_LENGTH(COALESCE(c.tdv_route, '')) > CHAR_LENGTH(COALESCE(a.tdv_route, ''))
                  THEN c.tdv_route
                  ELSE a.tdv_route
              END
          END AS tdv_route,

        COALESCE(s.begindesc, c.begindesc, a.begindesc) AS begindesc,
        COALESCE(s.enddesc, c.enddesc, a.enddesc) AS enddesc
      FROM (
        SELECT DISTINCT
            rc_station,
            rg AS region,
            region_code,
            county_code
          FROM highway_data_services.short_count_speed
        UNION
        SELECT DISTINCT
            rc_station,
            rg AS region,
            region_code,
            county_code
          FROM highway_data_services.short_count_vehicle_classification
        UNION
        SELECT DISTINCT
            rc_station,
            rg AS region,
            region_code,
            county_code
          FROM highway_data_services.short_count_volume
        UNION
        SELECT DISTINCT
            rc || '_' || station AS rc_station,
            region,
            SUBSTRING(rc FROM 1 FOR 1)::SMALLINT AS region_code,
            SUBSTRING(rc FROM 2 FOR 1)::SMALLINT AS county_code
          FROM highway_data_services.continuous_vehicle_classification
        UNION
        SELECT DISTINCT
            rc || '_' || station AS rc_station,
            region,
            SUBSTRING(rc FROM 1 FOR 1)::SMALLINT AS region_code,
            SUBSTRING(rc FROM 2 FOR 1)::SMALLINT AS county_code
          FROM highway_data_services.continuous_volume
      ) AS d
      LEFT OUTER JOIN highway_data_services.short_counts_shp AS s ON (d.rc_station = s.rc_id)
      LEFT OUTER JOIN highway_data_services.continuous_counts_shp AS c USING (rc_id)
      LEFT OUTER JOIN highway_data_services.aadt_shp AS a USING (rc_id)
    ) AS t
  WHERE row_num = 1
;

ALTER MATERIALIZED VIEW highway_data_services.station_location_data OWNER TO npmrds_ninja;

CREATE INDEX station_location_idx ON highway_data_services.station_location_data (station_id);

CLUSTER highway_data_services.station_location_data USING station_location_idx;

COMMIT;

ANALYZE highway_data_services.station_location_data;
