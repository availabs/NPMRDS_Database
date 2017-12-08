CLUSTER public.urban_area_populations USING urban_area_populations_pkey;

VACUUM FULL FREEZE ANALYZE public.urban_area_populations;
