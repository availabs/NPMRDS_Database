BEGIN ;

CREATE OR REPLACE FUNCTION public._qa_tmc_metadata_versions_diff(
    state       TEXT,
    version_a   TEXT,
    version_b   TEXT
  )
  RETURNS TABLE (
    tmc                   TEXT,
    diff                  JSONB
  )
  AS $$
    BEGIN

    EXECUTE FORMAT('
        CREATE TEMPORARY TABLE tmp_ver_a (
          tmc     TEXT,
          key     TEXT,
          value   JSON,

          PRIMARY KEY (tmc, key)
        ) WITH (fillfactor=100)
          ON COMMIT DROP
        ;

        INSERT INTO tmp_ver_a (
          tmc,
          key,
          value
        )
          SELECT
              tmc::TEXT,
              (d).key,
              (d).value
            FROM (
              SELECT
                  tmc,
                  json_each(
                    row_to_json(x)
                  ) AS d
                FROM %I.%I AS x
              ) AS y
        ;

        CLUSTER tmp_ver_a USING tmp_ver_a_pkey ;
      ',
      state,
      version_a
    ) ;

    EXECUTE FORMAT('
        CREATE TEMPORARY TABLE tmp_ver_b (
          tmc     TEXT,
          key     TEXT,
          value   JSON,

          PRIMARY KEY (tmc, key)
        ) WITH (fillfactor=100)
          ON COMMIT DROP
        ;

        INSERT INTO tmp_ver_b (
          tmc,
          key,
          value
        )
          SELECT
              tmc::TEXT,
              (d).key,
              (d).value
            FROM (
              SELECT
                  tmc,
                  json_each(
                    row_to_json(x)
                  ) AS d
                FROM %I.%I AS x
              ) AS y
        ;

        CLUSTER tmp_ver_b USING tmp_ver_b_pkey ;
      ',
      state,
      version_b
    ) ;

    RETURN QUERY EXECUTE '
      SELECT
          tmc,
          jsonb_object_agg(
            key,
            json_build_object(
              ''ver_a'',    a.value,
              ''ver_b'',    b.value
            )
          )
        FROM tmp_ver_a AS a
          FULL OUTER JOIN tmp_ver_b AS b
            USING (tmc, key)
        WHERE (
          -- one measure data object has a key the other does not (both cannot be null if theres a row)
          ( a.key IS NULL )
          OR
          ( b.key IS NULL )
          OR
          ( a.value::TEXT <> b.value::TEXT ) -- values are different
          OR
          ( -- one, but not both, is null
            ( ( a.value::TEXT <> b.value::TEXT ) IS NULL )
            AND
            ( COALESCE(a.value, b.value) IS NOT NULL )
          )
        )
        GROUP BY tmc
      ;'
    ;

    END ;
  $$ LANGUAGE plpgsql
;


COMMENT ON FUNCTION public._qa_tmc_metadata_versions_diff(state TEXT, version_a TEXT, version_b TEXT) IS '
  This FUNCTION compares two tmc_metadata versions.
';


CREATE OR REPLACE FUNCTION public._qa_tmc_metadata_versions_diff_columns(
    state       TEXT,
    version_a   TEXT,
    version_b   TEXT
  )
  RETURNS TABLE (
    "column" TEXT
  )
  AS $$
    SELECT DISTINCT
        jsonb_object_keys(diff)
      FROM public._qa_tmc_metadata_versions_diff(state, version_a, version_b)
      ORDER BY 1
    ;
  $$ LANGUAGE SQL
;

COMMIT ;
