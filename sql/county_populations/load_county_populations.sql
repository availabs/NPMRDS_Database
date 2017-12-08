COPY public.county_populations (
  usps,
  geoid,
  ansicode,
  name,
  pop10,
  hu10,
  aland,
  awater,
  aland_sqmi,
  awater_sqmi,
  intptlat,
  intptlong
) FROM STDIN ; -- delimiter is \t
