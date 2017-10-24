DROP FUNCTION IF EXISTS terse_bq_top_level_measures_fn (
    VARCHAR(2)[],            -- states as array
    geography_level_type[],  -- geography levels as array
    SMALLINT[],              -- years as array
    SMALLINT[]               -- months as array
  );
