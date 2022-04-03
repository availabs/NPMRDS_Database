\set tbl_name :"STATE"'.npmrds_y':YEAR'm':MONTH

UPDATE :tbl_name
  SET travel_time_all_vehicles = COALESCE(travel_time_passenger_vehicles, travel_time_freight_trucks)
  WHERE (travel_time_all_vehicles IS NULL)
;
