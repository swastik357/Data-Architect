USE DATABASE "UDACITY";
USE SCHEMA "UDACITY"."STAGING_SCHEMA";

CREATE OR REPLACE TABLE yelp_covid_features (
    business_id VARCHAR,
    highlights VARCHAR,
    delivery_or_takeout VARCHAR,
    grubhub_enabled VARCHAR,
    call_to_action_enabled VARCHAR,
    request_a_quote_enabled VARCHAR,
    covid_banner VARCHAR,
    temporary_closed_until VARCHAR,
    virtual_services_offered VARCHAR
);

CREATE OR REPLACE FILE FORMAT sf_tut_csv_format
    FIELD_DELIMITER = NONE
    RECORD_DELIMITER = '\\n';

CREATE OR REPLACE TEMPORARY STAGE sf_tut_stage
    FILE_FORMAT = sf_tut_csv_format;

PUT file:///Users/swastik./Downloads/yelp_project_data/yelp_dataset/yelp_covid_features.json @sf_tut_stage;

COPY INTO yelp_covid_features(business_id, highlights, delivery_or_takeout, grubhub_enabled, call_to_action_enabled,
                     request_a_quote_enabled, covid_banner, temporary_closed_until, virtual_services_offered)
    FROM (SELECT parse_json($1):business_id,
                 parse_json($1):highlights,
                 parse_json($1):"delivery or takeout",
                 parse_json($1):"Grubhub enabled",
                 parse_json($1):"Call To Action enabled",
                 parse_json($1):"Request a Quote Enabled",
                 parse_json($1):"Covid Banner",
                 parse_json($1):"Temporary Closed Until",
                 parse_json($1):"Virtual Services Offered"
          FROM @sf_tut_stage/yelp_covid_features.json.gz t)
    ON_ERROR = 'continue';

SELECT * from yelp_covid_features LIMIT 2;
