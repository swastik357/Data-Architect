USE DATABASE "UDACITY";
USE SCHEMA "UDACITY"."STAGING_SCHEMA";

CREATE OR REPLACE TABLE yelp_review (
    review_id VARCHAR,
    user_id VARCHAR,
    business_id VARCHAR,
    stars FLOAT,
    useful INT,
    funny INT,
    cool INT,
    text VARCHAR,
    date DATETIME
);

CREATE OR REPLACE FILE FORMAT sf_tut_csv_format
    FIELD_DELIMITER = NONE
    RECORD_DELIMITER = '\\n';

CREATE OR REPLACE TEMPORARY STAGE sf_tut_stage
    FILE_FORMAT = sf_tut_csv_format;

PUT file:///Users/swastik./Downloads/yelp_project_data/yelp_dataset/yelp_review.json @sf_tut_stage;

COPY INTO yelp_review(review_id, user_id, business_id, stars, useful, funny, cool, text, date)
    FROM (SELECT parse_json($1):review_id,
                 parse_json($1):user_id,
                 parse_json($1):business_id,
                 parse_json($1):stars,
                 parse_json($1):useful,
                 parse_json($1):funny,
                 parse_json($1):cool,
                 parse_json($1):text,
                 to_timestamp_ntz(parse_json($1):date)
          FROM @sf_tut_stage/yelp_review.json.gz t)
    ON_ERROR = 'continue';

SELECT * from yelp_review LIMIT 2;
