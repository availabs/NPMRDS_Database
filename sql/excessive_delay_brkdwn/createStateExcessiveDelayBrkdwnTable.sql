BEGIN;

CREATE TABLE "__STATE__".excessive_delay_brkdwn (
  CONSTRAINT state_check CHECK(state = '__STATE__')
) INHERITS (public.excessive_delay_brkdwn);

COMMIT;
