/*
  SharedStreets RoadClass (network_level) logic:
    https://github.com/sharedstreets/sharedstreets-builder/blob/a554983e96010d32b71d7d23504fa88c6fbbad10/src/main/java/io/sharedstreets/tools/builder/osm/model/Way.java#L61-L94

  SharedStreets isOneWay logic:
    https://github.com/sharedstreets/sharedstreets-builder/blob/a554983e96010d32b71d7d23504fa88c6fbbad10/src/main/java/io/sharedstreets/tools/builder/osm/model/Way.java#L104-L130
*/

BEGIN;

DROP VIEW IF EXISTS osm.osm_roads_v:OSM_VERSION ;
CREATE OR REPLACE VIEW osm.osm_roads_v:OSM_VERSION
  AS
    SELECT
        id,
        tags,
        node_ids,

        tags->>'highway' AS highway,
        tags->>'service' AS service,

        /*
          // From SharedStreets
          public enum ROAD_CLASS {
              ClassMotorway(0),
              ClassTrunk(1),
              ClassPrimary(2),
              ClassSecondary(3),
              ClassTertiary(4),
              ClassResidential(5),
              ClassUnclassified(6),
              ClassService(7),
              ClassOther(8);
          }
        */
        CASE
          WHEN ( STARTS_WITH(TRIM(LOWER((tags->>'highway')::TEXT)), 'motorway'     ) )
            THEN 0
          WHEN ( STARTS_WITH(TRIM(LOWER((tags->>'highway')::TEXT)), 'trunk'        ) )
            THEN 1
          WHEN ( STARTS_WITH(TRIM(LOWER((tags->>'highway')::TEXT)), 'primary'      ) )
            THEN 2
          WHEN ( STARTS_WITH(TRIM(LOWER((tags->>'highway')::TEXT)), 'secondary'    ) )
            THEN 3
          WHEN ( STARTS_WITH(TRIM(LOWER((tags->>'highway')::TEXT)), 'tertiary'     ) )
            THEN 4
          WHEN ( STARTS_WITH(TRIM(LOWER((tags->>'highway')::TEXT)), 'unclassified' ) )
            THEN 6
          WHEN ( STARTS_WITH(TRIM(LOWER((tags->>'highway')::TEXT)), 'service'      ) )
            THEN
              CASE
                WHEN (
                  ( STARTS_WITH(TRIM(LOWER((tags->>'service')::TEXT)), 'parking'      ) )
                  OR
                  ( STARTS_WITH(TRIM(LOWER((tags->>'service')::TEXT)), 'driveway'     ) )
                  OR
                  ( STARTS_WITH(TRIM(LOWER((tags->>'service')::TEXT)), 'drive-through') )
                ) THEN 8
                ELSE 7
              END
          WHEN ( STARTS_WITH(TRIM(LOWER((tags->>'highway')::TEXT)), 'living_street'  ) )
            THEN 5
          ELSE 8
        END AS network_level,

        --  Normalize and backfill the "oneway" tag.
        --  See
        --    * https://wiki.openstreetmap.org/wiki/Key:oneway#List_of_values
        --    * the SharedStreets isOneWay logic link in this file's header comment.
        CASE
          -- Normalizing using OSM documentation
          WHEN ( TRIM(LOWER((tags->>'oneway')::TEXT)) IN ('yes', 'true', '1') )
            THEN 'yes'
          WHEN ( TRIM(LOWER((tags->>'oneway')::TEXT)) IN ('no', 'false', '0') )
            THEN 'no'
          WHEN ( TRIM(LOWER((tags->>'oneway')::TEXT)) IN ('reverse', '-1') )
            THEN 'reverse'
          WHEN ( TRIM(LOWER((tags->>'oneway')::TEXT)) = 'reversible'          )
            THEN 'reversible'
          WHEN ( TRIM(LOWER((tags->>'oneway')::TEXT)) = 'alternating'         )
            THEN 'alternating'
          -- Backfilling using SharedStreets logic
          WHEN (
              ( TRIM(LOWER((tags->>'highway')::TEXT)) = 'motorway'    )
              OR
              ( TRIM(LOWER((tags->>'junction')::TEXT)) = 'roundabout' )
            ) THEN 'yes'
          ELSE 'no'
        END AS is_oneway,

        ( ST_Length(GEOGRAPHY(wkb_geometry)) / 1000.0 ) AS length_km,

        wkb_geometry
      FROM osm.osm_ways_v:OSM_VERSION
      WHERE ( -- Apply filter to get ONLY roadways.
        (
          tags->>'highway' IN (
            'motorway',
            'trunk',
            'primary',
            'secondary',
            'tertiary',
            'unclassified',
            'residential',
            'living_street'
            'service'
          )
        )
      )
;

COMMIT;
