-- https://www.dot.ny.gov/divisions/engineering/technical-services/hds-respository/Traffic%20Data%20Report%202007.pdf
-- https://www.dot.ny.gov/divisions/engineering/technical-services/hds-respository/Tab/NYSDOT_2016_Seasonal_Adjustment_Factors.pdf

BEGIN;

CREATE TABLE highway_data_services.nysdot_seasonal_adjustment_factor_group_descriptions (
  factor_group        SMALLINT PRIMARY KEY,
  short_description   VARCHAR,
  long_description    VARCHAR,
  CHECK (factor_group IN (29, 30, 31, 39, 40, 41, 59, 60, 61))
) WITH (fillfactor=100, autovacuum_enabled=false);

INSERT INTO highway_data_services.nysdot_seasonal_adjustment_factor_group_descriptions
VALUES
  (29, 'Urban minor factor group.', 'Urban minor factor group. Minor factor groups surround the major factor groups and are labelled +/-1 of the major factor group label. These minor factor groups are supplied to give the user a more fine-tuned calculation of the AADT.'),
  (30, 'Urban', 'Urban traffic patterns minimally affected by the seasons coefficient of variation < 10%'),
  (31, 'Urban minor factor group.', 'Urban minor factor group. Minor factor groups surround the major factor groups and are labelled +/-1 of the major factor group label. These minor factor groups are supplied to give the user a more fine-tuned calculation of the AADT.'),
  (39, 'Suburban minor factor group.', 'Suburban minor factor group. Minor factor groups surround the major factor groups and are labelled +/-1 of the major factor group label. These minor factor groups are supplied to give the user a more fine-tuned calculation of the AADT.'),
  (40, 'Suburban', 'Suburban traffic patterns moderately affected by the seasons coefficient of variation >= 10% and < =25%'),
  (41, 'Suburban minor factor group.', 'Suburban minor factor group. Minor factor groups surround the major factor groups and are labelled +/-1 of the major factor group label. These minor factor groups are supplied to give the user a more fine-tuned calculation of the AADT.'),
  (59, 'Recreational minor factor group.', 'Recreational minor factor group. Minor factor groups surround the major factor groups and are labelled +/-1 of the major factor group label. These minor factor groups are supplied to give the user a more fine-tuned calculation of the AADT.'),
  (60, 'Recreational', 'Recreational traffic patterns extremely affected by the seasons coefficient of variation > 25%'),
  (61, 'Recreational minor factor group.', 'Recreational minor factor group. Minor factor groups surround the major factor groups and are labelled +/-1 of the major factor group label. These minor factor groups are supplied to give the user a more fine-tuned calculation of the AADT.')
;

COMMENT ON COLUMN highway_data_services.nysdot_seasonal_adjustment_factor_group_descriptions.factor_group IS
'Factor Group determines the set of seasonal factors to apply. Factor Groups are 30, 40, or 60 only.';

COMMIT;
