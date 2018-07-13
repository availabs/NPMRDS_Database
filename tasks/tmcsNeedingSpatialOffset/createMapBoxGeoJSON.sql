BEGIN;

-- DROP TABLE IF EXISTS tmp_buffered_lines;
CREATE TEMPORARY TABLE tmp_buffered_lines
  ON COMMIT DROP
  AS
  SELECT 
      tmc,
      GEOMETRY(
        ST_Buffer(
          GEOGRAPHY(
            wkb_geometry
          ),
          1, --meters
          'endcap=flat join=round'
        )
      ) AS line_buf,
      tmclinear,
      direction
    FROM inrix_shapefile AS shp
      INNER JOIN state_abbreviations AS abbr
      ON (shp.state = abbr.state_name)
    WHERE (abbr.abbreviation = :STATE)
--  and county = 'Albany'
;

-- DROP TABLE IF EXISTS tmp_segments_requiring_offset;
CREATE TEMPORARY TABLE tmp_segments_requiring_offset
  ON COMMIT DROP
  AS
    SELECT
        tmc,
        ST_Collect(segment) AS segment
      FROM (
        SELECT
            a.tmc, 
            (ST_Dump(
              ST_Intersection(
                a.wkb_geometry,
                b.line_buf
              )
            )).geom AS segment
          FROM inrix_shapefile AS a
            INNER JOIN tmp_buffered_lines AS b
            ON (
              (a.tmclinear = b.tmclinear)
              AND
              (ST_INTERSECTS(a.wkb_geometry, b.line_buf))
              AND
              (
                (a.direction = 'E' and b.direction = 'W')
                OR
                (a.direction = 'W' and b.direction = 'E') 
                OR 
                (a.direction = 'N' and b.direction = 'S')
                OR
                (a.direction = 'S' and b.direction = 'N')
              )
              AND (a.direction = ANY(:DIRECTIONS)) -- EG: '{N,E}'
            )
--  WHERE a.county = 'Albany'
        ) AS segs
      WHERE (ST_Length(segment) > 0)
      GROUP BY tmc
;


-- DROP TABLE IF EXISTS tmp_segments_not_requiring_offset;
CREATE TEMPORARY TABLE tmp_segments_not_requiring_offset
  ON COMMIT DROP
  AS
  SELECT
      tmc,
      ST_Collect(segment) AS segment
    FROM (
      SELECT
          tmc, 
          --Get rid of the buffer
          (ST_Dump(
            ST_Difference(
              shp.wkb_geometry,
              ST_Buffer(
                req_offset.segment,
                0.0000001,
                'endcap=flat join=round'
              )
            )
          )).geom AS segment
        FROM inrix_shapefile AS shp
          INNER JOIN tmp_segments_requiring_offset AS req_offset
          USING (tmc)
--  WHERE shp.county = 'Albany'
  ) AS segs
  WHERE (ST_Length(segment) > 0)
  GROUP BY tmc
;

INSERT INTO tmp_segments_not_requiring_offset (tmc, segment)
  SELECT
      tmc,
      shp.wkb_geometry AS segment
    FROM inrix_shapefile AS shp
      INNER JOIN tmp_buffered_lines USING (tmc)
      LEFT OUTER JOIN tmp_segments_not_requiring_offset AS nr USING (tmc)
      LEFT OUTER JOIN tmp_segments_requiring_offset AS r USING (tmc)
    WHERE (
      (nr.segment IS NULL AND r.segment IS NULL)
      AND 
      (shp.direction = ANY(:DIRECTIONS)) -- EG: '{N,E}'
    )
;

-- DROP TABLE IF EXISTS tmp_segments;
CREATE TEMPORARY TABLE tmp_segments
  ON COMMIT DROP
  AS
  SELECT
      tmc, 
      TRUE AS requires_offset,
      segment
    FROM tmp_segments_requiring_offset
  UNION
  SELECT
      tmc, 
      FALSE AS requires_offset,
      segment
    FROM tmp_segments_not_requiring_offset
;

-- DROP TABLE IF EXISTS tmp_lines;
CREATE TEMPORARY TABLE tmp_lines
  ON COMMIT DROP
  AS
  SELECT
      tmc,
      segment AS line,
      requires_offset
    FROM tmp_segments
    WHERE (requires_offset = :REQUIRES_OFFSET::BOOLEAN)
;

-- http://www.postgresonline.com/journal/archives/267-Creating-GeoJSON-Feature-Collections-with-JSON-and-PostGIS-functions.html

SELECT
    row_to_json(fc)::jsonb
  FROM (
    SELECT
        'FeatureCollection' AS type,
        array_to_json(
          array_agg(f)
        ) As features
      FROM (
        SELECT
            'Feature' As type,
            ST_AsGeoJSON(lg.line)::json AS geometry,
            row_to_json(lp) As properties
          FROM tmp_lines As lg 
            INNER JOIN (
              SELECT
                  tmc,
                  requires_offset
                FROM tmp_lines
            ) As lp 
            ON (
              (lg.tmc = lp.tmc)
              AND
              (lg.requires_offset = lp.requires_offset)
            )
      ) As f
  )  As fc;

COMMIT;
