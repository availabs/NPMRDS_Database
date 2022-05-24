# NYSDOT TRANSCOM Event Classifications

NOTE: The event_type column values are transformed to lowercase before loading
into the DB. This caused a PRIMARY KEY conflict with the "operational
activity" and "pothole repairs" rows. I deleted the second occurance for each
as it contained less data than the first.
