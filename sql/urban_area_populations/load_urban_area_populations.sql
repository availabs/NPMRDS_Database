COPY public.urban_area_populations (
    geoid,
    name,
    uatype,
    pop10,
    hu10,
    aland,
    awater,
    aland_sqmi,
    awater_sqmi,
    intptlat,
    intptlong
) FROM STDIN ; -- delimiter is \t
