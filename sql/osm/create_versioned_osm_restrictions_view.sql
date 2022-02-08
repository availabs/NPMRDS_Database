BEGIN;

\set tbl_name 'osm_relations_v':OSM_VERSION
\set view_name 'osm_restrictions_v':OSM_VERSION

CREATE MATERIALIZED VIEW IF NOT EXISTS osm.:view_name
  AS 
    SELECT DiSTINCT ON (id)
        a.id,
        a.tags,
        jsonb_agg(
          b.member
            ORDER BY b.idx
        ) FILTER ( WHERE ( b.member->>'role' = 'from' ) ) AS from,
        jsonb_agg(
          b.member
            ORDER BY b.idx
        ) FILTER ( WHERE ( b.member->>'role' = 'to' ) ) AS to,
        jsonb_agg(
          b.member
            ORDER BY b.idx
        ) FILTER ( WHERE ( b.member->>'role' = 'via' ) ) AS via
      FROM osm.:tbl_name AS a
        LEFT JOIN jsonb_array_elements(a.members) WITH ORDINALITY AS b(member, idx)
          ON TRUE
      WHERE ( a.tags->>'type' = 'restriction' )
      GROUP BY a.id
;

COMMIT;
