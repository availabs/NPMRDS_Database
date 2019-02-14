CREATE TABLE avail_table_metadata (
  class_oid          OID PRIMARY KEY,
  metadata           JSONB,
  sql                TEXT
) ;
