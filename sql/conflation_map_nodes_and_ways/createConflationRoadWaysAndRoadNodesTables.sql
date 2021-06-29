\timing

\set ON_ERROR_STOP on

\set conflation_map_table 'conflation_map_':YEAR'_v':CONFLATION_VERSION                                
\set conflation_nodes_table 'conflation_map_':YEAR'_nodes_v':CONFLATION_VERSION
\set conflation_ways_table 'conflation_map_':YEAR'_ways_v':CONFLATION_VERSION
\set osm_nodes_table 'osm_nodes_v':OSM_VERSION
\set osm_ways_table 'osm_ways_v':OSM_VERSION

\set conflation_nodes_gix :conflation_nodes_table'_gix'
\set conflation_nodes_geojson_idx :conflation_nodes_table'_geojson_idx'

\set conflation_ways_table_pkey_idx :conflation_ways_table'_pkey'

\set conflation_nodes_id_seq :conflation_nodes_table'_id_seq'

BEGIN ;

-- Conflation map segments exploded into points.

CREATE TEMPORARY TABLE tmp_conflation_dumped_roadway_points (
  id            BIGINT,
  idx           INTEGER,
  -- The GeoJSON representation rounds coordinate precision and is used for coordinate identity.
  geojson       TEXT NOT NULL,
  wkb_geometry  geometry(Point, 4326),

  PRIMARY KEY (id, idx)
) WITH (fillfactor=100)
  ON COMMIT DROP ;

-- Dump all conflation_map segment coordinates as points.
INSERT INTO tmp_conflation_dumped_roadway_points (
  id,
  idx,
  geojson,
  wkb_geometry
)
  SELECT
      id,
      (dp).path[1] AS idx,
      ST_AsGeoJSON((dp).geom) AS geojson,
      (dp).geom AS wkb_geometry
    FROM (
      SELECT
          id,
          public.ST_DumpPoints(wkb_geometry)
        FROM conflation.:conflation_map_table AS a
        WHERE ( a.n < 8 ) -- Include "Motorway" through "Service". Exclude "Other".
    ) AS t(id, dp) ;
  
-- Optimize for JOINing on geojson
CREATE INDEX tmp_conflation_dumped_roadway_points_geojson_idx
  ON tmp_conflation_dumped_roadway_points (geojson);

CLUSTER tmp_conflation_dumped_roadway_points
  USING tmp_conflation_dumped_roadway_points_geojson_idx;

-- === The Nodes table ===

DROP TABLE IF EXISTS conflation.:conflation_nodes_table ;

CREATE TABLE conflation.:conflation_nodes_table (
  id              BIGINT PRIMARY KEY,
  wkb_geometry    public.geometry(Point, 4326)
) WITH (fillfactor=100);

INSERT INTO conflation.:conflation_nodes_table (
  id,
  wkb_geometry
)
  SELECT 
      id,
      wkb_geometry
    FROM osm.:osm_nodes_table
      INNER JOIN (
          -- All OSM Nodes references in OSM ways referenced in ConflationMap segments.
          SELECT DISTINCT
              unnest(a.node_ids) AS id
            FROM osm.:osm_ways_table AS a
              INNER JOIN conflation.:conflation_map_table AS b
                ON (a.id = b.osm)
            WHERE ( b.n < 8 )
        ) AS t USING (id)
;

-- Used for JOINing. Coordinate identity based on the GeoJSON coordinate representation.
CREATE INDEX :conflation_nodes_geojson_idx
  ON conflation.:conflation_nodes_table (
    ST_AsGeoJSON(wkb_geometry)
  );

-- We create a sequence for the node ids table for auto ids of the nodes
--   created during the confltion map splitting process (not in original OSM).
-- https://dba.stackexchange.com/a/78735
DROP SEQUENCE IF EXISTS conflation.:conflation_nodes_id_seq ;

CREATE SEQUENCE conflation.:conflation_nodes_id_seq
  NO MAXVALUE
  OWNED BY conflation.:conflation_nodes_table.id ;

-- We want the Sequence to begin 
ALTER TABLE conflation.:conflation_nodes_table
  ALTER COLUMN id
    SET DEFAULT nextval('conflation.' || :'conflation_nodes_id_seq') ;

-- This sequence begins after the MAX id in the original OSM nodes table
--   because JOINs with osm.osm_nodes_<version> MUST fail for the synthetic nodes.
SELECT
    setval(
      'conflation.' || :'conflation_nodes_id_seq',
       MAX(id) + 1
    )
  FROM osm.:osm_nodes_table ;

INSERT INTO conflation.:conflation_nodes_table (wkb_geometry)
  SELECT DISTINCT
      -- Uses the SEQUENCE for the ID.
      MIN(a.wkb_geometry)  -- Because grouping by geojson need an aggregate function.
    FROM tmp_conflation_dumped_roadway_points AS a
      LEFT OUTER JOIN conflation.:conflation_nodes_table AS b
        ON ( a.geojson = ST_AsGeoJSON(b.wkb_geometry) )
    WHERE ( b.id IS NULL )
    GROUP BY a.geojson;

-- There may be duplicate occurances of the same GeoJSON representation.
--   Make sure that GeoJSON-to-OriginalGeometry is 1-to-many
DELETE FROM conflation.:conflation_nodes_table
  WHERE (
    id IN (
      SELECT
          id
        FROM (
          SELECT
              id,
              rank() OVER (PARTITION BY ST_AsGeoJSON(wkb_geometry) ORDER BY id) AS r 
            FROM conflation.:conflation_nodes_table
        ) AS t
        WHERE ( r > 1 )
    )
  )
;

CLUSTER tmp_conflation_dumped_roadway_points
  USING tmp_conflation_dumped_roadway_points_geojson_idx;

CLUSTER conflation.:conflation_nodes_table
  USING :conflation_nodes_geojson_idx;

DROP TABLE IF EXISTS conflation.:conflation_ways_table ;

CREATE TABLE conflation.:conflation_ways_table (
  id        INTEGER PRIMARY KEY,
  node_ids  BIGINT[],

  FOREIGN KEY (id)
    REFERENCES conflation.:conflation_map_table
    ON DELETE CASCADE
) WITH (fillfactor=100) ;


DELETE FROM tmp_conflation_dumped_roadway_points
  WHERE (
    (id, idx) IN (
      SELECT
          b.id,
          b.idx
        FROM tmp_conflation_dumped_roadway_points AS a
          INNER JOIN tmp_conflation_dumped_roadway_points AS b
            USING (id, geojson)
        WHERE ( ( a.idx + 1 ) = b.idx )
    )
  )
;

-- Join the exploded points to the ConflationMap Nodes
--   using the GeoJSON representation of the coordinates.
INSERT INTO conflation.:conflation_ways_table (
  id,
  node_ids
)
  SELECT
      a.id,
      array_agg(b.id ORDER BY a.idx) AS node_ids
    FROM tmp_conflation_dumped_roadway_points AS a
      INNER JOIN conflation.:conflation_nodes_table AS b
        ON ( a.geojson = ST_AsGeoJSON(b.wkb_geometry) )
    GROUP BY a.id
;

DELETE FROM conflation.:conflation_nodes_table
 WHERE (
   id IN (
    SELECT DISTINCT
        a.id
      FROM conflation.:conflation_nodes_table AS a
        LEFT OUTER JOIN (
          SELECT
              unnest(node_ids) AS id
            FROM conflation.:conflation_ways_table
        ) AS b USING (id)
      WHERE ( b.id IS NULL )
   )
 )
;

DROP INDEX IF EXISTS conflation.:conflation_nodes_geojson_idx ;

CREATE INDEX IF NOT EXISTS :conflation_nodes_gix
  ON conflation.:conflation_nodes_table (wkb_geometry) ;

CLUSTER conflation.:conflation_nodes_table
  USING :conflation_nodes_gix ;

CLUSTER conflation.:conflation_ways_table
  USING :conflation_ways_table_pkey_idx ;

COMMIT ;

ANALYZE conflation.:conflation_nodes_table ;
ANALYZE conflation.:conflation_ways_table ;

-- QA output
BEGIN;

SELECT
  NOT EXISTS (
    SELECT 
        1
      FROM conflation.:conflation_map_table AS a
        FULL OUTER JOIN conflation.:conflation_ways_table AS b
          USING (id)
      WHERE (
        ( a.n < 8 )
        AND
        (
          ( a.id IS NULL )
          OR
          ( b.id IS NULL )
        )
      )
  ) AS map_ways_set_equality_test_passes ;

SELECT 
  NOT EXISTS (
    SELECT
        1
      FROM conflation.:conflation_nodes_table AS a
        FULL OUTER JOIN (
          SELECT
              unnest(node_ids) AS id
            FROM conflation.:conflation_ways_table
        ) AS b USING (id)
      WHERE (
        ( a.id IS NULL )
        OR
        ( b.id IS NULL )
      )
  ) AS nodes_and_way_nodeids_set_equality_test_passes
;

COMMIT;
