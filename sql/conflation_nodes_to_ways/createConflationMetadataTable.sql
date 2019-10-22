BEGIN;

\set tbl_name 'conflation_nodes_to_ways_':YEAR
\set idx_name :tbl_name'_pkey'

CREATE TABLE IF NOT EXISTS public.:tbl_name (
  id        INTEGER PRIMARY KEY,
  ways_info JSONB
);

CLUSTER public.:tbl_name USING :idx_name;

COMMIT;
