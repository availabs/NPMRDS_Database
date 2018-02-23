BEGIN;

CREATE TABLE IF NOT EXISTS "__STATE__".phed_y__YEAR__m__MONTH__ ( 
    LIKE "__STATE__".phed INCLUDING ALL,
    CONSTRAINT phed_yr_check CHECK (year = __YEAR__),
    CONSTRAINT phed_mo_check CHECK (month = __MONTH__),
    CONSTRAINT phed_yrmo_check CHECK (
      (year = __YEAR__) 
      AND
      (month = __MONTH__)
    )
  )
  INHERITS ("__STATE__".phed)
;

COMMIT;
