-- This is required because cannot use psql script variables, i.e. :STATE, inside do block.
CREATE TEMPORARY TABLE tmp_script_variables
  ON COMMIT DROP
  AS
    SELECT
        :'STATE' AS state
;

-- This is necessary because ADD CONSTRAINT IF NOT EXISTS is not supported.
DO $$
  DECLARE
    state TEXT ;
    constraint_exists BOOLEAN ;
  BEGIN

    EXECUTE '
        SELECT
            state
          FROM tmp_script_variables
        ;
      '
      INTO state
    ;

    EXECUTE FORMAT('
        CREATE SCHEMA IF NOT EXISTS %I ;
      ', 
      state
    ) ;
    
    EXECUTE FORMAT('
        CREATE TABLE IF NOT EXISTS %I.npmrds (
          LIKE npmrds INCLUDING ALL
        ) ;
      ', 
      state
    ) ;
    
    -- Have we aleady created the state CHECK constraint?
    EXECUTE FORMAT('
        SELECT EXISTS (
          SELECT
              1
            FROM information_schema.constraint_column_usage  
            WHERE (
              ( table_schema = %L )
              AND
              ( table_name = ''npmrds'' )
              AND
              ( constraint_name = ''npmrds_state_check'' )
            )
        )
      ',
      state
    ) INTO constraint_exists
  ;

  IF NOT constraint_exists
    THEN
      -- ASSUMPTION: If npmrds_state_check does not exist, does not yet INHERIT 
      EXECUTE FORMAT('
          ALTER TABLE %I.npmrds
            ADD CONSTRAINT npmrds_state_check
              CHECK (state = %L),
            ALTER COLUMN state
              SET DEFAULT %L,
            INHERIT public.npmrds
          ;
        ',
        state,
        state,
        state
      ) ;
    END IF;
END $$ ;

DROP TABLE tmp_script_variables ;
