USE DATABASE "UDACITY";
USE SCHEMA "UDACITY"."STAGING_SCHEMA";

CREATE OR REPLACE TABLE yelp_tip (
    user_id VARCHAR,
    business_id VARCHAR,
    text VARCHAR,
    timestamp DATETIME,
    compliment_count INT
);

CREATE OR REPLACE FILE FORMAT sf_tut_csv_format
    FIELD_DELIMITER = NONE
    RECORD_DELIMITER = '\\n';

CREATE OR REPLACE TEMPORARY STAGE sf_tut_stage
    FILE_FORMAT = sf_tut_csv_format;

PUT file:///Users/swastik./Downloads/yelp_project_data/yelp_dataset/yelp_tip.json @sf_tut_stage;

COPY INTO yelp_tip(user_id, business_id, text, timestamp, compliment_count)
    FROM (SELECT parse_json($1):user_id,
                 parse_json($1):business_id,
                 parse_json($1):text,
                 to_timestamp_ntz(parse_json($1):date),
                 parse_json($1):compliment_count
          FROM @sf_tut_stage/yelp_tip.json.gz t)
    ON_ERROR = 'continue';

SELECT * from yelp_tip LIMIT 2;
