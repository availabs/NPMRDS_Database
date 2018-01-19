BEGIN;

CREATE TABLE public.mpo_to_ua (
  mpo_code  VARCHAR,
  ua_code   VARCHAR,
  PRIMARY KEY (mpo_code)
);

COMMIT;
