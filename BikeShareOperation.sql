REATE OR REPLACE TABLE  San_Francisco_bikshare.bikeshare_regions AS
 SELECT * FROM  `bigquery-public-data.san_francisco_bikeshare.bikeshare_regions`;


CREATE OR REPLACE TABLE  San_Francisco_bikshare.bikeshare_station_info AS
  SELECT * FROM  `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info`;

CREATE OR REPLACE TABLE San_Francisco_bikshare.bikeshare_station_status AS
  SELECT * FROM  `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_status`;

CREATE OR REPLACE TABLE San_Francisco_bikshare.bikeshare_trips AS
  SELECT * FROM  `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips`;



-- Replace Year 2017 to 2016 and 2018 to 2017
UPDATE `bigquery-course-328219.San_Francisco_bikshare.bikeshare_trips`
SET start_date = 
  TIMESTAMP_SUB(TIMESTAMP(start_date),INTERVAL 365 DAY)
  WHERE EXTRACT(YEAR FROM start_date) >= 2017;

-- Adding new column to the table with date only 
ALTER TABLE   `bigquery-course-328219.San_Francisco_bikshare.bikeshare_trips`
ADD COLUMN start_date_date DATE;
UPDATE San_Francisco_bikshare.bikeshare_trips
SET start_date_date = DATE(start_date) WHERE start_date_date  is null;

-- Changing id type 

ALTER TABLE `bigquery-course-328219.San_Francisco_bikshare.bikeshare_trips`
ADD COLUMN start_station_id_string STRING,
ADD COLUMN end_station_id_string  STRING;

UPDATE `bigquery-course-328219.San_Francisco_bikshare.bikeshare_trips`
SET start_station_id_string = CAST(start_station_id AS STRING) WHERE start_station_id_string IS NULL;

UPDATE `bigquery-course-328219.San_Francisco_bikshare.bikeshare_trips`
SET end_station_id_string = CAST(end_station_id AS STRING) WHERE end_station_id_string IS NULL;

ALTER TABLE `bigquery-course-328219.San_Francisco_bikshare.bikeshare_trips`
DROP COLUMN start_station_id,
DROP COLUMN end_station_id;

ALTER TABLE `bigquery-course-328219.San_Francisco_bikshare.bikeshare_trips`
RENAME COLUMN start_station_id_string TO start_station_id,
RENAME COLUMN end_station_id_string TO end_station_id;

-- Updating the missing value for subscription type
UPDATE San_Francisco_bikshare.bikeshare_trips
SET c_subscription_type = subscriber_type WHERE c_subscription_type is null;

UPDATE San_Francisco_bikshare.bikeshare_trips
SET c_subscription_type = 'Casual' WHERE c_subscription_type = 'Customer';

ALTER TABLE   `bigquery-course-328219.San_Francisco_bikshare.bikeshare_trips`
ADD COLUMN bike_type STRING;
UPDATE San_Francisco_bikshare.bikeshare_trips
SET bike_type  = CASE
  WHEN RAND() <0.33 THEN 'classic'
  WHEN RAND() <0.67 THEN 'electric'
  ELSE 'docked'
END
WHERE bike_type is null;

-- Adding missing value for Longitude and Latitude 
UPDATE San_Francisco_bikshare.bikeshare_trips AS t
SET 
start_station_longitude = 
  (SELECT 
    s.lon 
  FROM San_Francisco_bikshare.bikeshare_station_info AS s
  WHERE s.station_id = t.start_station_id),
start_station_latitude = 
  (SELECT 
    s.lat 
  FROM San_Francisco_bikshare.bikeshare_station_info AS s
  WHERE s.station_id = t.start_station_id),
end_station_latitude =
 (SELECT
  s.lat
  FROM San_Francisco_bikshare.bikeshare_station_info AS s
  WHERE s.station_id = t.end_station_id),
end_station_longitude =
 (SELECT
  s.lon
  FROM San_Francisco_bikshare.bikeshare_station_info AS s
  WHERE s.station_id = t.end_station_id)
WHERE 
  start_station_latitude IS NULL 
  OR start_station_longitude IS NULL
  OR end_station_latitude IS NULL
  OR end_station_longitude IS NULL;


-- Adding houre column 
ALTER TABLE `bigquery-course-328219.San_Francisco_bikshare.bikeshare_trips`
ADD COLUMN time_hour INTEGER,
ADD COLUMN day_time STRING;

UPDATE `bigquery-course-328219.San_Francisco_bikshare.bikeshare_trips`
SET time_hour = EXTRACT(HOUR FROM start_date) WHERE time_hour IS NULL;

UPDATE `bigquery-course-328219.San_Francisco_bikshare.bikeshare_trips`
SET day_time = CASE
  WHEN time_hour <4 THEN 'night'
  WHEN time_hour <12 THEN 'morning'
  WHEN time_hour <18 THEN 'afternoon'
  ELSE 'evening'
END
WHERE day_time IS NULL;

DELETE FROM `bigquery-course-328219.San_Francisco_bikshare.bikeshare_trips`
WHERE start_date_date >='2017-01-01';

SELECT * FROM `bigquery-course-328219.San_Francisco_bikshare.bikeshare_trips` LIMIT 10 




