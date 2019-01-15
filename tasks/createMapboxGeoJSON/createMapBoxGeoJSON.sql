-- http://www.postgresonline.com/journal/archives/267-Creating-GeoJSON-Feature-Collections-with-JSON-and-PostGIS-functions.html
SELECT
    row_to_json(fc)::json
  FROM (
    SELECT
        'FeatureCollection' AS type,
        array_to_json(
          array_agg(f)
        ) As features
      FROM (
        SELECT
            'Feature' As type,
            ST_AsGeoJSON(sub_shp.wkb_geometry)::json AS geometry,
            row_to_json(sub_attrs) As properties
          FROM (
            SELECT
                tmc,
                f_system,
                state_code,
                county_code,
                ua_code,
                mpo_code
              FROM tmc_attributes
              WHERE (county_code = '36001')
          ) AS sub_attrs INNER JOIN inrix_shapefile AS sub_shp USING (tmc)
      ) As f
  )  As fc;
