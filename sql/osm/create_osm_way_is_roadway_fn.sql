CREATE OR REPLACE FUNCTION osm.osm_way_is_roadway (
    tags JSONB
  )
  RETURNS BOOLEAN
  AS $body$
    SELECT (
       (
         REPLACE(tags->>'highway', '_link', '') IN (
           'motorway',
           'trunk',
           'primary',
           'secondary',
           'tertiary',

           'unclassified',
           'residential',
           'living_street'
         )
       )
       OR
       (
         ( tags->>'highway' = 'service' )
         AND
         (
           tags->>'service' NOT IN (
             'parking',
             'driveway',
             'drive-through'
           )
         )
       )
    )  
  $body$ LANGUAGE SQL
;
