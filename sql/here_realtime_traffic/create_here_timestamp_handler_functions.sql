BEGIN;

CREATE SCHEMA IF NOT EXISTS here_realtime_traffic_partitions ;
CREATE SCHEMA IF NOT EXISTS here_npmrds_schema_partitions ;

CREATE OR REPLACE FUNCTION here_realtime_traffic_partitions.parse_timestamp_fn(
    tstamp  TIMESTAMP
  )
  RETURNS JSONB
  AS $$
    DECLARE
      year    TEXT;
      month   TEXT;
      week    TEXT;
      day     TEXT;
      hour    TEXT;
      minute  TEXT;
    BEGIN

      year    := LPAD( EXTRACT('YEAR' FROM tstamp)::TEXT,    4, '0' );
      month   := LPAD( EXTRACT('MONTH' FROM tstamp)::TEXT,   2, '0' );
      week    := (
                    FLOOR (
                      ( EXTRACT('DAY' FROM tstamp)::SMALLINT - 1 ) / 7
                    ) + 1
                 )::TEXT;
      day     := LPAD( EXTRACT('DAY' FROM tstamp)::TEXT,     2, '0' );
      hour    := LPAD( EXTRACT('HOUR' FROM tstamp)::TEXT,    2, '0' );
      minute  := LPAD( EXTRACT('MINUTE' FROM tstamp)::TEXT,  2, '0' );

      RETURN json_build_object(
        'year',     year,
        'month',    month,
        'week',     week,
        'day',      day,
        'hour',     hour,
        'minute',   minute
      ) ;

    END
  $$ LANGUAGE PLPGSQL
;


CREATE OR REPLACE FUNCTION here_realtime_traffic_partitions.create_here_partition_timeframe_suffix_fn(
    tstamp             TIMESTAMP,
    suffix_precision   TEXT DEFAULT 'MINUTE'
  )
  RETURNS TEXT
  AS $$
    DECLARE
      parsed_timestamp JSONB;
      suffix TEXT;
    BEGIN

      EXECUTE '
          SELECT here_realtime_traffic_partitions.parse_timestamp_fn(''' || tstamp || ''')
        ;' INTO parsed_timestamp ;

      suffix := 'y' || (parsed_timestamp->>'year') || 'm' || (parsed_timestamp->>'month') ;

      IF ( suffix_precision = 'MONTH' )
        THEN RETURN suffix;
      END IF;

      suffix := suffix || 'w' || (parsed_timestamp->>'week') ;

      IF ( suffix_precision = 'WEEK' )
        THEN RETURN suffix;
      END IF;

      suffix := suffix || 'd' || (parsed_timestamp->>'day') ;

      IF ( suffix_precision = 'DAY' )
        THEN RETURN suffix;
      END IF;

      suffix := suffix || 'h' || (parsed_timestamp->>'hour') ;

      IF ( suffix_precision = 'HOUR' )
        THEN RETURN suffix;
      END IF;

      suffix := suffix || 'm' || (parsed_timestamp->>'minute') ;

      IF ( suffix_precision = 'MINUTE' )
        THEN RETURN suffix;
      END IF;

      -- Raise invalid_parameter_value
      RAISE EXCEPTION 'Unrecognized suffix suffix_precision --> %', suffix_precision
        USING HINT = 'Supported precisions: (MONTH, WEEK, DAY, HOUR, MINUTE)' ;

    END ;

  $$ LANGUAGE PLPGSQL
;


CREATE OR REPLACE FUNCTION here_realtime_traffic_partitions.parse_here_partition_timeframe_suffix_fn(
    suffix  TEXT
  )
  RETURNS JSONB
  AS $$
    DECLARE
      year    TEXT;
      month   TEXT;
      week    TEXT;
      day     TEXT;
      hour    TEXT;
      minute  TEXT;

    BEGIN
      year    := NULLIF(SUBSTRING(suffix FROM  2 FOR 4), '');
      month   := NULLIF(SUBSTRING(suffix FROM  7 FOR 2), '');
      week    := NULLIF(SUBSTRING(suffix FROM 10 FOR 1), '');
      day     := NULLIF(SUBSTRING(suffix FROM 12 FOR 2), '');
      hour    := NULLIF(SUBSTRING(suffix FROM 15 FOR 2), '');
      minute  := NULLIF(SUBSTRING(suffix FROM 18 FOR 2), '');

      RETURN json_build_object(
        'year',     year,
        'month',    month,
        'week',     week,
        'day',      day,
        'hour',     hour,
        'minute',   minute
      ) ;

    END
  $$ LANGUAGE PLPGSQL
;


CREATE OR REPLACE FUNCTION here_realtime_traffic_partitions.here_timeframe_suffix_date_extent(
    suffix TEXT
  )
  RETURNS TIMESTAMP[2] -- The extent. Lower is inclusive. Upper is exclusive.
  AS
  $$
    DECLARE
      parsed_suffix JSONB;

      year    TEXT;
      month   TEXT;
      week    TEXT;
      day     TEXT;
      hour    TEXT;
      minute  TEXT;

      start_timestamp TIMESTAMP;
      end_timestamp   TIMESTAMP;

    BEGIN
      EXECUTE '
        SELECT
            here_realtime_traffic_partitions.parse_here_partition_timeframe_suffix_fn('''
              || suffix ||
            ''')
        ;' INTO parsed_suffix ;

      year    := parsed_suffix->>'year';
      month   := parsed_suffix->>'month';
      week    := parsed_suffix->>'week';
      day     := parsed_suffix->>'day';
      hour    := parsed_suffix->>'hour';
      minute  := parsed_suffix->>'minute';

      -- Create the start_timestamp
      IF ( (week IS NULL) AND (day IS NULL) )
        THEN
          start_timestamp := ( year || '-' || month || '-' || '01' )::TIMESTAMP ;
      ELSIF ( (week IS NOT NULL) AND (day IS NULL) )
        THEN
          start_timestamp := (
            year || '-' || month || '-' ||
            LPAD( ( 1 + ((week::SMALLINT - 1) * 7) )::TEXT, 2, '0' )
          )::TIMESTAMP ;
      ELSE
        start_timestamp := ( year || '-' || month || '-' || day )::TIMESTAMP ;
      END IF ;


      start_timestamp := start_timestamp + ( COALESCE(hour::SMALLINT, 0)    || ' hours'   )::INTERVAL ;

      start_timestamp := start_timestamp + ( COALESCE(minute::SMALLINT, 0) || ' minutes' )::INTERVAL ;

      -- Create the end_timestamp

      IF ( week IS NULL )
        THEN
          end_timestamp := start_timestamp + '1 month'::INTERVAL ;
      ELSIF ( day IS NULL )
        THEN
          end_timestamp := LEAST(
            (
              DATE_TRUNC('MONTH', start_timestamp)
              + (((week::SMALLINT) * 7)::TEXT || ' days')::INTERVAL
            ),
            (DATE_TRUNC('MONTH', start_timestamp) + '1 month'::INTERVAL)
          ) ;
      ELSIF ( hour IS NULL )
        THEN
          end_timestamp := start_timestamp + '1 day'::INTERVAL;
      ELSIF ( minute IS NULL )
        THEN
          end_timestamp := start_timestamp + '1 hour'::INTERVAL;
      ELSE
        end_timestamp := start_timestamp + '1 minute'::INTERVAL;
      END IF ;

      RETURN ARRAY[start_timestamp, end_timestamp] ;

    END
  $$ LANGUAGE PLPGSQL
;

COMMIT ;
