/*
  here_realtime_traffic_partitions table rolling

    Consolidates smaller time unit partition tables into larger time unit partitions.
*/
BEGIN;

CREATE SCHEMA IF NOT EXISTS _transcom_admin ;

DROP PROCEDURE IF EXISTS _transcom_admin.project_transcom_events_onto_osm_map_proc();

CREATE OR REPLACE PROCEDURE _transcom_admin.project_transcom_events_onto_osm_map_proc()
  LANGUAGE plpgsql
  AS $$
    DECLARE
      -- These variables are relevant for the PROCEDURE versioning.
      procedure_version TEXT := 'v0_0_1' ;
      conflation_map_version TEXT := 'v0_6_0' ;
      -- NOTE: conflation_map must exist for every year in range.
      --  min_event_year SMALLINT := 2016 ;
      min_event_year SMALLINT := 2020 ;
      max_event_year SMALLINT := 2020 ;

      table_name TEXT;
      current_max_modified_timestamp TIMESTAMP;

      event_year SMALLINT;
    BEGIN
      -- When the search_path was set to _transcom_admin, the following error occurred:
      --    LINE 1: SELECT point_geom <-> point_geom from transcom.transcom_hist...
      --                              ^       
      --    HINT:  No operator matches the given name and argument types.
      --
      -- The below PERFORM fixes that problem by temporarily restoring the default search_path.
      PERFORM
          set_config(
            'search_path',
            ( SELECT boot_val FROM pg_settings WHERE name='search_path' ),
            true
          )
      ;

      table_name := 'transcom_events_osm_mappings_' || procedure_version ;

      EXECUTE FORMAT ('
          CREATE TABLE IF NOT EXISTS _transcom_admin.%I (
            LIKE transcom.transcom_events_osm_mappings INCLUDING ALL
          )
        ',
        table_name
      ) ;

      EXECUTE FORMAT ('
          SELECT
              MAX(_modified_timestamp)
            FROM (
              SELECT
                  _modified_timestamp
                FROM _transcom_admin.%I
              UNION
              SELECT
                  ''1900-01-01''::TIMESTAMP AS _modified_timestamp
            ) AS t
        ',
        table_name
      ) INTO current_max_modified_timestamp ;

      EXECUTE FORMAT ('
          CREATE TEMPORARY TABLE tmp_new_events
            WITH (fillfactor = 100)
            ON COMMIT DROP
            AS
              SELECT
                  a.event_id,
                  b.year,
                  a.description,
                  a.point_geom
                FROM transcom.transcom_historical_events AS a
                  LEFT JOIN LATERAL generate_series(
                    EXTRACT(YEAR FROM open_time)::INTEGER,
                    EXTRACT(YEAR FROM close_time)::INTEGER
                  ) AS b(year) ON TRUE
                WHERE (
                  ( _modified_timestamp >= %L::TIMESTAMP )
                  AND
                  ( b.year BETWEEN %L and %L )
                )
          ;

          CREATE INDEX tmp_new_events_geom_index
            ON tmp_new_events
              USING GIST (point_geom)
          ;
          
          CLUSTER tmp_new_events USING tmp_new_events_geom_index ;

          ANALYZE tmp_new_events ;
        ',
        current_max_modified_timestamp,
        min_event_year,
        max_event_year
      ) ;
      
      FOR event_year IN ( SELECT DISTINCT year FROM tmp_new_events ORDER BY year )
        LOOP
          EXECUTE FORMAT('
            INSERT INTO _transcom_admin.%I (
              event_id,
              year,
              node_id,
              way_id,
              _created_timestamp,
              _modified_timestamp
            )
              SELECT
                  a.event_id,
                  %L AS year,
                  CASE
                    WHEN b.osm_fwd = 0 THEN -b.node_id
                    ELSE b.node_id
                  END AS node_id,
                  b.way_id,
                  NOW(),
                  NOW()
                FROM tmp_new_events AS a
                  LEFT JOIN LATERAL (
                    SELECT UNNEST(node_ids) AS node_id,
                      COALESCE(osm_fwd, 1)::INTEGER AS osm_fwd,
                      id AS way_id
                    FROM conflation.%I AS x
                      INNER JOIN conflation.%I AS y
                        USING(id)
                      LEFT OUTER JOIN ny.%I AS z
                        USING(tmc)
                    WHERE (
                      (
                        COALESCE(z.direction, ''NONE'') =
                          CASE
                            WHEN a.description LIKE ''%%northbound%%''  THEN ''N''
                            WHEN a.description LIKE ''%%southbound%%''  THEN ''S''
                            WHEN a.description LIKE ''%%eastbound%%''   THEN ''E''
                            WHEN a.description LIKE ''%%westbound%%''   THEN ''W''
                            ELSE ''NONE''
                          END
                      )
                      AND
                      ( x.n < 7 )
                    )
                    ORDER BY ( a.point_geom <-> x.wkb_geometry ) ASC
                    LIMIT 1
                  ) AS b ON TRUE

              ON CONFLICT (event_id, year) DO
                UPDATE SET
                  node_id              = EXCLUDED.node_id,
                  way_id               = EXCLUDED.way_id,
                  _modified_timestamp  = EXCLUDED._modified_timestamp
            ',
            table_name,
            event_year,
            'conflation_map_' || event_year || '_' || conflation_map_version,
            'conflation_map_' || event_year || '_ways_' || conflation_map_version,
            'tmc_metadata_'   || event_year
          )
        ;

        END LOOP ;

    END;
$$;

COMMIT;
