CREATE TEMPORARY TABLE tmp_mdd_version AS
  SELECT
    :'STATE' AS state,
    :YEAR AS year,
    :'VERSION_TIMESTAMP' AS version_timestamp
;

DO
  LANGUAGE plpgsql
  $$
    DECLARE
      state                 TEXT;
      year                  SMALLINT;
      version_timestamp     TEXT;

      prev_active_partition TEXT ;

    BEGIN

      SELECT * FROM tmp_mdd_version INTO state, year, version_timestamp;
        

      EXECUTE FORMAT (
        'CLUSTER %I.%I USING %I;',
        state,
        'mdd_tmc_shapes_' || year || '_v' || version_timestamp,
        'mdd_tmc_shapes_' || year || '_v' || version_timestamp || '_gix'
      ) ;

      FOR prev_active_partition IN
        EXECUTE FORMAT('
            SELECT
                inhrelid::regclass::TEXT AS partition
              FROM pg_catalog.pg_inherits
              WHERE inhparent = %L::regclass;
          ',
          state || '.mdd_tmc_shapes_' || year
        )
      LOOP

        EXECUTE FORMAT('
            ALTER TABLE %I.%I
              DETACH PARTITION %s ;
          ',
          state,
          'mdd_tmc_shapes_' || year,
          prev_active_partition
        );

      END LOOP ;

      EXECUTE FORMAT ('
          ALTER TABLE %I.%I
            ATTACH PARTITION %I.%I
            FOR VALUES IN (%L)
        ',
        state, 
        'mdd_tmc_shapes_' || year,
        state,
        'mdd_tmc_shapes_' || year || '_v' || version_timestamp,
        state
      ) ;

    END;
$$;
