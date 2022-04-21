CREATE SCHEMA IF NOT EXISTS _transcom_admin ;

DROP PROCEDURE IF EXISTS _transcom_admin.update_transcom_events_to_osm_ways_table();

CREATE OR REPLACE PROCEDURE _transcom_admin.update_transcom_events_to_osm_ways_table()
  LANGUAGE plpgsql
  AS $$
    DECLARE
      -- These variables are relevant for the PROCEDURE versioning.
      procedure_version TEXT := 'v0_0_2' ;
      conflation_map_version TEXT := 'v0_6_0' ;
      -- NOTE: conflation_map must exist for every year in range.
      --  min_event_year SMALLINT := 2016 ;
      min_event_year SMALLINT := 2016 ;
      max_event_year SMALLINT := 2021 ;

      cmd TEXT ;

      table_name TEXT ;

      current_max_modified_timestamp TIMESTAMP ;

      mapping_start_timestamp TIMESTAMP := NOW() ;

      event_year SMALLINT ;

      knn_K SMALLINT := 5 ;

    BEGIN
      RAISE NOTICE 'DONE:   %', clock_timestamp();

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

      --  This table into which the TRANSCOM Events -> OSM Ways mappings are loaded
      --    is created in the _transcom_admin schema.
      --  This table will inherit from transcom.transcom_events_to_osm_ways.
      table_name := 'transcom_events_to_osm_ways_' || procedure_version ;

      EXECUTE FORMAT ('
          CREATE TABLE IF NOT EXISTS transcom.transcom_events_to_osm_ways (
            event_id              TEXT,
            year                  SMALLINT,
            osm_way_id            BIGINT,
            osm_fwd               INTEGER,
            snap_pt_geom          public.geometry(Point, 4326),

            _modified_timestamp   TIMESTAMP NOT NULL,

            PRIMARY KEY (event_id, year)
          ) ;

          CREATE TABLE IF NOT EXISTS _transcom_admin.%I (
            LIKE transcom.transcom_events_to_osm_ways INCLUDING ALL
          )
        ',
        table_name
      ) ;

      -- If the table has already been loaded, get the last _modified_timestamp from the table.
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

      RAISE NOTICE 'create tmp_transcom_events start: %', clock_timestamp();

      EXECUTE FORMAT ('
          CREATE TEMPORARY TABLE tmp_transcom_events
            WITH (fillfactor = 100)
            ON COMMIT DROP
            AS
              SELECT
                  a.event_id,
                  b.year,
                  a.description,
                  a.point_geom,
                  a._modified_timestamp
                FROM transcom._transcom_historical_events AS a
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

          CREATE INDEX tmp_transcom_events_gix
            ON tmp_transcom_events
              USING GIST (point_geom)
          ;
          
          CLUSTER tmp_transcom_events
            USING tmp_transcom_events_gix ;

          ANALYZE tmp_transcom_events ;
        ',
        current_max_modified_timestamp,
        min_event_year,
        max_event_year
      ) ;

      RAISE NOTICE 'create tmp_transcom_events done:  %', clock_timestamp();

      CREATE TEMPORARY TABLE tmp_event_to_cways_knn (
        event_id            TEXT,
        c_way_id            BIGINT,
        snap_dist           DOUBLE PRECISION,
        snap_pt_geom           public.geometry(Geometry,4326),
        PRIMARY KEY (event_id, c_way_id)
      ) WITH (fillfactor=100)
        ON COMMIT DROP
      ;

      CREATE INDEX tmp_event_to_cways_knn_idx
        ON tmp_event_to_cways_knn (c_way_id)
      ;

      FOR event_year IN ( SELECT DISTINCT year FROM tmp_transcom_events ORDER BY year )
        LOOP
          RAISE NOTICE 'Event Year: %', event_year;
          RAISE NOTICE '  start time: %', clock_timestamp();

          TRUNCATE tmp_event_to_cways_knn ;

          EXECUTE FORMAT('
              INSERT INTO tmp_event_to_cways_knn (
                event_id,
                c_way_id,
                snap_dist,
                snap_pt_geom
              )
                SELECT
                    a.event_id,
                    b.c_way_id,
                    b.snap_dist,
                    b.snap_pt_geom
                  FROM tmp_transcom_events AS a
                    INNER JOIN LATERAL (
                      SELECT 
                        id AS c_way_id,
                        ST_Distance(
                          GEOGRAPHY(a.point_geom),
                          GEOGRAPHY(x.wkb_geometry)
                        ) AS snap_dist,
                        ST_ClosestPoint(x.wkb_geometry, a.point_geom) AS snap_pt_geom
                      FROM conflation.%I AS x
                      WHERE ( x.n < 7 )
                      ORDER BY ( a.point_geom <-> x.wkb_geometry ) ASC
                      LIMIT %L -- The K of the KNN
                    ) AS b ON TRUE
                  WHERE ( a.year = %L )
              ;

              CLUSTER tmp_event_to_cways_knn
                USING tmp_event_to_cways_knn_idx
              ;
            ',
            'conflation_map_' || event_year || '_' || conflation_map_version,
            knn_K,
            event_year
          ) ;

        EXECUTE FORMAT('
            INSERT INTO _transcom_admin.%I (
              event_id,
              year,
              osm_way_id,
              osm_fwd,
              snap_pt_geom,
              _modified_timestamp
            )
              SELECT
                  event_id,
                  %L AS year,
                  osm_way_id,
                  osm_fwd,
                  snap_pt_geom,
                  _modified_timestamp
                FROM (
                  SELECT
                      event_id,
                      _modified_timestamp,
                      osm_way_id,
                      osm_fwd,
                      snap_pt_geom,

                      row_number() OVER (
                        PARTITION BY event_id
                        ORDER BY
                          (
                            snap_dist 
                            *
                            CASE
                              WHEN is_same_dir THEN 0.5
                              ELSE 1
                            END
                          ) ASC,
                          osm_fwd ASC,
                          osm_way_id ASC
                      ) AS rownum

                    FROM (
                      SELECT
                          a.event_id,
                          a._modified_timestamp,
                          c.osm AS osm_way_id,
                          c.osm_fwd,
                          b.snap_pt_geom,
                          b.snap_dist,
                          (
                            COALESCE(d.direction, ''NONE'') =
                              CASE
                                WHEN a.description ILIKE ''%%northbound%%''  THEN ''N''
                                WHEN a.description ILIKE ''%%southbound%%''  THEN ''S''
                                WHEN a.description ILIKE ''%%eastbound%%''   THEN ''E''
                                WHEN a.description ILIKE ''%%westbound%%''   THEN ''W''
                                ELSE ''NONE''
                              END
                          ) AS is_same_dir
                        FROM tmp_transcom_events AS a
                          INNER JOIN tmp_event_to_cways_knn  AS b
                            USING (event_id)
                          INNER JOIN conflation.%I AS c
                            ON ( b.c_way_id = c.id )
                          LEFT OUTER JOIN ny.%I AS d
                            USING (tmc)
                        WHERE ( a.year = %L )
                    ) AS x
                  ) AS y
                  WHERE ( rownum = 1 )

              ON CONFLICT (event_id, year) DO
                UPDATE SET
                  osm_way_id           = EXCLUDED.osm_way_id,
                  osm_fwd              = EXCLUDED.osm_fwd,
                  snap_pt_geom         = EXCLUDED.snap_pt_geom,
                  _modified_timestamp  = EXCLUDED._modified_timestamp
            ;
          ',
          table_name,
          event_year,
          'conflation_map_' || event_year || '_' || conflation_map_version,
          'tmc_metadata_' || event_year,
          event_year
        ) ;

        RAISE NOTICE '  end time:   %', clock_timestamp();

        END LOOP ;

      RAISE NOTICE 'DONE:   %', clock_timestamp();

    END;
$$;
