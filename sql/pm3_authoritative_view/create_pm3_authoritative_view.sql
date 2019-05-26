CREATE VIEW public.pm3_authoritative_view
AS 
  SELECT
      (a.metadata->>'state') AS state,
      (b.metadata->>'measure') AS measure,
      (b.metadata->>'year')::SMALLINT AS year,
      (b.metadata->>'isCanonical')::BOOLEAN AS is_canonical,
      b.metadata,
      tmc,
      attribute,
      NULLIF(value, 'null'::JSONB) AS value
    FROM pm3_calculator_metadata AS a
      INNER JOIN pm3_measure_calculator_metadata AS b
        ON (a.id = b.pm3calc_id)
      INNER JOIN pm3_eav_append_only AS c
        ON (b.id = c.pm3meacalc_id)
    WHERE (
      (b.authoritative_start IS NOT NULL)
      AND
      (b.authoritative_end IS NULL)
    )
;
