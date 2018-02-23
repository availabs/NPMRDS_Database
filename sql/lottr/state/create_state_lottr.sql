BEGIN;

CREATE TABLE IF NOT EXISTS "__STATE__".lottr ( 
    LIKE public.lottr INCLUDING ALL,
    CONSTRAINT lottr_pkey PRIMARY KEY (tmc),
    CONSTRAINT lottr_state_check CHECK (state = '__STATE__')
  )
  INHERITS (public.lottr)
;

COMMIT;
