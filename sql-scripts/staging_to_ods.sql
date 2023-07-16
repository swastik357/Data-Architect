USE DATABASE "UDACITY";
USE SCHEMA "UDACITY"."ODS_SCHEMA";

DROP TABLE IF EXISTS temperature;

CREATE TABLE temperature (
  date DATE PRIMARY KEY,
	min_temp FLOAT,
	max_temp FLOAT,
	normal_min_temp FLOAT,
	normal_max_temp FLOAT
);

INSERT INTO temperature(date, min_temp, max_temp, normal_min_temp, normal_max_temp)
SELECT TO_DATE(date, 'YYYYMMDD'),
CAST(min AS FLOAT),
CAST(max AS FLOAT),
CAST(normal_min AS FLOAT),
CAST(normal_max AS FLOAT) FROM STAGING_SCHEMA.climate_temperature AS climate_temperature;

SELECT * from temperature LIMIT 2;

DROP TABLE IF EXISTS precipitation;

CREATE TABLE precipitation (
  date DATE PRIMARY KEY,
	precipitation FLOAT,
	precipitation_normal FLOAT
);

INSERT INTO precipitation(date, precipitation, precipitation_normal)
SELECT TO_DATE(date,'YYYYMMDD'),
CAST(precipitation AS FLOAT),
CAST(precipitation_normal AS FLOAT) FROM STAGING_SCHEMA.climate_precipitation AS climate_precipitation;

SELECT * from precipitation LIMIT 2;

DROP TABLE IF EXISTS timestamp_table;

CREATE TABLE timestamp_table (
    timestamp DATETIME PRIMARY KEY,
    date DATE,
    CONSTRAINT FK_DT_TD FOREIGN KEY(date) REFERENCES  temperature(date),
    CONSTRAINT FK_DT_PT FOREIGN KEY(date) REFERENCES  precipitation(date)
);

INSERT INTO timestamp_table (timestamp, date)
SELECT yelp_tip.timestamp,
       DATE(yelp_tip.timestamp)
FROM STAGING_SCHEMA.yelp_tip AS yelp_tip
WHERE yelp_tip.timestamp NOT IN (SELECT timestamp FROM timestamp_table);

SELECT * from timestamp_table LIMIT 2;

DROP TABLE IF EXISTS user;

CREATE TABLE user (
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
  compliment_photos INT,
  CONSTRAINT FK_YS_TS FOREIGN KEY(yelping_since) REFERENCES  timestamp_table(timestamp)
);

/* Loading user data from staging to ods */
INSERT INTO user (user_id, name, review_count, yelping_since, useful, funny, cool, elite, friends,
                      fans, average_stars, compliment_hot, compliment_more, compliment_profile, compliment_cute,
                      compliment_list, compliment_note, compliment_plain, compliment_cool, compliment_funny,
                      compliment_writer, compliment_photos)

SELECT yelp_user.user_id, yelp_user.name, yelp_user.review_count, yelp_user.yelping_since, yelp_user.useful, yelp_user.funny, yelp_user.cool, yelp_user.elite, yelp_user.friends,
       yelp_user.fans, yelp_user.average_stars, yelp_user.compliment_hot, yelp_user.compliment_more, yelp_user.compliment_profile, yelp_user.compliment_cute,
       yelp_user.compliment_list, yelp_user.compliment_note, yelp_user.compliment_plain, yelp_user.compliment_cool, yelp_user.compliment_funny,
       yelp_user.compliment_writer, yelp_user.compliment_photos
FROM STAGING_SCHEMA.yelp_user AS yelp_user
WHERE yelp_user.user_id NOT IN (SELECT user_id FROM user);

SELECT * from user LIMIT 2;

DROP TABLE IF EXISTS location;

CREATE TABLE location (
    location_id INT PRIMARY KEY IDENTITY,
    address VARCHAR,
    city VARCHAR,
    state VARCHAR,
    postal_code INT,
    latitude FLOAT,
    longitude FLOAT
);

INSERT INTO location (address, city, state, postal_code, latitude, longitude)
SELECT yelp_business.address, yelp_business.city, yelp_business.state, CAST(yelp_business.postal_code AS INT),yelp_business.latitude, yelp_business.longitude
FROM STAGING_SCHEMA.yelp_business AS yelp_business
WHERE TRY_TO_DECIMAL(yelp_business.postal_code) IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY yelp_business.address,yelp_business.city,yelp_business.state,yelp_business.postal_code ORDER BY yelp_business.address,yelp_business.city,yelp_business.state,yelp_business.postal_code) = 1;

SELECT * FROM location LIMIT 2;

DROP TABLE IF EXISTS business;

CREATE TABLE business (
  business_id VARCHAR PRIMARY KEY,
  name VARCHAR,
  location_id INT,
  stars FLOAT,
  review_count INT,
  is_open BOOLEAN,
  CONSTRAINT FK_LOC_ID FOREIGN KEY(location_id) REFERENCES location(location_id)
);

INSERT INTO business (business_id, name, location_id, stars, review_count, is_open)
SELECT  yelp_business.business_id,
        yelp_business.name,
        location.location_id,
        yelp_business.stars,
        yelp_business.review_count,
        CAST(yelp_business.is_open AS BOOLEAN)
FROM STAGING_SCHEMA.yelp_business AS yelp_business
LEFT JOIN location
ON yelp_business.address = location.address AND
yelp_business.city = location.city AND
yelp_business.state = location.state AND
CAST(yelp_business.postal_code AS INT) = location.postal_code
WHERE yelp_business.business_id NOT IN (SELECT business_id FROM business) AND TRY_TO_DECIMAL(yelp_business.postal_code) IS NOT NULL;

SELECT * FROM business LIMIT 2;

DROP TABLE IF EXISTS covid_features;

CREATE TABLE covid_features (
    covid_id INT PRIMARY KEY IDENTITY,
    business_id VARCHAR,
    highlights VARCHAR,
    delivery_or_takeout VARCHAR,
    grubhub_enabled VARCHAR,
    call_to_action_enabled VARCHAR,
    request_a_quote_enabled VARCHAR,
    covid_banner VARCHAR,
    temporary_closed_until VARCHAR,
    virtual_services_offered VARCHAR,
    CONSTRAINT FK_BU_BI FOREIGN KEY(business_id) REFERENCES business(business_id)
);

INSERT INTO covid_features (business_id, highlights, delivery_or_takeout, grubhub_enabled,
                       call_to_action_enabled, request_a_quote_enabled, covid_banner,
                       temporary_closed_until, virtual_services_offered)
SELECT yelp_covid_features.business_id, yelp_covid_features.highlights, yelp_covid_features.delivery_or_takeout,
       yelp_covid_features.grubhub_enabled, yelp_covid_features.call_to_action_enabled,
       yelp_covid_features.request_a_quote_enabled, yelp_covid_features.covid_banner,
       yelp_covid_features.temporary_closed_until, yelp_covid_features.virtual_services_offered
FROM STAGING_SCHEMA.yelp_covid_features AS yelp_covid_features;

SELECT * from covid_features LIMIT 2;

DROP TABLE IF EXISTS checkin;

CREATE TABLE checkin (
  checkin_id INT PRIMARY KEY IDENTITY,
  business_id VARCHAR,
  date VARCHAR,
  CONSTRAINT FK_BI_ID FOREIGN KEY(business_id) REFERENCES business(business_id)
);

INSERT INTO checkin (business_id, date)
SELECT yelp_checkin.business_id, yelp_checkin.date
FROM STAGING_SCHEMA.yelp_checkin AS yelp_checkin;

SELECT * from checkin LIMIT 2;

DROP TABLE IF EXISTS tip;

CREATE TABLE tip (
  tip_id INT PRIMARY KEY IDENTITY,
  user_id VARCHAR,
  business_id VARCHAR,
  text VARCHAR,
  timestamp DATETIME,
  compliment_count INT,
  CONSTRAINT FK_UI_UI FOREIGN KEY(user_id) REFERENCES  user(user_id),
  CONSTRAINT FK_BI_BI FOREIGN KEY(business_id) REFERENCES  business(business_id),
  CONSTRAINT FK_TI_TI FOREIGN KEY(timestamp) REFERENCES  timestamp_table(timestamp)
);

INSERT INTO tip (user_id, business_id, text, timestamp, compliment_count)
SELECT yelp_tip.user_id, yelp_tip.business_id, yelp_tip.text, yelp_tip.timestamp, yelp_tip.compliment_count
FROM STAGING_SCHEMA.yelp_tip AS yelp_tip;

SELECT * from tip LIMIT 2;

DROP TABLE IF EXISTS review;

CREATE TABLE review (
  review_id VARCHAR PRIMARY KEY,
  user_id VARCHAR,
  business_id VARCHAR,
  stars FLOAT,
  useful INT,
  funny INT,
  cool INT,
  text VARCHAR,
  timestamp DATETIME,
  CONSTRAINT FK_US_US FOREIGN KEY(user_id) REFERENCES  user(user_id),
  CONSTRAINT FK_BU_BU FOREIGN KEY(business_id) REFERENCES  business(business_id),
  CONSTRAINT FK_TS_TS FOREIGN KEY(timestamp) REFERENCES  timestamp_table(timestamp)
);

INSERT INTO review (review_id, user_id, business_id, stars, useful,
                         funny, cool, text, timestamp)
SELECT  yelp_review.review_id, yelp_review.user_id, yelp_review.business_id, yelp_review.stars, yelp_review.useful,
        yelp_review.funny, yelp_review.cool, yelp_review.text, yelp_review.date
FROM STAGING_SCHEMA.yelp_review AS yelp_review
WHERE yelp_review.review_id NOT IN (SELECT review_id FROM review);

SELECT * from review LIMIT 2;
