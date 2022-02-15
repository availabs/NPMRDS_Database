BEGIN;

CREATE SCHEMA IF NOT EXISTS _osm_admin ;

DROP VIEW IF EXISTS _osm_admin.osm_road_routes_metadata_v:OSM_VERSION ;

CREATE OR REPLACE VIEW _osm_admin.osm_road_routes_metadata_v:OSM_VERSION
  AS
    SELECT
        id,
        tags->>'name' AS name,
        tags->>'ref' AS ref,
        tags->>'unsigned_ref' AS unsigned_ref,
        tags->>'network' AS network,
        tags->>'direction' AS direction,
        tags->>'symbol' AS symbol,
        tags
      FROM osm.osm_relations_v:OSM_VERSION
      WHERE (
        ( tags->>'type' = 'route' )
        AND
        ( tags->>'route' = 'road' )
      )
;

DROP VIEW IF EXISTS _osm_admin.osm_road_super_routes_v:OSM_VERSION ;

CREATE OR REPLACE VIEW _osm_admin.osm_road_nonsuper_routes_v:OSM_VERSION
  AS
    SELECT DISTINCT
        r.id AS osm_relation_id,
        (m.member->>'ref')::BIGINT AS osm_way_id,
        m.idx AS member_osm_relation_idx
      FROM osm.osm_relations_v:OSM_VERSION AS r,
        jsonb_array_elements(r.members) WITH ORDINALITY AS m(member, idx)
      WHERE (
        ( r.tags->>'type' = 'route' )
        AND
        ( r.tags->>'route' = 'road' )
        AND
        ( m.member->>'type' = 'way' )
      )
;

CREATE OR REPLACE VIEW _osm_admin.osm_road_super_routes_v:OSM_VERSION
  AS
    SELECT
        r.id AS osm_relation_id,
        (m.member->>'ref')::BIGINT AS member_osm_relation_id,
        m.idx AS member_osm_relation_idx
      FROM osm.osm_relations_v:OSM_VERSION AS r,
        jsonb_array_elements(r.members) WITH ORDINALITY AS m(member, idx)
      WHERE (
        ( r.tags->>'type' = 'route' )
        AND
        ( r.tags->>'route' = 'road' )
        AND
        ( m.member->>'type' = 'relation' )
      )
;

COMMIT;
