CREATE FUNCTION terse_bq_top_level_measures_fn (
    VARCHAR(2)[],            -- states as array
    geography_level_type[],  -- geography levels as array
    SMALLINT[],              -- years as array
    SMALLINT[]               -- months as array
  ) 
  RETURNS TEXT
  LANGUAGE plpgsql

  AS $body$

    DECLARE
      measures TEXT;

    BEGIN
      SET LOCAL work_mem = '256MB';

      SELECT INTO measures JSONB_BUILD_OBJECT(
        'schema',
        JSONB_BUILD_OBJECT(
          'fields',
          JSONB_BUILD_ARRAY(

            -- travel_time_reliability schema description object
            JSONB_BUILD_OBJECT(
              'name',
              'travel_time_reliability',
              'type',
              'record',
              'fields',
              JSONB_BUILD_ARRAY(
                JSON_BUILD_OBJECT('name', 'state'),
                JSON_BUILD_OBJECT('name', 'geography_level'),
                JSON_BUILD_OBJECT('name', 'geography_name'),
                JSON_BUILD_OBJECT('name', 'year'),
                JSON_BUILD_OBJECT('name', 'month'),
                JSON_BUILD_OBJECT('name', 'functional_class'),
                JSON_BUILD_OBJECT('name', 'travel_time_reliability')
              ) --end travel_time_reliability fields array
            ), --end travel_time_reliability description object

            -- freight_reliability schema description object
            JSONB_BUILD_OBJECT(
              'name',
              'freight_reliability',
              'type',
              'record',
              'fields',
              JSONB_BUILD_ARRAY(
                JSON_BUILD_OBJECT('name', 'state'),
                JSON_BUILD_OBJECT('name', 'geography_level'),
                JSON_BUILD_OBJECT('name', 'geography_name'),
                JSON_BUILD_OBJECT('name', 'year'),
                JSON_BUILD_OBJECT('name', 'month'),
                JSON_BUILD_OBJECT('name', 'functional_class'),
                JSON_BUILD_OBJECT('name', 'freight_reliability')
              ) --end freight_reliability fields array
            ), --end freight_reliability description object

            -- total_excessive_delay schema description object
            JSONB_BUILD_OBJECT(
              'name',
              'total_excessive_delay',
              'type',
              'record',
              'fields',
              JSONB_BUILD_ARRAY(
                JSON_BUILD_OBJECT('name', 'state'),
                JSON_BUILD_OBJECT('name', 'geography_level'),
                JSON_BUILD_OBJECT('name', 'geography_name'),
                JSON_BUILD_OBJECT('name', 'year'),
                JSON_BUILD_OBJECT('name', 'month'),
                JSON_BUILD_OBJECT('name', 'functional_class'),
                JSON_BUILD_OBJECT('name', 'total_excessive_delay')
              )
            )
          ) -- end root fields array
        ), -- end the schema description object

        'data',
        JSONB_BUILD_ARRAY(

          ( -- begin travel_time_reliability
            SELECT JSONB_AGG(
                JSONB_BUILD_ARRAY(
                  state,
                  geography_level,
                  geography_name,
                  year,
                  month,
                  functional_class,
                  ttr
                )
              )
              FROM top_level_travel_time_reliability
              WHERE 
                (state = ANY($1::VARCHAR[]))
                AND (
                  ($2::geography_level_type[] IS NULL) 
                  OR (geography_level::geography_level_type = ANY($2::geography_level_type[]))
                ) AND (
                  ($3::SMALLINT[] IS NULL)
                  OR (year = ANY($3::SMALLINT[]))
                ) AND (
                  ($4::SMALLINT[] IS NULL)
                  OR (month = ANY($4::SMALLINT[]))
                )
          ), --end travel_time_reliability

          ( -- begin freight_reliability
            SELECT JSONB_AGG(
                JSONB_BUILD_ARRAY(
                  state,
                  geography_level,
                  geography_name,
                  year,
                  month,
                  functional_class,
                  fr
                )
              )
              FROM top_level_freight_reliability
              WHERE 
                (state = ANY($1::VARCHAR[]))
                AND (
                  ($2::geography_level_type[] IS NULL)
                  OR (geography_level::geography_level_type = ANY($2::geography_level_type[]))
                ) AND (
                  ($3::SMALLINT[] IS NULL)
                  OR (year = ANY($3::SMALLINT[]))
                ) AND (
                  ($4::SMALLINT[] IS NULL)
                  OR (month = ANY($4::SMALLINT[]))
                )
          ), -- end freight_reliability

          ( -- begin total_excessive_delay
            SELECT JSONB_AGG(
                JSONB_BUILD_ARRAY(
                  state,
                  geography_level,
                  geography_name,
                  year,
                  month,
                  functional_class,
                  total_excessive_delay
                )
              )
              FROM top_level_total_excessive_delay
              WHERE 
                (state = ANY($1::VARCHAR[]))
                AND (
                  ($2::geography_level_type[] IS NULL)
                  OR (geography_level::geography_level_type = ANY($2::geography_level_type[]))
                ) AND (
                  ($3::SMALLINT[] IS NULL)
                  OR (year = ANY($3::SMALLINT[]))
                ) AND (
                  ($4::SMALLINT[] IS NULL)
                  OR (month = ANY($4::SMALLINT[]))
                )
          ) -- end total_excessive_delay
        ) -- end the data array
      )::TEXT;

    RETURN measures;
    END;

  $body$;

