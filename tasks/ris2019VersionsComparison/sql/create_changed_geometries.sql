BEGIN;

DROP TABLE IF EXISTS ris_segment_changed_geometries;

CREATE TABLE ris_segment_changed_geometries (
  GIS_ID                INTEGER,
  Beg_MP                REAL,

  PRIMARY KEY (GIS_ID, Beg_MP)
) WITHOUT ROWID;

INSERT INTO ris_segment_changed_geometries (
  GIS_ID,
  Beg_MP
)
  SELECT
      GIS_ID,
      Beg_MP
    FROM ris_a.roadway_inventory_system AS a
      INNER JOIN ris_b.roadway_inventory_system AS b
        USING (GIS_ID, Beg_MP)
    WHERE ( a.Shape <> b.Shape ) ;

COMMIT;
