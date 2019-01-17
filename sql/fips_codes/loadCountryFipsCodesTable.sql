COPY "__COUNTRY__".fips_codes (
  state,
  state_code,
  county_code,
  county
) FROM STDIN CSV;
