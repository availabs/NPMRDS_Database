DO
  LANGUAGE plpgsql
  $$
    DECLARE
      state         TEXT;
      test_result   TEXT;

    BEGIN
      FOR state IN 
        SELECT
            schemaname AS state
          FROM pg_catalog.pg_tables
          WHERE (
            -- NOTE: For on and qc, all AADT NULL
            ( schemaname NOT IN ('public', 'on', 'qc' ) )
            AND
            ( tablename = 'tmc_metadata_2020' )
          )
          ORDER BY 1
      LOOP

        EXECUTE FORMAT('
          SELECT
              CASE WHEN (apples_to_apples.count > apples_to_oranges.count)
                THEN ''passed''
                ELSE  ''failed''
              END AS result
            FROM (
              SELECT
                  COUNT(1) AS count
                FROM %I.tmc_metadata_2019 as a
                  INNER JOIN %I.tmc_metadata_2020 as b
                    USING (tmc)
                WHERE (
                  ( abs(a.aadt_singl - b.aadt_singl) + abs(a.aadt_combi - b.aadt_combi) )
                  <
                  ( abs(a.aadt_singl - b.aadt_combi) + abs(a.aadt_combi - b.aadt_singl) )
                )
            ) AS apples_to_apples CROSS JOIN (
              SELECT
                  COUNT(1) AS count
                FROM %I.tmc_metadata_2019 as a
                  INNER JOIN %I.tmc_metadata_2020 as b
                    USING (tmc)
                WHERE (
                  ( abs(a.aadt_singl - b.aadt_singl) + abs(a.aadt_combi - b.aadt_combi) )
                  >
                  ( abs(a.aadt_singl - b.aadt_combi) + abs(a.aadt_combi - b.aadt_singl) )
                )
            ) AS apples_to_oranges
        ', state, state, state, state)
        INTO test_result ;

        RAISE NOTICE '% %', state, test_result;

      END LOOP;

    END ;
  $$

/* -- RESULTS:
psql:qa.sql:67: NOTICE:  ct passed
psql:qa.sql:67: NOTICE:  hi passed
psql:qa.sql:67: NOTICE:  nj passed
psql:qa.sql:67: NOTICE:  ny passed
psql:qa.sql:67: NOTICE:  pa passed
*/
