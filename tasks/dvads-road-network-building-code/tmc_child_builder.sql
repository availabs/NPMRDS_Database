BEGIN TRANSACTION;
-- This table is used to cache the individual vertices that can be found along a single tmc
CREATE 
TEMPORARY 
TABLE tmc_verts AS (
	SELECT tmc, array_agg(verts.vert) as vertices
	FROM ( 
	SELECT lut.tmc,shp.source as vert FROM "npmrds_shapefile_2016Q2" AS shp
	JOIN "npmrds_tmc_lut_2016Q2" AS lut USING (link_id)
	UNION
	SELECT lut.tmc,shp.target as vert FROM "npmrds_shapefile_2016Q2" AS shp
	JOIN "npmrds_tmc_lut_2016Q2" AS lut USING (link_id)
	) as verts
	GROUP BY tmc
);

-- This table is used to map tmcs to other tmcs that share common links, but who travel 
-- in the same directions along those same links. This is needed to construct the flow graph
-- in such a way that flow in the graph cannot mistakenly be bidirectional
CREATE
TEMPORARY
TABLE tmc_2_tmc_same_links AS (
	SELECT lut1.tmc as tmc1, lut2.tmc as tmc2, lut1.dir as dir1, lut2.dir as dir2 FROM "npmrds_tmc_lut_2016Q2" as lut1 
	JOIN "npmrds_tmc_lut_2016Q2" as lut2 USING (link_id)
	WHERE lut1.tmc <> lut2.tmc
);

CREATE 
TABLE tmc_children AS (
	SELECT adjs.base as base, term.tmc as child	
	-- terminal points in the tmcs
        FROM public.tmc_terminals as term
        -- endpoints of the tmcs
	JOIN public.tmc_origins as origin USING (tmc)
	-- use terminal tmcs as the children of possible tmcs
	JOIN tmc_adjs as adjs ON adjs.child = term.tmc
	-- link vertices to the possible parent tmc
	JOIN tmc_verts as verts ON adjs.base=verts.tmc
	-- remove anything where the terminal point is the end point of the child tmc
	WHERE origin.origin <> term.id 
	-- allow rows that whose origin point lie somewhere on the parent tmc 
	AND term.id = ANY(verts.vertices) 
	AND
	(
	-- allow rows that do not have similar links 
	term.tmc NOT IN (select tmc1 from tmc_2_tmc_same_links where tmc2=adjs.base )
	-- allow if they have similar links but are in the same direction 
	OR term.tmc NOT IN (SELECT tmc1 FROM tmc_2_tmc_same_links 
		WHERE tmc2=adjs.base and dir1 <> dir2) 
	)
);


COMMIT;