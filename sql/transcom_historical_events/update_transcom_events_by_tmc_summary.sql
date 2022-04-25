CREATE SCHEMA IF NOT EXISTS _transcom_admin ;

DROP PROCEDURE IF EXISTS _transcom_admin.update_transcom_events_by_tmc_summary();

CREATE OR REPLACE PROCEDURE _transcom_admin.update_transcom_events_by_tmc_summary()
  LANGUAGE plpgsql
  AS $$
    DECLARE
      -- These variables are relevant for the PROCEDURE versioning.
      procedure_version TEXT := 'v0_0_1' ;

    BEGIN
      PERFORM
          set_config(
            'search_path',
            ( SELECT boot_val FROM pg_settings WHERE name='search_path' ),
            true
          )
      ;

      EXECUTE FORMAT('
          CREATE OR REPLACE VIEW _transcom_admin.%I
            AS
              SELECT
                  tmc,
                  year,

                  jsonb_object_agg(
                    t1.event_type,
                    t1.event_type_ct
                  ) AS event_type_summary,

                  jsonb_object_agg(
                    t2.event_class,
                    t2.event_class_ct
                  ) AS event_class_summary

                FROM (
                  SELECT
                      tmc,
                      year,
                      event_type,
                      count(1) AS event_type_ct
                  FROM _transcom_admin.%I AS a
                  GROUP BY tmc, year, event_type
                ) AS t1 INNER JOIN (
                  SELECT
                      tmc,
                      year,
                      COALESCE(event_class, ''unknown'') AS event_class,
                      count(1) AS event_class_ct
                  FROM _transcom_admin.%I AS a
                  GROUP BY tmc, year, event_class
                ) AS t2 USING (tmc, year)
                GROUP BY tmc, year
        ',
        'transcom_events_by_tmc_summary_' || procedure_version,
        'transcom_events_onto_road_network_' || procedure_version,
        'transcom_events_onto_road_network_' || procedure_version
      ) ;

    END;
$$;

