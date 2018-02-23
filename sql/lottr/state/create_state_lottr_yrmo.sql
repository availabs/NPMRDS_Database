BEGIN;

CREATE TABLE IF NOT EXISTS "__STATE__".lottr_y__YEAR__m__MONTH__ ( 
    LIKE "__STATE__".lottr INCLUDING ALL,
    CONSTRAINT lottr_yr_check CHECK (year = __YEAR__),
    CONSTRAINT lottr_mo_check CHECK (month = __MONTH__),
    CONSTRAINT lottr_yrmo_check CHECK (
      (year = __YEAR__) 
      AND
      (month = __MONTH__)
    )
  )
  INHERITS ("__STATE__".lottr)
;

COMMIT;
