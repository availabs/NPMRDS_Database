CREATE TABLE "__STATE__".nprm7_time_dist (
  CONSTRAINT nprm7_time_dist_state_check CHECK(state = '__STATE__')
) INHERITS (public.nprm7_time_dist);
