USE DATABASE "UDACITY";
USE SCHEMA "UDACITY"."STAGING_SCHEMA";

CREATE OR REPLACE TABLE climate_precipitation (
  date VARCHAR,
	precipitation VARCHAR,
	precipitation_normal VARCHAR
);

CREATE OR REPLACE TEMPORARY STAGE sf_tut_stage
    FILE_FORMAT = (type=csv field_delimiter=',' skip_header=1);


PUT file:///Users/swastik./Downloads/yelp_project_data/yelp_dataset/precipitation.csv @sf_tut_stage;


COPY INTO climate_precipitation
    FROM @sf_tut_stage/precipitation.csv.gz
    ON_ERROR = 'continue';

UPDATE climate_precipitation set precipitation = 0 where precipitation = 'T';

SELECT * from climate_precipitation LIMIT 2;
