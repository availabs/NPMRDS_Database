-- select st_astext(st_pointn(st_linemerge(wkb_geometry), generate_series(1, st_npoints(wkb_geometry)-1))),
--        st_astext(st_pointn(st_linemerge(wkb_geometry), generate_series(1, st_npoints(wkb_geometry)-1)+1))
--        from inrix_shapefile_geoms_normal where tmc = '120P11204';


-- select ps.tmc, st_astext(st_makeline(ps.p1,ps.p2))
-- from (select tmc, st_pointn(st_linemerge(wkb_geometry), generate_series(1, st_npoints(wkb_geometry)-1)) p1,
--        st_pointn(st_linemerge(wkb_geometry), generate_series(1, st_npoints(wkb_geometry)-1)+1) p2
--        from inrix_shapefile_geoms_normal where tmc = '120P11204') as ps;
-- DROP TABLE IF EXISTS tmc_links;
-- CREATE TABLE tmc_links as (select ps.tmc, st_makeline(ps.p1,ps.p2) as the_geom
--        from (select tmc, st_pointn(st_linemerge(wkb_geometry), generate_series(1, st_npoints(wkb_geometry)-1)) p1,
--        	    st_pointn(st_linemerge(wkb_geometry), generate_series(1, st_npoints(wkb_geometry)-1)+1) p2
--        	    from inrix_shapefile_geoms_normal) as ps);

-- ALTER TABLE tmc_links ADD COLUMN id serial, ADD COLUMN source integer, ADD COLUMN target integer;

-- SELECT pgr_createTopology('tmc_links', 0.001);
 -- This method results in tmcs that are joinable but not connected 

-- select p1.tmc, p2.tmc, ST_Intersects(p1.wkb_geometry, p2.wkb_geometry)
-- from inrix_shapefile_geoms_normal as p1 , inrix_shapefile_geoms_normal as p2
-- WHERE p1.tmc in ('104N10170', '104P10170', '104N06738') and p2.tmc in ('104N10170', '104P10170', '104N06738')
--This above is an example

-- junctions will still be based on the assumption that 2 tmcs will not be routable if one tmc does not end
-- or begin within the geometry of the other tmc
-- drop table if exists tempnormaltable cascade;
-- create table tempnormaltable as (
--      select tmc, st_linemerge(wkb_geometry) as wkb_geometry,
--      st_LineInterpolatePoint( st_linemerge(wkb_geometry), st_LineLocatePoint( st_linemerge(wkb_geometry), ST_setsrid(ST_MakePoint(startlong,startlat),4326) )) as startp,
--      st_LineInterpolatePoint( st_linemerge(wkb_geometry), ST_LineLocatePoint( st_linemerge(wkb_geometry), ST_setsrid(ST_MakePoint(endlong, endlat), 4326) )) as endp
--      from inrix_shapefile_201707
--      WHERE ST_NumGeometries(wkb_geometry) = 1 -- select linestrings
-- );
-- CREATE INDEX tempnormaltable_gix ON tempnormaltable USING GIST (wkb_geometry);

-- drop table if exists normalintersects cascade;
-- create table normalintersects as (
--        select p1.tmc as tmc1, p2.tmc as tmc2, (ST_Dump(ST_Intersection(p1.wkb_geometry, p2.wkb_geometry))).geom
--      from tempnormaltable as p1
--      join tempnormaltable as p2 ON p1.wkb_geometry && p2.wkb_geometry
--      WHERE st_numgeometries(st_linemerge(st_intersection(p1.wkb_geometry, p2.wkb_geometry))) > 0
--      and p1.tmc != p2.tmc
-- );
-- CREATE INDEX normalintersects_gix ON normalintersects USING GIST (geom);

-- drop table if exists tmc_children;
-- create table tmc_children as (
-- select distinct  p1.tmc as parent, p2.tmc as child, p2.startp
-- FROM tempnormaltable as p1
-- JOIN tempnormaltable as p2 ON p1.wkb_geometry && p2.wkb_geometry -- geometries in same bbox
-- LEFT OUTER JOIN normalintersects as p3 ON p1.tmc = tmc1 and p2.tmc = tmc2
-- -- differnet tmcs
-- WHERE p1.tmc != p2.tmc
-- -- the starting point of the child tmc must originate within the parent tmc
-- -- OR the end point of the parent tmc must land within the child tmc
-- AND ( ST_DWITHIN(geography(ST_Transform(p2.startp,4326)), geography(ST_Transform(p1.wkb_geometry, 4326)), 10)
--     OR
--       ST_DWITHIN(geography(ST_Transform(p1.endp, 4326)), geography(ST_Transform(p2.wkb_geometry, 4326)), 10)
--       )
-- -- and if they intersected more than pointwise
-- AND (
--     CASE
-- 	WHEN p3.geom is NULL THEN true -- didn't intersect 
-- 	ELSE --the intersections flow the same way along both geometries (correct orientation)
--     	sign( ST_linelocatepoint(p1.wkb_geometry, st_endpoint(p3.geom)) -
--     	      ST_linelocatepoint(p1.wkb_geometry, st_startpoint(p3.geom)) )
--     		=
-- 	sign( ST_linelocatepoint(p2.wkb_geometry, st_endpoint(p3.geom)) -
--     	      ST_linelocatepoint(p2.wkb_geometry, st_startpoint(p3.geom)) )
--     END
--    )
-- )



-- add multihead segments manually
/* Create Function to expedite the process */
CREATE OR REPLACE FUNCTION create_child_table_from_shapefile( tname varchar ) RETURNS BOOLEAN as $$
       BEGIN
		DROP TABLE IF EXISTS tempnormaltable;
		EXECUTE 'create table tempnormaltable as ('
     		|| 'select tmc, st_linemerge(wkb_geometry) as wkb_geometry,'
     		|| 'st_LineInterpolatePoint( st_linemerge(wkb_geometry), '
		||			' st_LineLocatePoint( st_linemerge(wkb_geometry), ST_setsrid(ST_MakePoint(startlong,startlat),4326) )) as startp,'
     		|| 'st_LineInterpolatePoint( st_linemerge(wkb_geometry), ST_LineLocatePoint( st_linemerge(wkb_geometry), ST_setsrid(ST_MakePoint(endlong, endlat), 4326) )) as endp '
     		|| ' from ' || tname || ' '
     		|| 'WHERE ST_NumGeometries(wkb_geometry) = 1 '
		||');';
		CREATE INDEX tempnormaltable_gix ON tempnormaltable USING GIST (wkb_geometry);
		
		drop table if exists normalintersects;
		create table normalintersects as (
       		       select p1.tmc as tmc1, p2.tmc as tmc2, (ST_Dump(ST_Intersection(p1.wkb_geometry, p2.wkb_geometry))).geom
     		       from tempnormaltable as p1
     		       join tempnormaltable as p2 ON p1.wkb_geometry && p2.wkb_geometry
     		       WHERE st_numgeometries(st_linemerge(st_intersection(p1.wkb_geometry, p2.wkb_geometry))) > 0
     		       and p1.tmc != p2.tmc
		);
		CREATE INDEX normalintersects_gix ON normalintersects USING GIST (geom);
		

		drop table if exists tmc_children;
		create table tmc_children as (
				select distinct  p1.tmc as base, p2.tmc as child, p2.startp
				FROM tempnormaltable as p1
				JOIN tempnormaltable as p2 ON p1.wkb_geometry && p2.wkb_geometry -- geometries in same bbox
				LEFT OUTER JOIN normalintersects as p3 ON p1.tmc = tmc1 and p2.tmc = tmc2
				-- differnet tmcs
				WHERE p1.tmc != p2.tmc
				-- the starting point of the child tmc must originate within the parent tmc
				-- OR the end point of the parent tmc must land within the child tmc
				AND ( ST_DWITHIN(geography(ST_Transform(p2.startp,4326)), geography(ST_Transform(p1.wkb_geometry, 4326)), 10)
				OR
				ST_DWITHIN(geography(ST_Transform(p1.endp, 4326)), geography(ST_Transform(p2.wkb_geometry, 4326)), 10)
				)
				-- and if they intersected more than pointwise
				AND (
				CASE
				WHEN p3.geom is NULL THEN true -- didn't intersect 
				ELSE --the intersections flow the same way along both geometries (correct orientation)
    				sign( ST_linelocatepoint(st_linemerge(p1.wkb_geometry), st_endpoint(p3.geom)) -
    				ST_linelocatepoint(st_linemerge(p1.wkb_geometry), st_startpoint(p3.geom)) )
    				=
				sign( ST_linelocatepoint(st_linemerge(p2.wkb_geometry), st_endpoint(p3.geom)) -
    				ST_linelocatepoint(st_linemerge(p2.wkb_geometry), st_startpoint(p3.geom)) )
				END
		)
		);
		drop table normalintersects;
		drop table tempnormaltable;
		return true;
       END;
$$ LANGUAGE plpgsql; 

-- DROP TABLE IF EXISTS tmc_links;
-- CREATE TABLE tmc_links as (select ps.tmc, st_makeline(ps.p1,ps.p2) as the_geom
--        from (select tmc, st_pointn(st_linemerge(wkb_geometry), generate_series(1, st_npoints(wkb_geometry)-1)) p1,
--        	    st_pointn(st_linemerge(wkb_geometry), generate_series(1, st_npoints(wkb_geometry)-1)+1) p2
--        	    from inrix_shapefile_geoms_normal) as ps);

-- ALTER TABLE tmc_links ADD COLUMN id serial, ADD COLUMN source integer, ADD COLUMN target integer;

-- CREATE TABLE split_tmcs as (
--        Select st_lineinterpolatepoint(wkb
-- );

-- Splitting isn't seeming to work well for these kinds of coordinates
-- select st_numgeometries(
-- 	st_split(st_linemerge(wkb_geometry),
--        	st_lineinterpolatepoint(st_linemerge(wkb_geometry),0.5)))
-- 	from inrix_shapefile_201707
-- 	where tmc='120P11204'

-- select 
--        	st_numgeometries(st_split(st_linemerge(wkb_geometry), st_lineinterpolatepoint(st_linemerge(wkb_geometry),0.5))),
-- 	st_numgeometries(st_split(st_linemerge(wkb_geometry), st_snap(st_lineinterpolatepoint(st_linemerge(wkb_geometry),0.5), st_linemerge(wkb_geometry), 0.001)))
-- 	from inrix_shapefile_201707
-- 	where tmc='120P11204'

-- !!CREATE ROUTABLE NETWORK STARTING HERE!!

drop table if exists tempnormaltable cascade;
create table tempnormaltable as (
     select tmc, st_linemerge(wkb_geometry) as wkb_geometry,
     st_LineInterpolatePoint( st_linemerge(wkb_geometry), st_LineLocatePoint( st_linemerge(wkb_geometry), ST_setsrid(ST_MakePoint(startlong,startlat),4326) )) as startp,
     st_LineInterpolatePoint( st_linemerge(wkb_geometry), ST_LineLocatePoint( st_linemerge(wkb_geometry), ST_setsrid(ST_MakePoint(endlong, endlat), 4326) )) as endp
     from inrix_shapefile_201707
     WHERE ST_NumGeometries(wkb_geometry) = 1 -- select linestrings
);

CREATE INDEX tempnormaltable_gix ON tempnormaltable USING GIST (wkb_geometry);
DROP TABLE IF EXISTS tmc_touching_terminals;
CREATE TABLE tmc_touching_terminals as (
       (SELECT p1.tmc, st_LineLocatePoint(p1.wkb_geometry, p2.startp) as dalong
       FROM tempnormaltable as p1
       JOIN tempnormaltable as p2 ON p1.wkb_geometry && p2.wkb_geometry
       WHERE p1.tmc != p2.tmc AND
       ST_DWITHIN(geography(ST_Transform(p2.startp,4326)), geography(ST_Transform(p1.wkb_geometry, 4326)), 20)
       )
       UNION
       (SELECT p1.tmc, st_LineLocatePoint(p1.wkb_geometry, p2.startp) as dalong
       FROM tempnormaltable as p1
       JOIN tempnormaltable as p2 ON p1.wkb_geometry && p2.wkb_geometry
       WHERE p1.tmc != p2.tmc AND
       ST_DWITHIN(geography(ST_Transform(p2.endp,4326)), geography(ST_Transform(p1.wkb_geometry, 4326)), 20)
       )
);
DROP TABLE IF EXISTS tmc_routable cascade;
CREATE TABLE tmc_routable as (
WITH juncts as (
     SELECT tmc, array_length(ds, 1) as njuncts, ds from (select tmc, 
     	    case
		WHEN (NOT 0 = ANY(ds)) AND (NOT 1 = ANY(ds)) THEN cast(0 as double precision) || ds || cast(1 as double precision)
		WHEN NOT 0 = ANY(ds) THEN cast(0 as double precision) || ds
		WHEN NOT 1 = ANY(ds) THEN  ds || cast(1.0 as double precision)
		ELSE ds
	    end as ds
	    FROM (SELECT tmc, count(*) as njuncts,
            	 	 array_agg(dalong order by dalong asc) as ds
	          FROM tmc_touching_terminals
		  GROUP BY tmc) as t) as k
), indxs as (
       SELECT tnt.tmc,
       generate_series(1, juncts.njuncts-1) as st,
       generate_series(1, juncts.njuncts-1)+1 as en,
       juncts.ds as locs
       from tempnormaltable as tnt
       JOIN juncts USING (tmc)
)
	SELECT p1.tmc,
	(CASE
		when i.st IS NOT NULL THEN ST_LineSubstring(p1.wkb_geometry, i.locs[i.st], i.locs[i.en])
		ELSE p1.wkb_geometry
	END) as the_geom
	from tempnormaltable as p1
	LEFT OUTER JOIN indxs as i USING (tmc)
	WHERE
		(CASE
			WHEN i.st IS NOT NULL THEN ST_NumPoints(ST_LineSubstring(p1.wkb_geometry, i.locs[i.st], i.locs[i.en])) > 1
			ELSE TRUE
		END)
);
CREATE INDEX tmc_routable_gix ON tmc_split_shapes USING GIST (the_geom);

ALTER TABLE tmc_routable ADD COLUMN id serial, ADD COLUMN source int4, ADD COLUMN target int4;

DROP TABLE IF EXISTS tmc_routable_vertices_pgr;
SELECT pgr_createTopology('tmc_routable', 0.0000001);
--play with tolerance till the vertices all touch their tmcs at least relatively
ALTER TABLE tmc_routable ADD COLUMN cost float8;
UPDATE tmc_routable
SET cost = ST_Length(the_geom);


--Bad find closestpoint
-- (SELECT id 
--                 		      FROM tmc_routable_vertices_pgr 
--                 		      ORDER BY 
--                 		      ST_Distance(the_geom, ST_SETSRID(ST_GeomFROMText('POINT('||waypoints[ix] || ' ' || waypoints[ix+1] ||')' ),4326)) ASC
--                 		      LIMIT 1) 
--                 		      as t1
--
CREATE OR REPLACE FUNCTION get_closest_id (p1 float8, p2 float8) RETURNS Table (id int4) AS
$$
BEGIN
RETURN QUERY WITH tmppnt as (Select ST_SETSRID(ST_MakePoint(p1,p2), 4326) as pnt)
,tmp as (select tmc, ST_ClosestPoint(wkb_geometry, tmppnt.pnt) as cp, ST_Distance(wkb_geometry, tmppnt.pnt) as d
FROM inrix_shapefile , tmppnt
ORDER BY wkb_geometry <-> tmppnt.pnt limit 10)
, the_tmc as (select * from tmp order by d asc limit 1)
,tmp_tmcvertices as (
SELECT source as id from tmc_routable where tmc in (select the_tmc.tmc from the_tmc)
UNION
SELECT target as id from tmc_routable where tmc in (select the_tmc.tmc from the_tmc)
)

SELECT pgr.id::int4
FROM tmc_routable_vertices_pgr as pgr
JOIN tmp_tmcvertices USING(id), the_tmc as tt
ORDER BY pgr.the_geom <-> tt.cp ASC limit 1;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION route_from_tmc(waypoints float8[]) RETURNS Table(seq int4, nid int4, tmc character varying) AS
$$
DECLARE
	ix int4;
	lastsq int4 = 0;
BEGIN
	ix := 1;
	WHILE ix <= (array_upper(waypoints,1) -3) -- Assumes minumum of 2 coor pairs
	LOOP
		RAISE NOTICE '1row=%, 2row=%, 3row=%, 4row=%', waypoints[ix], waypoints[ix+1], waypoints[ix+2], waypoints[ix+3];
		RETURN QUERY WITH temp as (SELECT t.seq + lastsq, t.id2, tss.tmc 
		       FROM (SELECT pgr.seq, pgr.id2
		       	    FROM (SELECT t1.id as st , t2.id as en 
                	    	 FROM 
				 get_closest_id(waypoints[ix], waypoints[ix+1]) as t1
                		 ,   get_closest_id(waypoints[ix+2], waypoints[ix+3]) as t2
				)
			    as t , 
			    pgr_dijkstra('SELECT id, source, target, cost FROM tmc_routable', 
                	    t.st::int4, t.en::int4, true, false) as pgr
			    ) as t 
		JOIN tmc_routable as tss ON t.id2=tss.id)
		SELECT * from temp;
	ix := ix + 2;
	END LOOP;

END;
$$ LANGUAGE plpgsql;
-- test
select route_from_tmc(ARRAY[-78.75909805297852, 42.951396938304185, -78.41719150543213, 43.00078678412019 ]);
select route_from_tmc(ARRAY[-73.82593604961585, 40.838116014180294, -73.84877800941467, 40.82771730843219, -73.86295080184935, 40.825850076930145,  -73.87584686279297, 40.82412081130137,  -73.89181673526762, 40.819387426415084,  -73.89627456665039, 40.81503127720488,  -73.89776051044464, 40.813711790666275,  -73.90441238880157, 40.80890863805406,  -73.91634815196085, 40.803861502093845]);





select tmc, ST_ClosestPoint(wkb_geometry, ST_SETSRID(ST_GeomFromText('POINT(-73.82593604961585 40.838116014180294)'), 4326) ) as pt
       FROM inrix_shapefile_201707 
       ORDER BY ST_Distance(wkb_geometry, ST_SETSRID(ST_GeomFromText('POINT(-73.82593604961585 40.838116014180294)'), 4326)) limit 10
