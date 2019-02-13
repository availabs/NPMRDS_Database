CREATE TABLE avail_table_metadata (
  class_oid          OID PRIMARY KEY,
  created_timestamp  TIMESTAMP,
  metadata           JSONB,
  sql                TEXT
) ;
