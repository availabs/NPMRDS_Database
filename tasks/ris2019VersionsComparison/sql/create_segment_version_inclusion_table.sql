BEGIN;

DROP TABLE IF EXISTS ris_segment_version_inclusion;

CREATE TABLE ris_segment_version_inclusion (
  GIS_ID                INTEGER,
  Beg_MP                REAL,

  is_in_ris_version_a   INTEGER NOT NULL,
  is_in_ris_version_b   INTEGER NOT NULL,

  PRIMARY KEY (GIS_ID, Beg_MP)
) WITHOUT ROWID;

INSERT INTO ris_segment_version_inclusion (
  GIS_ID,
  Beg_MP,
  is_in_ris_version_a,
  is_in_ris_version_b
)
  SELECT
      GIS_ID,
      Beg_MP,
      0,
      0
    FROM ris_a.roadway_inventory_system

  UNION

  SELECT
      GIS_ID,
      Beg_MP,
      0,
      0
    FROM ris_b.roadway_inventory_system
;

UPDATE ris_segment_version_inclusion
  SET is_in_ris_version_a = 1
  WHERE ( (GIS_ID, Beg_MP) IN (
      SELECT
          GIS_ID,
          Beg_MP
        FROM ris_a.roadway_inventory_system
    )
  ) ;

UPDATE ris_segment_version_inclusion
  SET is_in_ris_version_b = 1
  WHERE ( (GIS_ID, Beg_MP) IN (
      SELECT
          GIS_ID,
          Beg_MP
        FROM ris_b.roadway_inventory_system
    )
  );

COMMIT;
