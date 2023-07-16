USE DATABASE "UDACITY";
USE SCHEMA "UDACITY"."DWH_SCHEMA";

DROP TABLE IF EXISTS dim_user;

CREATE TABLE dim_user (
  user_id VARCHAR PRIMARY KEY,
  name VARCHAR,
  review_count INT,
  yelping_since DATETIME,
  useful INT,
  funny INT,
  cool INT,
  elite VARCHAR,
  friends VARCHAR,
  fans INT,
	average_stars FLOAT,
  compliment_hot INT,
  compliment_more INT,
  compliment_profile INT,
  compliment_cute INT,
  compliment_list INT,
  compliment_note INT,
  compliment_plain INT,
	compliment_cool INT,
	compliment_funny INT,
	compliment_writer INT,
  compliment_photos INT
);

INSERT INTO dim_user (user_id, name, review_count, yelping_since, useful, funny, cool, elite, friends, fans,
                      average_stars, compliment_hot, compliment_more, compliment_profile, compliment_cute,
                      compliment_list, compliment_note, compliment_plain, compliment_cool, compliment_funny,
                      compliment_writer, compliment_photos)
SELECT  user.user_id, user.name, user.review_count, user.yelping_since, user.useful, user.funny, user.cool,
        user.elite, user.friends, user.fans, user.average_stars, user.compliment_hot, user.compliment_more,
        user.compliment_profile, user.compliment_cute, user.compliment_list, user.compliment_note, user.compliment_plain,
        user.compliment_cool, user.compliment_funny, user.compliment_writer, user.compliment_photos
FROM ODS_SCHEMA.user AS user;

SELECT * from dim_user LIMIT 2;

DROP TABLE IF EXISTS dim_weather;

CREATE TABLE dim_weather (
  date DATE PRIMARY KEY,
	min_temp FLOAT,
	max_temp FLOAT,
	normal_min_temp FLOAT,
	normal_max_temp FLOAT,
  precipitation FLOAT,
  precipitation_normal FLOAT
);

INSERT INTO dim_weather (date, min_temp, max_temp, normal_min_temp, normal_max_temp, precipitation, precipitation_normal)
SELECT temperature.date, temperature.min_temp, temperature.max_temp, temperature.normal_min_temp, temperature.normal_max_temp, precipitation.precipitation, precipitation.precipitation_normal
FROM ODS_SCHEMA.temperature AS temperature
INNER JOIN ODS_SCHEMA.precipitation AS precipitation
ON temperature.date=precipitation.date;

SELECT * from dim_weather LIMIT 2;

DROP TABLE IF EXISTS dim_business;

CREATE TABLE dim_business (
    business_id VARCHAR PRIMARY KEY,
    name VARCHAR,
    address VARCHAR,
    city VARCHAR,
    state VARCHAR,
    postal_code INT,
    latitude FLOAT,
    longitude FLOAT,
    stars FLOAT,
    review_count INT,
    is_open BOOLEAN,
    checkin_date VARCHAR,
    covid_features_highlights VARCHAR,
    covid_features_delivery_or_takeout VARCHAR,
    covid_features_grubhub_enabled VARCHAR,
    covid_features_call_to_action_enabled VARCHAR,
    covid_features_request_a_quote_enabled VARCHAR,
    covid_features_banner VARCHAR,
    covid_features_temporary_closed_until VARCHAR,
    covid_features_virtual_services_offered VARCHAR
);

INSERT INTO dim_business (business_id, name, address, city, state, postal_code, latitude, longitude, stars,
                         review_count, is_open, checkin_date, covid_features_highlights, covid_features_delivery_or_takeout,
                         covid_features_grubhub_enabled, covid_features_call_to_action_enabled, covid_features_request_a_quote_enabled,
                         covid_features_banner, covid_features_temporary_closed_until, covid_features_virtual_services_offered)
SELECT  business.business_id,business.name,location.address,location.city,location.state,location.postal_code,location.latitude,
        location.longitude,business.stars,business.review_count,business.is_open,checkin.date,covid_features.highlights,
        covid_features.delivery_or_takeout,covid_features.grubhub_enabled,covid_features.call_to_action_enabled,
        covid_features.request_a_quote_enabled,covid_features.covid_banner,covid_features.temporary_closed_until,
        covid_features.virtual_services_offered
FROM ODS_SCHEMA.business AS business
LEFT JOIN ODS_SCHEMA.location AS location ON business.location_id=location.location_id
LEFT JOIN ODS_SCHEMA.checkin AS checkin ON business.business_id=checkin.business_id
LEFT JOIN ODS_SCHEMA.covid_features AS covid_features ON business.business_id=covid_features.business_id;

SELECT * FROM dim_business LIMIT 2;

DROP TABLE IF EXISTS dim_timestamp;

CREATE TABLE dim_timestamp (
  timestamp DATETIME PRIMARY KEY,
  date DATE
);

INSERT INTO dim_timestamp (timestamp, date)
SELECT timestamp_table.timestamp, timestamp_table.date
FROM ODS_SCHEMA.timestamp_table AS timestamp_table;

SELECT * FROM dim_timestamp LIMIT 2;

DROP TABLE IF EXISTS fact_review;

CREATE TABLE fact_review (
    review_id VARCHAR PRIMARY KEY,
    user_id VARCHAR,
    business_id VARCHAR,
    stars FLOAT,
    useful INT,
    funny INT,
    cool INT,
    text VARCHAR,
    timestamp DATETIME,
    date DATE,
    CONSTRAINT FK_DT_DT FOREIGN KEY(date) REFERENCES  dim_weather(date),
    CONSTRAINT FK_UI_UI FOREIGN KEY(user_id) REFERENCES  dim_user(user_id),
    CONSTRAINT FK_TS_TS FOREIGN KEY(timestamp) REFERENCES  dim_timestamp(timestamp),
    CONSTRAINT FK_BU_BU FOREIGN KEY(business_id) REFERENCES  dim_business(business_id)
);

INSERT INTO fact_review (review_id, user_id, business_id, stars, useful, funny, cool, text, timestamp, date)
SELECT  review.review_id,review.user_id,review.business_id,review.stars,review.useful,review.funny,
        review.cool,review.text,review.timestamp,dim_timestamp.date
FROM ODS_SCHEMA.review AS review
INNER JOIN dim_timestamp ON review.timestamp=dim_timestamp.timestamp;

SELECT * FROM fact_review LIMIT 2;
