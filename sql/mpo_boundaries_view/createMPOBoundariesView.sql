	CREATE VIEW public.mpo_boundaries AS
    SELECT *
      FROM us.mpo_boundaries___LATEST_VERSION__
        LEFT OUTER JOIN us.mpo_acronyms
        USING (mpo_id)
;
