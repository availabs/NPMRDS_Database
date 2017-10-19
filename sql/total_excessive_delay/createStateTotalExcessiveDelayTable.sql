BEGIN;

CREATE TABLE "__STATE__".total_excessive_delay (
  CONSTRAINT state_check CHECK(state = '__STATE__')
) INHERITS (public.total_excessive_delay);

COMMIT;
