CREATE OR REPLACE FUNCTION public.npmrds_year(d1 date)
  RETURNS integer
  LANGUAGE sql
  STRICT
  AS $function$select (extract(year from d1))::integer;$function$

