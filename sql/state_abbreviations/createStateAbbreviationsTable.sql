BEGIN;

CREATE TABLE public.state_abbreviations (
  state_name    VARCHAR PRIMARY KEY,
  abbreviation  CHAR(2),
  country       VARCHAR
);

CREATE TABLE us.state_abbreviations (
    CONSTRAINT state_abbreviations_pkey PRIMARY KEY(abbreviation),
    CONSTRAINT country CHECK (country = 'us')
  )
  INHERITS (public.state_abbreviations)
  WITH (fillfactor=100, autovacuum_enabled=false)
;

ALTER TABLE us.state_abbreviations
  ALTER COLUMN country SET DEFAULT 'us';

INSERT INTO us.state_abbreviations (state_name, abbreviation)
  VALUES
    ('Alabama', 'al'),
    ('Alaska', 'ak'),
    ('Arizona', 'az'),
    ('Arkansas', 'ar'),
    ('California', 'ca'),
    ('Colorado', 'co'),
    ('Connecticut', 'ct'),
    ('Delaware', 'de'),
    ('District of Columbia', 'dc'),
    ('Florida', 'fl'),
    ('Georgia', 'ga'),
    ('Hawaii', 'hi'),
    ('Idaho', 'id'),
    ('Illinois', 'il'),
    ('Indiana', 'in'),
    ('Iowa', 'ia'),
    ('Kansas', 'ks'),
    ('Kentucky', 'ky'),
    ('Louisiana', 'la'),
    ('Maine', 'me'),
    ('Montana', 'mt'),
    ('Nebraska', 'ne'),
    ('Nevada', 'nv'),
    ('New Hampshire', 'nh'),
    ('New Jersey', 'nj'),
    ('New Mexico', 'nm'),
    ('New York', 'ny'),
    ('North Carolina', 'nc'),
    ('North Dakota', 'nd'),
    ('Ohio', 'oh'),
    ('Oklahoma', 'ok'),
    ('Oregon', 'or'),
    ('Maryland', 'md'),
    ('Massachusetts', 'ma'),
    ('Michigan', 'mi'),
    ('Minnesota', 'mn'),
    ('Mississippi', 'ms'),
    ('Missouri', 'mo'),
    ('Pennsylvania', 'pa'),
    ('Rhode Island', 'ri'),
    ('South Carolina', 'sc'),
    ('South Dakota', 'sd'),
    ('Tennessee', 'tn'),
    ('Texas', 'tx'),
    ('Utah', 'ut'),
    ('Vermont', 'vt'),
    ('Virginia', 'va'),
    ('Washington', 'wa'),
    ('West Virginia', 'wv'),
    ('Wisconsin', 'wi'),
    ('Wyoming', 'wy')
;

CREATE TABLE cn.state_abbreviations (
    CONSTRAINT state_abbreviations_pkey PRIMARY KEY(abbreviation),
    CONSTRAINT country CHECK (country = 'cn')
  )
  INHERITS (public.state_abbreviations)
  WITH (fillfactor=100, autovacuum_enabled=false)
;

ALTER TABLE cn.state_abbreviations
  ALTER COLUMN country SET DEFAULT 'cn';

INSERT INTO cn.state_abbreviations (state_name, abbreviation)
  VALUES
    ('Alberta', 'ab'),
    ('British Columbia', 'bc'),
    ('Manitoba', 'mb'),
    ('New Brunswick', 'nb'),
    ('Newfoundland and Labrador', 'nl'),
    ('Northwest Territories', 'nt'),
    ('Nova Scotia', 'ns'),
    ('Nunavut', 'nu'),
    ('Ontario', 'on'),
    ('Prince Edward Island', 'pe'),
    ('Québec', 'qc'),
    ('Saskatchewan', 'sk'),
    ('Yukon', 'yt')
;

COMMIT;

VACUUM FULL ANALYZE us.state_abbreviations;
VACUUM FULL ANALYZE cn.state_abbreviations;
