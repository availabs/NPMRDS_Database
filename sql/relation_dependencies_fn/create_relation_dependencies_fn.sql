/*
  # Step 1: Recursively decompose the VIEWs to the underlying tables

    PostgreSQL catalog tables used:

      https://www.postgresql.org/docs/9.6/catalog-pg-rewrite.html
      pg_rewrite: stores rewrite rules for tables and views
        ev_class     | The table this rule is for

      https://www.postgresql.org/docs/9.6/catalog-pg-class.html
      pg_class: catalogs tables and most everything else that has columns or is otherwise similar to a table
        oid          | Row identifier
        relname      | Name of the table, index, view, etc.
        relnamespace | The OID of the namespace that contains this relation
        relkind      | r = ordinary table
                     | v = view

      https://www.postgresql.org/docs/9.6/catalog-pg-depend.html
      pg_depend: records the dependency relationships between database objects
        objid        | The OID of the specific dependent object
        refobjid     | The OID of the specific referenced object

      https://www.postgresql.org/docs/9.6/catalog-pg-namespace.html
      pg_namespace: stores namespaces
        objid        | Row identifier
        nspname      | Name of the namespace

  # Step 2: Recursively get the leaf tables in the inheritance hierarchies for all tables
  
    PostgreSQL catalog tables used:

      https://www.postgresql.org/docs/9.6/catalog-pg-inherits.html
      pg_inherits: records information about table inheritance hierarchies
        inhrelid     | The OID of the child table
        inhparent    | The OID of the parent table

*/

CREATE OR REPLACE FUNCTION relation_dependencies_fn(json) RETURNS json
  AS $$
    WITH RECURSIVE view_decompositions (schemaname, relname) AS (
      SELECT schemaname::TEXT, relname::TEXT
        FROM json_to_recordset($1) AS r(schemaname TEXT, relname TEXT)
      UNION
      SELECT
          ns_d.nspname AS schemaname,
          cl_d.relname::TEXT AS relname
        FROM pg_rewrite AS r
          JOIN pg_class AS cl_r
            ON (r.ev_class = cl_r.oid)
          JOIN pg_namespace AS ns_r
            ON (cl_r.relnamespace = ns_r.oid)
          JOIN pg_depend AS d
            ON (r.oid = d.objid)
          JOIN pg_class AS cl_d
            ON (d.refobjid = cl_d.oid)
          JOIN pg_namespace AS ns_d
            ON (cl_d.relnamespace = ns_d.oid)
          JOIN view_decompositions
            ON (
              (ns_r.nspname = view_decompositions.schemaname)
              AND
              (cl_r.relname::TEXT = view_decompositions.relname::TEXT)
            )
        WHERE (
          (cl_r.relkind = 'v')
          AND
          (cl_d.relkind IN ('r','v'))
        )
    ), leaf_tables (schemaname, relname) AS (
      SELECT * FROM view_decompositions
      UNION
        SELECT 
          cn.nspname AS schemaname,
          c.relname AS relname
        FROM pg_inherits 
          JOIN pg_class AS c ON (inhrelid=c.oid)
          JOIN pg_class as p ON (inhparent=p.oid)
          JOIN pg_namespace pn ON pn.oid = p.relnamespace
          JOIN pg_namespace cn ON cn.oid = c.relnamespace
          JOIN view_decompositions
            ON (
              (pn.nspname = view_decompositions.schemaname)
              AND
              (p.relname = view_decompositions.relname)
            )
    )
    SELECT
        json_agg(row_to_json(t))::JSON AS dependencies
      FROM (
        SELECT
            schemaname,
            relname
          FROM leaf_tables
          ORDER BY schemaname, relname
      ) AS t
  $$
  LANGUAGE SQL
;
