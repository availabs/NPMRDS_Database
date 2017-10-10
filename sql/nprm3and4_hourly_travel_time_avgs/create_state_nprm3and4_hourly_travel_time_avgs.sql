CREATE TABLE "__STATE__".nprm3and4_hourly_travel_time_avgs (
  CONSTRAINT nprm3and4_hourly_travel_time_avgs_state_check CHECK(state = '__STATE__')
) INHERITS (public.nprm3and4_hourly_travel_time_avgs);
