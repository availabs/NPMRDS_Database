CREATE TABLE "__STATE__".npmrds_y__YEAR__m__MONTH__ (

  PRIMARY KEY (tmc, date, epoch),

  CHECK((date >= DATE '__START_DATE__') AND (date < '__END_DATE__'))
) INHERITS ("__STATE__".npmrds);

