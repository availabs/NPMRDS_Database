CLUSTER :"COUNTRY".fips_codes USING fips_codes_pkey;
VACUUM FULL FREEZE ANALYZE :"COUNTRY".fips_codes;
