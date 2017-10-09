CREATE TABLE "__STATE__".nprm1and2_time_dist (
  CONSTRAINT nprm1and2_time_dist_state_check CHECK(state = '__STATE__')
) INHERITS (public.nprm1and2_time_dist);
