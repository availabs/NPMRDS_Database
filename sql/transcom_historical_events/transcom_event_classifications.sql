BEGIN ;

  CREATE SCHEMA IF NOT EXISTS transcom ;

  CREATE TABLE IF NOT EXISTS transcom.transcom_event_classes (
    event_class     TEXT PRIMARY KEY
  ) ;

  INSERT INTO transcom.transcom_event_classes (
    event_class
  )
    VALUES
      ('accident'),
      ('construction'),
      ('other')
    ON CONFLICT (event_class) DO NOTHING ;

  CREATE TABLE IF NOT EXISTS transcom.transcom_event_type_classifications (
    event_type      TEXT PRIMARY KEY,
    event_class     TEXT,

    CONSTRAINT transcom_event_classes_fk
      FOREIGN KEY (event_class)
        REFERENCES transcom.transcom_event_classes (event_class)
  ) ;

  CLUSTER transcom.transcom_event_type_classifications
    USING transcom_event_type_classifications_pkey
  ;

COMMIT ;
