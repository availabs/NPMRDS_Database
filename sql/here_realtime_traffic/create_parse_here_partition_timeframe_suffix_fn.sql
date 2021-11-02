BEGIN;

CREATE SCHEMA IF NOT EXISTS here_realtime_traffic_partitions ;

CREATE OR REPLACE FUNCTION
  -- Example Suffix: y2021m10w1d06h19m10
  here_realtime_traffic_partitions.parse_here_partition_timeframe_suffix_fn(suffix TEXT)
  RETURNS TIMESTAMP[2] -- The extent. Lower is inclusive. Upper is exclusive.
  AS
  $$
    DECLARE

      year    TEXT;
      month   TEXT;
      week    TEXT;
      date    TEXT;
      hour    TEXT;
      minutes TEXT;

      start_timestamp TIMESTAMP;
      end_timestamp   TIMESTAMP;

    BEGIN
      year    := NULLIF(SUBSTRING(suffix FROM  2 FOR 4), '');
      month   := NULLIF(SUBSTRING(suffix FROM  7 FOR 2), '');
      week    := NULLIF(SUBSTRING(suffix FROM 10 FOR 1), '');
      date    := NULLIF(SUBSTRING(suffix FROM 12 FOR 2), '');
      hour    := NULLIF(SUBSTRING(suffix FROM 15 FOR 2), '');
      minutes := NULLIF(SUBSTRING(suffix FROM 18 FOR 2), '');

      -- Create the start_timestamp
      IF ( (week IS NULL) AND (date IS NULL) )
        THEN
          start_timestamp := ( year || '-' || month || '-' || '01' )::TIMESTAMP ;
      ELSIF ( (week IS NOT NULL) AND (date IS NULL) )
        THEN
          start_timestamp := (
            year || '-' || month || '-' ||
            LPAD( ( 1 + ((week::SMALLINT - 1) * 7) )::TEXT, 2, '0' )
          )::TIMESTAMP ;
      ELSE 
        start_timestamp := ( year || '-' || month || '-' || date )::TIMESTAMP ;
      END IF ;


      start_timestamp := start_timestamp + ( COALESCE(hour::SMALLINT, 0)    || ' hours'   )::INTERVAL ;

      start_timestamp := start_timestamp + ( COALESCE(minutes::SMALLINT, 0) || ' minutes' )::INTERVAL ;

      -- Create the end_timestamp

      IF ( week IS NULL )
        THEN
          end_timestamp := start_timestamp + '1 month'::INTERVAL ;
      ELSIF ( date IS NULL )
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
      ELSIF ( minutes IS NULL ) 
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
