-- This is required because cannot use psql script variables, i.e. :STATE, inside do block.
CREATE TEMPORARY TABLE tmp_script_variables
 AS
    SELECT
        :'STATE' AS state,
        (:YEAR)::SMALLINT AS year,
        (:MONTH)::SMALLINT AS month
;

-- This is necessary because ADD CONSTRAINT IF NOT EXISTS is not supported.
DO $$
  DECLARE
    state TEXT ;
    year  SMALLINT ;
    month SMALLINT ;

    table_name TEXT ;

    start_date DATE ;
    end_date DATE ;
  BEGIN
    EXECUTE '
      SELECT
          state,
          year,
          month
        FROM tmp_script_variables
    ' INTO state, year, month ;

    table_name := 'npmrds_y' || year || 'm' || lpad(month::TEXT, 2, '0') ;

    start_date := make_date(year, month, 1) ;
    end_date := start_date + '1 month'::INTERVAL;

    EXECUTE FORMAT('
        CREATE TABLE IF NOT EXISTS %I.%I (
          PRIMARY KEY (tmc, date, epoch),

          CHECK((date >= %L) AND (date < %L))
        ) INHERITS (%I.npmrds);
      ',
      state,
      table_name,
      start_date,
      end_date,
      state
    ) ;
        
  END
$$ ;

DROP TABLE tmp_script_variables ;
