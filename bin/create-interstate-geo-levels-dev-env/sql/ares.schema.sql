--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: .o; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ".o";


--
-- Name: admin; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA admin;


--
-- Name: nj; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA nj;


--
-- Name: ny; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ny;


--
-- Name: us; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA us;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: pgrouting; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgrouting WITH SCHEMA public;


--
-- Name: EXTENSION pgrouting; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgrouting IS 'pgRouting Extension';


--
-- Name: pgstattuple; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgstattuple WITH SCHEMA public;


--
-- Name: EXTENSION pgstattuple; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgstattuple IS 'show tuple-level statistics';


SET search_path = public, pg_catalog;

--
-- Name: functional_class_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE functional_class_type AS ENUM (
    'INTERSTATE',
    'NONINTERSTATE',
    'CONTROLLED-ACCESS',
    'NON-CONTROLLED-ACCESS'
);


--
-- Name: geography_level_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE geography_level_type AS ENUM (
    'CBSA',
    'COUNTY',
    'MPO',
    'STATE',
    'UA',
    'REGION',
    'TMC',
    'ROUTE'
);


--
-- Name: phed_peak_period_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE phed_peak_period_type AS ENUM (
    'PHED_AM_PEAK',
    'PHED_PM_PEAK_1',
    'PHED_PM_PEAK_2'
);


--
-- Name: state_code; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE state_code AS ENUM (
    'al',
    'ak',
    'az',
    'ar',
    'ca',
    'co',
    'ct',
    'de',
    'fl',
    'ga',
    'hi',
    'id',
    'il',
    'in',
    'ia',
    'ks',
    'ky',
    'la',
    'me',
    'md',
    'ma',
    'mi',
    'mn',
    'ms',
    'mo',
    'mt',
    'ne',
    'nv',
    'nh',
    'nj',
    'nm',
    'ny',
    'nc',
    'nd',
    'oh',
    'ok',
    'or',
    'pa',
    'ri',
    'sc',
    'sd',
    'tn',
    'tx',
    'ut',
    'vt',
    'va',
    'wa',
    'wv',
    'wi',
    'wy'
);


--
-- Name: traffic_dist_congestion_level_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE traffic_dist_congestion_level_type AS ENUM (
    'NO2LOW_CONGESTION',
    'MODERATE_CONGESTION',
    'SEVERE_CONGESTION'
);


--
-- Name: traffic_dist_day_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE traffic_dist_day_type AS ENUM (
    'WEEKDAY',
    'WEEKEND'
);


--
-- Name: traffic_dist_directionality_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE traffic_dist_directionality_type AS ENUM (
    'AM_PEAK',
    'PM_PEAK',
    'EVEN_DIST'
);


--
-- Name: traffic_dist_functional_class_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE traffic_dist_functional_class_type AS ENUM (
    'FREEWAY',
    'NONFREEWAY'
);


SET search_path = admin, pg_catalog;

--
-- Name: reports_created_updated_trigger(); Type: FUNCTION; Schema: admin; Owner: -
--

CREATE FUNCTION reports_created_updated_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO
      admin.reports_created_updated_at(report_id,created_at,updated_at)
        VALUES(new.id,now(),now())
    ON CONFLICT ON CONSTRAINT reports_created_updated_at_pkey DO UPDATE
    SET updated_at = now();
    RETURN new;
END;

$$;


--
-- Name: reports_delete_created_updated_trigger(); Type: FUNCTION; Schema: admin; Owner: -
--

CREATE FUNCTION reports_delete_created_updated_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    DELETE FROM 
    	admin.reports_created_updated_at
    WHERE 
    	admin.reports_created_updated_at.report_id = OLD.id;
    RETURN OLD;
END
$$;


--
-- Name: templates_created_updated_trigger(); Type: FUNCTION; Schema: admin; Owner: -
--

CREATE FUNCTION templates_created_updated_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO
      admin.templates_created_updated_at(template_id,created_at,updated_at)
        VALUES(new.id,now(),now())
    ON CONFLICT ON CONSTRAINT templates_created_updated_at_pkey DO UPDATE
    SET updated_at = now();
    RETURN new;
END;
$$;


--
-- Name: templates_delete_created_updated_trigger(); Type: FUNCTION; Schema: admin; Owner: -
--

CREATE FUNCTION templates_delete_created_updated_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM 
    	admin.templates_created_updated_at
    WHERE 
    	admin.templates_created_updated_at.template_id = OLD.id;
    RETURN OLD;
END

$$;


SET search_path = public, pg_catalog;

--
-- Name: create_child_table_from_shapefile(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION create_child_table_from_shapefile(tname character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
       BEGIN
  DROP TABLE IF EXISTS tempnormaltable;
  EXECUTE 'create table tempnormaltable as ('
       || 'select tmc, st_linemerge(wkb_geometry) as wkb_geometry,'
       || 'st_LineInterpolatePoint( st_linemerge(wkb_geometry), '
  ||   ' st_LineLocatePoint( st_linemerge(wkb_geometry), ST_setsrid(ST_MakePoint(startlong,startlat),4326) )) as startp,'
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
$$;


--
-- Name: get_closest_id(double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_closest_id(p1 double precision, p2 double precision) RETURNS TABLE(id integer)
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: npmrds_date(date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION npmrds_date(d1 date) RETURNS integer
    LANGUAGE sql STRICT
    AS $$select (extract(year from d1) * 10000 + extract(month from d1) * 100 + extract(day from d1))::integer;$$;


--
-- Name: npmrds_month(date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION npmrds_month(d1 date) RETURNS integer
    LANGUAGE sql STRICT
    AS $$select (extract(year from d1) * 100 + extract(month from d1))::integer;$$;


--
-- Name: npmrds_year(date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION npmrds_year(d1 date) RETURNS integer
    LANGUAGE sql STRICT
    AS $$select (extract(year from d1))::integer;$$;


--
-- Name: route_from_tmc(double precision[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION route_from_tmc(waypoints double precision[]) RETURNS TABLE(seq integer, nid integer, tmc character varying)
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: terse_bq_top_level_measures_fn(character varying[], geography_level_type[], smallint[], smallint[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION terse_bq_top_level_measures_fn(character varying[], geography_level_type[], smallint[], smallint[]) RETURNS text
    LANGUAGE plpgsql
    AS $_$

    DECLARE
      measures TEXT;

    BEGIN
      SET LOCAL work_mem = '256MB';

      SELECT INTO measures JSONB_BUILD_OBJECT(
        'schema',
        JSONB_BUILD_OBJECT(
          'fields',
          JSONB_BUILD_ARRAY(

            -- travel_time_reliability schema description object
            JSONB_BUILD_OBJECT(
              'name',
              'travel_time_reliability',
              'type',
              'record',
              'fields',
              JSONB_BUILD_ARRAY(
                JSON_BUILD_OBJECT('name', 'state'),
                JSON_BUILD_OBJECT('name', 'geography_level'),
                JSON_BUILD_OBJECT('name', 'geography_name'),
                JSON_BUILD_OBJECT('name', 'year'),
                JSON_BUILD_OBJECT('name', 'month'),
                JSON_BUILD_OBJECT('name', 'functional_class'),
                JSON_BUILD_OBJECT('name', 'travel_time_reliability')
              ) --end travel_time_reliability fields array
            ), --end travel_time_reliability description object

            -- freight_reliability schema description object
            JSONB_BUILD_OBJECT(
              'name',
              'freight_reliability',
              'type',
              'record',
              'fields',
              JSONB_BUILD_ARRAY(
                JSON_BUILD_OBJECT('name', 'state'),
                JSON_BUILD_OBJECT('name', 'geography_level'),
                JSON_BUILD_OBJECT('name', 'geography_name'),
                JSON_BUILD_OBJECT('name', 'year'),
                JSON_BUILD_OBJECT('name', 'month'),
                JSON_BUILD_OBJECT('name', 'functional_class'),
                JSON_BUILD_OBJECT('name', 'freight_reliability')
              ) --end freight_reliability fields array
            ), --end freight_reliability description object

            -- total_excessive_delay schema description object
            JSONB_BUILD_OBJECT(
              'name',
              'total_excessive_delay',
              'type',
              'record',
              'fields',
              JSONB_BUILD_ARRAY(
                JSON_BUILD_OBJECT('name', 'state'),
                JSON_BUILD_OBJECT('name', 'geography_level'),
                JSON_BUILD_OBJECT('name', 'geography_name'),
                JSON_BUILD_OBJECT('name', 'year'),
                JSON_BUILD_OBJECT('name', 'month'),
                JSON_BUILD_OBJECT('name', 'functional_class'),
                JSON_BUILD_OBJECT('name', 'total_excessive_delay'),
                JSON_BUILD_OBJECT('name', 'population_info')
              )
            )
          ) -- end root fields array
        ), -- end the schema description object

        'data',
        JSONB_BUILD_ARRAY(

          ( -- begin travel_time_reliability
            SELECT JSONB_AGG(
                JSONB_BUILD_ARRAY(
                  state,
                  geography_level,
                  geography_name,
                  year,
                  month,
                  functional_class,
                  ttr
                )
              )
              FROM top_level_travel_time_reliability
              WHERE 
                (state = ANY($1::VARCHAR[]))
                AND (
                  ($2::geography_level_type[] IS NULL) 
                  OR (geography_level::geography_level_type = ANY($2::geography_level_type[]))
                ) AND (
                  ($3::SMALLINT[] IS NULL)
                  OR (year = ANY($3::SMALLINT[]))
                ) AND (
                  ($4::SMALLINT[] IS NULL)
                  OR (month = ANY($4::SMALLINT[]))
                )
          ), --end travel_time_reliability

          ( -- begin freight_reliability
            SELECT JSONB_AGG(
                JSONB_BUILD_ARRAY(
                  state,
                  geography_level,
                  geography_name,
                  year,
                  month,
                  functional_class,
                  fr
                )
              )
              FROM top_level_freight_reliability
              WHERE 
                (state = ANY($1::VARCHAR[]))
                AND (
                  ($2::geography_level_type[] IS NULL)
                  OR (geography_level::geography_level_type = ANY($2::geography_level_type[]))
                ) AND (
                  ($3::SMALLINT[] IS NULL)
                  OR (year = ANY($3::SMALLINT[]))
                ) AND (
                  ($4::SMALLINT[] IS NULL)
                  OR (month = ANY($4::SMALLINT[]))
                )
          ), -- end freight_reliability

          ( -- begin total_excessive_delay
            SELECT JSONB_AGG(
                JSONB_BUILD_ARRAY(
                  state,
                  geography_level,
                  geography_name,
                  year,
                  month,
                  functional_class,
                  (
                    am_peak_total_xdelay_hrs + 
                    GREATEST(
                      pm1_peak_total_xdelay_hrs,
                      pm2_peak_total_xdelay_hrs
                    )
                  ),
                  population_info
                )
              )
              FROM top_level_total_excessive_delay
              WHERE 
                (state = ANY($1::VARCHAR[]))
                AND (
                  ($2::geography_level_type[] IS NULL)
                  OR (geography_level::geography_level_type = ANY($2::geography_level_type[]))
                ) AND (
                  ($3::SMALLINT[] IS NULL)
                  OR (year = ANY($3::SMALLINT[]))
                ) AND (
                  ($4::SMALLINT[] IS NULL)
                  OR (month = ANY($4::SMALLINT[]))
                )
          ) -- end total_excessive_delay
        ) -- end the data array
      )::TEXT;

    RETURN measures;
    END;

  $_$;


--
-- Name: timestamptoepoch(timestamp without time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION timestamptoepoch(d1 timestamp without time zone) RETURNS integer
    LANGUAGE sql STRICT
    AS $$select ( (extract(hour from d1) * 12) + floor(extract(minute from d1) / 5) )::integer;$$;


--
-- Name: vec_add(double precision[], double precision[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION vec_add(a double precision[], b double precision[]) RETURNS double precision[]
    LANGUAGE plpgsql
    AS $$ DECLARE x double precision[]; BEGIN SELECT array_agg(a.a + b.b ORDER BY a.ordinality ) INTO x FROM unnest(a) WITH ORDINALITY as a INNER JOIN LATERAL unnest(b) WITH ORDINALITY as b ON (a.ordinality=b.ordinality); RETURN x; END; $$;


--
-- Name: verbose_bq_top_level_measures_fn(character varying[], geography_level_type[], smallint[], smallint[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION verbose_bq_top_level_measures_fn(character varying[], geography_level_type[], smallint[], smallint[]) RETURNS text
    LANGUAGE plpgsql
    AS $_$

    DECLARE
      measures TEXT;

    BEGIN
      SET LOCAL work_mem = '256MB';

      SELECT INTO measures JSONB_BUILD_OBJECT(
        'schema',
        JSONB_BUILD_OBJECT(
          'fields',
          JSONB_BUILD_ARRAY(

            -- travel_time_reliability schema description object
            JSONB_BUILD_OBJECT(
              'name',
              'travel_time_reliability',
              'type',
              'record',
              'fields',
              JSONB_BUILD_ARRAY(
                JSON_BUILD_OBJECT('name', 'state'),
                JSON_BUILD_OBJECT('name', 'geography_level'),
                JSON_BUILD_OBJECT('name', 'geography_name'),
                JSON_BUILD_OBJECT('name', 'year'),
                JSON_BUILD_OBJECT('name', 'month'),
                JSON_BUILD_OBJECT('name', 'functional_class'),
                JSON_BUILD_OBJECT('name', 'travel_time_reliability'),
                JSON_BUILD_OBJECT('name', 'included_miles'),
                JSON_BUILD_OBJECT('name', 'passing_miles'),
                JSON_BUILD_OBJECT('name', 'excluded_miles'),
                JSON_BUILD_OBJECT('name', 'included_tmcs_ct'),
                JSON_BUILD_OBJECT('name', 'excluded_tmcs_ct'),
                JSON_BUILD_OBJECT('name', 'lottr_quartiles'),
                JSON_BUILD_OBJECT('name', 'lottr_mean'),
                JSON_BUILD_OBJECT('name', 'lottr_stddev')
              ) --end travel_time_reliability fields array
            ), --end travel_time_reliability description object

            -- freight_reliability schema description object
            JSONB_BUILD_OBJECT(
              'name',
              'freight_reliability',
              'type',
              'record',
              'fields',
              JSONB_BUILD_ARRAY(
                JSON_BUILD_OBJECT('name', 'state'),
                JSON_BUILD_OBJECT('name', 'geography_level'),
                JSON_BUILD_OBJECT('name', 'geography_name'),
                JSON_BUILD_OBJECT('name', 'year'),
                JSON_BUILD_OBJECT('name', 'month'),
                JSON_BUILD_OBJECT('name', 'functional_class'),
                JSON_BUILD_OBJECT('name', 'freight_reliability'),
                JSON_BUILD_OBJECT('name', 'included_miles'),
                JSON_BUILD_OBJECT('name', 'excluded_miles'),
                JSON_BUILD_OBJECT('name', 'included_tmcs_ct'),
                JSON_BUILD_OBJECT('name', 'excluded_tmcs_ct'),
                JSON_BUILD_OBJECT('name', 'tttr_quartiles'),
                JSON_BUILD_OBJECT('name', 'tttr_mean'),
                JSON_BUILD_OBJECT('name', 'tttr_stddev')
              ) --end freight_reliability fields array
            ), --end freight_reliability description object

            -- total_excessive_delay schema description object
            JSONB_BUILD_OBJECT(
              'name',
              'total_excessive_delay',
              'type',
              'record',
              'fields',
              JSONB_BUILD_ARRAY(
                JSON_BUILD_OBJECT('name', 'state'),
                JSON_BUILD_OBJECT('name', 'geography_level'),
                JSON_BUILD_OBJECT('name', 'geography_name'),
                JSON_BUILD_OBJECT('name', 'year'),
                JSON_BUILD_OBJECT('name', 'month'),
                JSON_BUILD_OBJECT('name', 'functional_class'),
                JSON_BUILD_OBJECT('name', 'total_excessive_delay'),
                JSON_BUILD_OBJECT('name', 'included_miles'),
                JSON_BUILD_OBJECT('name', 'excluded_miles'),
                JSON_BUILD_OBJECT('name', 'included_tmcs_ct'),
                JSON_BUILD_OBJECT('name', 'excluded_tmcs_ct'),
                JSON_BUILD_OBJECT('name', 'total_excessive_delay_quartiles'),
                JSON_BUILD_OBJECT('name', 'total_excessive_delay_mean'),
                JSON_BUILD_OBJECT('name', 'total_excessive_delay_stddev'),
                JSON_BUILD_OBJECT('name', 'total_excessive_delay_per_mile_quartiles'),
                JSON_BUILD_OBJECT('name', 'total_excessive_delay_per_mile_mean'),
                JSON_BUILD_OBJECT('name', 'total_excessive_delay_per_mile_stddev'),
                JSON_BUILD_OBJECT('name', 'population_info')
              )
            )
          ) -- end root fields array
        ), -- end the schema description object

        'data',
        JSONB_BUILD_ARRAY(

          ( -- begin travel_time_reliability
            SELECT JSONB_AGG(
                JSONB_BUILD_ARRAY(
                  state,
                  geography_level,
                  geography_name,
                  year,
                  month,
                  functional_class,
                  ttr,
                  included_mi,
                  passing_mi,
                  excluded_mi,
                  included_tmcs_ct,
                  excluded_tmcs_ct,
                  lottr_quartiles,
                  lottr_mean,
                  lottr_stddev
                )
              )
              FROM top_level_travel_time_reliability
              WHERE 
                (state = ANY($1::VARCHAR[]))
                AND (
                  ($2::geography_level_type[] IS NULL) 
                  OR (geography_level::geography_level_type = ANY($2::geography_level_type[]))
                ) AND (
                  ($3::SMALLINT[] IS NULL)
                  OR (year = ANY($3::SMALLINT[]))
                ) AND (
                  ($4::SMALLINT[] IS NULL)
                  OR (month = ANY($4::SMALLINT[]))
                )
          ), --end travel_time_reliability

          ( -- begin freight_reliability
            SELECT JSONB_AGG(
                JSONB_BUILD_ARRAY(
                  state,
                  geography_level,
                  geography_name,
                  year,
                  month,
                  functional_class,
                  fr,
                  included_mi,
                  excluded_mi,
                  included_tmcs_ct,
                  excluded_tmcs_ct,
                  tttr_quartiles,
                  tttr_mean,
                  tttr_stddev
                )
              )
              FROM top_level_freight_reliability
              WHERE 
                (state = ANY($1::VARCHAR[]))
                AND (
                  ($2::geography_level_type[] IS NULL)
                  OR (geography_level::geography_level_type = ANY($2::geography_level_type[]))
                ) AND (
                  ($3::SMALLINT[] IS NULL)
                  OR (year = ANY($3::SMALLINT[]))
                ) AND (
                  ($4::SMALLINT[] IS NULL)
                  OR (month = ANY($4::SMALLINT[]))
                )
          ), -- end freight_reliability

          ( -- begin total_excessive_delay
            SELECT JSONB_AGG(
                JSONB_BUILD_ARRAY(
                  state,
                  geography_level,
                  geography_name,
                  year,
                  month,
                  functional_class,
                  (
                    am_peak_total_xdelay_hrs + 
                    GREATEST(
                      pm1_peak_total_xdelay_hrs,
                      pm2_peak_total_xdelay_hrs
                    )
                  ),
                  included_mi,
                  excluded_mi,
                  included_tmcs_ct,
                  excluded_tmcs_ct,
                  summary_stats_by_phed_period,
                  population_info
                )
              )
              FROM top_level_total_excessive_delay
              WHERE 
                (state = ANY($1::VARCHAR[]))
                AND (
                  ($2::geography_level_type[] IS NULL)
                  OR (geography_level::geography_level_type = ANY($2::geography_level_type[]))
                ) AND (
                  ($3::SMALLINT[] IS NULL)
                  OR (year = ANY($3::SMALLINT[]))
                ) AND (
                  ($4::SMALLINT[] IS NULL)
                  OR (month = ANY($4::SMALLINT[]))
                )
          ) -- end total_excessive_delay
        ) -- end the data array
      )::TEXT;

    RETURN measures;
    END;

  $_$;


SET search_path = admin, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: folders; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE folders (
    id bigint NOT NULL,
    name text,
    owner text,
    type text,
    routes integer[]
);


--
-- Name: folders_id_seq; Type: SEQUENCE; Schema: admin; Owner: -
--

CREATE SEQUENCE folders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: folders_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: -
--

ALTER SEQUENCE folders_id_seq OWNED BY folders.id;


--
-- Name: net_templates; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE net_templates (
    id bigint NOT NULL,
    type text,
    owner text,
    title text,
    description text,
    ncomps integer,
    comps json,
    graph_comps json,
    special boolean DEFAULT false
);


--
-- Name: net_templates_id_seq; Type: SEQUENCE; Schema: admin; Owner: -
--

CREATE SEQUENCE net_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: net_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: -
--

ALTER SEQUENCE net_templates_id_seq OWNED BY net_templates.id;


--
-- Name: notification_views; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE notification_views (
    user_id character varying NOT NULL,
    notification_id character varying NOT NULL
);


--
-- Name: notifications; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE notifications (
    id integer NOT NULL,
    sender character varying NOT NULL,
    recipient character varying NOT NULL,
    type character varying NOT NULL,
    shared_id character varying NOT NULL,
    message character varying
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: admin; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: reports; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE reports (
    id bigint NOT NULL,
    type text,
    owner text,
    title text,
    description text,
    route_comps text,
    graph_comps text,
    thumbnail character varying
);


--
-- Name: reports_created_updated_at; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE reports_created_updated_at (
    report_id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: reports_id_seq; Type: SEQUENCE; Schema: admin; Owner: -
--

CREATE SEQUENCE reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: -
--

ALTER SEQUENCE reports_id_seq OWNED BY reports.id;


--
-- Name: templates; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE templates (
    id bigint NOT NULL,
    type text,
    owner text,
    title text,
    description text,
    routes integer,
    route_comps text,
    graph_comps text,
    special boolean DEFAULT false
);


--
-- Name: templates_created_updated_at; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE templates_created_updated_at (
    template_id bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: templates_id_seq; Type: SEQUENCE; Schema: admin; Owner: -
--

CREATE SEQUENCE templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: templates_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: -
--

ALTER SEQUENCE templates_id_seq OWNED BY templates.id;


--
-- Name: user_report_views; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE user_report_views (
    user_id integer NOT NULL,
    report_ids integer[] NOT NULL,
    CONSTRAINT report_ids_length CHECK ((cardinality(report_ids) < 14))
);


SET search_path = public, pg_catalog;

--
-- Name: avg_speedlimits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE avg_speedlimits (
    state character(2),
    tmc character varying,
    avg_speedlimit real
);


SET search_path = nj, pg_catalog;

--
-- Name: avg_speedlimits; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE avg_speedlimits (
    state character(2) DEFAULT 'nj'::bpchar,
    tmc character varying NOT NULL,
    avg_speedlimit real,
    CONSTRAINT avg_speedlimits_state_check CHECK ((state = 'nj'::bpchar))
)
INHERITS (public.avg_speedlimits);


SET search_path = public, pg_catalog;

--
-- Name: excessive_delay_brkdwn; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE excessive_delay_brkdwn (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9),
    excessive_delay_brkdwn jsonb
);


SET search_path = nj, pg_catalog;

--
-- Name: excessive_delay_brkdwn; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE excessive_delay_brkdwn (
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (public.excessive_delay_brkdwn);


--
-- Name: excessive_delay_brkdwn_y2017m00; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m00 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m02; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m02 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m03; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m03 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m04; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m04 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m05; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m05 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m06; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m06 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m07; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m07 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m08; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m08 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m09; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m09 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m10; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m10 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m11; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m11 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


SET search_path = public, pg_catalog;

--
-- Name: inrix_shapefile; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE inrix_shapefile (
    ogc_fid integer NOT NULL,
    tmc character varying,
    tmctype character varying,
    roadnumber character varying,
    roadname character varying,
    firstname character varying,
    tmclinear bigint,
    country character varying,
    state character varying,
    county character varying,
    zip character varying,
    direction character varying,
    startlat double precision,
    startlong double precision,
    endlat double precision,
    endlong double precision,
    miles double precision,
    frc bigint,
    border_set character varying,
    f_system bigint,
    urban_code bigint,
    faciltype bigint,
    structype bigint,
    thrulanes bigint,
    route_numb bigint,
    route_sign bigint,
    route_qual bigint,
    altrtename character varying,
    aadt bigint,
    aadt_singl bigint,
    aadt_combi bigint,
    nhs bigint,
    nhs_pct bigint,
    strhnt_typ bigint,
    strhnt_pct bigint,
    truck bigint,
    wkb_geometry geometry(MultiLineString,4326)
);


SET search_path = nj, pg_catalog;

--
-- Name: inrix_shapefile_20170707; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE inrix_shapefile_20170707 (
    ogc_fid integer,
    tmc character varying,
    tmctype character varying,
    roadnumber character varying,
    roadname character varying,
    firstname character varying,
    tmclinear bigint,
    country character varying,
    state character varying,
    county character varying,
    zip character varying,
    direction character varying,
    startlat double precision,
    startlong double precision,
    endlat double precision,
    endlong double precision,
    miles double precision,
    frc bigint,
    border_set character varying,
    f_system bigint,
    urban_code bigint,
    faciltype bigint,
    structype bigint,
    thrulanes bigint,
    route_numb bigint,
    route_sign bigint,
    route_qual bigint,
    altrtename character varying,
    aadt bigint,
    aadt_singl bigint,
    aadt_combi bigint,
    nhs bigint,
    nhs_pct bigint,
    strhnt_typ bigint,
    strhnt_pct bigint,
    truck bigint,
    wkb_geometry public.geometry(MultiLineString,4326)
)
INHERITS (public.inrix_shapefile);


--
-- Name: inrix_shapefile_20170707_ogc_fid_seq; Type: SEQUENCE; Schema: nj; Owner: -
--

CREATE SEQUENCE inrix_shapefile_20170707_ogc_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inrix_shapefile_20170707_ogc_fid_seq; Type: SEQUENCE OWNED BY; Schema: nj; Owner: -
--

ALTER SEQUENCE inrix_shapefile_20170707_ogc_fid_seq OWNED BY inrix_shapefile_20170707.ogc_fid;


SET search_path = public, pg_catalog;

--
-- Name: lottr_percentiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE lottr_percentiles (
    state character varying(2),
    tmc character varying(9),
    year smallint,
    month smallint,
    data jsonb
);


SET search_path = nj, pg_catalog;

--
-- Name: lottr_percentiles; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE lottr_percentiles (
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (public.lottr_percentiles);


--
-- Name: lottr_percentiles_y2017m00; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m00 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m00 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m02; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m02 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m02 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m03; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m03 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m03 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m04; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m04 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m04 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m05; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m05 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m05 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m06; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m06 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m06 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m07; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m07 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m07 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m08; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m08 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m08 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m09; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m09 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m09 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m10; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m10 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m10 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m11; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m11 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m11 ALTER COLUMN data SET STATISTICS 0;


SET search_path = public, pg_catalog;

--
-- Name: npmrds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE npmrds (
    tmc character varying(9),
    date date,
    epoch smallint,
    travel_time_all_vehicles real,
    travel_time_passenger_vehicles real,
    travel_time_freight_trucks real,
    state character(2)
);


SET search_path = nj, pg_catalog;

--
-- Name: npmrds; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE npmrds (
    tmc character varying(9),
    date date,
    epoch smallint,
    travel_time_all_vehicles real,
    travel_time_passenger_vehicles real,
    travel_time_freight_trucks real,
    state character(2) DEFAULT 'nj'::bpchar,
    CONSTRAINT npmrds_state_check CHECK ((state = 'nj'::bpchar))
)
INHERITS (public.npmrds);


--
-- Name: npmrds_y2017m02; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE npmrds_y2017m02 (
    CONSTRAINT npmrds_y2017m02_date_check CHECK (((date >= '2017-02-01'::date) AND (date < '2017-03-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m02 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m02 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m02 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m03; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE npmrds_y2017m03 (
    CONSTRAINT npmrds_y2017m03_date_check CHECK (((date >= '2017-03-01'::date) AND (date < '2017-04-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m03 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m03 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m03 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m04; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE npmrds_y2017m04 (
    CONSTRAINT npmrds_y2017m04_date_check CHECK (((date >= '2017-04-01'::date) AND (date < '2017-05-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m04 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m04 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m04 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m05; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE npmrds_y2017m05 (
    CONSTRAINT npmrds_y2017m05_date_check CHECK (((date >= '2017-05-01'::date) AND (date < '2017-06-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m05 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m05 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m05 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m06; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE npmrds_y2017m06 (
    CONSTRAINT npmrds_y2017m06_date_check CHECK (((date >= '2017-06-01'::date) AND (date < '2017-07-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m06 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m06 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m06 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m07; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE npmrds_y2017m07 (
    CONSTRAINT npmrds_y2017m07_date_check CHECK (((date >= '2017-07-01'::date) AND (date < '2017-08-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m07 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m07 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m07 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m08; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE npmrds_y2017m08 (
    CONSTRAINT npmrds_y2017m08_date_check CHECK (((date >= '2017-08-01'::date) AND (date < '2017-09-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m08 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m08 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m08 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m09; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE npmrds_y2017m09 (
    CONSTRAINT npmrds_y2017m09_date_check CHECK (((date >= '2017-09-01'::date) AND (date < '2017-10-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m09 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m09 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m09 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m10; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE npmrds_y2017m10 (
    CONSTRAINT npmrds_y2017m10_date_check CHECK (((date >= '2017-10-01'::date) AND (date < '2017-11-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m10 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m10 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m10 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m11; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE npmrds_y2017m11 (
    CONSTRAINT npmrds_y2017m11_date_check CHECK (((date >= '2017-11-01'::date) AND (date < '2017-12-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m11 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m11 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m11 ALTER COLUMN epoch SET NOT NULL;


SET search_path = public, pg_catalog;

--
-- Name: tmc_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tmc_attributes (
    tmc character varying,
    tmctype character varying,
    roadnumber character varying,
    roadname character varying,
    firstname character varying,
    tmclinear bigint,
    country character varying,
    statename character varying,
    county character varying,
    zip character varying,
    direction character varying,
    startlat double precision,
    startlong double precision,
    endlat double precision,
    endlong double precision,
    miles double precision,
    frc bigint,
    border_set character varying,
    f_system bigint,
    urban_code bigint,
    faciltype bigint,
    structype bigint,
    thrulanes bigint,
    route_numb bigint,
    route_sign bigint,
    route_qual bigint,
    altrtename character varying,
    aadt bigint,
    aadt_singl bigint,
    aadt_combi bigint,
    nhs bigint,
    nhs_pct bigint,
    strhnt_typ bigint,
    strhnt_pct bigint,
    truck bigint,
    admin_level_1 character varying,
    admin_level_2 character varying,
    admin_level_3 character varying,
    distance double precision,
    length double precision,
    road_number character varying,
    road_name character varying,
    latitude double precision,
    longitude double precision,
    road_direction text,
    occupancy_factor real,
    state character(2),
    is_interstate boolean,
    is_controlled_access boolean,
    avg_speedlimit real,
    cbsa_code character varying,
    cbsa_name character varying,
    mpo_code character varying,
    mpo_acrony character varying,
    mpo_name character varying,
    ua_code character varying,
    ua_name character varying,
    region_code smallint,
    region_name character varying,
    congestion_level traffic_dist_congestion_level_type,
    directionality traffic_dist_directionality_type,
    bounding_box box2d
)
WITH (fillfactor='100', autovacuum_enabled='false');


SET search_path = nj, pg_catalog;

--
-- Name: tmc_attributes; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE tmc_attributes (
    tmc character varying NOT NULL,
    tmctype character varying,
    roadnumber character varying,
    roadname character varying,
    firstname character varying,
    tmclinear bigint,
    country character varying,
    statename character varying,
    county character varying,
    zip character varying,
    direction character varying,
    startlat double precision,
    startlong double precision,
    endlat double precision,
    endlong double precision,
    miles double precision,
    frc bigint,
    border_set character varying,
    f_system bigint,
    urban_code bigint,
    faciltype bigint,
    structype bigint,
    thrulanes bigint,
    route_numb bigint,
    route_sign bigint,
    route_qual bigint,
    altrtename character varying,
    aadt bigint,
    aadt_singl bigint,
    aadt_combi bigint,
    nhs bigint,
    nhs_pct bigint,
    strhnt_typ bigint,
    strhnt_pct bigint,
    truck bigint,
    admin_level_1 character varying,
    admin_level_2 character varying,
    admin_level_3 character varying,
    distance double precision,
    length double precision,
    road_number character varying,
    road_name character varying,
    latitude double precision,
    longitude double precision,
    road_direction text,
    occupancy_factor real,
    state character(2),
    is_interstate boolean,
    is_controlled_access boolean,
    avg_speedlimit real,
    cbsa_code character varying,
    cbsa_name character varying,
    mpo_code character varying,
    mpo_acrony character varying,
    mpo_name character varying,
    ua_code character varying,
    ua_name character varying,
    region_code smallint,
    region_name character varying,
    congestion_level public.traffic_dist_congestion_level_type,
    directionality public.traffic_dist_directionality_type,
    bounding_box public.box2d,
    CONSTRAINT tmc_attributes_state_check CHECK ((state = 'nj'::bpchar))
)
INHERITS (public.tmc_attributes)
WITH (fillfactor='100', autovacuum_enabled='false');


SET search_path = public, pg_catalog;

--
-- Name: tmc_date_ranges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tmc_date_ranges (
    tmc character varying(9),
    first_date date,
    last_date date,
    state character(2)
);


SET search_path = nj, pg_catalog;

--
-- Name: tmc_date_ranges; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE tmc_date_ranges (
    tmc character varying(9) NOT NULL,
    first_date date,
    last_date date,
    state character(2) DEFAULT 'nj'::bpchar,
    CONSTRAINT tmc_date_ranges_state_check CHECK ((state = 'nj'::bpchar))
)
INHERITS (public.tmc_date_ranges);


SET search_path = public, pg_catalog;

--
-- Name: top_level_freight_reliability; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE top_level_freight_reliability (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level geography_level_type,
    geography_name character varying,
    functional_class functional_class_type,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real
);


SET search_path = nj, pg_catalog;

--
-- Name: top_level_freight_reliability; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_freight_reliability (
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (public.top_level_freight_reliability);


--
-- Name: top_level_freight_reliability_y2017m00; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m00 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m02; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m02 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m03; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m03 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m04; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m04 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m05; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m05 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m06; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m06 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m07; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m07 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m08; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m08 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m09; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m09 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m10; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m10 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m11; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m11 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


SET search_path = public, pg_catalog;

--
-- Name: top_level_total_excessive_delay; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE top_level_total_excessive_delay (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level geography_level_type,
    geography_name character varying,
    functional_class functional_class_type,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb
);


SET search_path = nj, pg_catalog;

--
-- Name: top_level_total_excessive_delay; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_total_excessive_delay (
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (public.top_level_total_excessive_delay);


--
-- Name: top_level_total_excessive_delay_y2017m00; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m00 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m02; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m02 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m03; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m03 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m04; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m04 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m05; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m05 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m06; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m06 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m07; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m07 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m08; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m08 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m09; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m09 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m10; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m10 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m11; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m11 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


SET search_path = public, pg_catalog;

--
-- Name: top_level_travel_time_reliability; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE top_level_travel_time_reliability (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level geography_level_type,
    geography_name character varying,
    functional_class functional_class_type,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real
);


SET search_path = nj, pg_catalog;

--
-- Name: top_level_travel_time_reliability; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_travel_time_reliability (
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (public.top_level_travel_time_reliability);


--
-- Name: top_level_travel_time_reliability_y2017m00; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m00 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m02; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m02 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m03; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m03 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m04; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m04 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m05; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m05 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m06; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m06 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m07; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m07 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m08; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m08 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m09; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m09 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m10; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m10 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m11; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m11 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


SET search_path = public, pg_catalog;

--
-- Name: tttr_percentiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tttr_percentiles (
    state character varying(2),
    tmc character varying(9),
    year smallint,
    month smallint,
    data jsonb
);


SET search_path = nj, pg_catalog;

--
-- Name: tttr_percentiles; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE tttr_percentiles (
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (public.tttr_percentiles);


--
-- Name: tttr_percentiles_y2017m00; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m00 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m00 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m02; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m02 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m02 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m03; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m03 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m03 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m04; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m04 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m04 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m05; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m05 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m05 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m06; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m06 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m06 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m07; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m07 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m07 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m08; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m08 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m08 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m09; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m09 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m09 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m10; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m10 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m10 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m11; Type: TABLE; Schema: nj; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m11 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'nj'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m11 ALTER COLUMN data SET STATISTICS 0;


SET search_path = ny, pg_catalog;

--
-- Name: avg_speedlimits; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE avg_speedlimits (
    state character(2) DEFAULT 'ny'::bpchar,
    tmc character varying NOT NULL,
    avg_speedlimit real,
    CONSTRAINT avg_speedlimits_state_check CHECK ((state = 'ny'::bpchar))
)
INHERITS (public.avg_speedlimits);


--
-- Name: bottleneck_effects; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE bottleneck_effects (
    id integer NOT NULL,
    depth smallint NOT NULL,
    affected text[] NOT NULL
);


--
-- Name: bottlenecks; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE bottlenecks (
    tmc character varying(9) NOT NULL,
    start_epoch smallint NOT NULL,
    end_epoch smallint NOT NULL,
    year smallint NOT NULL,
    month smallint NOT NULL,
    peak_severity real NOT NULL,
    peak_epoch smallint NOT NULL,
    peak_depth smallint NOT NULL,
    hours_of_delay_dist real[] NOT NULL,
    traffic_volume_dist real[] NOT NULL,
    aadttype character varying NOT NULL,
    id integer NOT NULL
);


--
-- Name: bottlenecks_id_seq; Type: SEQUENCE; Schema: ny; Owner: -
--

CREATE SEQUENCE bottlenecks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bottlenecks_id_seq; Type: SEQUENCE OWNED BY; Schema: ny; Owner: -
--

ALTER SEQUENCE bottlenecks_id_seq OWNED BY bottlenecks.id;


SET search_path = public, pg_catalog;

--
-- Name: tmp_tmc_to_mpo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tmp_tmc_to_mpo (
    tmc character varying,
    mpo_code character varying
);


SET search_path = ny, pg_catalog;

--
-- Name: bottlenecks_summary; Type: MATERIALIZED VIEW; Schema: ny; Owner: -
--

CREATE MATERIALIZED VIEW bottlenecks_summary AS
 WITH t_hours AS (
         SELECT
                CASE
                    WHEN ((i.aadttype)::text = 'all'::text) THEN 'total'::character varying
                    ELSE i.aadttype
                END AS aadttype,
            i.tmc,
            i.year,
            i.month,
            array_agg(i.start_epoch ORDER BY i.start_epoch) AS starts,
            array_agg(i.end_epoch ORDER BY i.start_epoch) AS ends,
            sum(( SELECT COALESCE(sum(s.s), (0)::real) AS "coalesce"
                   FROM unnest(i.hours_of_delay_dist) s(s))) AS total_hours,
            mpo.mpo_code AS mpo_id
           FROM (bottlenecks i
             LEFT JOIN public.tmp_tmc_to_mpo mpo USING (tmc))
          GROUP BY i.tmc, i.year, i.month, i.aadttype, mpo.mpo_code
        )
 SELECT t_hours.aadttype,
    t_hours.tmc,
    t_hours.year,
    t_hours.month,
    t_hours.total_hours,
    t_hours.starts,
    t_hours.ends,
    row_number() OVER (PARTITION BY t_hours.aadttype, t_hours.month, t_hours.year ORDER BY t_hours.total_hours DESC) AS hrank,
    row_number() OVER (PARTITION BY t_hours.aadttype, t_hours.month, t_hours.year, t_hours.mpo_id ORDER BY t_hours.total_hours DESC) AS mpohrank,
    t_hours.mpo_id
   FROM t_hours
  WITH NO DATA;


--
-- Name: bottlenecks_temp; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE bottlenecks_temp (
    tmc character varying(9) NOT NULL,
    start_epoch smallint NOT NULL,
    end_epoch smallint NOT NULL,
    year smallint NOT NULL,
    month smallint NOT NULL,
    peak_severity real NOT NULL,
    peak_epoch smallint NOT NULL,
    peak_depth smallint NOT NULL,
    hours_of_delay_dist real[] NOT NULL,
    traffic_volume_dist real[] NOT NULL
);


--
-- Name: excessive_delay_brkdwn; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn (
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (public.excessive_delay_brkdwn);


--
-- Name: excessive_delay_brkdwn_y2015m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2015m00 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2015m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2015m01 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2015m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2015m02 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2015m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2015m03 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2015m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2015m04 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2015m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2015m05 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2015m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2015m06 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2015m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2015m07 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2015m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2015m08 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2015m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2015m09 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2015m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2015m10 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2015m11; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2015m11 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2015m12; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2015m12 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 12))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2016m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2016m00 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2016m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2016m01 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2016m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2016m02 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2016m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2016m03 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2016m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2016m04 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2016m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2016m05 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2016m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2016m06 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2016m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2016m07 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2016m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2016m08 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2016m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2016m09 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2016m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2016m10 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2016m11; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2016m11 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2016m12; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2016m12 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 12))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m00 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m01 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m02 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m03 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m04 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m05 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m06 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m07 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m08 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m09 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: excessive_delay_brkdwn_y2017m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE excessive_delay_brkdwn_y2017m10 (
    state character varying(2),
    year smallint,
    month smallint,
    tmc character varying(9) NOT NULL,
    excessive_delay_brkdwn jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (excessive_delay_brkdwn)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: inrix_shapefile_20170707; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE inrix_shapefile_20170707 (
    ogc_fid integer,
    tmc character varying,
    tmctype character varying,
    roadnumber character varying,
    roadname character varying,
    firstname character varying,
    tmclinear bigint,
    country character varying,
    state character varying,
    county character varying,
    zip character varying,
    direction character varying,
    startlat double precision,
    startlong double precision,
    endlat double precision,
    endlong double precision,
    miles double precision,
    frc bigint,
    border_set character varying,
    f_system bigint,
    urban_code bigint,
    faciltype bigint,
    structype bigint,
    thrulanes bigint,
    route_numb bigint,
    route_sign bigint,
    route_qual bigint,
    altrtename character varying,
    aadt bigint,
    aadt_singl bigint,
    aadt_combi bigint,
    nhs bigint,
    nhs_pct bigint,
    strhnt_typ bigint,
    strhnt_pct bigint,
    truck bigint,
    wkb_geometry public.geometry(MultiLineString,4326)
)
INHERITS (public.inrix_shapefile);


--
-- Name: inrix_shapefile_20170707_ogc_fid_seq; Type: SEQUENCE; Schema: ny; Owner: -
--

CREATE SEQUENCE inrix_shapefile_20170707_ogc_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inrix_shapefile_20170707_ogc_fid_seq; Type: SEQUENCE OWNED BY; Schema: ny; Owner: -
--

ALTER SEQUENCE inrix_shapefile_20170707_ogc_fid_seq OWNED BY inrix_shapefile_20170707.ogc_fid;


--
-- Name: lottr_percentiles; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles (
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (public.lottr_percentiles);


--
-- Name: lottr_percentiles_y2015m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2015m00 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2015m00 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2015m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2015m01 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2015m01 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2015m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2015m02 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2015m02 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2015m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2015m03 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2015m03 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2015m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2015m04 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2015m04 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2015m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2015m05 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2015m05 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2015m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2015m06 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2015m06 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2015m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2015m07 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2015m07 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2015m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2015m08 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2015m08 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2015m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2015m09 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2015m09 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2015m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2015m10 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2015m10 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2015m11; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2015m11 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2015m11 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2015m12; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2015m12 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 12))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2015m12 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2016m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2016m00 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100');
ALTER TABLE ONLY lottr_percentiles_y2016m00 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2016m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2016m01 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100');
ALTER TABLE ONLY lottr_percentiles_y2016m01 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2016m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2016m02 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100');
ALTER TABLE ONLY lottr_percentiles_y2016m02 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2016m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2016m03 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100');
ALTER TABLE ONLY lottr_percentiles_y2016m03 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2016m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2016m04 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100');
ALTER TABLE ONLY lottr_percentiles_y2016m04 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2016m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2016m05 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100');
ALTER TABLE ONLY lottr_percentiles_y2016m05 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2016m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2016m06 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100');
ALTER TABLE ONLY lottr_percentiles_y2016m06 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2016m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2016m07 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100');
ALTER TABLE ONLY lottr_percentiles_y2016m07 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2016m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2016m08 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100');
ALTER TABLE ONLY lottr_percentiles_y2016m08 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2016m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2016m09 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100');
ALTER TABLE ONLY lottr_percentiles_y2016m09 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2016m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2016m10 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100');
ALTER TABLE ONLY lottr_percentiles_y2016m10 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2016m11; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2016m11 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100');
ALTER TABLE ONLY lottr_percentiles_y2016m11 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2016m12; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2016m12 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 12))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100');
ALTER TABLE ONLY lottr_percentiles_y2016m12 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m00 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m00 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m01 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100');
ALTER TABLE ONLY lottr_percentiles_y2017m01 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m02 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m02 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m03 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m03 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m04 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m04 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m05 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m05 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m06 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m06 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m07 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100');
ALTER TABLE ONLY lottr_percentiles_y2017m07 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m08 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m08 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m09 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m09 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: lottr_percentiles_y2017m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE lottr_percentiles_y2017m10 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (lottr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY lottr_percentiles_y2017m10 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: npmrds; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds (
    tmc character varying(9),
    date date,
    epoch smallint,
    travel_time_all_vehicles real,
    travel_time_passenger_vehicles real,
    travel_time_freight_trucks real,
    state character(2) DEFAULT 'ny'::bpchar,
    CONSTRAINT npmrds_state_check CHECK ((state = 'ny'::bpchar))
)
INHERITS (public.npmrds);


--
-- Name: npmrds_y2015m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2015m01 (
    CONSTRAINT npmrds_y2015m01_date_check CHECK (((date >= '2015-01-01'::date) AND (date < '2015-02-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2015m01 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m01 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m01 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2015m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2015m02 (
    CONSTRAINT npmrds_y2015m02_date_check CHECK (((date >= '2015-02-01'::date) AND (date < '2015-03-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2015m02 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m02 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m02 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2015m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2015m03 (
    CONSTRAINT npmrds_y2015m03_date_check CHECK (((date >= '2015-03-01'::date) AND (date < '2015-04-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2015m03 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m03 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m03 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2015m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2015m04 (
    CONSTRAINT npmrds_y2015m04_date_check CHECK (((date >= '2015-04-01'::date) AND (date < '2015-05-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2015m04 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m04 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m04 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2015m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2015m05 (
    CONSTRAINT npmrds_y2015m05_date_check CHECK (((date >= '2015-05-01'::date) AND (date < '2015-06-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2015m05 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m05 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m05 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2015m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2015m06 (
    CONSTRAINT npmrds_y2015m06_date_check CHECK (((date >= '2015-06-01'::date) AND (date < '2015-07-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2015m06 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m06 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m06 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2015m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2015m07 (
    CONSTRAINT npmrds_y2015m07_date_check CHECK (((date >= '2015-07-01'::date) AND (date < '2015-08-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2015m07 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m07 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m07 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2015m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2015m08 (
    CONSTRAINT npmrds_y2015m08_date_check CHECK (((date >= '2015-08-01'::date) AND (date < '2015-09-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2015m08 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m08 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m08 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2015m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2015m09 (
    CONSTRAINT npmrds_y2015m09_date_check CHECK (((date >= '2015-09-01'::date) AND (date < '2015-10-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2015m09 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m09 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m09 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2015m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2015m10 (
    CONSTRAINT npmrds_y2015m10_date_check CHECK (((date >= '2015-10-01'::date) AND (date < '2015-11-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2015m10 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m10 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m10 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2015m11; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2015m11 (
    CONSTRAINT npmrds_y2015m11_date_check CHECK (((date >= '2015-11-01'::date) AND (date < '2015-12-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2015m11 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m11 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m11 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2015m12; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2015m12 (
    CONSTRAINT npmrds_y2015m12_date_check CHECK (((date >= '2015-12-01'::date) AND (date < '2016-01-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2015m12 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m12 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2015m12 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2016m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2016m01 (
    CONSTRAINT npmrds_y2016m01_date_check CHECK (((date >= '2016-01-01'::date) AND (date < '2016-02-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2016m01 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m01 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m01 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2016m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2016m02 (
    CONSTRAINT npmrds_y2016m02_date_check CHECK (((date >= '2016-02-01'::date) AND (date < '2016-03-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2016m02 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m02 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m02 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2016m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2016m03 (
    CONSTRAINT npmrds_y2016m03_date_check CHECK (((date >= '2016-03-01'::date) AND (date < '2016-04-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2016m03 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m03 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m03 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2016m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2016m04 (
    CONSTRAINT npmrds_y2016m04_date_check CHECK (((date >= '2016-04-01'::date) AND (date < '2016-05-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2016m04 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m04 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m04 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2016m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2016m05 (
    CONSTRAINT npmrds_y2016m05_date_check CHECK (((date >= '2016-05-01'::date) AND (date < '2016-06-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2016m05 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m05 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m05 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2016m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2016m06 (
    CONSTRAINT npmrds_y2016m06_date_check CHECK (((date >= '2016-06-01'::date) AND (date < '2016-07-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2016m06 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m06 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m06 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2016m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2016m07 (
    CONSTRAINT npmrds_y2016m07_date_check CHECK (((date >= '2016-07-01'::date) AND (date < '2016-08-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2016m07 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m07 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m07 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2016m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2016m08 (
    CONSTRAINT npmrds_y2016m08_date_check CHECK (((date >= '2016-08-01'::date) AND (date < '2016-09-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2016m08 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m08 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m08 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2016m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2016m09 (
    CONSTRAINT npmrds_y2016m09_date_check CHECK (((date >= '2016-09-01'::date) AND (date < '2016-10-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2016m09 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m09 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m09 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2016m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2016m10 (
    CONSTRAINT npmrds_y2016m10_date_check CHECK (((date >= '2016-10-01'::date) AND (date < '2016-11-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2016m10 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m10 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m10 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2016m11; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2016m11 (
    CONSTRAINT npmrds_y2016m11_date_check CHECK (((date >= '2016-11-01'::date) AND (date < '2016-12-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2016m11 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m11 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m11 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2016m12; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2016m12 (
    CONSTRAINT npmrds_y2016m12_date_check CHECK (((date >= '2016-12-01'::date) AND (date < '2017-01-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2016m12 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m12 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2016m12 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2017m01 (
    CONSTRAINT npmrds_y2017m01_date_check CHECK (((date >= '2017-01-01'::date) AND (date < '2017-02-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m01 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m01 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m01 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2017m02 (
    CONSTRAINT npmrds_y2017m02_date_check CHECK (((date >= '2017-02-01'::date) AND (date < '2017-03-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m02 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m02 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m02 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2017m03 (
    CONSTRAINT npmrds_y2017m03_date_check CHECK (((date >= '2017-03-01'::date) AND (date < '2017-04-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m03 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m03 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m03 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2017m04 (
    CONSTRAINT npmrds_y2017m04_date_check CHECK (((date >= '2017-04-01'::date) AND (date < '2017-05-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m04 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m04 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m04 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2017m05 (
    CONSTRAINT npmrds_y2017m05_date_check CHECK (((date >= '2017-05-01'::date) AND (date < '2017-06-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m05 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m05 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m05 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2017m06 (
    CONSTRAINT npmrds_y2017m06_date_check CHECK (((date >= '2017-06-01'::date) AND (date < '2017-07-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m06 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m06 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m06 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2017m07 (
    CONSTRAINT npmrds_y2017m07_date_check CHECK (((date >= '2017-07-01'::date) AND (date < '2017-08-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m07 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m07 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m07 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2017m08 (
    CONSTRAINT npmrds_y2017m08_date_check CHECK (((date >= '2017-08-01'::date) AND (date < '2017-09-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m08 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m08 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m08 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2017m09 (
    CONSTRAINT npmrds_y2017m09_date_check CHECK (((date >= '2017-09-01'::date) AND (date < '2017-10-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m09 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m09 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m09 ALTER COLUMN epoch SET NOT NULL;


--
-- Name: npmrds_y2017m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE npmrds_y2017m10 (
    CONSTRAINT npmrds_y2017m10_date_check CHECK (((date >= '2017-10-01'::date) AND (date < '2017-11-01'::date)))
)
INHERITS (npmrds);
ALTER TABLE ONLY npmrds_y2017m10 ALTER COLUMN tmc SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m10 ALTER COLUMN date SET NOT NULL;
ALTER TABLE ONLY npmrds_y2017m10 ALTER COLUMN epoch SET NOT NULL;


SET search_path = public, pg_catalog;

--
-- Name: occupancy_factor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE occupancy_factor (
    state character varying(2),
    geography_level geography_level_type,
    geography_level_name character varying,
    occupancy_factor real
);


SET search_path = ny, pg_catalog;

--
-- Name: occupancy_factor; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE occupancy_factor (
    CONSTRAINT occupancy_factor_state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (public.occupancy_factor)
WITH (fillfactor='100');
ALTER TABLE ONLY occupancy_factor ALTER COLUMN geography_level SET NOT NULL;
ALTER TABLE ONLY occupancy_factor ALTER COLUMN geography_level_name SET NOT NULL;


--
-- Name: pm_bottlenecks; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE pm_bottlenecks (
    tmc character varying(9) NOT NULL,
    year smallint NOT NULL,
    month smallint NOT NULL,
    phed real NOT NULL,
    tttr real NOT NULL,
    lottr real NOT NULL
);


--
-- Name: pm_bottlenecks_summary; Type: MATERIALIZED VIEW; Schema: ny; Owner: -
--

CREATE MATERIALIZED VIEW pm_bottlenecks_summary AS
 SELECT pm.tmc,
    pm.year,
    pm.month,
    pm.phed,
    pm.tttr,
    pm.lottr,
    att.mpo_code AS mpo_id,
    row_number() OVER (PARTITION BY pm.year, pm.month ORDER BY pm.phed DESC) AS phedrank,
    row_number() OVER (PARTITION BY pm.year, pm.month ORDER BY pm.tttr DESC) AS tttrrank,
    row_number() OVER (PARTITION BY pm.year, pm.month ORDER BY pm.lottr DESC) AS lottrrank,
    row_number() OVER (PARTITION BY att.mpo_code, pm.year, pm.month ORDER BY pm.phed DESC) AS mpophedrank,
    row_number() OVER (PARTITION BY att.mpo_code, pm.year, pm.month ORDER BY pm.tttr DESC) AS mpotttrrank,
    row_number() OVER (PARTITION BY att.mpo_code, pm.year, pm.month ORDER BY pm.lottr DESC) AS mpolottrrank
   FROM (pm_bottlenecks pm
     JOIN public.tmc_attributes att USING (tmc))
  WITH NO DATA;


SET search_path = public, pg_catalog;

--
-- Name: region_to_county; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE region_to_county (
    region_id smallint,
    county character varying,
    state character varying(2)
)
WITH (fillfactor='100', autovacuum_enabled='false');


SET search_path = ny, pg_catalog;

--
-- Name: region_to_county; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE region_to_county (
    CONSTRAINT region_to_county_state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (public.region_to_county)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY region_to_county ALTER COLUMN county SET NOT NULL;
ALTER TABLE ONLY region_to_county ALTER COLUMN state SET NOT NULL;


SET search_path = public, pg_catalog;

--
-- Name: regions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE regions (
    id smallint,
    name character varying,
    state character varying(2)
)
WITH (fillfactor='100', autovacuum_enabled='false');


SET search_path = ny, pg_catalog;

--
-- Name: regions; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE regions (
    CONSTRAINT regions_state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (public.regions)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY regions ALTER COLUMN id SET NOT NULL;


--
-- Name: tmc_attributes; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tmc_attributes (
    tmc character varying NOT NULL,
    tmctype character varying,
    roadnumber character varying,
    roadname character varying,
    firstname character varying,
    tmclinear bigint,
    country character varying,
    statename character varying,
    county character varying,
    zip character varying,
    direction character varying,
    startlat double precision,
    startlong double precision,
    endlat double precision,
    endlong double precision,
    miles double precision,
    frc bigint,
    border_set character varying,
    f_system bigint,
    urban_code bigint,
    faciltype bigint,
    structype bigint,
    thrulanes bigint,
    route_numb bigint,
    route_sign bigint,
    route_qual bigint,
    altrtename character varying,
    aadt bigint,
    aadt_singl bigint,
    aadt_combi bigint,
    nhs bigint,
    nhs_pct bigint,
    strhnt_typ bigint,
    strhnt_pct bigint,
    truck bigint,
    admin_level_1 character varying,
    admin_level_2 character varying,
    admin_level_3 character varying,
    distance double precision,
    length double precision,
    road_number character varying,
    road_name character varying,
    latitude double precision,
    longitude double precision,
    road_direction text,
    occupancy_factor real,
    state character(2),
    is_interstate boolean,
    is_controlled_access boolean,
    avg_speedlimit real,
    cbsa_code character varying,
    cbsa_name character varying,
    mpo_code character varying,
    mpo_acrony character varying,
    mpo_name character varying,
    ua_code character varying,
    ua_name character varying,
    region_code smallint,
    region_name character varying,
    congestion_level public.traffic_dist_congestion_level_type,
    directionality public.traffic_dist_directionality_type,
    bounding_box public.box2d,
    CONSTRAINT tmc_attributes_state_check CHECK ((state = 'ny'::bpchar))
)
INHERITS (public.tmc_attributes)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: tmc_date_ranges; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tmc_date_ranges (
    tmc character varying(9) NOT NULL,
    first_date date,
    last_date date,
    state character(2) DEFAULT 'ny'::bpchar,
    CONSTRAINT tmc_date_ranges_state_check CHECK ((state = 'ny'::bpchar))
)
INHERITS (public.tmc_date_ranges);


--
-- Name: top_level_freight_reliability; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability (
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (public.top_level_freight_reliability);


--
-- Name: top_level_freight_reliability_y2015m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2015m00 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2015m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2015m01 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2015m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2015m02 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2015m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2015m03 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2015m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2015m04 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2015m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2015m05 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2015m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2015m06 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2015m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2015m07 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2015m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2015m08 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2015m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2015m09 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2015m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2015m10 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2015m11; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2015m11 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2015m12; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2015m12 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 12))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2016m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2016m00 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2016m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2016m01 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2016m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2016m02 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2016m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2016m03 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2016m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2016m04 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2016m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2016m05 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2016m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2016m06 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2016m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2016m07 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2016m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2016m08 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2016m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2016m09 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2016m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2016m10 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2016m11; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2016m11 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2016m12; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2016m12 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 12))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m00 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m01 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m02 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m03 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m04 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m05 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m06 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m07 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m08 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m09 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_freight_reliability_y2017m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_freight_reliability_y2017m10 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    tttr_quartiles real[],
    tttr_mean real,
    tttr_stddev real,
    fr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_freight_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay (
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (public.top_level_total_excessive_delay);


--
-- Name: top_level_total_excessive_delay_y2015m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2015m00 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2015m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2015m01 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2015m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2015m02 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2015m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2015m03 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2015m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2015m04 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2015m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2015m05 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2015m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2015m06 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2015m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2015m07 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2015m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2015m08 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2015m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2015m09 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2015m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2015m10 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2015m11; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2015m11 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2015m12; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2015m12 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 12))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2016m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2016m00 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2016m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2016m01 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2016m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2016m02 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2016m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2016m03 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2016m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2016m04 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2016m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2016m05 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2016m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2016m06 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2016m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2016m07 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2016m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2016m08 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2016m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2016m09 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2016m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2016m10 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2016m11; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2016m11 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2016m12; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2016m12 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 12))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m00 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m01 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m02 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m03 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m04 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m05 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m06 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m07 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m08 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m09 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_total_excessive_delay_y2017m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_total_excessive_delay_y2017m10 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    am_peak_total_xdelay_hrs double precision,
    pm1_peak_total_xdelay_hrs double precision,
    pm2_peak_total_xdelay_hrs double precision,
    included_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    summary_stats_by_phed_period jsonb,
    population_info jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_total_excessive_delay)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability (
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (public.top_level_travel_time_reliability);


--
-- Name: top_level_travel_time_reliability_y2015m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2015m00 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2015m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2015m01 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2015m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2015m02 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2015m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2015m03 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2015m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2015m04 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2015m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2015m05 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2015m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2015m06 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2015m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2015m07 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2015m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2015m08 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2015m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2015m09 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2015m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2015m10 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2015m11; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2015m11 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2015m12; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2015m12 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 12))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2016m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2016m00 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2016m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2016m01 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2016m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2016m02 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2016m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2016m03 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2016m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2016m04 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2016m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2016m05 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2016m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2016m06 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2016m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2016m07 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2016m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2016m08 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2016m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2016m09 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2016m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2016m10 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2016m11; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2016m11 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2016m12; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2016m12 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 12))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m00 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m01 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m02 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m03 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m04 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m05 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m06 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m07 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m08 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m09 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: top_level_travel_time_reliability_y2017m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE top_level_travel_time_reliability_y2017m10 (
    state character varying(2),
    year smallint,
    month smallint,
    geography_level public.geography_level_type NOT NULL,
    geography_name character varying NOT NULL,
    functional_class public.functional_class_type NOT NULL,
    included_mi real,
    passing_mi real,
    excluded_mi real,
    included_tmcs_ct integer,
    excluded_tmcs_ct integer,
    lottr_quartiles real[],
    lottr_mean real,
    lottr_stddev real,
    ttr real,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (top_level_travel_time_reliability)
WITH (fillfactor='100');


--
-- Name: transcom_events_by_tmc; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE transcom_events_by_tmc (
    tmc character(9),
    event_type character varying,
    event_id character varying,
    open_time timestamp without time zone,
    close_time timestamp without time zone,
    point text,
    coordinates public.geometry,
    description character varying,
    state text,
    CONSTRAINT tmc_transcom_events_state_check CHECK ((state = 'ny'::text))
)
WITH (fillfactor='100');


--
-- Name: tttr_percentiles; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles (
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (public.tttr_percentiles);


--
-- Name: tttr_percentiles_y2015m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2015m00 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2015m00 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2015m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2015m01 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2015m01 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2015m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2015m02 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2015m02 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2015m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2015m03 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2015m03 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2015m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2015m04 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2015m04 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2015m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2015m05 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2015m05 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2015m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2015m06 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2015m06 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2015m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2015m07 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2015m07 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2015m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2015m08 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2015m08 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2015m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2015m09 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2015m09 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2015m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2015m10 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2015m10 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2015m11; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2015m11 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2015m11 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2015m12; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2015m12 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2015) AND (month = 12))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2015m12 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2016m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2016m00 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2016m00 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2016m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2016m01 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2016m01 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2016m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2016m02 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2016m02 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2016m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2016m03 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2016m03 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2016m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2016m04 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2016m04 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2016m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2016m05 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2016m05 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2016m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2016m06 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2016m06 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2016m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2016m07 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2016m07 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2016m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2016m08 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2016m08 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2016m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2016m09 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2016m09 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2016m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2016m10 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2016m10 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2016m11; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2016m11 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 11))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2016m11 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2016m12; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2016m12 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2016) AND (month = 12))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2016m12 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m00; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m00 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 0))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m00 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m01; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m01 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 1))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m01 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m02; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m02 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 2))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m02 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m03; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m03 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 3))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m03 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m04; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m04 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 4))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m04 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m05; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m05 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 5))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m05 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m06; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m06 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 6))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m06 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m07; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m07 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 7))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m07 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m08; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m08 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 8))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m08 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m09; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m09 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 9))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m09 ALTER COLUMN data SET STATISTICS 0;


--
-- Name: tttr_percentiles_y2017m10; Type: TABLE; Schema: ny; Owner: -
--

CREATE TABLE tttr_percentiles_y2017m10 (
    state character varying(2),
    tmc character varying(9) NOT NULL,
    year smallint,
    month smallint,
    data jsonb,
    CONSTRAINT date_range CHECK (((year = 2017) AND (month = 10))),
    CONSTRAINT state_check CHECK (((state)::text = 'ny'::text))
)
INHERITS (tttr_percentiles)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY tttr_percentiles_y2017m10 ALTER COLUMN data SET STATISTICS 0;


SET search_path = public, pg_catalog;

--
-- Name: SMTC_MPA_2013; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "SMTC_MPA_2013" (
    id integer NOT NULL,
    geom geometry(MultiPolygon,26918),
    mpo character varying(10),
    sqmiles double precision
);


--
-- Name: SMTC_MPA_2013_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "SMTC_MPA_2013_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: SMTC_MPA_2013_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "SMTC_MPA_2013_id_seq" OWNED BY "SMTC_MPA_2013".id;


--
-- Name: collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE collection (
    state character(2),
    name text,
    type text,
    owner text,
    length real,
    colltype text,
    "amPeakStart" integer,
    "amPeakEnd" integer,
    "pmPeakStart" integer,
    "pmPeakEnd" integer,
    points jsonb,
    "tmcArray" jsonb,
    id integer NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


--
-- Name: collection_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE collection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE collection_id_seq OWNED BY collection.id;


--
-- Name: core_based_statistical_area_boundaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE core_based_statistical_area_boundaries (
    ogc_fid integer NOT NULL,
    wkb_geometry geometry(MultiPolygon,4326),
    csafp character varying,
    geoid character varying,
    name character varying,
    namelsad character varying,
    lsad character varying,
    mtfcc character varying,
    aland double precision,
    awater double precision,
    intptlat character varying,
    intptlon character varying
)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: county_populations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE county_populations (
    state_code character varying(2),
    county_code character varying(3),
    population bigint,
    year smallint
)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: federal_holidays; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE federal_holidays (
    date date
);


--
-- Name: fips_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE fips_codes (
    state character varying(2),
    state_code character varying(2) NOT NULL,
    county_code character varying(3) NOT NULL,
    county character varying
)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: mpo_boundaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE mpo_boundaries (
    ogc_fid integer NOT NULL,
    wkb_geometry geometry(MultiPolygon,4326),
    area double precision,
    mpo_id character varying,
    mpo_name character varying,
    state character varying
)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: state_codes; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW state_codes AS
 SELECT DISTINCT fips_codes.state,
    fips_codes.state_code
   FROM fips_codes;


--
-- Name: state_populations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE state_populations (
    state_code character varying(2),
    population bigint,
    year smallint
)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: urban_area_boundaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE urban_area_boundaries (
    ogc_fid integer NOT NULL,
    wkb_geometry geometry(MultiPolygon,4326),
    uace10 character varying,
    geoid10 character varying,
    name10 character varying,
    namelsad10 character varying,
    lsad10 character varying,
    mtfcc10 character varying,
    uatyp10 character varying,
    funcstat10 character varying,
    aland10 double precision,
    awater10 double precision,
    intptlat10 character varying,
    intptlon10 character varying
)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: urban_area_populations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE urban_area_populations (
    ua_code character varying,
    population bigint,
    year smallint
)
WITH (fillfactor='100', autovacuum_enabled='false');


--
-- Name: geography_level_attributes_view; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW geography_level_attributes_view AS
 WITH cte_mpo_to_ua_intersection_areas AS (
         SELECT m.mpo_id,
            u.geoid10 AS ua_id,
            u.name10 AS ua_name,
            st_area(st_intersection(m.wkb_geometry, u.wkb_geometry)) AS intersection_area
           FROM (mpo_boundaries m
             JOIN urban_area_boundaries u ON (st_intersects(m.wkb_geometry, u.wkb_geometry)))
          WHERE ((m.state)::text = 'NY'::text)
        ), cte_max_intersection_area AS (
         SELECT cte_mpo_to_ua_intersection_areas.mpo_id,
            max(cte_mpo_to_ua_intersection_areas.intersection_area) AS max_intersection_area
           FROM cte_mpo_to_ua_intersection_areas
          GROUP BY cte_mpo_to_ua_intersection_areas.mpo_id
        ), cte_mpo_2_ua AS (
         SELECT a.mpo_id,
            a.ua_id,
            a.ua_name
           FROM (cte_mpo_to_ua_intersection_areas a
             JOIN cte_max_intersection_area m ON ((((a.mpo_id)::text = (m.mpo_id)::text) AND (a.intersection_area = m.max_intersection_area))))
          ORDER BY a.mpo_id
        ), cte_county_populations AS (
         SELECT fips_codes.state,
            fips_codes.county,
            county_populations.population,
            county_populations.year
           FROM (county_populations
             JOIN fips_codes USING (state_code, county_code))
        )
 SELECT 'MPO'::geography_level_type AS geography_level,
    geography_level_name,
    t1.interstate_miles,
    t1.interstate_tmcs_ct,
    t2.noninterstate_miles,
    t2.noninterstate_tmcs_ct,
    t3.bounding_box,
    t4.population_info,
    state
   FROM (((( SELECT tmc_attributes.mpo_acrony AS geography_level_name,
            sum(tmc_attributes.miles) AS interstate_miles,
            count(tmc_attributes.tmc) AS interstate_tmcs_ct,
            tmc_attributes.state
           FROM tmc_attributes
          WHERE ((tmc_attributes.is_interstate = true) AND (tmc_attributes.mpo_acrony IS NOT NULL))
          GROUP BY tmc_attributes.mpo_acrony, tmc_attributes.state) t1
     FULL JOIN ( SELECT tmc_attributes.mpo_acrony AS geography_level_name,
            sum(tmc_attributes.miles) AS noninterstate_miles,
            count(tmc_attributes.tmc) AS noninterstate_tmcs_ct,
            tmc_attributes.state
           FROM tmc_attributes
          WHERE (((tmc_attributes.is_interstate = false) OR (tmc_attributes.is_interstate IS NULL)) AND (tmc_attributes.mpo_acrony IS NOT NULL))
          GROUP BY tmc_attributes.mpo_acrony, tmc_attributes.state) t2 USING (geography_level_name, state))
     FULL JOIN ( SELECT tmc_attributes.mpo_code,
            tmc_attributes.mpo_acrony AS geography_level_name,
            st_extent(inrix_shapefile.wkb_geometry) AS bounding_box,
            tmc_attributes.state
           FROM (inrix_shapefile
             JOIN tmc_attributes USING (tmc))
          GROUP BY tmc_attributes.mpo_code, tmc_attributes.mpo_acrony, tmc_attributes.state) t3 USING (geography_level_name, state))
     FULL JOIN ( SELECT cte_mpo_2_ua.mpo_id AS mpo_code,
            jsonb_object_agg(urban_area_populations.year, jsonb_build_array(jsonb_build_object('geography_level', 'URBAN_AREA', 'geography_name', cte_mpo_2_ua.ua_name, 'total', urban_area_populations.population))) AS population_info
           FROM (cte_mpo_2_ua
             JOIN urban_area_populations ON (((cte_mpo_2_ua.ua_id)::text = (urban_area_populations.ua_code)::text)))
          GROUP BY cte_mpo_2_ua.mpo_id, cte_mpo_2_ua.ua_name) t4 USING (mpo_code))
UNION ALL
 SELECT 'COUNTY'::geography_level_type AS geography_level,
    geography_level_name,
    t1.interstate_miles,
    t1.interstate_tmcs_ct,
    t2.noninterstate_miles,
    t2.noninterstate_tmcs_ct,
    t3.bounding_box,
    t4.population_info,
    state
   FROM (((( SELECT tmc_attributes.county AS geography_level_name,
            sum(tmc_attributes.miles) AS interstate_miles,
            count(tmc_attributes.tmc) AS interstate_tmcs_ct,
            tmc_attributes.state
           FROM tmc_attributes
          WHERE ((tmc_attributes.is_interstate = true) AND (tmc_attributes.county IS NOT NULL))
          GROUP BY tmc_attributes.county, tmc_attributes.state) t1
     FULL JOIN ( SELECT tmc_attributes.county AS geography_level_name,
            sum(tmc_attributes.miles) AS noninterstate_miles,
            count(tmc_attributes.tmc) AS noninterstate_tmcs_ct,
            tmc_attributes.state
           FROM tmc_attributes
          WHERE (((tmc_attributes.is_interstate = false) OR (tmc_attributes.is_interstate IS NULL)) AND (tmc_attributes.county IS NOT NULL))
          GROUP BY tmc_attributes.county, tmc_attributes.state) t2 USING (geography_level_name, state))
     FULL JOIN ( SELECT tmc_attributes.county AS geography_level_name,
            st_extent(inrix_shapefile.wkb_geometry) AS bounding_box,
            tmc_attributes.state
           FROM (inrix_shapefile
             JOIN tmc_attributes USING (tmc))
          GROUP BY tmc_attributes.county, tmc_attributes.state) t3 USING (geography_level_name, state))
     FULL JOIN ( SELECT cte_county_populations.county AS geography_level_name,
            cte_county_populations.state,
            jsonb_object_agg(cte_county_populations.year, jsonb_build_array(jsonb_build_object('total', cte_county_populations.population))) AS population_info
           FROM cte_county_populations
          GROUP BY cte_county_populations.county, cte_county_populations.state) t4 USING (geography_level_name, state))
UNION ALL
 SELECT 'CBSA'::geography_level_type AS geography_level,
    geography_level_name,
    t1.interstate_miles,
    t1.interstate_tmcs_ct,
    t2.noninterstate_miles,
    t2.noninterstate_tmcs_ct,
    t3.bounding_box,
    NULL::jsonb AS population_info,
    state
   FROM ((( SELECT tmc_attributes.cbsa_name AS geography_level_name,
            sum(tmc_attributes.miles) AS interstate_miles,
            count(tmc_attributes.tmc) AS interstate_tmcs_ct,
            tmc_attributes.state
           FROM tmc_attributes
          WHERE ((tmc_attributes.is_interstate = true) AND (tmc_attributes.cbsa_name IS NOT NULL))
          GROUP BY tmc_attributes.cbsa_name, tmc_attributes.state) t1
     FULL JOIN ( SELECT tmc_attributes.cbsa_name AS geography_level_name,
            sum(tmc_attributes.miles) AS noninterstate_miles,
            count(tmc_attributes.tmc) AS noninterstate_tmcs_ct,
            tmc_attributes.state
           FROM tmc_attributes
          WHERE (((tmc_attributes.is_interstate = false) OR (tmc_attributes.is_interstate IS NULL)) AND (tmc_attributes.cbsa_name IS NOT NULL))
          GROUP BY tmc_attributes.cbsa_name, tmc_attributes.state) t2 USING (geography_level_name, state))
     FULL JOIN ( SELECT tmc_attributes.cbsa_name AS geography_level_name,
            st_extent(inrix_shapefile.wkb_geometry) AS bounding_box,
            tmc_attributes.state
           FROM (inrix_shapefile
             JOIN tmc_attributes USING (tmc))
          GROUP BY tmc_attributes.cbsa_name, tmc_attributes.state) t3 USING (geography_level_name, state))
UNION ALL
 SELECT 'UA'::geography_level_type AS geography_level,
    geography_level_name,
    t1.interstate_miles,
    t1.interstate_tmcs_ct,
    t2.noninterstate_miles,
    t2.noninterstate_tmcs_ct,
    t3.bounding_box,
    t4.population_info,
    state
   FROM (((( SELECT tmc_attributes.ua_name AS geography_level_name,
            sum(tmc_attributes.miles) AS interstate_miles,
            count(tmc_attributes.tmc) AS interstate_tmcs_ct,
            tmc_attributes.state
           FROM tmc_attributes
          WHERE ((tmc_attributes.is_interstate = true) AND (tmc_attributes.ua_name IS NOT NULL))
          GROUP BY tmc_attributes.ua_name, tmc_attributes.state) t1
     FULL JOIN ( SELECT tmc_attributes.ua_name AS geography_level_name,
            sum(tmc_attributes.miles) AS noninterstate_miles,
            count(tmc_attributes.tmc) AS noninterstate_tmcs_ct,
            tmc_attributes.state
           FROM tmc_attributes
          WHERE (((tmc_attributes.is_interstate = false) OR (tmc_attributes.is_interstate IS NULL)) AND (tmc_attributes.ua_name IS NOT NULL))
          GROUP BY tmc_attributes.ua_name, tmc_attributes.state) t2 USING (geography_level_name, state))
     FULL JOIN ( SELECT tmc_attributes.ua_code,
            tmc_attributes.ua_name AS geography_level_name,
            st_extent(inrix_shapefile.wkb_geometry) AS bounding_box,
            tmc_attributes.state
           FROM (inrix_shapefile
             JOIN tmc_attributes USING (tmc))
          GROUP BY tmc_attributes.ua_code, tmc_attributes.ua_name, tmc_attributes.state) t3 USING (geography_level_name, state))
     FULL JOIN ( SELECT urban_area_populations.ua_code,
            jsonb_object_agg(urban_area_populations.year, jsonb_build_array(jsonb_build_object('total', urban_area_populations.population))) AS population_info
           FROM urban_area_populations
          GROUP BY urban_area_populations.ua_code) t4 USING (ua_code))
UNION ALL
 SELECT 'REGION'::geography_level_type AS geography_level,
    geography_level_name,
    t1.interstate_miles,
    t1.interstate_tmcs_ct,
    t2.noninterstate_miles,
    t2.noninterstate_tmcs_ct,
    t3.bounding_box,
    t4.population_info,
    state
   FROM (((( SELECT (tmc_attributes.region_code)::character varying AS geography_level_name,
            sum(tmc_attributes.miles) AS interstate_miles,
            count(tmc_attributes.tmc) AS interstate_tmcs_ct,
            tmc_attributes.state
           FROM tmc_attributes
          WHERE ((tmc_attributes.is_interstate = true) AND (tmc_attributes.region_code IS NOT NULL))
          GROUP BY tmc_attributes.region_code, tmc_attributes.state) t1
     FULL JOIN ( SELECT (tmc_attributes.region_code)::character varying AS geography_level_name,
            sum(tmc_attributes.miles) AS noninterstate_miles,
            count(tmc_attributes.tmc) AS noninterstate_tmcs_ct,
            tmc_attributes.state
           FROM tmc_attributes
          WHERE (((tmc_attributes.is_interstate = false) OR (tmc_attributes.is_interstate IS NULL)) AND (tmc_attributes.region_code IS NOT NULL))
          GROUP BY tmc_attributes.region_code, tmc_attributes.state) t2 USING (geography_level_name, state))
     FULL JOIN ( SELECT (tmc_attributes.region_code)::character varying AS geography_level_name,
            st_extent(inrix_shapefile.wkb_geometry) AS bounding_box,
            tmc_attributes.state
           FROM (inrix_shapefile
             JOIN tmc_attributes USING (tmc))
          GROUP BY (tmc_attributes.region_code)::character varying, tmc_attributes.state) t3 USING (geography_level_name, state))
     FULL JOIN ( SELECT (sub_region_populations.region_id)::character varying AS geography_level_name,
            sub_region_populations.state,
            jsonb_object_agg(sub_region_populations.year, jsonb_build_array(jsonb_build_object('total', sub_region_populations.population))) AS population_info
           FROM ( SELECT region_to_county.region_id,
                    region_to_county.state,
                    cte_county_populations.year,
                    sum(cte_county_populations.population) AS population
                   FROM (region_to_county
                     JOIN cte_county_populations USING (state, county))
                  GROUP BY region_to_county.region_id, region_to_county.state, cte_county_populations.year) sub_region_populations
          GROUP BY (sub_region_populations.region_id)::character varying, sub_region_populations.state) t4 USING (geography_level_name, state))
UNION ALL
 SELECT 'STATE'::geography_level_type AS geography_level,
    geography_level_name,
    t1.interstate_miles,
    t1.interstate_tmcs_ct,
    t2.noninterstate_miles,
    t2.noninterstate_tmcs_ct,
    t3.bounding_box,
    t4.population_info,
    state
   FROM (((( SELECT tmc_attributes.state AS geography_level_name,
            sum(tmc_attributes.miles) AS interstate_miles,
            count(tmc_attributes.tmc) AS interstate_tmcs_ct,
            tmc_attributes.state
           FROM tmc_attributes
          WHERE ((tmc_attributes.is_interstate = true) AND (tmc_attributes.state IS NOT NULL))
          GROUP BY tmc_attributes.state) t1
     FULL JOIN ( SELECT tmc_attributes.state AS geography_level_name,
            sum(tmc_attributes.miles) AS noninterstate_miles,
            count(tmc_attributes.tmc) AS noninterstate_tmcs_ct,
            tmc_attributes.state
           FROM tmc_attributes
          WHERE (((tmc_attributes.is_interstate = false) OR (tmc_attributes.is_interstate IS NULL)) AND (tmc_attributes.state IS NOT NULL))
          GROUP BY tmc_attributes.state) t2 USING (geography_level_name, state))
     FULL JOIN ( SELECT tmc_attributes.state AS geography_level_name,
            st_extent(inrix_shapefile.wkb_geometry) AS bounding_box,
            tmc_attributes.state
           FROM (inrix_shapefile
             JOIN tmc_attributes USING (tmc))
          GROUP BY tmc_attributes.state) t3 USING (geography_level_name, state))
     FULL JOIN ( SELECT state_codes.state AS geography_level_name,
            jsonb_object_agg(state_populations.year, jsonb_build_array(jsonb_build_object('total', state_populations.population))) AS population_info
           FROM (state_populations
             JOIN state_codes USING (state_code))
          GROUP BY state_codes.state) t4 USING (geography_level_name))
  WITH NO DATA;


--
-- Name: here_to_inrix; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE here_to_inrix (
    here character varying(254),
    inrix character varying
);


--
-- Name: inrix_atri_measure_materialized; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE inrix_atri_measure_materialized (
    tmc character varying(9) NOT NULL,
    year integer NOT NULL,
    month integer NOT NULL,
    epochs integer[],
    totals double precision[],
    singls double precision[],
    combis double precision[],
    passs double precision[]
);


--
-- Name: inrix_atri_measure_summary; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW inrix_atri_measure_summary AS
 WITH totals AS (
         SELECT i_1.tmc,
            i_1.year,
            i_1.month,
            ( SELECT sum(s.s) AS sum
                   FROM unnest(i_1.totals) s(s)) AS total,
            ( SELECT sum(s.s) AS sum
                   FROM unnest(i_1.singls) s(s)) AS singl,
            ( SELECT sum(s.s) AS sum
                   FROM unnest(i_1.combis) s(s)) AS combi,
            (( SELECT sum(s.s) AS sum
                   FROM unnest(i_1.singls) s(s)) + ( SELECT sum(s.s) AS sum
                   FROM unnest(i_1.combis) s(s))) AS truck,
            ( SELECT sum(s.s) AS sum
                   FROM unnest(i_1.passs) s(s)) AS pass
           FROM inrix_atri_measure_materialized i_1
        )
 SELECT i.tmc,
    i.year,
    i.month,
    i.total,
    i.singl,
    i.combi,
    i.pass,
    rank() OVER (PARTITION BY i.month, i.year ORDER BY i.total) AS totalrank,
    rank() OVER (PARTITION BY i.month, i.year ORDER BY i.singl) AS singlrank,
    rank() OVER (PARTITION BY i.month, i.year ORDER BY i.combi) AS combirank,
    rank() OVER (PARTITION BY i.month, i.year ORDER BY i.pass) AS passrank,
    rank() OVER (PARTITION BY i.month, i.year ORDER BY i.truck) AS truckrank,
    rank() OVER (PARTITION BY i.month, i.year, ttm.mpo_code ORDER BY i.total) AS mpototalrank,
    rank() OVER (PARTITION BY i.month, i.year, ttm.mpo_code ORDER BY i.singl) AS mposinglrank,
    rank() OVER (PARTITION BY i.month, i.year, ttm.mpo_code ORDER BY i.combi) AS mpocombirank,
    rank() OVER (PARTITION BY i.month, i.year, ttm.mpo_code ORDER BY i.pass) AS mpopassrank,
    rank() OVER (PARTITION BY i.month, i.year, ttm.mpo_code ORDER BY i.truck) AS mpotruckrank,
    ttm.mpo_code AS mpo_id
   FROM (totals i
     LEFT JOIN tmp_tmc_to_mpo ttm USING (tmc))
  WITH NO DATA;


--
-- Name: inrix_tmc_traffic_distribution_factors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE inrix_tmc_traffic_distribution_factors (
    tmc character varying(10),
    avg_free_flow_travel_time real,
    avg_peak_period_travel_time real,
    speed_reduction_factor real,
    functional_class traffic_dist_functional_class_type,
    avg_free_flow_speed_mph real,
    avg_peak_period_speed_mph real,
    avg_am_peak_travel_time real,
    avg_pm_peak_travel_time real,
    avg_am_peak_speed_mph real,
    avg_pm_peak_speed_mph real,
    congestion_level traffic_dist_congestion_level_type,
    directionality traffic_dist_directionality_type,
    month integer,
    year integer
);


SET search_path = us, pg_catalog;

--
-- Name: mpo_acronyms; Type: TABLE; Schema: us; Owner: -
--

CREATE TABLE mpo_acronyms (
    mpo_id character varying NOT NULL,
    mpo_acrony character varying
);


SET search_path = public, pg_catalog;

--
-- Name: mpo_boundaries_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW mpo_boundaries_view AS
 SELECT mpo_boundaries.mpo_id,
    mpo_boundaries.ogc_fid,
    mpo_boundaries.wkb_geometry,
    mpo_boundaries.area,
    mpo_boundaries.mpo_name,
    mpo_boundaries.state,
    mpo_acronyms.mpo_acrony
   FROM (mpo_boundaries
     LEFT JOIN us.mpo_acronyms USING (mpo_id));


--
-- Name: network; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE network (
    state character(2),
    name text,
    type text,
    owner text,
    "tmcArray" jsonb,
    id integer NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    origin_tmc text,
    filters jsonb,
    hierarchy jsonb,
    "amPeakStart" integer,
    "amPeakEnd" integer,
    "pmPeakStart" integer,
    "pmPeakEnd" integer,
    routes jsonb,
    edges jsonb
);


--
-- Name: network_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE network_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: network_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE network_id_seq OWNED BY network.id;


--
-- Name: nj inrix_shapefile_20170707; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "nj inrix_shapefile_20170707" (
    ogc_fid integer NOT NULL,
    wkb_geometry geometry(MultiLineString,4326),
    tmc character varying,
    tmctype character varying,
    roadnumber character varying,
    roadname character varying,
    firstname character varying,
    tmclinear integer,
    country character varying,
    state character varying,
    county character varying,
    zip character varying,
    direction character varying,
    startlat double precision,
    startlong double precision,
    endlat double precision,
    endlong double precision,
    miles double precision,
    frc integer,
    border_set character varying,
    f_system integer,
    urban_code integer,
    faciltype integer,
    structype integer,
    thrulanes integer,
    route_numb integer,
    route_sign integer,
    route_qual integer,
    altrtename character varying,
    aadt integer,
    aadt_singl integer,
    aadt_combi integer,
    nhs integer,
    nhs_pct integer,
    strhnt_typ integer,
    strhnt_pct integer,
    truck integer
);


--
-- Name: nj inrix_shapefile_20170707_ogc_fid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "nj inrix_shapefile_20170707_ogc_fid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nj inrix_shapefile_20170707_ogc_fid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "nj inrix_shapefile_20170707_ogc_fid_seq" OWNED BY "nj inrix_shapefile_20170707".ogc_fid;


--
-- Name: route_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE route_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: route; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE route (
    state character(2),
    name text,
    type text,
    owner text,
    length real,
    "amPeakStart" integer,
    "amPeakEnd" integer,
    "pmPeakStart" integer,
    "pmPeakEnd" integer,
    points jsonb,
    "tmcArray" jsonb,
    id integer DEFAULT nextval('route_id_seq'::regclass) NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    heretmcarray jsonb
);


--
-- Name: state_abbreviations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE state_abbreviations (
    state_name character varying(20) NOT NULL,
    abbreviation character(2)
)
WITH (fillfactor='100');


--
-- Name: tmc_children; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tmc_children (
    base character varying,
    child character varying,
    startp geometry
);


--
-- Name: tmc_routable; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tmc_routable (
    tmc character varying,
    the_geom geometry,
    id integer NOT NULL,
    source integer,
    target integer,
    cost double precision
);


--
-- Name: tmc_routable_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tmc_routable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tmc_routable_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tmc_routable_id_seq OWNED BY tmc_routable.id;


--
-- Name: tmc_routable_vertices_pgr; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tmc_routable_vertices_pgr (
    id bigint NOT NULL,
    cnt integer,
    chk integer,
    ein integer,
    eout integer,
    the_geom geometry(Point,4326)
);


--
-- Name: tmc_routable_vertices_pgr_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tmc_routable_vertices_pgr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tmc_routable_vertices_pgr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tmc_routable_vertices_pgr_id_seq OWNED BY tmc_routable_vertices_pgr.id;


--
-- Name: tmc_touching_terminals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tmc_touching_terminals (
    tmc character varying,
    dalong double precision
);


--
-- Name: tmcs_with_unknown_speedlimits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tmcs_with_unknown_speedlimits (
    tmc character varying,
    tmctype character varying,
    roadnumber character varying,
    roadname character varying,
    firstname character varying,
    tmclinear bigint,
    country character varying,
    statename character varying,
    county character varying,
    zip character varying,
    direction character varying,
    startlat double precision,
    startlong double precision,
    endlat double precision,
    endlong double precision,
    miles double precision,
    frc bigint,
    border_set character varying,
    f_system bigint,
    urban_code bigint,
    faciltype bigint,
    structype bigint,
    thrulanes bigint,
    route_numb bigint,
    route_sign bigint,
    route_qual bigint,
    altrtename character varying,
    aadt bigint,
    aadt_singl bigint,
    aadt_combi bigint,
    nhs bigint,
    nhs_pct bigint,
    strhnt_typ bigint,
    strhnt_pct bigint,
    truck bigint,
    admin_level_1 character varying,
    admin_level_2 character varying,
    admin_level_3 character varying,
    distance double precision,
    length double precision,
    road_number character varying,
    road_name character varying,
    latitude double precision,
    longitude double precision,
    road_direction text,
    occupancy_factor real,
    state character(2),
    is_interstate boolean,
    is_controlled_access boolean,
    avg_speedlimit real,
    cbsa_code character varying,
    cbsa_name character varying,
    mpo_code character varying,
    mpo_acrony character varying,
    mpo_name character varying,
    ua_code character varying,
    ua_name character varying,
    region_code smallint,
    region_name character varying,
    congestion_level traffic_dist_congestion_level_type,
    directionality traffic_dist_directionality_type,
    bounding_box box2d,
    wkb_geometry geometry(MultiLineString,4326)
);


--
-- Name: tmp_hourly_traffic_volumes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tmp_hourly_traffic_volumes (
    day_type traffic_dist_day_type,
    congestion_level traffic_dist_congestion_level_type,
    directionality traffic_dist_directionality_type,
    functional_class traffic_dist_functional_class_type,
    hour smallint,
    pct_daily_vol real
);


--
-- Name: tmp_tmc_to_cbsa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tmp_tmc_to_cbsa (
    tmc character varying,
    cbsa_code character varying
);


--
-- Name: tmp_transcom_events_buffered; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tmp_transcom_events_buffered (
    event_id character varying,
    buffered_geog geometry
);


--
-- Name: tmp_transcom_tmc; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tmp_transcom_tmc (
    event_id character varying,
    tmc character varying
);


--
-- Name: traffic_distributions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE traffic_distributions (
    day_type traffic_dist_day_type,
    congestion_level traffic_dist_congestion_level_type,
    directionality traffic_dist_directionality_type,
    functional_class traffic_dist_functional_class_type,
    epoch smallint,
    percent_daily_volume real
)
WITH (fillfactor='100');


--
-- Name: traffic_signals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE traffic_signals (
    id integer NOT NULL,
    geom geometry(Point,4326),
    "Signal Number" character varying,
    "Record ID" character varying,
    "Location Description" character varying,
    "Municipality" character varying,
    "Main Route Number" character varying,
    "Longitude" double precision,
    "Latitude" double precision
);


--
-- Name: traffic_signals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE traffic_signals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: traffic_signals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE traffic_signals_id_seq OWNED BY traffic_signals.id;


--
-- Name: transcom_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE transcom_events (
    event_id character varying NOT NULL,
    event_type character varying,
    facility character varying,
    creation timestamp without time zone,
    open_time timestamp without time zone,
    close_time timestamp without time zone,
    duration character varying,
    description character varying,
    from_city character varying,
    from_count character varying,
    to_city character varying,
    state character varying,
    from_mile_marker double precision,
    to_mile_marker double precision,
    latitude double precision,
    longitude double precision,
    event_category character varying,
    point_geom geometry,
    tmc character varying
);


SET search_path = us, pg_catalog;

--
-- Name: core_based_staticstical_area_boundaries_2016; Type: TABLE; Schema: us; Owner: -
--

CREATE TABLE core_based_staticstical_area_boundaries_2016 (
    ogc_fid integer NOT NULL,
    csafp character varying,
    geoid character varying,
    name character varying,
    namelsad character varying,
    lsad character varying,
    mtfcc character varying,
    aland bigint,
    awater bigint,
    intptlat character varying,
    intptlon character varying,
    wkb_geometry public.geometry(MultiPolygon,4326)
);


--
-- Name: core_based_staticstical_area_boundaries_2016_ogc_fid_seq; Type: SEQUENCE; Schema: us; Owner: -
--

CREATE SEQUENCE core_based_staticstical_area_boundaries_2016_ogc_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: core_based_staticstical_area_boundaries_2016_ogc_fid_seq; Type: SEQUENCE OWNED BY; Schema: us; Owner: -
--

ALTER SEQUENCE core_based_staticstical_area_boundaries_2016_ogc_fid_seq OWNED BY core_based_staticstical_area_boundaries_2016.ogc_fid;


--
-- Name: core_based_statistical_area_boundaries_2017; Type: TABLE; Schema: us; Owner: -
--

CREATE TABLE core_based_statistical_area_boundaries_2017 (
    ogc_fid integer,
    wkb_geometry public.geometry(MultiPolygon,4326),
    csafp character varying,
    geoid character varying,
    name character varying,
    namelsad character varying,
    lsad character varying,
    mtfcc character varying,
    aland double precision,
    awater double precision,
    intptlat character varying,
    intptlon character varying
)
INHERITS (public.core_based_statistical_area_boundaries);


--
-- Name: core_based_statistical_area_boundaries_2017_ogc_fid_seq; Type: SEQUENCE; Schema: us; Owner: -
--

CREATE SEQUENCE core_based_statistical_area_boundaries_2017_ogc_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: core_based_statistical_area_boundaries_2017_ogc_fid_seq; Type: SEQUENCE OWNED BY; Schema: us; Owner: -
--

ALTER SEQUENCE core_based_statistical_area_boundaries_2017_ogc_fid_seq OWNED BY core_based_statistical_area_boundaries_2017.ogc_fid;


--
-- Name: county_populations_y2015; Type: TABLE; Schema: us; Owner: -
--

CREATE TABLE county_populations_y2015 (
    CONSTRAINT county_populations_year_chk CHECK ((year = 2015))
)
INHERITS (public.county_populations)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY county_populations_y2015 ALTER COLUMN state_code SET NOT NULL;
ALTER TABLE ONLY county_populations_y2015 ALTER COLUMN county_code SET NOT NULL;


--
-- Name: county_populations_y2016; Type: TABLE; Schema: us; Owner: -
--

CREATE TABLE county_populations_y2016 (
    CONSTRAINT county_populations_year_chk CHECK ((year = 2016))
)
INHERITS (public.county_populations)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY county_populations_y2016 ALTER COLUMN state_code SET NOT NULL;
ALTER TABLE ONLY county_populations_y2016 ALTER COLUMN county_code SET NOT NULL;


--
-- Name: mpo_boundaries_20170928; Type: TABLE; Schema: us; Owner: -
--

CREATE TABLE mpo_boundaries_20170928 (
    ogc_fid integer,
    wkb_geometry public.geometry(MultiPolygon,4326),
    area double precision,
    mpo_id character varying,
    mpo_name character varying,
    state character varying
)
INHERITS (public.mpo_boundaries);


--
-- Name: mpo_boundaries_20170928_ogc_fid_seq; Type: SEQUENCE; Schema: us; Owner: -
--

CREATE SEQUENCE mpo_boundaries_20170928_ogc_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mpo_boundaries_20170928_ogc_fid_seq; Type: SEQUENCE OWNED BY; Schema: us; Owner: -
--

ALTER SEQUENCE mpo_boundaries_20170928_ogc_fid_seq OWNED BY mpo_boundaries_20170928.ogc_fid;


--
-- Name: state_populations_y2015; Type: TABLE; Schema: us; Owner: -
--

CREATE TABLE state_populations_y2015 (
    CONSTRAINT state_populations_year_chk CHECK ((year = 2015))
)
INHERITS (public.state_populations)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY state_populations_y2015 ALTER COLUMN state_code SET NOT NULL;


--
-- Name: state_populations_y2016; Type: TABLE; Schema: us; Owner: -
--

CREATE TABLE state_populations_y2016 (
    CONSTRAINT state_populations_year_chk CHECK ((year = 2016))
)
INHERITS (public.state_populations)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY state_populations_y2016 ALTER COLUMN state_code SET NOT NULL;


--
-- Name: urban_area_boundaries_2016; Type: TABLE; Schema: us; Owner: -
--

CREATE TABLE urban_area_boundaries_2016 (
    ogc_fid integer NOT NULL,
    uace10 character varying,
    geoid10 character varying,
    name10 character varying,
    namelsad10 character varying,
    lsad10 character varying,
    mtfcc10 character varying,
    uatyp10 character varying,
    funcstat10 character varying,
    aland10 bigint,
    awater10 bigint,
    intptlat10 character varying,
    intptlon10 character varying,
    wkb_geometry public.geometry(MultiPolygon,4326)
);


--
-- Name: urban_area_boundaries_2016_ogc_fid_seq; Type: SEQUENCE; Schema: us; Owner: -
--

CREATE SEQUENCE urban_area_boundaries_2016_ogc_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: urban_area_boundaries_2016_ogc_fid_seq; Type: SEQUENCE OWNED BY; Schema: us; Owner: -
--

ALTER SEQUENCE urban_area_boundaries_2016_ogc_fid_seq OWNED BY urban_area_boundaries_2016.ogc_fid;


--
-- Name: urban_area_boundaries_2017; Type: TABLE; Schema: us; Owner: -
--

CREATE TABLE urban_area_boundaries_2017 (
    ogc_fid integer,
    wkb_geometry public.geometry(MultiPolygon,4326),
    uace10 character varying,
    geoid10 character varying,
    name10 character varying,
    namelsad10 character varying,
    lsad10 character varying,
    mtfcc10 character varying,
    uatyp10 character varying,
    funcstat10 character varying,
    aland10 double precision,
    awater10 double precision,
    intptlat10 character varying,
    intptlon10 character varying
)
INHERITS (public.urban_area_boundaries);


--
-- Name: urban_area_boundaries_2017_ogc_fid_seq; Type: SEQUENCE; Schema: us; Owner: -
--

CREATE SEQUENCE urban_area_boundaries_2017_ogc_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: urban_area_boundaries_2017_ogc_fid_seq; Type: SEQUENCE OWNED BY; Schema: us; Owner: -
--

ALTER SEQUENCE urban_area_boundaries_2017_ogc_fid_seq OWNED BY urban_area_boundaries_2017.ogc_fid;


--
-- Name: urban_area_populations_y2015; Type: TABLE; Schema: us; Owner: -
--

CREATE TABLE urban_area_populations_y2015 (
    CONSTRAINT urban_area_populations_year_chk CHECK ((year = 2015))
)
INHERITS (public.urban_area_populations)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY urban_area_populations_y2015 ALTER COLUMN ua_code SET NOT NULL;


--
-- Name: urban_area_populations_y2016; Type: TABLE; Schema: us; Owner: -
--

CREATE TABLE urban_area_populations_y2016 (
    CONSTRAINT urban_area_populations_year_chk CHECK ((year = 2016))
)
INHERITS (public.urban_area_populations)
WITH (fillfactor='100', autovacuum_enabled='false');
ALTER TABLE ONLY urban_area_populations_y2016 ALTER COLUMN ua_code SET NOT NULL;


SET search_path = admin, pg_catalog;

--
-- Name: folders id; Type: DEFAULT; Schema: admin; Owner: -
--

ALTER TABLE ONLY folders ALTER COLUMN id SET DEFAULT nextval('folders_id_seq'::regclass);


--
-- Name: net_templates id; Type: DEFAULT; Schema: admin; Owner: -
--

ALTER TABLE ONLY net_templates ALTER COLUMN id SET DEFAULT nextval('net_templates_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: admin; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: reports id; Type: DEFAULT; Schema: admin; Owner: -
--

ALTER TABLE ONLY reports ALTER COLUMN id SET DEFAULT nextval('reports_id_seq'::regclass);


--
-- Name: templates id; Type: DEFAULT; Schema: admin; Owner: -
--

ALTER TABLE ONLY templates ALTER COLUMN id SET DEFAULT nextval('templates_id_seq'::regclass);


SET search_path = nj, pg_catalog;

--
-- Name: inrix_shapefile_20170707 ogc_fid; Type: DEFAULT; Schema: nj; Owner: -
--

ALTER TABLE ONLY inrix_shapefile_20170707 ALTER COLUMN ogc_fid SET DEFAULT nextval('inrix_shapefile_20170707_ogc_fid_seq'::regclass);


--
-- Name: npmrds_y2017m02 state; Type: DEFAULT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m02 ALTER COLUMN state SET DEFAULT 'nj'::bpchar;


--
-- Name: npmrds_y2017m03 state; Type: DEFAULT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m03 ALTER COLUMN state SET DEFAULT 'nj'::bpchar;


--
-- Name: npmrds_y2017m04 state; Type: DEFAULT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m04 ALTER COLUMN state SET DEFAULT 'nj'::bpchar;


--
-- Name: npmrds_y2017m05 state; Type: DEFAULT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m05 ALTER COLUMN state SET DEFAULT 'nj'::bpchar;


--
-- Name: npmrds_y2017m06 state; Type: DEFAULT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m06 ALTER COLUMN state SET DEFAULT 'nj'::bpchar;


--
-- Name: npmrds_y2017m07 state; Type: DEFAULT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m07 ALTER COLUMN state SET DEFAULT 'nj'::bpchar;


--
-- Name: npmrds_y2017m08 state; Type: DEFAULT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m08 ALTER COLUMN state SET DEFAULT 'nj'::bpchar;


--
-- Name: npmrds_y2017m09 state; Type: DEFAULT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m09 ALTER COLUMN state SET DEFAULT 'nj'::bpchar;


--
-- Name: npmrds_y2017m10 state; Type: DEFAULT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m10 ALTER COLUMN state SET DEFAULT 'nj'::bpchar;


--
-- Name: npmrds_y2017m11 state; Type: DEFAULT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m11 ALTER COLUMN state SET DEFAULT 'nj'::bpchar;


SET search_path = ny, pg_catalog;

--
-- Name: bottlenecks id; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY bottlenecks ALTER COLUMN id SET DEFAULT nextval('bottlenecks_id_seq'::regclass);


--
-- Name: inrix_shapefile_20170707 ogc_fid; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY inrix_shapefile_20170707 ALTER COLUMN ogc_fid SET DEFAULT nextval('inrix_shapefile_20170707_ogc_fid_seq'::regclass);


--
-- Name: npmrds_y2015m01 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m01 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2015m02 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m02 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2015m03 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m03 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2015m04 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m04 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2015m05 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m05 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2015m06 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m06 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2015m07 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m07 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2015m08 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m08 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2015m09 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m09 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2015m10 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m10 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2015m11 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m11 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2015m12 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m12 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2016m01 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m01 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2016m02 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m02 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2016m03 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m03 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2016m04 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m04 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2016m05 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m05 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2016m06 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m06 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2016m07 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m07 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2016m08 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m08 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2016m09 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m09 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2016m10 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m10 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2016m11 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m11 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2016m12 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m12 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2017m01 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m01 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2017m02 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m02 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2017m03 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m03 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2017m04 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m04 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2017m05 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m05 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2017m06 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m06 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2017m07 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m07 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2017m08 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m08 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2017m09 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m09 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: npmrds_y2017m10 state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m10 ALTER COLUMN state SET DEFAULT 'ny'::bpchar;


--
-- Name: occupancy_factor state; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY occupancy_factor ALTER COLUMN state SET DEFAULT 'ny'::character varying(2);


--
-- Name: occupancy_factor occupancy_factor; Type: DEFAULT; Schema: ny; Owner: -
--

ALTER TABLE ONLY occupancy_factor ALTER COLUMN occupancy_factor SET DEFAULT 1.5;


SET search_path = public, pg_catalog;

--
-- Name: SMTC_MPA_2013 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "SMTC_MPA_2013" ALTER COLUMN id SET DEFAULT nextval('"SMTC_MPA_2013_id_seq"'::regclass);


--
-- Name: collection id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection ALTER COLUMN id SET DEFAULT nextval('collection_id_seq'::regclass);


--
-- Name: network id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY network ALTER COLUMN id SET DEFAULT nextval('network_id_seq'::regclass);


--
-- Name: nj inrix_shapefile_20170707 ogc_fid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "nj inrix_shapefile_20170707" ALTER COLUMN ogc_fid SET DEFAULT nextval('"nj inrix_shapefile_20170707_ogc_fid_seq"'::regclass);


--
-- Name: tmc_routable id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tmc_routable ALTER COLUMN id SET DEFAULT nextval('tmc_routable_id_seq'::regclass);


--
-- Name: tmc_routable_vertices_pgr id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tmc_routable_vertices_pgr ALTER COLUMN id SET DEFAULT nextval('tmc_routable_vertices_pgr_id_seq'::regclass);


--
-- Name: traffic_signals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY traffic_signals ALTER COLUMN id SET DEFAULT nextval('traffic_signals_id_seq'::regclass);


SET search_path = us, pg_catalog;

--
-- Name: core_based_staticstical_area_boundaries_2016 ogc_fid; Type: DEFAULT; Schema: us; Owner: -
--

ALTER TABLE ONLY core_based_staticstical_area_boundaries_2016 ALTER COLUMN ogc_fid SET DEFAULT nextval('core_based_staticstical_area_boundaries_2016_ogc_fid_seq'::regclass);


--
-- Name: core_based_statistical_area_boundaries_2017 ogc_fid; Type: DEFAULT; Schema: us; Owner: -
--

ALTER TABLE ONLY core_based_statistical_area_boundaries_2017 ALTER COLUMN ogc_fid SET DEFAULT nextval('core_based_statistical_area_boundaries_2017_ogc_fid_seq'::regclass);


--
-- Name: county_populations_y2015 year; Type: DEFAULT; Schema: us; Owner: -
--

ALTER TABLE ONLY county_populations_y2015 ALTER COLUMN year SET DEFAULT 2015;


--
-- Name: county_populations_y2016 year; Type: DEFAULT; Schema: us; Owner: -
--

ALTER TABLE ONLY county_populations_y2016 ALTER COLUMN year SET DEFAULT 2016;


--
-- Name: mpo_boundaries_20170928 ogc_fid; Type: DEFAULT; Schema: us; Owner: -
--

ALTER TABLE ONLY mpo_boundaries_20170928 ALTER COLUMN ogc_fid SET DEFAULT nextval('mpo_boundaries_20170928_ogc_fid_seq'::regclass);


--
-- Name: state_populations_y2015 year; Type: DEFAULT; Schema: us; Owner: -
--

ALTER TABLE ONLY state_populations_y2015 ALTER COLUMN year SET DEFAULT 2015;


--
-- Name: state_populations_y2016 year; Type: DEFAULT; Schema: us; Owner: -
--

ALTER TABLE ONLY state_populations_y2016 ALTER COLUMN year SET DEFAULT 2016;


--
-- Name: urban_area_boundaries_2016 ogc_fid; Type: DEFAULT; Schema: us; Owner: -
--

ALTER TABLE ONLY urban_area_boundaries_2016 ALTER COLUMN ogc_fid SET DEFAULT nextval('urban_area_boundaries_2016_ogc_fid_seq'::regclass);


--
-- Name: urban_area_boundaries_2017 ogc_fid; Type: DEFAULT; Schema: us; Owner: -
--

ALTER TABLE ONLY urban_area_boundaries_2017 ALTER COLUMN ogc_fid SET DEFAULT nextval('urban_area_boundaries_2017_ogc_fid_seq'::regclass);


--
-- Name: urban_area_populations_y2015 year; Type: DEFAULT; Schema: us; Owner: -
--

ALTER TABLE ONLY urban_area_populations_y2015 ALTER COLUMN year SET DEFAULT 2015;


--
-- Name: urban_area_populations_y2016 year; Type: DEFAULT; Schema: us; Owner: -
--

ALTER TABLE ONLY urban_area_populations_y2016 ALTER COLUMN year SET DEFAULT 2016;


SET search_path = admin, pg_catalog;

--
-- Name: folders folders_table_primary_key; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY folders
    ADD CONSTRAINT folders_table_primary_key PRIMARY KEY (id);


--
-- Name: net_templates net_templates_pkey; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY net_templates
    ADD CONSTRAINT net_templates_pkey PRIMARY KEY (id);


--
-- Name: notification_views notification_views_pk; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY notification_views
    ADD CONSTRAINT notification_views_pk PRIMARY KEY (user_id, notification_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: reports_created_updated_at reports_created_updated_at_pkey; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY reports_created_updated_at
    ADD CONSTRAINT reports_created_updated_at_pkey PRIMARY KEY (report_id);


--
-- Name: reports reports_table_primary_key; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY reports
    ADD CONSTRAINT reports_table_primary_key PRIMARY KEY (id);


--
-- Name: templates_created_updated_at templates_created_updated_at_pkey; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY templates_created_updated_at
    ADD CONSTRAINT templates_created_updated_at_pkey PRIMARY KEY (template_id);


--
-- Name: templates templates_table_primary_key; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY templates
    ADD CONSTRAINT templates_table_primary_key PRIMARY KEY (id);


--
-- Name: user_report_views user_report_views_table_primary_key; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY user_report_views
    ADD CONSTRAINT user_report_views_table_primary_key PRIMARY KEY (user_id);


SET search_path = nj, pg_catalog;

--
-- Name: avg_speedlimits avg_speedlimits_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY avg_speedlimits
    ADD CONSTRAINT avg_speedlimits_pkey PRIMARY KEY (tmc);

ALTER TABLE avg_speedlimits CLUSTER ON avg_speedlimits_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m00 excessive_delay_brkdwn_y2017m00_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m00
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m00_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m00 CLUSTER ON excessive_delay_brkdwn_y2017m00_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m02 excessive_delay_brkdwn_y2017m02_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m02
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m02_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m02 CLUSTER ON excessive_delay_brkdwn_y2017m02_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m03 excessive_delay_brkdwn_y2017m03_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m03
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m03_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m03 CLUSTER ON excessive_delay_brkdwn_y2017m03_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m04 excessive_delay_brkdwn_y2017m04_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m04
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m04_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m04 CLUSTER ON excessive_delay_brkdwn_y2017m04_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m05 excessive_delay_brkdwn_y2017m05_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m05
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m05_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m05 CLUSTER ON excessive_delay_brkdwn_y2017m05_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m06 excessive_delay_brkdwn_y2017m06_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m06
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m06_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m06 CLUSTER ON excessive_delay_brkdwn_y2017m06_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m07 excessive_delay_brkdwn_y2017m07_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m07
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m07_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m07 CLUSTER ON excessive_delay_brkdwn_y2017m07_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m08 excessive_delay_brkdwn_y2017m08_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m08
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m08_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m08 CLUSTER ON excessive_delay_brkdwn_y2017m08_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m09 excessive_delay_brkdwn_y2017m09_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m09
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m09_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m09 CLUSTER ON excessive_delay_brkdwn_y2017m09_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m10 excessive_delay_brkdwn_y2017m10_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m10
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m10_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m10 CLUSTER ON excessive_delay_brkdwn_y2017m10_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m11 excessive_delay_brkdwn_y2017m11_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m11
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m11_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m11 CLUSTER ON excessive_delay_brkdwn_y2017m11_pkey;


--
-- Name: inrix_shapefile_20170707 inrix_shapefile_20170707_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY inrix_shapefile_20170707
    ADD CONSTRAINT inrix_shapefile_20170707_pkey PRIMARY KEY (ogc_fid);


--
-- Name: lottr_percentiles_y2017m00 lottr_percentiles_y2017m00_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m00
    ADD CONSTRAINT lottr_percentiles_y2017m00_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m00 CLUSTER ON lottr_percentiles_y2017m00_pkey;


--
-- Name: lottr_percentiles_y2017m02 lottr_percentiles_y2017m02_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m02
    ADD CONSTRAINT lottr_percentiles_y2017m02_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m02 CLUSTER ON lottr_percentiles_y2017m02_pkey;


--
-- Name: lottr_percentiles_y2017m03 lottr_percentiles_y2017m03_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m03
    ADD CONSTRAINT lottr_percentiles_y2017m03_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m03 CLUSTER ON lottr_percentiles_y2017m03_pkey;


--
-- Name: lottr_percentiles_y2017m04 lottr_percentiles_y2017m04_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m04
    ADD CONSTRAINT lottr_percentiles_y2017m04_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m04 CLUSTER ON lottr_percentiles_y2017m04_pkey;


--
-- Name: lottr_percentiles_y2017m05 lottr_percentiles_y2017m05_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m05
    ADD CONSTRAINT lottr_percentiles_y2017m05_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m05 CLUSTER ON lottr_percentiles_y2017m05_pkey;


--
-- Name: lottr_percentiles_y2017m06 lottr_percentiles_y2017m06_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m06
    ADD CONSTRAINT lottr_percentiles_y2017m06_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m06 CLUSTER ON lottr_percentiles_y2017m06_pkey;


--
-- Name: lottr_percentiles_y2017m07 lottr_percentiles_y2017m07_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m07
    ADD CONSTRAINT lottr_percentiles_y2017m07_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m07 CLUSTER ON lottr_percentiles_y2017m07_pkey;


--
-- Name: lottr_percentiles_y2017m08 lottr_percentiles_y2017m08_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m08
    ADD CONSTRAINT lottr_percentiles_y2017m08_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m08 CLUSTER ON lottr_percentiles_y2017m08_pkey;


--
-- Name: lottr_percentiles_y2017m09 lottr_percentiles_y2017m09_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m09
    ADD CONSTRAINT lottr_percentiles_y2017m09_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m09 CLUSTER ON lottr_percentiles_y2017m09_pkey;


--
-- Name: lottr_percentiles_y2017m10 lottr_percentiles_y2017m10_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m10
    ADD CONSTRAINT lottr_percentiles_y2017m10_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m10 CLUSTER ON lottr_percentiles_y2017m10_pkey;


--
-- Name: lottr_percentiles_y2017m11 lottr_percentiles_y2017m11_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m11
    ADD CONSTRAINT lottr_percentiles_y2017m11_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m11 CLUSTER ON lottr_percentiles_y2017m11_pkey;


--
-- Name: npmrds_y2017m02 npmrds_y2017m02_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m02
    ADD CONSTRAINT npmrds_y2017m02_pkey PRIMARY KEY (tmc, date, epoch);


--
-- Name: npmrds_y2017m03 npmrds_y2017m03_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m03
    ADD CONSTRAINT npmrds_y2017m03_pkey PRIMARY KEY (tmc, date, epoch);


--
-- Name: npmrds_y2017m04 npmrds_y2017m04_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m04
    ADD CONSTRAINT npmrds_y2017m04_pkey PRIMARY KEY (tmc, date, epoch);


--
-- Name: npmrds_y2017m05 npmrds_y2017m05_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m05
    ADD CONSTRAINT npmrds_y2017m05_pkey PRIMARY KEY (tmc, date, epoch);


--
-- Name: npmrds_y2017m06 npmrds_y2017m06_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m06
    ADD CONSTRAINT npmrds_y2017m06_pkey PRIMARY KEY (tmc, date, epoch);


--
-- Name: npmrds_y2017m07 npmrds_y2017m07_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m07
    ADD CONSTRAINT npmrds_y2017m07_pkey PRIMARY KEY (tmc, date, epoch);


--
-- Name: npmrds_y2017m08 npmrds_y2017m08_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m08
    ADD CONSTRAINT npmrds_y2017m08_pkey PRIMARY KEY (tmc, date, epoch);


--
-- Name: npmrds_y2017m09 npmrds_y2017m09_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m09
    ADD CONSTRAINT npmrds_y2017m09_pkey PRIMARY KEY (tmc, date, epoch);


--
-- Name: npmrds_y2017m10 npmrds_y2017m10_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m10
    ADD CONSTRAINT npmrds_y2017m10_pkey PRIMARY KEY (tmc, date, epoch);


--
-- Name: npmrds_y2017m11 npmrds_y2017m11_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m11
    ADD CONSTRAINT npmrds_y2017m11_pkey PRIMARY KEY (tmc, date, epoch);


--
-- Name: tmc_attributes tmc_attributes_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY tmc_attributes
    ADD CONSTRAINT tmc_attributes_pkey PRIMARY KEY (tmc);

ALTER TABLE tmc_attributes CLUSTER ON tmc_attributes_pkey;


--
-- Name: tmc_date_ranges tmc_date_ranges_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY tmc_date_ranges
    ADD CONSTRAINT tmc_date_ranges_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tmc_date_ranges CLUSTER ON tmc_date_ranges_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m00 top_level_excessive_delay_y2017m00_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m00
    ADD CONSTRAINT top_level_excessive_delay_y2017m00_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m00 CLUSTER ON top_level_excessive_delay_y2017m00_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m02 top_level_excessive_delay_y2017m02_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m02
    ADD CONSTRAINT top_level_excessive_delay_y2017m02_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m02 CLUSTER ON top_level_excessive_delay_y2017m02_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m03 top_level_excessive_delay_y2017m03_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m03
    ADD CONSTRAINT top_level_excessive_delay_y2017m03_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m03 CLUSTER ON top_level_excessive_delay_y2017m03_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m04 top_level_excessive_delay_y2017m04_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m04
    ADD CONSTRAINT top_level_excessive_delay_y2017m04_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m04 CLUSTER ON top_level_excessive_delay_y2017m04_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m05 top_level_excessive_delay_y2017m05_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m05
    ADD CONSTRAINT top_level_excessive_delay_y2017m05_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m05 CLUSTER ON top_level_excessive_delay_y2017m05_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m06 top_level_excessive_delay_y2017m06_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m06
    ADD CONSTRAINT top_level_excessive_delay_y2017m06_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m06 CLUSTER ON top_level_excessive_delay_y2017m06_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m07 top_level_excessive_delay_y2017m07_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m07
    ADD CONSTRAINT top_level_excessive_delay_y2017m07_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m07 CLUSTER ON top_level_excessive_delay_y2017m07_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m08 top_level_excessive_delay_y2017m08_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m08
    ADD CONSTRAINT top_level_excessive_delay_y2017m08_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m08 CLUSTER ON top_level_excessive_delay_y2017m08_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m09 top_level_excessive_delay_y2017m09_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m09
    ADD CONSTRAINT top_level_excessive_delay_y2017m09_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m09 CLUSTER ON top_level_excessive_delay_y2017m09_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m10 top_level_excessive_delay_y2017m10_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m10
    ADD CONSTRAINT top_level_excessive_delay_y2017m10_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m10 CLUSTER ON top_level_excessive_delay_y2017m10_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m11 top_level_excessive_delay_y2017m11_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m11
    ADD CONSTRAINT top_level_excessive_delay_y2017m11_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m11 CLUSTER ON top_level_excessive_delay_y2017m11_pkey;


--
-- Name: top_level_freight_reliability_y2017m00 top_level_freight_reliability_y2017m00_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m00
    ADD CONSTRAINT top_level_freight_reliability_y2017m00_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m00 CLUSTER ON top_level_freight_reliability_y2017m00_pkey;


--
-- Name: top_level_freight_reliability_y2017m02 top_level_freight_reliability_y2017m02_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m02
    ADD CONSTRAINT top_level_freight_reliability_y2017m02_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m02 CLUSTER ON top_level_freight_reliability_y2017m02_pkey;


--
-- Name: top_level_freight_reliability_y2017m03 top_level_freight_reliability_y2017m03_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m03
    ADD CONSTRAINT top_level_freight_reliability_y2017m03_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m03 CLUSTER ON top_level_freight_reliability_y2017m03_pkey;


--
-- Name: top_level_freight_reliability_y2017m04 top_level_freight_reliability_y2017m04_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m04
    ADD CONSTRAINT top_level_freight_reliability_y2017m04_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m04 CLUSTER ON top_level_freight_reliability_y2017m04_pkey;


--
-- Name: top_level_freight_reliability_y2017m05 top_level_freight_reliability_y2017m05_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m05
    ADD CONSTRAINT top_level_freight_reliability_y2017m05_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m05 CLUSTER ON top_level_freight_reliability_y2017m05_pkey;


--
-- Name: top_level_freight_reliability_y2017m06 top_level_freight_reliability_y2017m06_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m06
    ADD CONSTRAINT top_level_freight_reliability_y2017m06_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m06 CLUSTER ON top_level_freight_reliability_y2017m06_pkey;


--
-- Name: top_level_freight_reliability_y2017m07 top_level_freight_reliability_y2017m07_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m07
    ADD CONSTRAINT top_level_freight_reliability_y2017m07_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m07 CLUSTER ON top_level_freight_reliability_y2017m07_pkey;


--
-- Name: top_level_freight_reliability_y2017m08 top_level_freight_reliability_y2017m08_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m08
    ADD CONSTRAINT top_level_freight_reliability_y2017m08_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m08 CLUSTER ON top_level_freight_reliability_y2017m08_pkey;


--
-- Name: top_level_freight_reliability_y2017m09 top_level_freight_reliability_y2017m09_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m09
    ADD CONSTRAINT top_level_freight_reliability_y2017m09_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m09 CLUSTER ON top_level_freight_reliability_y2017m09_pkey;


--
-- Name: top_level_freight_reliability_y2017m10 top_level_freight_reliability_y2017m10_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m10
    ADD CONSTRAINT top_level_freight_reliability_y2017m10_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m10 CLUSTER ON top_level_freight_reliability_y2017m10_pkey;


--
-- Name: top_level_freight_reliability_y2017m11 top_level_freight_reliability_y2017m11_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m11
    ADD CONSTRAINT top_level_freight_reliability_y2017m11_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m11 CLUSTER ON top_level_freight_reliability_y2017m11_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m00 top_level_travel_time_reliability_y2017m00_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m00
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m00_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m00 CLUSTER ON top_level_travel_time_reliability_y2017m00_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m02 top_level_travel_time_reliability_y2017m02_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m02
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m02_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m02 CLUSTER ON top_level_travel_time_reliability_y2017m02_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m03 top_level_travel_time_reliability_y2017m03_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m03
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m03_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m03 CLUSTER ON top_level_travel_time_reliability_y2017m03_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m04 top_level_travel_time_reliability_y2017m04_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m04
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m04_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m04 CLUSTER ON top_level_travel_time_reliability_y2017m04_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m05 top_level_travel_time_reliability_y2017m05_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m05
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m05_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m05 CLUSTER ON top_level_travel_time_reliability_y2017m05_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m06 top_level_travel_time_reliability_y2017m06_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m06
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m06_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m06 CLUSTER ON top_level_travel_time_reliability_y2017m06_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m07 top_level_travel_time_reliability_y2017m07_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m07
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m07_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m07 CLUSTER ON top_level_travel_time_reliability_y2017m07_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m08 top_level_travel_time_reliability_y2017m08_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m08
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m08_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m08 CLUSTER ON top_level_travel_time_reliability_y2017m08_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m09 top_level_travel_time_reliability_y2017m09_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m09
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m09_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m09 CLUSTER ON top_level_travel_time_reliability_y2017m09_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m10 top_level_travel_time_reliability_y2017m10_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m10
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m10_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m10 CLUSTER ON top_level_travel_time_reliability_y2017m10_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m11 top_level_travel_time_reliability_y2017m11_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m11
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m11_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m11 CLUSTER ON top_level_travel_time_reliability_y2017m11_pkey;


--
-- Name: tttr_percentiles_y2017m00 tttr_percentiles_y2017m00_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m00
    ADD CONSTRAINT tttr_percentiles_y2017m00_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m00 CLUSTER ON tttr_percentiles_y2017m00_pkey;


--
-- Name: tttr_percentiles_y2017m02 tttr_percentiles_y2017m02_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m02
    ADD CONSTRAINT tttr_percentiles_y2017m02_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m02 CLUSTER ON tttr_percentiles_y2017m02_pkey;


--
-- Name: tttr_percentiles_y2017m03 tttr_percentiles_y2017m03_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m03
    ADD CONSTRAINT tttr_percentiles_y2017m03_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m03 CLUSTER ON tttr_percentiles_y2017m03_pkey;


--
-- Name: tttr_percentiles_y2017m04 tttr_percentiles_y2017m04_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m04
    ADD CONSTRAINT tttr_percentiles_y2017m04_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m04 CLUSTER ON tttr_percentiles_y2017m04_pkey;


--
-- Name: tttr_percentiles_y2017m05 tttr_percentiles_y2017m05_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m05
    ADD CONSTRAINT tttr_percentiles_y2017m05_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m05 CLUSTER ON tttr_percentiles_y2017m05_pkey;


--
-- Name: tttr_percentiles_y2017m06 tttr_percentiles_y2017m06_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m06
    ADD CONSTRAINT tttr_percentiles_y2017m06_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m06 CLUSTER ON tttr_percentiles_y2017m06_pkey;


--
-- Name: tttr_percentiles_y2017m07 tttr_percentiles_y2017m07_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m07
    ADD CONSTRAINT tttr_percentiles_y2017m07_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m07 CLUSTER ON tttr_percentiles_y2017m07_pkey;


--
-- Name: tttr_percentiles_y2017m08 tttr_percentiles_y2017m08_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m08
    ADD CONSTRAINT tttr_percentiles_y2017m08_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m08 CLUSTER ON tttr_percentiles_y2017m08_pkey;


--
-- Name: tttr_percentiles_y2017m09 tttr_percentiles_y2017m09_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m09
    ADD CONSTRAINT tttr_percentiles_y2017m09_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m09 CLUSTER ON tttr_percentiles_y2017m09_pkey;


--
-- Name: tttr_percentiles_y2017m10 tttr_percentiles_y2017m10_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m10
    ADD CONSTRAINT tttr_percentiles_y2017m10_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m10 CLUSTER ON tttr_percentiles_y2017m10_pkey;


--
-- Name: tttr_percentiles_y2017m11 tttr_percentiles_y2017m11_pkey; Type: CONSTRAINT; Schema: nj; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m11
    ADD CONSTRAINT tttr_percentiles_y2017m11_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m11 CLUSTER ON tttr_percentiles_y2017m11_pkey;


SET search_path = ny, pg_catalog;

--
-- Name: avg_speedlimits avg_speedlimits_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY avg_speedlimits
    ADD CONSTRAINT avg_speedlimits_pkey PRIMARY KEY (tmc);

ALTER TABLE avg_speedlimits CLUSTER ON avg_speedlimits_pkey;


--
-- Name: bottlenecks bottlenecks_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY bottlenecks
    ADD CONSTRAINT bottlenecks_pkey PRIMARY KEY (tmc, start_epoch, year, month, aadttype);


--
-- Name: excessive_delay_brkdwn_y2015m00 excessive_delay_brkdwn_y2015m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2015m00
    ADD CONSTRAINT excessive_delay_brkdwn_y2015m00_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2015m00 CLUSTER ON excessive_delay_brkdwn_y2015m00_pkey;


--
-- Name: excessive_delay_brkdwn_y2015m01 excessive_delay_brkdwn_y2015m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2015m01
    ADD CONSTRAINT excessive_delay_brkdwn_y2015m01_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2015m01 CLUSTER ON excessive_delay_brkdwn_y2015m01_pkey;


--
-- Name: excessive_delay_brkdwn_y2015m02 excessive_delay_brkdwn_y2015m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2015m02
    ADD CONSTRAINT excessive_delay_brkdwn_y2015m02_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2015m02 CLUSTER ON excessive_delay_brkdwn_y2015m02_pkey;


--
-- Name: excessive_delay_brkdwn_y2015m03 excessive_delay_brkdwn_y2015m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2015m03
    ADD CONSTRAINT excessive_delay_brkdwn_y2015m03_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2015m03 CLUSTER ON excessive_delay_brkdwn_y2015m03_pkey;


--
-- Name: excessive_delay_brkdwn_y2015m04 excessive_delay_brkdwn_y2015m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2015m04
    ADD CONSTRAINT excessive_delay_brkdwn_y2015m04_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2015m04 CLUSTER ON excessive_delay_brkdwn_y2015m04_pkey;


--
-- Name: excessive_delay_brkdwn_y2015m05 excessive_delay_brkdwn_y2015m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2015m05
    ADD CONSTRAINT excessive_delay_brkdwn_y2015m05_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2015m05 CLUSTER ON excessive_delay_brkdwn_y2015m05_pkey;


--
-- Name: excessive_delay_brkdwn_y2015m06 excessive_delay_brkdwn_y2015m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2015m06
    ADD CONSTRAINT excessive_delay_brkdwn_y2015m06_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2015m06 CLUSTER ON excessive_delay_brkdwn_y2015m06_pkey;


--
-- Name: excessive_delay_brkdwn_y2015m07 excessive_delay_brkdwn_y2015m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2015m07
    ADD CONSTRAINT excessive_delay_brkdwn_y2015m07_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2015m07 CLUSTER ON excessive_delay_brkdwn_y2015m07_pkey;


--
-- Name: excessive_delay_brkdwn_y2015m08 excessive_delay_brkdwn_y2015m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2015m08
    ADD CONSTRAINT excessive_delay_brkdwn_y2015m08_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2015m08 CLUSTER ON excessive_delay_brkdwn_y2015m08_pkey;


--
-- Name: excessive_delay_brkdwn_y2015m09 excessive_delay_brkdwn_y2015m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2015m09
    ADD CONSTRAINT excessive_delay_brkdwn_y2015m09_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2015m09 CLUSTER ON excessive_delay_brkdwn_y2015m09_pkey;


--
-- Name: excessive_delay_brkdwn_y2015m10 excessive_delay_brkdwn_y2015m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2015m10
    ADD CONSTRAINT excessive_delay_brkdwn_y2015m10_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2015m10 CLUSTER ON excessive_delay_brkdwn_y2015m10_pkey;


--
-- Name: excessive_delay_brkdwn_y2015m11 excessive_delay_brkdwn_y2015m11_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2015m11
    ADD CONSTRAINT excessive_delay_brkdwn_y2015m11_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2015m11 CLUSTER ON excessive_delay_brkdwn_y2015m11_pkey;


--
-- Name: excessive_delay_brkdwn_y2015m12 excessive_delay_brkdwn_y2015m12_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2015m12
    ADD CONSTRAINT excessive_delay_brkdwn_y2015m12_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2015m12 CLUSTER ON excessive_delay_brkdwn_y2015m12_pkey;


--
-- Name: excessive_delay_brkdwn_y2016m00 excessive_delay_brkdwn_y2016m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2016m00
    ADD CONSTRAINT excessive_delay_brkdwn_y2016m00_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2016m00 CLUSTER ON excessive_delay_brkdwn_y2016m00_pkey;


--
-- Name: excessive_delay_brkdwn_y2016m01 excessive_delay_brkdwn_y2016m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2016m01
    ADD CONSTRAINT excessive_delay_brkdwn_y2016m01_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2016m01 CLUSTER ON excessive_delay_brkdwn_y2016m01_pkey;


--
-- Name: excessive_delay_brkdwn_y2016m02 excessive_delay_brkdwn_y2016m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2016m02
    ADD CONSTRAINT excessive_delay_brkdwn_y2016m02_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2016m02 CLUSTER ON excessive_delay_brkdwn_y2016m02_pkey;


--
-- Name: excessive_delay_brkdwn_y2016m03 excessive_delay_brkdwn_y2016m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2016m03
    ADD CONSTRAINT excessive_delay_brkdwn_y2016m03_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2016m03 CLUSTER ON excessive_delay_brkdwn_y2016m03_pkey;


--
-- Name: excessive_delay_brkdwn_y2016m04 excessive_delay_brkdwn_y2016m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2016m04
    ADD CONSTRAINT excessive_delay_brkdwn_y2016m04_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2016m04 CLUSTER ON excessive_delay_brkdwn_y2016m04_pkey;


--
-- Name: excessive_delay_brkdwn_y2016m05 excessive_delay_brkdwn_y2016m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2016m05
    ADD CONSTRAINT excessive_delay_brkdwn_y2016m05_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2016m05 CLUSTER ON excessive_delay_brkdwn_y2016m05_pkey;


--
-- Name: excessive_delay_brkdwn_y2016m06 excessive_delay_brkdwn_y2016m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2016m06
    ADD CONSTRAINT excessive_delay_brkdwn_y2016m06_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2016m06 CLUSTER ON excessive_delay_brkdwn_y2016m06_pkey;


--
-- Name: excessive_delay_brkdwn_y2016m07 excessive_delay_brkdwn_y2016m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2016m07
    ADD CONSTRAINT excessive_delay_brkdwn_y2016m07_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2016m07 CLUSTER ON excessive_delay_brkdwn_y2016m07_pkey;


--
-- Name: excessive_delay_brkdwn_y2016m08 excessive_delay_brkdwn_y2016m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2016m08
    ADD CONSTRAINT excessive_delay_brkdwn_y2016m08_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2016m08 CLUSTER ON excessive_delay_brkdwn_y2016m08_pkey;


--
-- Name: excessive_delay_brkdwn_y2016m09 excessive_delay_brkdwn_y2016m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2016m09
    ADD CONSTRAINT excessive_delay_brkdwn_y2016m09_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2016m09 CLUSTER ON excessive_delay_brkdwn_y2016m09_pkey;


--
-- Name: excessive_delay_brkdwn_y2016m10 excessive_delay_brkdwn_y2016m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2016m10
    ADD CONSTRAINT excessive_delay_brkdwn_y2016m10_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2016m10 CLUSTER ON excessive_delay_brkdwn_y2016m10_pkey;


--
-- Name: excessive_delay_brkdwn_y2016m11 excessive_delay_brkdwn_y2016m11_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2016m11
    ADD CONSTRAINT excessive_delay_brkdwn_y2016m11_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2016m11 CLUSTER ON excessive_delay_brkdwn_y2016m11_pkey;


--
-- Name: excessive_delay_brkdwn_y2016m12 excessive_delay_brkdwn_y2016m12_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2016m12
    ADD CONSTRAINT excessive_delay_brkdwn_y2016m12_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2016m12 CLUSTER ON excessive_delay_brkdwn_y2016m12_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m00 excessive_delay_brkdwn_y2017m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m00
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m00_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m00 CLUSTER ON excessive_delay_brkdwn_y2017m00_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m01 excessive_delay_brkdwn_y2017m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m01
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m01_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m01 CLUSTER ON excessive_delay_brkdwn_y2017m01_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m02 excessive_delay_brkdwn_y2017m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m02
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m02_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m02 CLUSTER ON excessive_delay_brkdwn_y2017m02_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m03 excessive_delay_brkdwn_y2017m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m03
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m03_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m03 CLUSTER ON excessive_delay_brkdwn_y2017m03_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m04 excessive_delay_brkdwn_y2017m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m04
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m04_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m04 CLUSTER ON excessive_delay_brkdwn_y2017m04_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m05 excessive_delay_brkdwn_y2017m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m05
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m05_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m05 CLUSTER ON excessive_delay_brkdwn_y2017m05_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m06 excessive_delay_brkdwn_y2017m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m06
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m06_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m06 CLUSTER ON excessive_delay_brkdwn_y2017m06_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m07 excessive_delay_brkdwn_y2017m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m07
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m07_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m07 CLUSTER ON excessive_delay_brkdwn_y2017m07_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m08 excessive_delay_brkdwn_y2017m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m08
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m08_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m08 CLUSTER ON excessive_delay_brkdwn_y2017m08_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m09 excessive_delay_brkdwn_y2017m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m09
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m09_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m09 CLUSTER ON excessive_delay_brkdwn_y2017m09_pkey;


--
-- Name: excessive_delay_brkdwn_y2017m10 excessive_delay_brkdwn_y2017m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY excessive_delay_brkdwn_y2017m10
    ADD CONSTRAINT excessive_delay_brkdwn_y2017m10_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE excessive_delay_brkdwn_y2017m10 CLUSTER ON excessive_delay_brkdwn_y2017m10_pkey;


--
-- Name: inrix_shapefile_20170707 inrix_shapefile_20170707_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY inrix_shapefile_20170707
    ADD CONSTRAINT inrix_shapefile_20170707_pkey PRIMARY KEY (ogc_fid);


--
-- Name: lottr_percentiles_y2015m00 lottr_percentiles_y2015m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2015m00
    ADD CONSTRAINT lottr_percentiles_y2015m00_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2015m00 CLUSTER ON lottr_percentiles_y2015m00_pkey;


--
-- Name: lottr_percentiles_y2015m01 lottr_percentiles_y2015m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2015m01
    ADD CONSTRAINT lottr_percentiles_y2015m01_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2015m01 CLUSTER ON lottr_percentiles_y2015m01_pkey;


--
-- Name: lottr_percentiles_y2015m02 lottr_percentiles_y2015m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2015m02
    ADD CONSTRAINT lottr_percentiles_y2015m02_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2015m02 CLUSTER ON lottr_percentiles_y2015m02_pkey;


--
-- Name: lottr_percentiles_y2015m03 lottr_percentiles_y2015m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2015m03
    ADD CONSTRAINT lottr_percentiles_y2015m03_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2015m03 CLUSTER ON lottr_percentiles_y2015m03_pkey;


--
-- Name: lottr_percentiles_y2015m04 lottr_percentiles_y2015m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2015m04
    ADD CONSTRAINT lottr_percentiles_y2015m04_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2015m04 CLUSTER ON lottr_percentiles_y2015m04_pkey;


--
-- Name: lottr_percentiles_y2015m05 lottr_percentiles_y2015m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2015m05
    ADD CONSTRAINT lottr_percentiles_y2015m05_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2015m05 CLUSTER ON lottr_percentiles_y2015m05_pkey;


--
-- Name: lottr_percentiles_y2015m06 lottr_percentiles_y2015m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2015m06
    ADD CONSTRAINT lottr_percentiles_y2015m06_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2015m06 CLUSTER ON lottr_percentiles_y2015m06_pkey;


--
-- Name: lottr_percentiles_y2015m07 lottr_percentiles_y2015m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2015m07
    ADD CONSTRAINT lottr_percentiles_y2015m07_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2015m07 CLUSTER ON lottr_percentiles_y2015m07_pkey;


--
-- Name: lottr_percentiles_y2015m08 lottr_percentiles_y2015m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2015m08
    ADD CONSTRAINT lottr_percentiles_y2015m08_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2015m08 CLUSTER ON lottr_percentiles_y2015m08_pkey;


--
-- Name: lottr_percentiles_y2015m09 lottr_percentiles_y2015m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2015m09
    ADD CONSTRAINT lottr_percentiles_y2015m09_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2015m09 CLUSTER ON lottr_percentiles_y2015m09_pkey;


--
-- Name: lottr_percentiles_y2015m10 lottr_percentiles_y2015m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2015m10
    ADD CONSTRAINT lottr_percentiles_y2015m10_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2015m10 CLUSTER ON lottr_percentiles_y2015m10_pkey;


--
-- Name: lottr_percentiles_y2015m11 lottr_percentiles_y2015m11_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2015m11
    ADD CONSTRAINT lottr_percentiles_y2015m11_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2015m11 CLUSTER ON lottr_percentiles_y2015m11_pkey;


--
-- Name: lottr_percentiles_y2015m12 lottr_percentiles_y2015m12_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2015m12
    ADD CONSTRAINT lottr_percentiles_y2015m12_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2015m12 CLUSTER ON lottr_percentiles_y2015m12_pkey;


--
-- Name: lottr_percentiles_y2016m00 lottr_percentiles_y2016m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2016m00
    ADD CONSTRAINT lottr_percentiles_y2016m00_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2016m00 CLUSTER ON lottr_percentiles_y2016m00_pkey;


--
-- Name: lottr_percentiles_y2016m01 lottr_percentiles_y2016m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2016m01
    ADD CONSTRAINT lottr_percentiles_y2016m01_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2016m01 CLUSTER ON lottr_percentiles_y2016m01_pkey;


--
-- Name: lottr_percentiles_y2016m02 lottr_percentiles_y2016m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2016m02
    ADD CONSTRAINT lottr_percentiles_y2016m02_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2016m02 CLUSTER ON lottr_percentiles_y2016m02_pkey;


--
-- Name: lottr_percentiles_y2016m03 lottr_percentiles_y2016m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2016m03
    ADD CONSTRAINT lottr_percentiles_y2016m03_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2016m03 CLUSTER ON lottr_percentiles_y2016m03_pkey;


--
-- Name: lottr_percentiles_y2016m04 lottr_percentiles_y2016m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2016m04
    ADD CONSTRAINT lottr_percentiles_y2016m04_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2016m04 CLUSTER ON lottr_percentiles_y2016m04_pkey;


--
-- Name: lottr_percentiles_y2016m05 lottr_percentiles_y2016m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2016m05
    ADD CONSTRAINT lottr_percentiles_y2016m05_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2016m05 CLUSTER ON lottr_percentiles_y2016m05_pkey;


--
-- Name: lottr_percentiles_y2016m06 lottr_percentiles_y2016m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2016m06
    ADD CONSTRAINT lottr_percentiles_y2016m06_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2016m06 CLUSTER ON lottr_percentiles_y2016m06_pkey;


--
-- Name: lottr_percentiles_y2016m07 lottr_percentiles_y2016m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2016m07
    ADD CONSTRAINT lottr_percentiles_y2016m07_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2016m07 CLUSTER ON lottr_percentiles_y2016m07_pkey;


--
-- Name: lottr_percentiles_y2016m08 lottr_percentiles_y2016m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2016m08
    ADD CONSTRAINT lottr_percentiles_y2016m08_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2016m08 CLUSTER ON lottr_percentiles_y2016m08_pkey;


--
-- Name: lottr_percentiles_y2016m09 lottr_percentiles_y2016m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2016m09
    ADD CONSTRAINT lottr_percentiles_y2016m09_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2016m09 CLUSTER ON lottr_percentiles_y2016m09_pkey;


--
-- Name: lottr_percentiles_y2016m10 lottr_percentiles_y2016m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2016m10
    ADD CONSTRAINT lottr_percentiles_y2016m10_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2016m10 CLUSTER ON lottr_percentiles_y2016m10_pkey;


--
-- Name: lottr_percentiles_y2016m11 lottr_percentiles_y2016m11_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2016m11
    ADD CONSTRAINT lottr_percentiles_y2016m11_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2016m11 CLUSTER ON lottr_percentiles_y2016m11_pkey;


--
-- Name: lottr_percentiles_y2016m12 lottr_percentiles_y2016m12_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2016m12
    ADD CONSTRAINT lottr_percentiles_y2016m12_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2016m12 CLUSTER ON lottr_percentiles_y2016m12_pkey;


--
-- Name: lottr_percentiles_y2017m00 lottr_percentiles_y2017m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m00
    ADD CONSTRAINT lottr_percentiles_y2017m00_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m00 CLUSTER ON lottr_percentiles_y2017m00_pkey;


--
-- Name: lottr_percentiles_y2017m01 lottr_percentiles_y2017m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m01
    ADD CONSTRAINT lottr_percentiles_y2017m01_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m01 CLUSTER ON lottr_percentiles_y2017m01_pkey;


--
-- Name: lottr_percentiles_y2017m02 lottr_percentiles_y2017m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m02
    ADD CONSTRAINT lottr_percentiles_y2017m02_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m02 CLUSTER ON lottr_percentiles_y2017m02_pkey;


--
-- Name: lottr_percentiles_y2017m03 lottr_percentiles_y2017m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m03
    ADD CONSTRAINT lottr_percentiles_y2017m03_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m03 CLUSTER ON lottr_percentiles_y2017m03_pkey;


--
-- Name: lottr_percentiles_y2017m04 lottr_percentiles_y2017m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m04
    ADD CONSTRAINT lottr_percentiles_y2017m04_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m04 CLUSTER ON lottr_percentiles_y2017m04_pkey;


--
-- Name: lottr_percentiles_y2017m05 lottr_percentiles_y2017m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m05
    ADD CONSTRAINT lottr_percentiles_y2017m05_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m05 CLUSTER ON lottr_percentiles_y2017m05_pkey;


--
-- Name: lottr_percentiles_y2017m06 lottr_percentiles_y2017m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m06
    ADD CONSTRAINT lottr_percentiles_y2017m06_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m06 CLUSTER ON lottr_percentiles_y2017m06_pkey;


--
-- Name: lottr_percentiles_y2017m07 lottr_percentiles_y2017m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m07
    ADD CONSTRAINT lottr_percentiles_y2017m07_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m07 CLUSTER ON lottr_percentiles_y2017m07_pkey;


--
-- Name: lottr_percentiles_y2017m08 lottr_percentiles_y2017m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m08
    ADD CONSTRAINT lottr_percentiles_y2017m08_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m08 CLUSTER ON lottr_percentiles_y2017m08_pkey;


--
-- Name: lottr_percentiles_y2017m09 lottr_percentiles_y2017m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m09
    ADD CONSTRAINT lottr_percentiles_y2017m09_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m09 CLUSTER ON lottr_percentiles_y2017m09_pkey;


--
-- Name: lottr_percentiles_y2017m10 lottr_percentiles_y2017m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY lottr_percentiles_y2017m10
    ADD CONSTRAINT lottr_percentiles_y2017m10_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE lottr_percentiles_y2017m10 CLUSTER ON lottr_percentiles_y2017m10_pkey;


--
-- Name: npmrds_y2015m01 npmrds_y2015m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m01
    ADD CONSTRAINT npmrds_y2015m01_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2015m01 CLUSTER ON npmrds_y2015m01_pkey;


--
-- Name: npmrds_y2015m02 npmrds_y2015m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m02
    ADD CONSTRAINT npmrds_y2015m02_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2015m02 CLUSTER ON npmrds_y2015m02_pkey;


--
-- Name: npmrds_y2015m03 npmrds_y2015m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m03
    ADD CONSTRAINT npmrds_y2015m03_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2015m03 CLUSTER ON npmrds_y2015m03_pkey;


--
-- Name: npmrds_y2015m04 npmrds_y2015m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m04
    ADD CONSTRAINT npmrds_y2015m04_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2015m04 CLUSTER ON npmrds_y2015m04_pkey;


--
-- Name: npmrds_y2015m05 npmrds_y2015m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m05
    ADD CONSTRAINT npmrds_y2015m05_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2015m05 CLUSTER ON npmrds_y2015m05_pkey;


--
-- Name: npmrds_y2015m06 npmrds_y2015m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m06
    ADD CONSTRAINT npmrds_y2015m06_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2015m06 CLUSTER ON npmrds_y2015m06_pkey;


--
-- Name: npmrds_y2015m07 npmrds_y2015m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m07
    ADD CONSTRAINT npmrds_y2015m07_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2015m07 CLUSTER ON npmrds_y2015m07_pkey;


--
-- Name: npmrds_y2015m08 npmrds_y2015m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m08
    ADD CONSTRAINT npmrds_y2015m08_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2015m08 CLUSTER ON npmrds_y2015m08_pkey;


--
-- Name: npmrds_y2015m09 npmrds_y2015m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m09
    ADD CONSTRAINT npmrds_y2015m09_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2015m09 CLUSTER ON npmrds_y2015m09_pkey;


--
-- Name: npmrds_y2015m10 npmrds_y2015m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m10
    ADD CONSTRAINT npmrds_y2015m10_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2015m10 CLUSTER ON npmrds_y2015m10_pkey;


--
-- Name: npmrds_y2015m11 npmrds_y2015m11_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m11
    ADD CONSTRAINT npmrds_y2015m11_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2015m11 CLUSTER ON npmrds_y2015m11_pkey;


--
-- Name: npmrds_y2015m12 npmrds_y2015m12_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2015m12
    ADD CONSTRAINT npmrds_y2015m12_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2015m12 CLUSTER ON npmrds_y2015m12_pkey;


--
-- Name: npmrds_y2016m01 npmrds_y2016m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m01
    ADD CONSTRAINT npmrds_y2016m01_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2016m01 CLUSTER ON npmrds_y2016m01_pkey;


--
-- Name: npmrds_y2016m02 npmrds_y2016m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m02
    ADD CONSTRAINT npmrds_y2016m02_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2016m02 CLUSTER ON npmrds_y2016m02_pkey;


--
-- Name: npmrds_y2016m03 npmrds_y2016m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m03
    ADD CONSTRAINT npmrds_y2016m03_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2016m03 CLUSTER ON npmrds_y2016m03_pkey;


--
-- Name: npmrds_y2016m04 npmrds_y2016m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m04
    ADD CONSTRAINT npmrds_y2016m04_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2016m04 CLUSTER ON npmrds_y2016m04_pkey;


--
-- Name: npmrds_y2016m05 npmrds_y2016m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m05
    ADD CONSTRAINT npmrds_y2016m05_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2016m05 CLUSTER ON npmrds_y2016m05_pkey;


--
-- Name: npmrds_y2016m06 npmrds_y2016m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m06
    ADD CONSTRAINT npmrds_y2016m06_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2016m06 CLUSTER ON npmrds_y2016m06_pkey;


--
-- Name: npmrds_y2016m07 npmrds_y2016m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m07
    ADD CONSTRAINT npmrds_y2016m07_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2016m07 CLUSTER ON npmrds_y2016m07_pkey;


--
-- Name: npmrds_y2016m08 npmrds_y2016m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m08
    ADD CONSTRAINT npmrds_y2016m08_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2016m08 CLUSTER ON npmrds_y2016m08_pkey;


--
-- Name: npmrds_y2016m09 npmrds_y2016m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m09
    ADD CONSTRAINT npmrds_y2016m09_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2016m09 CLUSTER ON npmrds_y2016m09_pkey;


--
-- Name: npmrds_y2016m10 npmrds_y2016m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m10
    ADD CONSTRAINT npmrds_y2016m10_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2016m10 CLUSTER ON npmrds_y2016m10_pkey;


--
-- Name: npmrds_y2016m11 npmrds_y2016m11_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m11
    ADD CONSTRAINT npmrds_y2016m11_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2016m11 CLUSTER ON npmrds_y2016m11_pkey;


--
-- Name: npmrds_y2016m12 npmrds_y2016m12_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2016m12
    ADD CONSTRAINT npmrds_y2016m12_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2016m12 CLUSTER ON npmrds_y2016m12_pkey;


--
-- Name: npmrds_y2017m01 npmrds_y2017m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m01
    ADD CONSTRAINT npmrds_y2017m01_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2017m01 CLUSTER ON npmrds_y2017m01_pkey;


--
-- Name: npmrds_y2017m02 npmrds_y2017m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m02
    ADD CONSTRAINT npmrds_y2017m02_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2017m02 CLUSTER ON npmrds_y2017m02_pkey;


--
-- Name: npmrds_y2017m03 npmrds_y2017m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m03
    ADD CONSTRAINT npmrds_y2017m03_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2017m03 CLUSTER ON npmrds_y2017m03_pkey;


--
-- Name: npmrds_y2017m04 npmrds_y2017m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m04
    ADD CONSTRAINT npmrds_y2017m04_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2017m04 CLUSTER ON npmrds_y2017m04_pkey;


--
-- Name: npmrds_y2017m05 npmrds_y2017m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m05
    ADD CONSTRAINT npmrds_y2017m05_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2017m05 CLUSTER ON npmrds_y2017m05_pkey;


--
-- Name: npmrds_y2017m06 npmrds_y2017m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m06
    ADD CONSTRAINT npmrds_y2017m06_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2017m06 CLUSTER ON npmrds_y2017m06_pkey;


--
-- Name: npmrds_y2017m07 npmrds_y2017m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m07
    ADD CONSTRAINT npmrds_y2017m07_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2017m07 CLUSTER ON npmrds_y2017m07_pkey;


--
-- Name: npmrds_y2017m08 npmrds_y2017m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m08
    ADD CONSTRAINT npmrds_y2017m08_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2017m08 CLUSTER ON npmrds_y2017m08_pkey;


--
-- Name: npmrds_y2017m09 npmrds_y2017m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m09
    ADD CONSTRAINT npmrds_y2017m09_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2017m09 CLUSTER ON npmrds_y2017m09_pkey;


--
-- Name: npmrds_y2017m10 npmrds_y2017m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY npmrds_y2017m10
    ADD CONSTRAINT npmrds_y2017m10_pkey PRIMARY KEY (tmc, date, epoch);

ALTER TABLE npmrds_y2017m10 CLUSTER ON npmrds_y2017m10_pkey;


--
-- Name: occupancy_factor pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY occupancy_factor
    ADD CONSTRAINT pkey PRIMARY KEY (geography_level, geography_level_name);


--
-- Name: region_to_county region_to_county_pk; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY region_to_county
    ADD CONSTRAINT region_to_county_pk PRIMARY KEY (county, state);


--
-- Name: regions regions_state_pk; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY regions
    ADD CONSTRAINT regions_state_pk PRIMARY KEY (id);


--
-- Name: tmc_attributes tmc_attributes_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tmc_attributes
    ADD CONSTRAINT tmc_attributes_pkey PRIMARY KEY (tmc);

ALTER TABLE tmc_attributes CLUSTER ON tmc_attributes_pkey;


--
-- Name: tmc_date_ranges tmc_date_ranges_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tmc_date_ranges
    ADD CONSTRAINT tmc_date_ranges_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tmc_date_ranges CLUSTER ON tmc_date_ranges_pkey;


--
-- Name: top_level_total_excessive_delay_y2015m00 top_level_excessive_delay_y2015m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2015m00
    ADD CONSTRAINT top_level_excessive_delay_y2015m00_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2015m00 CLUSTER ON top_level_excessive_delay_y2015m00_pkey;


--
-- Name: top_level_total_excessive_delay_y2015m01 top_level_excessive_delay_y2015m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2015m01
    ADD CONSTRAINT top_level_excessive_delay_y2015m01_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2015m01 CLUSTER ON top_level_excessive_delay_y2015m01_pkey;


--
-- Name: top_level_total_excessive_delay_y2015m02 top_level_excessive_delay_y2015m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2015m02
    ADD CONSTRAINT top_level_excessive_delay_y2015m02_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2015m02 CLUSTER ON top_level_excessive_delay_y2015m02_pkey;


--
-- Name: top_level_total_excessive_delay_y2015m03 top_level_excessive_delay_y2015m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2015m03
    ADD CONSTRAINT top_level_excessive_delay_y2015m03_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2015m03 CLUSTER ON top_level_excessive_delay_y2015m03_pkey;


--
-- Name: top_level_total_excessive_delay_y2015m04 top_level_excessive_delay_y2015m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2015m04
    ADD CONSTRAINT top_level_excessive_delay_y2015m04_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2015m04 CLUSTER ON top_level_excessive_delay_y2015m04_pkey;


--
-- Name: top_level_total_excessive_delay_y2015m05 top_level_excessive_delay_y2015m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2015m05
    ADD CONSTRAINT top_level_excessive_delay_y2015m05_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2015m05 CLUSTER ON top_level_excessive_delay_y2015m05_pkey;


--
-- Name: top_level_total_excessive_delay_y2015m06 top_level_excessive_delay_y2015m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2015m06
    ADD CONSTRAINT top_level_excessive_delay_y2015m06_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2015m06 CLUSTER ON top_level_excessive_delay_y2015m06_pkey;


--
-- Name: top_level_total_excessive_delay_y2015m07 top_level_excessive_delay_y2015m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2015m07
    ADD CONSTRAINT top_level_excessive_delay_y2015m07_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2015m07 CLUSTER ON top_level_excessive_delay_y2015m07_pkey;


--
-- Name: top_level_total_excessive_delay_y2015m08 top_level_excessive_delay_y2015m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2015m08
    ADD CONSTRAINT top_level_excessive_delay_y2015m08_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2015m08 CLUSTER ON top_level_excessive_delay_y2015m08_pkey;


--
-- Name: top_level_total_excessive_delay_y2015m09 top_level_excessive_delay_y2015m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2015m09
    ADD CONSTRAINT top_level_excessive_delay_y2015m09_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2015m09 CLUSTER ON top_level_excessive_delay_y2015m09_pkey;


--
-- Name: top_level_total_excessive_delay_y2015m10 top_level_excessive_delay_y2015m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2015m10
    ADD CONSTRAINT top_level_excessive_delay_y2015m10_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2015m10 CLUSTER ON top_level_excessive_delay_y2015m10_pkey;


--
-- Name: top_level_total_excessive_delay_y2015m11 top_level_excessive_delay_y2015m11_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2015m11
    ADD CONSTRAINT top_level_excessive_delay_y2015m11_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2015m11 CLUSTER ON top_level_excessive_delay_y2015m11_pkey;


--
-- Name: top_level_total_excessive_delay_y2015m12 top_level_excessive_delay_y2015m12_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2015m12
    ADD CONSTRAINT top_level_excessive_delay_y2015m12_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2015m12 CLUSTER ON top_level_excessive_delay_y2015m12_pkey;


--
-- Name: top_level_total_excessive_delay_y2016m00 top_level_excessive_delay_y2016m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2016m00
    ADD CONSTRAINT top_level_excessive_delay_y2016m00_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2016m00 CLUSTER ON top_level_excessive_delay_y2016m00_pkey;


--
-- Name: top_level_total_excessive_delay_y2016m01 top_level_excessive_delay_y2016m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2016m01
    ADD CONSTRAINT top_level_excessive_delay_y2016m01_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2016m01 CLUSTER ON top_level_excessive_delay_y2016m01_pkey;


--
-- Name: top_level_total_excessive_delay_y2016m02 top_level_excessive_delay_y2016m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2016m02
    ADD CONSTRAINT top_level_excessive_delay_y2016m02_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2016m02 CLUSTER ON top_level_excessive_delay_y2016m02_pkey;


--
-- Name: top_level_total_excessive_delay_y2016m03 top_level_excessive_delay_y2016m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2016m03
    ADD CONSTRAINT top_level_excessive_delay_y2016m03_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2016m03 CLUSTER ON top_level_excessive_delay_y2016m03_pkey;


--
-- Name: top_level_total_excessive_delay_y2016m04 top_level_excessive_delay_y2016m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2016m04
    ADD CONSTRAINT top_level_excessive_delay_y2016m04_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2016m04 CLUSTER ON top_level_excessive_delay_y2016m04_pkey;


--
-- Name: top_level_total_excessive_delay_y2016m05 top_level_excessive_delay_y2016m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2016m05
    ADD CONSTRAINT top_level_excessive_delay_y2016m05_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2016m05 CLUSTER ON top_level_excessive_delay_y2016m05_pkey;


--
-- Name: top_level_total_excessive_delay_y2016m06 top_level_excessive_delay_y2016m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2016m06
    ADD CONSTRAINT top_level_excessive_delay_y2016m06_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2016m06 CLUSTER ON top_level_excessive_delay_y2016m06_pkey;


--
-- Name: top_level_total_excessive_delay_y2016m07 top_level_excessive_delay_y2016m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2016m07
    ADD CONSTRAINT top_level_excessive_delay_y2016m07_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2016m07 CLUSTER ON top_level_excessive_delay_y2016m07_pkey;


--
-- Name: top_level_total_excessive_delay_y2016m08 top_level_excessive_delay_y2016m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2016m08
    ADD CONSTRAINT top_level_excessive_delay_y2016m08_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2016m08 CLUSTER ON top_level_excessive_delay_y2016m08_pkey;


--
-- Name: top_level_total_excessive_delay_y2016m09 top_level_excessive_delay_y2016m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2016m09
    ADD CONSTRAINT top_level_excessive_delay_y2016m09_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2016m09 CLUSTER ON top_level_excessive_delay_y2016m09_pkey;


--
-- Name: top_level_total_excessive_delay_y2016m10 top_level_excessive_delay_y2016m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2016m10
    ADD CONSTRAINT top_level_excessive_delay_y2016m10_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2016m10 CLUSTER ON top_level_excessive_delay_y2016m10_pkey;


--
-- Name: top_level_total_excessive_delay_y2016m11 top_level_excessive_delay_y2016m11_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2016m11
    ADD CONSTRAINT top_level_excessive_delay_y2016m11_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2016m11 CLUSTER ON top_level_excessive_delay_y2016m11_pkey;


--
-- Name: top_level_total_excessive_delay_y2016m12 top_level_excessive_delay_y2016m12_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2016m12
    ADD CONSTRAINT top_level_excessive_delay_y2016m12_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2016m12 CLUSTER ON top_level_excessive_delay_y2016m12_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m00 top_level_excessive_delay_y2017m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m00
    ADD CONSTRAINT top_level_excessive_delay_y2017m00_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m00 CLUSTER ON top_level_excessive_delay_y2017m00_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m01 top_level_excessive_delay_y2017m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m01
    ADD CONSTRAINT top_level_excessive_delay_y2017m01_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m01 CLUSTER ON top_level_excessive_delay_y2017m01_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m02 top_level_excessive_delay_y2017m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m02
    ADD CONSTRAINT top_level_excessive_delay_y2017m02_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m02 CLUSTER ON top_level_excessive_delay_y2017m02_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m03 top_level_excessive_delay_y2017m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m03
    ADD CONSTRAINT top_level_excessive_delay_y2017m03_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m03 CLUSTER ON top_level_excessive_delay_y2017m03_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m04 top_level_excessive_delay_y2017m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m04
    ADD CONSTRAINT top_level_excessive_delay_y2017m04_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m04 CLUSTER ON top_level_excessive_delay_y2017m04_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m05 top_level_excessive_delay_y2017m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m05
    ADD CONSTRAINT top_level_excessive_delay_y2017m05_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m05 CLUSTER ON top_level_excessive_delay_y2017m05_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m06 top_level_excessive_delay_y2017m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m06
    ADD CONSTRAINT top_level_excessive_delay_y2017m06_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m06 CLUSTER ON top_level_excessive_delay_y2017m06_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m07 top_level_excessive_delay_y2017m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m07
    ADD CONSTRAINT top_level_excessive_delay_y2017m07_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m07 CLUSTER ON top_level_excessive_delay_y2017m07_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m08 top_level_excessive_delay_y2017m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m08
    ADD CONSTRAINT top_level_excessive_delay_y2017m08_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m08 CLUSTER ON top_level_excessive_delay_y2017m08_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m09 top_level_excessive_delay_y2017m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m09
    ADD CONSTRAINT top_level_excessive_delay_y2017m09_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m09 CLUSTER ON top_level_excessive_delay_y2017m09_pkey;


--
-- Name: top_level_total_excessive_delay_y2017m10 top_level_excessive_delay_y2017m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_total_excessive_delay_y2017m10
    ADD CONSTRAINT top_level_excessive_delay_y2017m10_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_total_excessive_delay_y2017m10 CLUSTER ON top_level_excessive_delay_y2017m10_pkey;


--
-- Name: top_level_freight_reliability_y2015m00 top_level_freight_reliability_y2015m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2015m00
    ADD CONSTRAINT top_level_freight_reliability_y2015m00_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2015m00 CLUSTER ON top_level_freight_reliability_y2015m00_pkey;


--
-- Name: top_level_freight_reliability_y2015m01 top_level_freight_reliability_y2015m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2015m01
    ADD CONSTRAINT top_level_freight_reliability_y2015m01_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2015m01 CLUSTER ON top_level_freight_reliability_y2015m01_pkey;


--
-- Name: top_level_freight_reliability_y2015m02 top_level_freight_reliability_y2015m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2015m02
    ADD CONSTRAINT top_level_freight_reliability_y2015m02_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2015m02 CLUSTER ON top_level_freight_reliability_y2015m02_pkey;


--
-- Name: top_level_freight_reliability_y2015m03 top_level_freight_reliability_y2015m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2015m03
    ADD CONSTRAINT top_level_freight_reliability_y2015m03_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2015m03 CLUSTER ON top_level_freight_reliability_y2015m03_pkey;


--
-- Name: top_level_freight_reliability_y2015m04 top_level_freight_reliability_y2015m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2015m04
    ADD CONSTRAINT top_level_freight_reliability_y2015m04_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2015m04 CLUSTER ON top_level_freight_reliability_y2015m04_pkey;


--
-- Name: top_level_freight_reliability_y2015m05 top_level_freight_reliability_y2015m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2015m05
    ADD CONSTRAINT top_level_freight_reliability_y2015m05_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2015m05 CLUSTER ON top_level_freight_reliability_y2015m05_pkey;


--
-- Name: top_level_freight_reliability_y2015m06 top_level_freight_reliability_y2015m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2015m06
    ADD CONSTRAINT top_level_freight_reliability_y2015m06_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2015m06 CLUSTER ON top_level_freight_reliability_y2015m06_pkey;


--
-- Name: top_level_freight_reliability_y2015m07 top_level_freight_reliability_y2015m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2015m07
    ADD CONSTRAINT top_level_freight_reliability_y2015m07_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2015m07 CLUSTER ON top_level_freight_reliability_y2015m07_pkey;


--
-- Name: top_level_freight_reliability_y2015m08 top_level_freight_reliability_y2015m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2015m08
    ADD CONSTRAINT top_level_freight_reliability_y2015m08_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2015m08 CLUSTER ON top_level_freight_reliability_y2015m08_pkey;


--
-- Name: top_level_freight_reliability_y2015m09 top_level_freight_reliability_y2015m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2015m09
    ADD CONSTRAINT top_level_freight_reliability_y2015m09_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2015m09 CLUSTER ON top_level_freight_reliability_y2015m09_pkey;


--
-- Name: top_level_freight_reliability_y2015m10 top_level_freight_reliability_y2015m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2015m10
    ADD CONSTRAINT top_level_freight_reliability_y2015m10_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2015m10 CLUSTER ON top_level_freight_reliability_y2015m10_pkey;


--
-- Name: top_level_freight_reliability_y2015m11 top_level_freight_reliability_y2015m11_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2015m11
    ADD CONSTRAINT top_level_freight_reliability_y2015m11_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2015m11 CLUSTER ON top_level_freight_reliability_y2015m11_pkey;


--
-- Name: top_level_freight_reliability_y2015m12 top_level_freight_reliability_y2015m12_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2015m12
    ADD CONSTRAINT top_level_freight_reliability_y2015m12_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2015m12 CLUSTER ON top_level_freight_reliability_y2015m12_pkey;


--
-- Name: top_level_freight_reliability_y2016m00 top_level_freight_reliability_y2016m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2016m00
    ADD CONSTRAINT top_level_freight_reliability_y2016m00_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2016m00 CLUSTER ON top_level_freight_reliability_y2016m00_pkey;


--
-- Name: top_level_freight_reliability_y2016m01 top_level_freight_reliability_y2016m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2016m01
    ADD CONSTRAINT top_level_freight_reliability_y2016m01_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2016m01 CLUSTER ON top_level_freight_reliability_y2016m01_pkey;


--
-- Name: top_level_freight_reliability_y2016m02 top_level_freight_reliability_y2016m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2016m02
    ADD CONSTRAINT top_level_freight_reliability_y2016m02_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2016m02 CLUSTER ON top_level_freight_reliability_y2016m02_pkey;


--
-- Name: top_level_freight_reliability_y2016m03 top_level_freight_reliability_y2016m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2016m03
    ADD CONSTRAINT top_level_freight_reliability_y2016m03_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2016m03 CLUSTER ON top_level_freight_reliability_y2016m03_pkey;


--
-- Name: top_level_freight_reliability_y2016m04 top_level_freight_reliability_y2016m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2016m04
    ADD CONSTRAINT top_level_freight_reliability_y2016m04_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2016m04 CLUSTER ON top_level_freight_reliability_y2016m04_pkey;


--
-- Name: top_level_freight_reliability_y2016m05 top_level_freight_reliability_y2016m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2016m05
    ADD CONSTRAINT top_level_freight_reliability_y2016m05_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2016m05 CLUSTER ON top_level_freight_reliability_y2016m05_pkey;


--
-- Name: top_level_freight_reliability_y2016m06 top_level_freight_reliability_y2016m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2016m06
    ADD CONSTRAINT top_level_freight_reliability_y2016m06_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2016m06 CLUSTER ON top_level_freight_reliability_y2016m06_pkey;


--
-- Name: top_level_freight_reliability_y2016m07 top_level_freight_reliability_y2016m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2016m07
    ADD CONSTRAINT top_level_freight_reliability_y2016m07_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2016m07 CLUSTER ON top_level_freight_reliability_y2016m07_pkey;


--
-- Name: top_level_freight_reliability_y2016m08 top_level_freight_reliability_y2016m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2016m08
    ADD CONSTRAINT top_level_freight_reliability_y2016m08_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2016m08 CLUSTER ON top_level_freight_reliability_y2016m08_pkey;


--
-- Name: top_level_freight_reliability_y2016m09 top_level_freight_reliability_y2016m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2016m09
    ADD CONSTRAINT top_level_freight_reliability_y2016m09_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2016m09 CLUSTER ON top_level_freight_reliability_y2016m09_pkey;


--
-- Name: top_level_freight_reliability_y2016m10 top_level_freight_reliability_y2016m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2016m10
    ADD CONSTRAINT top_level_freight_reliability_y2016m10_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2016m10 CLUSTER ON top_level_freight_reliability_y2016m10_pkey;


--
-- Name: top_level_freight_reliability_y2016m11 top_level_freight_reliability_y2016m11_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2016m11
    ADD CONSTRAINT top_level_freight_reliability_y2016m11_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2016m11 CLUSTER ON top_level_freight_reliability_y2016m11_pkey;


--
-- Name: top_level_freight_reliability_y2016m12 top_level_freight_reliability_y2016m12_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2016m12
    ADD CONSTRAINT top_level_freight_reliability_y2016m12_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2016m12 CLUSTER ON top_level_freight_reliability_y2016m12_pkey;


--
-- Name: top_level_freight_reliability_y2017m00 top_level_freight_reliability_y2017m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m00
    ADD CONSTRAINT top_level_freight_reliability_y2017m00_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m00 CLUSTER ON top_level_freight_reliability_y2017m00_pkey;


--
-- Name: top_level_freight_reliability_y2017m01 top_level_freight_reliability_y2017m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m01
    ADD CONSTRAINT top_level_freight_reliability_y2017m01_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m01 CLUSTER ON top_level_freight_reliability_y2017m01_pkey;


--
-- Name: top_level_freight_reliability_y2017m02 top_level_freight_reliability_y2017m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m02
    ADD CONSTRAINT top_level_freight_reliability_y2017m02_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m02 CLUSTER ON top_level_freight_reliability_y2017m02_pkey;


--
-- Name: top_level_freight_reliability_y2017m03 top_level_freight_reliability_y2017m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m03
    ADD CONSTRAINT top_level_freight_reliability_y2017m03_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m03 CLUSTER ON top_level_freight_reliability_y2017m03_pkey;


--
-- Name: top_level_freight_reliability_y2017m04 top_level_freight_reliability_y2017m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m04
    ADD CONSTRAINT top_level_freight_reliability_y2017m04_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m04 CLUSTER ON top_level_freight_reliability_y2017m04_pkey;


--
-- Name: top_level_freight_reliability_y2017m05 top_level_freight_reliability_y2017m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m05
    ADD CONSTRAINT top_level_freight_reliability_y2017m05_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m05 CLUSTER ON top_level_freight_reliability_y2017m05_pkey;


--
-- Name: top_level_freight_reliability_y2017m06 top_level_freight_reliability_y2017m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m06
    ADD CONSTRAINT top_level_freight_reliability_y2017m06_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m06 CLUSTER ON top_level_freight_reliability_y2017m06_pkey;


--
-- Name: top_level_freight_reliability_y2017m07 top_level_freight_reliability_y2017m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m07
    ADD CONSTRAINT top_level_freight_reliability_y2017m07_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m07 CLUSTER ON top_level_freight_reliability_y2017m07_pkey;


--
-- Name: top_level_freight_reliability_y2017m08 top_level_freight_reliability_y2017m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m08
    ADD CONSTRAINT top_level_freight_reliability_y2017m08_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m08 CLUSTER ON top_level_freight_reliability_y2017m08_pkey;


--
-- Name: top_level_freight_reliability_y2017m09 top_level_freight_reliability_y2017m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m09
    ADD CONSTRAINT top_level_freight_reliability_y2017m09_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m09 CLUSTER ON top_level_freight_reliability_y2017m09_pkey;


--
-- Name: top_level_freight_reliability_y2017m10 top_level_freight_reliability_y2017m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_freight_reliability_y2017m10
    ADD CONSTRAINT top_level_freight_reliability_y2017m10_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_freight_reliability_y2017m10 CLUSTER ON top_level_freight_reliability_y2017m10_pkey;


--
-- Name: top_level_travel_time_reliability_y2015m00 top_level_travel_time_reliability_y2015m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2015m00
    ADD CONSTRAINT top_level_travel_time_reliability_y2015m00_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2015m00 CLUSTER ON top_level_travel_time_reliability_y2015m00_pkey;


--
-- Name: top_level_travel_time_reliability_y2015m01 top_level_travel_time_reliability_y2015m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2015m01
    ADD CONSTRAINT top_level_travel_time_reliability_y2015m01_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2015m01 CLUSTER ON top_level_travel_time_reliability_y2015m01_pkey;


--
-- Name: top_level_travel_time_reliability_y2015m02 top_level_travel_time_reliability_y2015m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2015m02
    ADD CONSTRAINT top_level_travel_time_reliability_y2015m02_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2015m02 CLUSTER ON top_level_travel_time_reliability_y2015m02_pkey;


--
-- Name: top_level_travel_time_reliability_y2015m03 top_level_travel_time_reliability_y2015m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2015m03
    ADD CONSTRAINT top_level_travel_time_reliability_y2015m03_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2015m03 CLUSTER ON top_level_travel_time_reliability_y2015m03_pkey;


--
-- Name: top_level_travel_time_reliability_y2015m04 top_level_travel_time_reliability_y2015m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2015m04
    ADD CONSTRAINT top_level_travel_time_reliability_y2015m04_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2015m04 CLUSTER ON top_level_travel_time_reliability_y2015m04_pkey;


--
-- Name: top_level_travel_time_reliability_y2015m05 top_level_travel_time_reliability_y2015m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2015m05
    ADD CONSTRAINT top_level_travel_time_reliability_y2015m05_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2015m05 CLUSTER ON top_level_travel_time_reliability_y2015m05_pkey;


--
-- Name: top_level_travel_time_reliability_y2015m06 top_level_travel_time_reliability_y2015m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2015m06
    ADD CONSTRAINT top_level_travel_time_reliability_y2015m06_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2015m06 CLUSTER ON top_level_travel_time_reliability_y2015m06_pkey;


--
-- Name: top_level_travel_time_reliability_y2015m07 top_level_travel_time_reliability_y2015m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2015m07
    ADD CONSTRAINT top_level_travel_time_reliability_y2015m07_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2015m07 CLUSTER ON top_level_travel_time_reliability_y2015m07_pkey;


--
-- Name: top_level_travel_time_reliability_y2015m08 top_level_travel_time_reliability_y2015m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2015m08
    ADD CONSTRAINT top_level_travel_time_reliability_y2015m08_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2015m08 CLUSTER ON top_level_travel_time_reliability_y2015m08_pkey;


--
-- Name: top_level_travel_time_reliability_y2015m09 top_level_travel_time_reliability_y2015m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2015m09
    ADD CONSTRAINT top_level_travel_time_reliability_y2015m09_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2015m09 CLUSTER ON top_level_travel_time_reliability_y2015m09_pkey;


--
-- Name: top_level_travel_time_reliability_y2015m10 top_level_travel_time_reliability_y2015m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2015m10
    ADD CONSTRAINT top_level_travel_time_reliability_y2015m10_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2015m10 CLUSTER ON top_level_travel_time_reliability_y2015m10_pkey;


--
-- Name: top_level_travel_time_reliability_y2015m11 top_level_travel_time_reliability_y2015m11_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2015m11
    ADD CONSTRAINT top_level_travel_time_reliability_y2015m11_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2015m11 CLUSTER ON top_level_travel_time_reliability_y2015m11_pkey;


--
-- Name: top_level_travel_time_reliability_y2015m12 top_level_travel_time_reliability_y2015m12_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2015m12
    ADD CONSTRAINT top_level_travel_time_reliability_y2015m12_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2015m12 CLUSTER ON top_level_travel_time_reliability_y2015m12_pkey;


--
-- Name: top_level_travel_time_reliability_y2016m00 top_level_travel_time_reliability_y2016m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2016m00
    ADD CONSTRAINT top_level_travel_time_reliability_y2016m00_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2016m00 CLUSTER ON top_level_travel_time_reliability_y2016m00_pkey;


--
-- Name: top_level_travel_time_reliability_y2016m01 top_level_travel_time_reliability_y2016m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2016m01
    ADD CONSTRAINT top_level_travel_time_reliability_y2016m01_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2016m01 CLUSTER ON top_level_travel_time_reliability_y2016m01_pkey;


--
-- Name: top_level_travel_time_reliability_y2016m02 top_level_travel_time_reliability_y2016m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2016m02
    ADD CONSTRAINT top_level_travel_time_reliability_y2016m02_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2016m02 CLUSTER ON top_level_travel_time_reliability_y2016m02_pkey;


--
-- Name: top_level_travel_time_reliability_y2016m03 top_level_travel_time_reliability_y2016m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2016m03
    ADD CONSTRAINT top_level_travel_time_reliability_y2016m03_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2016m03 CLUSTER ON top_level_travel_time_reliability_y2016m03_pkey;


--
-- Name: top_level_travel_time_reliability_y2016m04 top_level_travel_time_reliability_y2016m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2016m04
    ADD CONSTRAINT top_level_travel_time_reliability_y2016m04_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2016m04 CLUSTER ON top_level_travel_time_reliability_y2016m04_pkey;


--
-- Name: top_level_travel_time_reliability_y2016m05 top_level_travel_time_reliability_y2016m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2016m05
    ADD CONSTRAINT top_level_travel_time_reliability_y2016m05_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2016m05 CLUSTER ON top_level_travel_time_reliability_y2016m05_pkey;


--
-- Name: top_level_travel_time_reliability_y2016m06 top_level_travel_time_reliability_y2016m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2016m06
    ADD CONSTRAINT top_level_travel_time_reliability_y2016m06_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2016m06 CLUSTER ON top_level_travel_time_reliability_y2016m06_pkey;


--
-- Name: top_level_travel_time_reliability_y2016m07 top_level_travel_time_reliability_y2016m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2016m07
    ADD CONSTRAINT top_level_travel_time_reliability_y2016m07_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2016m07 CLUSTER ON top_level_travel_time_reliability_y2016m07_pkey;


--
-- Name: top_level_travel_time_reliability_y2016m08 top_level_travel_time_reliability_y2016m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2016m08
    ADD CONSTRAINT top_level_travel_time_reliability_y2016m08_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2016m08 CLUSTER ON top_level_travel_time_reliability_y2016m08_pkey;


--
-- Name: top_level_travel_time_reliability_y2016m09 top_level_travel_time_reliability_y2016m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2016m09
    ADD CONSTRAINT top_level_travel_time_reliability_y2016m09_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2016m09 CLUSTER ON top_level_travel_time_reliability_y2016m09_pkey;


--
-- Name: top_level_travel_time_reliability_y2016m10 top_level_travel_time_reliability_y2016m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2016m10
    ADD CONSTRAINT top_level_travel_time_reliability_y2016m10_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2016m10 CLUSTER ON top_level_travel_time_reliability_y2016m10_pkey;


--
-- Name: top_level_travel_time_reliability_y2016m11 top_level_travel_time_reliability_y2016m11_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2016m11
    ADD CONSTRAINT top_level_travel_time_reliability_y2016m11_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2016m11 CLUSTER ON top_level_travel_time_reliability_y2016m11_pkey;


--
-- Name: top_level_travel_time_reliability_y2016m12 top_level_travel_time_reliability_y2016m12_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2016m12
    ADD CONSTRAINT top_level_travel_time_reliability_y2016m12_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2016m12 CLUSTER ON top_level_travel_time_reliability_y2016m12_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m00 top_level_travel_time_reliability_y2017m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m00
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m00_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m00 CLUSTER ON top_level_travel_time_reliability_y2017m00_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m01 top_level_travel_time_reliability_y2017m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m01
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m01_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m01 CLUSTER ON top_level_travel_time_reliability_y2017m01_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m02 top_level_travel_time_reliability_y2017m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m02
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m02_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m02 CLUSTER ON top_level_travel_time_reliability_y2017m02_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m03 top_level_travel_time_reliability_y2017m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m03
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m03_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m03 CLUSTER ON top_level_travel_time_reliability_y2017m03_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m04 top_level_travel_time_reliability_y2017m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m04
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m04_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m04 CLUSTER ON top_level_travel_time_reliability_y2017m04_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m05 top_level_travel_time_reliability_y2017m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m05
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m05_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m05 CLUSTER ON top_level_travel_time_reliability_y2017m05_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m06 top_level_travel_time_reliability_y2017m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m06
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m06_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m06 CLUSTER ON top_level_travel_time_reliability_y2017m06_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m07 top_level_travel_time_reliability_y2017m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m07
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m07_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m07 CLUSTER ON top_level_travel_time_reliability_y2017m07_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m08 top_level_travel_time_reliability_y2017m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m08
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m08_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m08 CLUSTER ON top_level_travel_time_reliability_y2017m08_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m09 top_level_travel_time_reliability_y2017m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m09
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m09_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m09 CLUSTER ON top_level_travel_time_reliability_y2017m09_pkey;


--
-- Name: top_level_travel_time_reliability_y2017m10 top_level_travel_time_reliability_y2017m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY top_level_travel_time_reliability_y2017m10
    ADD CONSTRAINT top_level_travel_time_reliability_y2017m10_pkey PRIMARY KEY (geography_level, geography_name, functional_class) WITH (fillfactor='100');

ALTER TABLE top_level_travel_time_reliability_y2017m10 CLUSTER ON top_level_travel_time_reliability_y2017m10_pkey;


--
-- Name: tttr_percentiles_y2015m00 tttr_percentiles_y2015m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2015m00
    ADD CONSTRAINT tttr_percentiles_y2015m00_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2015m00 CLUSTER ON tttr_percentiles_y2015m00_pkey;


--
-- Name: tttr_percentiles_y2015m01 tttr_percentiles_y2015m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2015m01
    ADD CONSTRAINT tttr_percentiles_y2015m01_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2015m01 CLUSTER ON tttr_percentiles_y2015m01_pkey;


--
-- Name: tttr_percentiles_y2015m02 tttr_percentiles_y2015m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2015m02
    ADD CONSTRAINT tttr_percentiles_y2015m02_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2015m02 CLUSTER ON tttr_percentiles_y2015m02_pkey;


--
-- Name: tttr_percentiles_y2015m03 tttr_percentiles_y2015m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2015m03
    ADD CONSTRAINT tttr_percentiles_y2015m03_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2015m03 CLUSTER ON tttr_percentiles_y2015m03_pkey;


--
-- Name: tttr_percentiles_y2015m04 tttr_percentiles_y2015m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2015m04
    ADD CONSTRAINT tttr_percentiles_y2015m04_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2015m04 CLUSTER ON tttr_percentiles_y2015m04_pkey;


--
-- Name: tttr_percentiles_y2015m05 tttr_percentiles_y2015m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2015m05
    ADD CONSTRAINT tttr_percentiles_y2015m05_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2015m05 CLUSTER ON tttr_percentiles_y2015m05_pkey;


--
-- Name: tttr_percentiles_y2015m06 tttr_percentiles_y2015m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2015m06
    ADD CONSTRAINT tttr_percentiles_y2015m06_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2015m06 CLUSTER ON tttr_percentiles_y2015m06_pkey;


--
-- Name: tttr_percentiles_y2015m07 tttr_percentiles_y2015m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2015m07
    ADD CONSTRAINT tttr_percentiles_y2015m07_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2015m07 CLUSTER ON tttr_percentiles_y2015m07_pkey;


--
-- Name: tttr_percentiles_y2015m08 tttr_percentiles_y2015m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2015m08
    ADD CONSTRAINT tttr_percentiles_y2015m08_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2015m08 CLUSTER ON tttr_percentiles_y2015m08_pkey;


--
-- Name: tttr_percentiles_y2015m09 tttr_percentiles_y2015m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2015m09
    ADD CONSTRAINT tttr_percentiles_y2015m09_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2015m09 CLUSTER ON tttr_percentiles_y2015m09_pkey;


--
-- Name: tttr_percentiles_y2015m10 tttr_percentiles_y2015m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2015m10
    ADD CONSTRAINT tttr_percentiles_y2015m10_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2015m10 CLUSTER ON tttr_percentiles_y2015m10_pkey;


--
-- Name: tttr_percentiles_y2015m11 tttr_percentiles_y2015m11_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2015m11
    ADD CONSTRAINT tttr_percentiles_y2015m11_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2015m11 CLUSTER ON tttr_percentiles_y2015m11_pkey;


--
-- Name: tttr_percentiles_y2015m12 tttr_percentiles_y2015m12_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2015m12
    ADD CONSTRAINT tttr_percentiles_y2015m12_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2015m12 CLUSTER ON tttr_percentiles_y2015m12_pkey;


--
-- Name: tttr_percentiles_y2016m00 tttr_percentiles_y2016m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2016m00
    ADD CONSTRAINT tttr_percentiles_y2016m00_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2016m00 CLUSTER ON tttr_percentiles_y2016m00_pkey;


--
-- Name: tttr_percentiles_y2016m01 tttr_percentiles_y2016m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2016m01
    ADD CONSTRAINT tttr_percentiles_y2016m01_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2016m01 CLUSTER ON tttr_percentiles_y2016m01_pkey;


--
-- Name: tttr_percentiles_y2016m02 tttr_percentiles_y2016m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2016m02
    ADD CONSTRAINT tttr_percentiles_y2016m02_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2016m02 CLUSTER ON tttr_percentiles_y2016m02_pkey;


--
-- Name: tttr_percentiles_y2016m03 tttr_percentiles_y2016m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2016m03
    ADD CONSTRAINT tttr_percentiles_y2016m03_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2016m03 CLUSTER ON tttr_percentiles_y2016m03_pkey;


--
-- Name: tttr_percentiles_y2016m04 tttr_percentiles_y2016m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2016m04
    ADD CONSTRAINT tttr_percentiles_y2016m04_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2016m04 CLUSTER ON tttr_percentiles_y2016m04_pkey;


--
-- Name: tttr_percentiles_y2016m05 tttr_percentiles_y2016m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2016m05
    ADD CONSTRAINT tttr_percentiles_y2016m05_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2016m05 CLUSTER ON tttr_percentiles_y2016m05_pkey;


--
-- Name: tttr_percentiles_y2016m06 tttr_percentiles_y2016m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2016m06
    ADD CONSTRAINT tttr_percentiles_y2016m06_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2016m06 CLUSTER ON tttr_percentiles_y2016m06_pkey;


--
-- Name: tttr_percentiles_y2016m07 tttr_percentiles_y2016m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2016m07
    ADD CONSTRAINT tttr_percentiles_y2016m07_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2016m07 CLUSTER ON tttr_percentiles_y2016m07_pkey;


--
-- Name: tttr_percentiles_y2016m08 tttr_percentiles_y2016m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2016m08
    ADD CONSTRAINT tttr_percentiles_y2016m08_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2016m08 CLUSTER ON tttr_percentiles_y2016m08_pkey;


--
-- Name: tttr_percentiles_y2016m09 tttr_percentiles_y2016m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2016m09
    ADD CONSTRAINT tttr_percentiles_y2016m09_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2016m09 CLUSTER ON tttr_percentiles_y2016m09_pkey;


--
-- Name: tttr_percentiles_y2016m10 tttr_percentiles_y2016m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2016m10
    ADD CONSTRAINT tttr_percentiles_y2016m10_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2016m10 CLUSTER ON tttr_percentiles_y2016m10_pkey;


--
-- Name: tttr_percentiles_y2016m11 tttr_percentiles_y2016m11_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2016m11
    ADD CONSTRAINT tttr_percentiles_y2016m11_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2016m11 CLUSTER ON tttr_percentiles_y2016m11_pkey;


--
-- Name: tttr_percentiles_y2016m12 tttr_percentiles_y2016m12_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2016m12
    ADD CONSTRAINT tttr_percentiles_y2016m12_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2016m12 CLUSTER ON tttr_percentiles_y2016m12_pkey;


--
-- Name: tttr_percentiles_y2017m00 tttr_percentiles_y2017m00_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m00
    ADD CONSTRAINT tttr_percentiles_y2017m00_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m00 CLUSTER ON tttr_percentiles_y2017m00_pkey;


--
-- Name: tttr_percentiles_y2017m01 tttr_percentiles_y2017m01_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m01
    ADD CONSTRAINT tttr_percentiles_y2017m01_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m01 CLUSTER ON tttr_percentiles_y2017m01_pkey;


--
-- Name: tttr_percentiles_y2017m02 tttr_percentiles_y2017m02_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m02
    ADD CONSTRAINT tttr_percentiles_y2017m02_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m02 CLUSTER ON tttr_percentiles_y2017m02_pkey;


--
-- Name: tttr_percentiles_y2017m03 tttr_percentiles_y2017m03_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m03
    ADD CONSTRAINT tttr_percentiles_y2017m03_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m03 CLUSTER ON tttr_percentiles_y2017m03_pkey;


--
-- Name: tttr_percentiles_y2017m04 tttr_percentiles_y2017m04_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m04
    ADD CONSTRAINT tttr_percentiles_y2017m04_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m04 CLUSTER ON tttr_percentiles_y2017m04_pkey;


--
-- Name: tttr_percentiles_y2017m05 tttr_percentiles_y2017m05_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m05
    ADD CONSTRAINT tttr_percentiles_y2017m05_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m05 CLUSTER ON tttr_percentiles_y2017m05_pkey;


--
-- Name: tttr_percentiles_y2017m06 tttr_percentiles_y2017m06_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m06
    ADD CONSTRAINT tttr_percentiles_y2017m06_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m06 CLUSTER ON tttr_percentiles_y2017m06_pkey;


--
-- Name: tttr_percentiles_y2017m07 tttr_percentiles_y2017m07_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m07
    ADD CONSTRAINT tttr_percentiles_y2017m07_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m07 CLUSTER ON tttr_percentiles_y2017m07_pkey;


--
-- Name: tttr_percentiles_y2017m08 tttr_percentiles_y2017m08_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m08
    ADD CONSTRAINT tttr_percentiles_y2017m08_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m08 CLUSTER ON tttr_percentiles_y2017m08_pkey;


--
-- Name: tttr_percentiles_y2017m09 tttr_percentiles_y2017m09_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m09
    ADD CONSTRAINT tttr_percentiles_y2017m09_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m09 CLUSTER ON tttr_percentiles_y2017m09_pkey;


--
-- Name: tttr_percentiles_y2017m10 tttr_percentiles_y2017m10_pkey; Type: CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY tttr_percentiles_y2017m10
    ADD CONSTRAINT tttr_percentiles_y2017m10_pkey PRIMARY KEY (tmc) WITH (fillfactor='100');

ALTER TABLE tttr_percentiles_y2017m10 CLUSTER ON tttr_percentiles_y2017m10_pkey;


SET search_path = public, pg_catalog;

--
-- Name: SMTC_MPA_2013 SMTC_MPA_2013_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "SMTC_MPA_2013"
    ADD CONSTRAINT "SMTC_MPA_2013_pkey" PRIMARY KEY (id);


--
-- Name: collection collection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection
    ADD CONSTRAINT collection_pkey PRIMARY KEY (id);


--
-- Name: fips_codes fips_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fips_codes
    ADD CONSTRAINT fips_codes_pkey PRIMARY KEY (state_code, county_code);

ALTER TABLE fips_codes CLUSTER ON fips_codes_pkey;


--
-- Name: inrix_atri_measure_materialized inrix_atri_measure_materialized_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inrix_atri_measure_materialized
    ADD CONSTRAINT inrix_atri_measure_materialized_pkey PRIMARY KEY (tmc, year, month);


--
-- Name: network network_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY network
    ADD CONSTRAINT network_pkey PRIMARY KEY (id);


--
-- Name: nj inrix_shapefile_20170707 nj inrix_shapefile_20170707_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "nj inrix_shapefile_20170707"
    ADD CONSTRAINT "nj inrix_shapefile_20170707_pkey" PRIMARY KEY (ogc_fid);


--
-- Name: route route_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY route
    ADD CONSTRAINT route_pkey PRIMARY KEY (id);


--
-- Name: state_abbreviations state_abbreviations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY state_abbreviations
    ADD CONSTRAINT state_abbreviations_pkey PRIMARY KEY (state_name);


--
-- Name: tmc_routable_vertices_pgr tmc_routable_vertices_pgr_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tmc_routable_vertices_pgr
    ADD CONSTRAINT tmc_routable_vertices_pgr_pkey PRIMARY KEY (id);


--
-- Name: traffic_signals traffic_signals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY traffic_signals
    ADD CONSTRAINT traffic_signals_pkey PRIMARY KEY (id);


--
-- Name: transcom_events transcom_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transcom_events
    ADD CONSTRAINT transcom_events_pkey PRIMARY KEY (event_id);


SET search_path = us, pg_catalog;

--
-- Name: core_based_staticstical_area_boundaries_2016 core_based_staticstical_area_boundaries_2016_pkey; Type: CONSTRAINT; Schema: us; Owner: -
--

ALTER TABLE ONLY core_based_staticstical_area_boundaries_2016
    ADD CONSTRAINT core_based_staticstical_area_boundaries_2016_pkey PRIMARY KEY (ogc_fid);


--
-- Name: core_based_statistical_area_boundaries_2017 core_based_statistical_area_boundaries_2017_pkey; Type: CONSTRAINT; Schema: us; Owner: -
--

ALTER TABLE ONLY core_based_statistical_area_boundaries_2017
    ADD CONSTRAINT core_based_statistical_area_boundaries_2017_pkey PRIMARY KEY (ogc_fid);


--
-- Name: county_populations_y2015 county_populations_y2015_pkey; Type: CONSTRAINT; Schema: us; Owner: -
--

ALTER TABLE ONLY county_populations_y2015
    ADD CONSTRAINT county_populations_y2015_pkey PRIMARY KEY (state_code, county_code);

ALTER TABLE county_populations_y2015 CLUSTER ON county_populations_y2015_pkey;


--
-- Name: county_populations_y2016 county_populations_y2016_pkey; Type: CONSTRAINT; Schema: us; Owner: -
--

ALTER TABLE ONLY county_populations_y2016
    ADD CONSTRAINT county_populations_y2016_pkey PRIMARY KEY (state_code, county_code);

ALTER TABLE county_populations_y2016 CLUSTER ON county_populations_y2016_pkey;


--
-- Name: mpo_acronyms mpo_acronymns_pkey; Type: CONSTRAINT; Schema: us; Owner: -
--

ALTER TABLE ONLY mpo_acronyms
    ADD CONSTRAINT mpo_acronymns_pkey PRIMARY KEY (mpo_id);


--
-- Name: mpo_boundaries_20170928 mpo_boundaries_20170928_pkey; Type: CONSTRAINT; Schema: us; Owner: -
--

ALTER TABLE ONLY mpo_boundaries_20170928
    ADD CONSTRAINT mpo_boundaries_20170928_pkey PRIMARY KEY (ogc_fid);


--
-- Name: state_populations_y2015 state_populations_y2015_pkey; Type: CONSTRAINT; Schema: us; Owner: -
--

ALTER TABLE ONLY state_populations_y2015
    ADD CONSTRAINT state_populations_y2015_pkey PRIMARY KEY (state_code);

ALTER TABLE state_populations_y2015 CLUSTER ON state_populations_y2015_pkey;


--
-- Name: state_populations_y2016 state_populations_y2016_pkey; Type: CONSTRAINT; Schema: us; Owner: -
--

ALTER TABLE ONLY state_populations_y2016
    ADD CONSTRAINT state_populations_y2016_pkey PRIMARY KEY (state_code);

ALTER TABLE state_populations_y2016 CLUSTER ON state_populations_y2016_pkey;


--
-- Name: urban_area_boundaries_2016 urban_area_boundaries_2016_pkey; Type: CONSTRAINT; Schema: us; Owner: -
--

ALTER TABLE ONLY urban_area_boundaries_2016
    ADD CONSTRAINT urban_area_boundaries_2016_pkey PRIMARY KEY (ogc_fid);


--
-- Name: urban_area_boundaries_2017 urban_area_boundaries_2017_pkey; Type: CONSTRAINT; Schema: us; Owner: -
--

ALTER TABLE ONLY urban_area_boundaries_2017
    ADD CONSTRAINT urban_area_boundaries_2017_pkey PRIMARY KEY (ogc_fid);


--
-- Name: urban_area_populations_y2015 urban_area_populations_y2015_pkey; Type: CONSTRAINT; Schema: us; Owner: -
--

ALTER TABLE ONLY urban_area_populations_y2015
    ADD CONSTRAINT urban_area_populations_y2015_pkey PRIMARY KEY (ua_code);

ALTER TABLE urban_area_populations_y2015 CLUSTER ON urban_area_populations_y2015_pkey;


--
-- Name: urban_area_populations_y2016 urban_area_populations_y2016_pkey; Type: CONSTRAINT; Schema: us; Owner: -
--

ALTER TABLE ONLY urban_area_populations_y2016
    ADD CONSTRAINT urban_area_populations_y2016_pkey PRIMARY KEY (ua_code);

ALTER TABLE urban_area_populations_y2016 CLUSTER ON urban_area_populations_y2016_pkey;


SET search_path = nj, pg_catalog;

--
-- Name: inrix_shapefile_20170707_wkb_geometry_geom_idx; Type: INDEX; Schema: nj; Owner: -
--

CREATE INDEX inrix_shapefile_20170707_wkb_geometry_geom_idx ON inrix_shapefile_20170707 USING gist (wkb_geometry);


SET search_path = ny, pg_catalog;

--
-- Name: inrix_shapefile_20170707_wkb_geometry_geom_idx; Type: INDEX; Schema: ny; Owner: -
--

CREATE INDEX inrix_shapefile_20170707_wkb_geometry_geom_idx ON inrix_shapefile_20170707 USING gist (wkb_geometry);


--
-- Name: ny_bottleneck_effects_idx; Type: INDEX; Schema: ny; Owner: -
--

CREATE INDEX ny_bottleneck_effects_idx ON bottleneck_effects USING btree (id);


--
-- Name: ny_bottlenecks_idx; Type: INDEX; Schema: ny; Owner: -
--

CREATE INDEX ny_bottlenecks_idx ON bottlenecks USING btree (tmc, year, month);


--
-- Name: ny_bottlenecks_join_idx; Type: INDEX; Schema: ny; Owner: -
--

CREATE INDEX ny_bottlenecks_join_idx ON bottlenecks USING btree (id);


--
-- Name: ny_bottlenecks_summary_year_month_hrank_ix; Type: INDEX; Schema: ny; Owner: -
--

CREATE INDEX ny_bottlenecks_summary_year_month_hrank_ix ON bottlenecks_summary USING btree (aadttype, year, month, hrank);


--
-- Name: ny_bottlenecks_summary_year_month_mpohrank_ix; Type: INDEX; Schema: ny; Owner: -
--

CREATE INDEX ny_bottlenecks_summary_year_month_mpohrank_ix ON bottlenecks_summary USING btree (aadttype, year, month, mpohrank);


--
-- Name: transcom_events_by_tmc_gix; Type: INDEX; Schema: ny; Owner: -
--

CREATE INDEX transcom_events_by_tmc_gix ON transcom_events_by_tmc USING gist (coordinates);


--
-- Name: transcom_events_by_tmc_idx; Type: INDEX; Schema: ny; Owner: -
--

CREATE INDEX transcom_events_by_tmc_idx ON transcom_events_by_tmc USING btree (tmc, open_time) WITH (fillfactor='100');

ALTER TABLE transcom_events_by_tmc CLUSTER ON transcom_events_by_tmc_idx;


--
-- Name: year_month_lottr_ix; Type: INDEX; Schema: ny; Owner: -
--

CREATE INDEX year_month_lottr_ix ON pm_bottlenecks_summary USING btree (year, month, lottrrank);


--
-- Name: year_month_phed_ix; Type: INDEX; Schema: ny; Owner: -
--

CREATE INDEX year_month_phed_ix ON pm_bottlenecks_summary USING btree (year, month, phedrank);


--
-- Name: year_month_tttr_ix; Type: INDEX; Schema: ny; Owner: -
--

CREATE INDEX year_month_tttr_ix ON pm_bottlenecks_summary USING btree (year, month, tttrrank);


SET search_path = public, pg_catalog;

--
-- Name: inrix_atri_materialized_month_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inrix_atri_materialized_month_idx ON inrix_atri_measure_materialized USING btree (month);


--
-- Name: inrix_atri_materialized_year_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inrix_atri_materialized_year_idx ON inrix_atri_measure_materialized USING btree (year);


--
-- Name: nj inrix_shapefile_20170707_wkb_geometry_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "nj inrix_shapefile_20170707_wkb_geometry_geom_idx" ON "nj inrix_shapefile_20170707" USING gist (wkb_geometry);


--
-- Name: sidx_traffic_signals_geom; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sidx_traffic_signals_geom ON traffic_signals USING gist (geom);


--
-- Name: tmc_routable_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tmc_routable_id_idx ON tmc_routable USING btree (id);


--
-- Name: tmc_routable_source_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tmc_routable_source_idx ON tmc_routable USING btree (source);


--
-- Name: tmc_routable_target_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tmc_routable_target_idx ON tmc_routable USING btree (target);


--
-- Name: tmc_routable_the_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tmc_routable_the_geom_idx ON tmc_routable USING gist (the_geom);


--
-- Name: tmc_routable_vertices_pgr_the_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tmc_routable_vertices_pgr_the_geom_idx ON tmc_routable_vertices_pgr USING gist (the_geom);


--
-- Name: tmp_transcom_events_buffered_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tmp_transcom_events_buffered_idx ON tmp_transcom_events_buffered USING btree (buffered_geog);


--
-- Name: transcom_events_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transcom_events_date_index ON transcom_events USING btree (creation);


--
-- Name: transcom_events_geom_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transcom_events_geom_index ON transcom_events USING gist (point_geom);

ALTER TABLE transcom_events CLUSTER ON transcom_events_geom_index;


--
-- Name: transcom_events_tmc_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transcom_events_tmc_index ON transcom_events USING btree (tmc);


--
-- Name: transcom_events_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX transcom_events_year ON transcom_events USING btree (date_part('year'::text, creation), event_category);


SET search_path = us, pg_catalog;

--
-- Name: core_based_staticstical_area_boundaries_2016_wkb_geometry_geom_; Type: INDEX; Schema: us; Owner: -
--

CREATE INDEX core_based_staticstical_area_boundaries_2016_wkb_geometry_geom_ ON core_based_staticstical_area_boundaries_2016 USING gist (wkb_geometry);


--
-- Name: core_based_statistical_area_boundaries_2017_wkb_geometry_geom_i; Type: INDEX; Schema: us; Owner: -
--

CREATE INDEX core_based_statistical_area_boundaries_2017_wkb_geometry_geom_i ON core_based_statistical_area_boundaries_2017 USING gist (wkb_geometry);


--
-- Name: mpo_boundaries_20170928_wkb_geometry_geom_idx; Type: INDEX; Schema: us; Owner: -
--

CREATE INDEX mpo_boundaries_20170928_wkb_geometry_geom_idx ON mpo_boundaries_20170928 USING gist (wkb_geometry);


--
-- Name: urban_area_boundaries_2016_wkb_geometry_geom_idx; Type: INDEX; Schema: us; Owner: -
--

CREATE INDEX urban_area_boundaries_2016_wkb_geometry_geom_idx ON urban_area_boundaries_2016 USING gist (wkb_geometry);


--
-- Name: urban_area_boundaries_2017_wkb_geometry_geom_idx; Type: INDEX; Schema: us; Owner: -
--

CREATE INDEX urban_area_boundaries_2017_wkb_geometry_geom_idx ON urban_area_boundaries_2017 USING gist (wkb_geometry);


SET search_path = admin, pg_catalog;

--
-- Name: templates created_updated_at; Type: TRIGGER; Schema: admin; Owner: -
--

CREATE TRIGGER created_updated_at BEFORE INSERT OR UPDATE ON templates FOR EACH ROW EXECUTE PROCEDURE templates_created_updated_trigger();


--
-- Name: reports created_updated_at; Type: TRIGGER; Schema: admin; Owner: -
--

CREATE TRIGGER created_updated_at BEFORE INSERT OR UPDATE ON reports FOR EACH ROW EXECUTE PROCEDURE reports_created_updated_trigger();


--
-- Name: templates delete_created_updated_at; Type: TRIGGER; Schema: admin; Owner: -
--

CREATE TRIGGER delete_created_updated_at AFTER DELETE ON templates FOR EACH ROW EXECUTE PROCEDURE templates_delete_created_updated_trigger();


--
-- Name: reports delete_created_updated_at; Type: TRIGGER; Schema: admin; Owner: -
--

CREATE TRIGGER delete_created_updated_at AFTER DELETE ON reports FOR EACH ROW EXECUTE PROCEDURE reports_delete_created_updated_trigger();


SET search_path = ny, pg_catalog;

--
-- Name: region_to_county region_to_county_fk; Type: FK CONSTRAINT; Schema: ny; Owner: -
--

ALTER TABLE ONLY region_to_county
    ADD CONSTRAINT region_to_county_fk FOREIGN KEY (region_id) REFERENCES regions(id);


--
-- PostgreSQL database dump complete
--

