USE DATABASE "UDACITY";
USE SCHEMA "UDACITY"."STAGING_SCHEMA";

CREATE OR REPLACE TABLE climate_temperature (
  date VARCHAR,
	min VARCHAR,
	max VARCHAR,
	normal_min VARCHAR,
	normal_max VARCHAR
);

CREATE OR REPLACE TEMPORARY STAGE sf_tut_stage
    FILE_FORMAT = (type=csv field_delimiter=',' skip_header=1);

PUT file:///Users/swastik./Downloads/yelp_project_data/yelp_dataset/temperature.csv @sf_tut_stage;

COPY INTO climate_temperature
    FROM @sf_tut_stage/temperature.csv.gz
    ON_ERROR = 'continue';

SELECT * from climate_temperature LIMIT 2;
