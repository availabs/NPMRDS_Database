CREATE VIEW public.pm3_authorative_view
AS 
  SELECT
      (metadata->>'measure') AS measure,
      (metadata->>'year')::SMALLINT AS year,
      metadata,
      tmc,
      attribute,
      value
    FROM pm3_measure_calculator_metadata AS a
      INNER JOIN pm3_eav_append_only AS b
      ON (a.id = b.pm3meacalc_id)
    WHERE (
      (a.authorative_start IS NOT NULL)
      AND
      (a.authorative_end IS NULL)
    )
;
