BEGIN;

CREATE TABLE IF NOT EXISTS "__STATE__".phed ( 
    LIKE public.phed INCLUDING ALL,
    CONSTRAINT phed_pkey PRIMARY KEY (tmc),
    CONSTRAINT phed_state_check CHECK (state = '__STATE__')
  )
  INHERITS (public.phed)
;

COMMIT;
