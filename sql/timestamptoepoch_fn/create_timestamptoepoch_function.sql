CREATE OR REPLACE FUNCTION public.timestamptoepoch(d1 timestamp without time zone)
  RETURNS integer
  LANGUAGE sql
  STRICT
  AS $function$select ( (extract(hour from d1) * 12) + floor(extract(minute from d1) / 5) )::integer;$function$

