BEGIN ;

CREATE TEMPORARY TABLE tmp_transcom_event_type_classifications (
  LIKE transcom.transcom_event_type_classifications
) ON COMMIT DROP ;

\COPY tmp_transcom_event_type_classifications (event_type, event_class) FROM PSTDIN WITH ( FORMAT CSV, HEADER, DELIMITER (',') ) ;

INSERT INTO transcom.transcom_event_type_classifications (
  event_type,
  event_class
)
  SELECT
      *
    FROM tmp_transcom_event_type_classifications
  ON CONFLICT (event_type) DO
    UPDATE SET event_class = EXCLUDED.event_class
;

COMMIT ;
