CLUSTER public.county_populations USING county_populations_pkey;

VACUUM FULL FREEZE ANALYZE public.county_populations;
