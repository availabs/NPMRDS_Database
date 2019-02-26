CREATE TABLE tmc_shapes AS (

	SELECT lut.tmc, CAST(ST_UNION(array_agg(shp.wkb_geometry)) AS geometry(MultiLineString,4326)) as wkb_geometry
	FROM "npmrds_tmc_lut_2016Q2" as lut
	JOIN "npmrds_shapefile_2016Q2" as shp USING(link_id)
	GROUP BY lut.tmc

)
