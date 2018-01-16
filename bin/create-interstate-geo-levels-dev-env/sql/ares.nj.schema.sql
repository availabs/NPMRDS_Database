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
-- Name: nj; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA nj;


SET search_path = nj, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

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


--
-- Name: inrix_shapefile_20170707_wkb_geometry_geom_idx; Type: INDEX; Schema: nj; Owner: -
--

CREATE INDEX inrix_shapefile_20170707_wkb_geometry_geom_idx ON inrix_shapefile_20170707 USING gist (wkb_geometry);


--
-- PostgreSQL database dump complete
--

