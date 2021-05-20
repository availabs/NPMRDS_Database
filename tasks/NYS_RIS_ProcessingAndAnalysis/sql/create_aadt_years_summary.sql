BEGIN;

DROP TABLE IF EXISTS roadway_inventory_system_aadt_years_summary ;

CREATE TABLE roadway_inventory_system_aadt_years_summary (
  year                 TEXT,
  aadt_values_count_a  INTEGER,
  aadt_values_count_b  INTEGER
) ;

INSERT INTO roadway_inventory_system_aadt_years_summary (
  year,
  aadt_values_count_a,
  aadt_values_count_b
)
  SELECT
      year,
      COUNT(aadt_value_a) AS aadt_values_count_a,
      COUNT(aadt_value_b) AS aadt_values_count_b
    FROM (
      SELECT
          Last_Actual_CNTYR AS year,
          a.AADT_Actual AS aadt_value_a,
          NULL AS aadt_value_b
        FROM ris_a.roadway_inventory_system AS a

      UNION ALL

      SELECT
          Last_Actual_CNTYR AS year,
          NULL AS aadt_value_a,
          b.AADT_Actual AS aadt_value_b
        FROM ris_b.roadway_inventory_system AS b
    )
    GROUP BY year
    HAVING (COUNT(IFNULL(aadt_value_a, aadt_value_b)) > 1)
;

COMMIT;
