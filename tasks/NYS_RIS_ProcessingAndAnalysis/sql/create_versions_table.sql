BEGIN;

DROP TABLE IF EXISTS roadway_inventory_system_versions;

CREATE TABLE roadway_inventory_system_versions (
  ris_version_a   INTEGER,
  ris_version_b   INTEGER
);

INSERT INTO roadway_inventory_system_versions (ris_version_a, ris_version_b)
  SELECT
      a.version AS ris_version_a,
      b.version AS ris_version_b
    FROM ris_a.roadway_inventory_system_version AS a,
      ris_b.roadway_inventory_system_version AS b
;

COMMIT;
