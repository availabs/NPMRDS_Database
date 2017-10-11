BEGIN;

TRUNCATE TABLE ny.regions;

INSERT INTO ny.regions (id, name, state)
  VALUES
    (1,  'Capital District', 'ny'),
    (2,  'Mohawk Valley', 'ny'),
    (3,  'Central New York', 'ny'),
    (4,  'Genesee Valley', 'ny'),
    (5,  'Western New York', 'ny'),
    (6,  'Southern Tier/Central New York', 'ny'),
    (7,  'North Country', 'ny'),
    (8,  'Hudson Valley', 'ny'),
    (9,  'Southern Tier', 'ny'),
    (10, 'Long Island', 'ny'),
    (11, 'New York City', 'ny')
;

COMMIT;
