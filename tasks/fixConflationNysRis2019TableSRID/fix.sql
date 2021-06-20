BEGIN;

/* NOT IDEMPOTENT

CREATE TABLE conflation.nys_ris_2019_before_srid_fix
  AS
    SELECT *
      FROM conflation.nys_ris_2019
;

CREATE TABLE conflation.tmp_nys_ris_2019_corrected_srid
  AS
    SELECT
        objectid,
        shape
      FROM conflation.nys_ris_2019
;

SELECT public.UpdateGeometrySRID('conflation', 'tmp_nys_ris_2019_corrected_srid', 'shape', 26918);

UPDATE conflation.nys_ris_2019 AS a
  SET shape = ST_Transform(b.shape, 4326)
  FROM conflation.tmp_nys_ris_2019_corrected_srid AS b
  WHERE a.objectid = b.objectid
;

DROP TABLE conflation.tmp_nys_ris_2019_corrected_srid ;

*/

COMMIT;
