SELECT
    c.relname AS child
  FROM pg_inherits 
    JOIN pg_class AS c ON (inhrelid=c.oid)
    JOIN pg_class as p ON (inhparent=p.oid)
    JOIN pg_namespace pn ON pn.oid = p.relnamespace
    JOIN pg_namespace cn ON cn.oid = c.relnamespace
  WHERE (
    (p.relname = 'core_based_statistical_area_boundaries')
    AND
    (pn.nspname = 'public')
    AND
    (cn.nspname = 'us')
  )
;
