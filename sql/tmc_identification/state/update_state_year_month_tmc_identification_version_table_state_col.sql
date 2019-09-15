BEGIN;

\set tbl_name :"STATE"'.tmc_identification_':YEAR'_v':DOWNLOAD_TIMESTAMP

UPDATE :tbl_name
    SET state = UPPER(abbrs.abbreviation)
  FROM state_abbreviations AS abbrs
  WHERE (
    (char_length(state) > 2)
    AND
    (UPPER(state) = UPPER(abbrs.state_name))
  )
;

COMMIT;
