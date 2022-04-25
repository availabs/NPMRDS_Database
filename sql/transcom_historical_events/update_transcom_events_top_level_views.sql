CREATE SCHEMA IF NOT EXISTS _transcom_admin ;

DROP PROCEDURE IF EXISTS _transcom_admin.update_transcom_events_top_level_views();

CREATE OR REPLACE PROCEDURE _transcom_admin.update_transcom_events_top_level_views()
  LANGUAGE plpgsql
  AS $$
    DECLARE
      -- These variables are relevant for the PROCEDURE versioning.
      procedure_version TEXT := 'v0_0_1' ;

    BEGIN
      EXECUTE FORMAT('
          CREATE OR REPLACE VIEW transcom.transcom_events_onto_road_network
            AS
              SELECT
                  *
                FROM _transcom_admin.%I
          ;
        ',
        'transcom_events_onto_road_network_' || procedure_version
      ) ;

      EXECUTE FORMAT('
          DROP MATERIALIZED VIEW IF EXISTS transcom_events_by_tmc_summary ;

          CREATE MATERIALIZED VIEW IF NOT EXISTS transcom.transcom_events_by_tmc_summary
            WITH (fillfactor=100)
            AS
              SELECT
                  *
                FROM _transcom_admin.%I
          ;

          CREATE INDEX transcom_events_by_tmc_summary_pkey_idx
            ON transcom.transcom_events_by_tmc_summary (tmc, year)
            WITH (fillfactor=100)
          ;

          CLUSTER transcom.transcom_events_by_tmc_summary
            USING transcom_events_by_tmc_summary_pkey_idx
          ;
        ',
        'transcom_events_by_tmc_summary_' || procedure_version
      ) ;
    END;
$$;
