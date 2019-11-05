-- Eventually to be used by code that allows directional ways OSRM requests.
--   As of 21091105, that code exists in its own prototype repo and uses LevelDB.
--   Eventually, that code should be moved to the main Falcor server and use the production database.

BEGIN;

\set tbl_name 'conflation_nodes_to_ways_':YEAR
\set idx_name :tbl_name'_pkey'

CREATE TABLE IF NOT EXISTS public.:tbl_name (
  id        BIGINT PRIMARY KEY,
  ways_info JSONB
);

CLUSTER public.:tbl_name USING :idx_name;

COMMIT;
