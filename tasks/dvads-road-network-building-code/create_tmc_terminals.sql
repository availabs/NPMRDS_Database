-- Query for tmc endpoints
DROP TABLE IF EXISTS tmc_terminals;
CREATE TABLE tmc_terminals as (
Select lut.tmc,vert.id,count(lut.link_id) as cnt from public."npmrds_shapefile_2016Q2" as shp 
JOIN public."npmrds_tmc_lut_2016Q2" as lut USING(link_id)
JOIN public."npmrds_shapefile_2016Q2_vertices_pgr" as vert on shp.source=vert.id OR shp.target=vert.id
GROUP BY vert.id, lut.tmc HAVING count(lut.link_id) = 1
)