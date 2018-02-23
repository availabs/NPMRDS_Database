BEGIN;

CREATE TABLE IF NOT EXISTS "__STATE__".tttr ( 
    LIKE public.tttr INCLUDING ALL,
    CONSTRAINT tttr_pkey PRIMARY KEY (tmc),
    CONSTRAINT tttr_state_check CHECK (state = '__STATE__')
  )
  INHERITS (public.tttr)
;

COMMIT;
