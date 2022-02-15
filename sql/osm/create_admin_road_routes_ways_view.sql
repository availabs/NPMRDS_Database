/*
NOTE: Relation members can be hybrid:

  npmrds_production=# select m.member->>'type' member_type, count(1) from osm.osm_relations_v210101, jsonb_array_elements(members) as m(member) where id = 112101 group by 1;
   member_type | count 
  -------------+-------
   way         |     7
   relation    |    13
  (2 rows)

*/

BEGIN;

CREATE SCHEMA IF NOT EXISTS _osm_admin ;

DROP VIEW IF EXISTS _osm_admin.osm_road_routes_ways_v:OSM_VERSION ;

CREATE OR REPLACE VIEW _osm_admin.osm_road_routes_ways_v:OSM_VERSION
  AS
    WITH RECURSIVE cte_routes_hierarchy AS (
      SELECT
          r.id::BIGINT AS osm_route_id,
          '{}'::BIGINT[] AS children_ids,
          ARRAY[m.idx] AS member_indexes,
          (m.member->>'ref')::BIGINT AS osm_way_id,
          false as cycle
        FROM osm.osm_relations_v:OSM_VERSION AS r,
          jsonb_array_elements(members) WITH ORDINALITY AS m(member, idx)
        WHERE (
          ( tags->>'type' = 'route' )
          AND
          ( tags->>'route' = 'road' )
          AND
          ( member->>'type' = 'way' )
        )
      UNION ALL
      SELECT
          r.id AS osm_route_id,
          array_prepend(h.osm_route_id, h.children_ids) AS children_ids,
          array_prepend(m.idx, h.member_indexes) AS member_indexes,
          h.osm_way_id,
          ((m.member->>'ref')::BIGINT = ANY(h.children_ids) ) AS cycle
        FROM osm.osm_relations_v:OSM_VERSION AS r
          INNER JOIN LATERAL jsonb_array_elements(r.members) WITH ORDINALITY AS m(member, idx)
            ON (true)
          INNER JOIN cte_routes_hierarchy AS h
            ON ((m.member->>'ref')::BIGINT = h.osm_route_id)
        WHERE (
          ( NOT h.cycle )
          AND
          ( r.tags->>'type' = 'route' )
          AND
          ( r.tags->>'route' = 'road' )
          AND
          ( m.member->>'type' = 'relation' )
        )
    )
      SELECT
          osm_route_id,
          array_prepend(osm_route_id, children_ids) AS path,
          member_indexes,
          osm_way_id
        FROM cte_routes_hierarchy
;

COMMIT ;
