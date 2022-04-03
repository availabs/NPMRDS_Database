\set tbl_name :"STATE"'.npmrds_y':YEAR'm':MONTH

DELETE FROM :tbl_name
  WHERE (
    COALESCE(
      travel_time_all_vehicles,
      travel_time_passenger_vehicles,
      travel_time_freight_trucks
    ) IS NULL
  )
;
