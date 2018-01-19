CREATE FUNCTION terse_bq_top_level_measures_fn (
    VARCHAR(2)[],            -- $1 -- states as array
    geography_level_type[],  -- $2 -- geography levels as array
    SMALLINT[],              -- $3 -- years as array
    SMALLINT[]               -- $4 -- months as array
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
                JSON_BUILD_OBJECT('name', 'states'),
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
                JSON_BUILD_OBJECT('name', 'states'),
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
                JSON_BUILD_OBJECT('name', 'states'),
                JSON_BUILD_OBJECT('name', 'geography_level'),
                JSON_BUILD_OBJECT('name', 'geography_name'),
                JSON_BUILD_OBJECT('name', 'year'),
                JSON_BUILD_OBJECT('name', 'month'),
                JSON_BUILD_OBJECT('name', 'functional_class'),
                JSON_BUILD_OBJECT('name', 'total_excessive_delay'),
                JSON_BUILD_OBJECT('name', 'population_info')
              )
            )
          ) -- end root fields array
        ), -- end the schema description object

        'data',
        JSONB_BUILD_ARRAY(

          ( -- begin travel_time_reliability
            SELECT JSONB_AGG(
                JSONB_BUILD_ARRAY(
                  array_to_string(d.states, '--'),
                  d.geography_level,
                  geography_name,
                  year,
                  month,
                  functional_class,
                  ttr
                )
              )
              FROM top_level_travel_time_reliability AS d
                INNER JOIN geography_level_attributes_view AS a ON (
                  (d.geography_level = a.geography_level)
                  AND
                  (d.geography_name = a.geography_level_name)
                  AND
                  (d.states <@ a.states) -- topLevelMeasure states is a subset of geoLevelAttr states
                )
              WHERE (
                (a.states && $1::VARCHAR(2)[])
                AND
                (
                  ($2::geography_level_type[] IS NULL) 
                  OR (d.geography_level::geography_level_type = ANY($2::geography_level_type[]))
                )
                AND
                (
                  ($3::SMALLINT[] IS NULL)
                  OR (year = ANY($3::SMALLINT[]))
                )
                AND
                (
                  ($4::SMALLINT[] IS NULL)
                  OR (month = ANY($4::SMALLINT[]))
                )
              )
          ), --end travel_time_reliability

          ( -- begin freight_reliability
            SELECT JSONB_AGG(
                JSONB_BUILD_ARRAY(
                  array_to_string(d.states, '--'),
                  d.geography_level,
                  geography_name,
                  year,
                  month,
                  functional_class,
                  fr
                )
              )
              FROM top_level_freight_reliability AS d
                INNER JOIN geography_level_attributes_view AS a ON (
                  (d.geography_level = a.geography_level)
                  AND
                  (d.geography_name = a.geography_level_name)
                  AND
                  (d.states <@ a.states) -- topLevelMeasure states is a subset of geoLevelAttr states
                )
              WHERE (
                (a.states && $1::VARCHAR(2)[])
                AND
                (
                  ($2::geography_level_type[] IS NULL)
                  OR (d.geography_level::geography_level_type = ANY($2::geography_level_type[]))
                )
                AND
                (
                  ($3::SMALLINT[] IS NULL)
                  OR (year = ANY($3::SMALLINT[]))
                )
                AND
                (
                  ($4::SMALLINT[] IS NULL)
                  OR (month = ANY($4::SMALLINT[]))
                )
              )
          ), -- end freight_reliability

          ( -- begin total_excessive_delay
            SELECT JSONB_AGG(
                JSONB_BUILD_ARRAY(
                  array_to_string(d.states, '--'),
                  d.geography_level,
                  geography_name,
                  year,
                  month,
                  functional_class,
                  (
                    am_peak_total_xdelay_hrs + 
                    GREATEST(
                      pm1_peak_total_xdelay_hrs,
                      pm2_peak_total_xdelay_hrs
                    )
                  ),
                  d.population_info
                )
              )
              FROM top_level_total_excessive_delay AS d
                INNER JOIN geography_level_attributes_view AS a ON (
                  (d.geography_level = a.geography_level)
                  AND
                  (d.geography_name = a.geography_level_name)
                  AND
                -- MPOs are single states, states from d are multi-state
                  (d.states && a.states) -- topLevelMeasure states is a subset of geoLevelAttr states
                )
                NATURAL LEFT OUTER JOIN LATERAL (
                  SELECT
                      mpo_code AS geography_level_code,
                      states AS mpo_relevant_states
                    FROM mpo_to_ua
                      INNER JOIN geography_level_attributes_view ON (
                        (geography_level_code = ua_code)
                      )
                    WHERE (a.geography_level = 'MPO')
                    ORDER BY array_length(states, 1) DESC
                    LIMIT 1
                ) AS sub_mpo_interstate
                NATURAL LEFT OUTER JOIN LATERAL (
                  SELECT
                      geography_level_code,
                      states AS ua_relevant_states
                    FROM geography_level_attributes_view
                    WHERE (a.geography_level = 'UA')
                    ORDER BY array_length(states, 1) DESC
                    LIMIT 1
                ) AS sub_ua_relevant_states
              WHERE (
                -- Omitting NJ specific MPO when requested state is NY.
                --   Only returning for NJ's MPO across interstate UA.
                (
                  (a.states && $1::VARCHAR(2)[])
                  OR
                  (sub_mpo_interstate.mpo_relevant_states && $1::VARCHAR(2)[])
                  OR
                  (sub_ua_relevant_states.ua_relevant_states && $1::VARCHAR(2)[])
                )
                AND
                (
                  ($2::geography_level_type[] IS NULL)
                  OR (d.geography_level::geography_level_type = ANY($2::geography_level_type[]))
                )
                AND
                (
                  ($3::SMALLINT[] IS NULL)
                  OR (year = ANY($3::SMALLINT[]))
                )
                AND
                (
                  ($4::SMALLINT[] IS NULL)
                  OR (month = ANY($4::SMALLINT[]))
                )
              )
          ) -- end total_excessive_delay
        ) -- end the data array
      )::TEXT;

    RETURN measures;
    END;

  $body$;

