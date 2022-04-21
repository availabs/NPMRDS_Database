CREATE SCHEMA IF NOT EXISTS _transcom_admin ;

DROP PROCEDURE IF EXISTS _transcom_admin.update_transcom_events_to_signed_conflation_map_nodes_view();

CREATE OR REPLACE PROCEDURE _transcom_admin.update_transcom_events_to_signed_conflation_map_nodes_view()
  LANGUAGE plpgsql
  AS $$
    DECLARE
      -- These variables are relevant for the PROCEDURE versioning.
      procedure_version TEXT := 'v0_0_2' ;
      conflation_map_version TEXT := 'v0_6_0' ;

      table_name TEXT ;

      event_year SMALLINT ;

      ddl TEXT ;
      ddl_arr TEXT[] ;

    BEGIN
      PERFORM
          set_config(
            'search_path',
            ( SELECT boot_val FROM pg_settings WHERE name='search_path' ),
            true
          )
      ;

      table_name := 'transcom_events_to_osm_ways_' || procedure_version ;

      FOR event_year IN
        EXECUTE FORMAT('SELECT DISTINCT year FROM _transcom_admin.%I ORDER BY year ', table_name)
        LOOP

          SELECT FORMAT('
            SELECT
                a.event_id,
                a.year,
                b.c_way_id AS conflation_way_id,
                CASE
                  WHEN a.osm_fwd = 0 THEN -b.c_node_id
                  ELSE b.c_node_id
                END AS conflation_node_id,
                b.tmc
              FROM _transcom_admin.%I AS a
                INNER JOIN LATERAL (
                  SELECT
                      x.id AS c_way_id,
                      y.c_node_id,
                      z.wkb_geometry AS node_geom,
                      x.tmc
                  FROM conflation.%I AS x
                    INNER JOIN LATERAL (
                      SELECT
                          UNNEST(t.node_ids)  AS c_node_id
                        FROM conflation.%I AS t
                        WHERE ( x.id = t.id )
                    ) AS y ON TRUE
                      INNER JOIN conflation.%I AS z
                        ON ( y.c_node_id = z.id )
                  WHERE (
                    ( a.osm_way_id = x.osm )
                    AND
                    ( a.osm_fwd = x.osm_fwd )
                  )
                  ORDER BY ( a.snap_pt_geom <-> z.wkb_geometry ) ASC
                  LIMIT 1
                ) AS b ON TRUE
              WHERE ( a.year = %L )
          ',
          table_name,
          'conflation_map_' || event_year || '_' || conflation_map_version,
          'conflation_map_' || event_year || '_ways_' || conflation_map_version,
          'conflation_map_' || event_year || '_nodes_' || conflation_map_version,
          event_year
        ) INTO ddl ;

        ddl_arr := ddl || ddl_arr ;

      END LOOP ;

      EXECUTE FORMAT('SELECT array_to_string(%L::TEXT[], ''
          UNION ALL''
        ) ;
        ',
        ddl_arr
      ) INTO ddl ;

      SELECT FORMAT('
        CREATE OR REPLACE VIEW _transcom_admin.%I
          AS ',
        'transcom_events_to_signed_conflation_map_nodes_' || procedure_version,
        ddl
      ) || ddl
        || '
        ;' INTO ddl;

      EXECUTE ddl;

      RAISE NOTICE 'DONE:   %', clock_timestamp();

    END;
$$;
