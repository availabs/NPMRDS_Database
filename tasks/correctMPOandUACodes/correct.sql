UPDATE pm3
  SET (mpo, ua) = (
    SELECT mpo_code, ua_code FROM tmc_attributes
      WHERE pm3.tmc = tmc_attributes.tmc
  )
;
