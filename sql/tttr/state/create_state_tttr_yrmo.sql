BEGIN;

CREATE TABLE IF NOT EXISTS "__STATE__".tttr_y__YEAR__m__MONTH__ ( 
    LIKE "__STATE__".tttr INCLUDING ALL,
    CONSTRAINT tttr_yr_check CHECK (year = __YEAR__),
    CONSTRAINT tttr_mo_check CHECK (month = __MONTH__),
    CONSTRAINT tttr_yrmo_check CHECK (
      (year = __YEAR__) 
      AND
      (month = __MONTH__)
    )
  )
  INHERITS ("__STATE__".tttr)
;

COMMIT;
