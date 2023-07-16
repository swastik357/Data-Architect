USE DATABASE "UDACITY";
USE SCHEMA "UDACITY"."STAGING_SCHEMA";

CREATE OR REPLACE TABLE yelp_user (
    user_id VARCHAR,
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

CREATE OR REPLACE FILE FORMAT sf_tut_csv_format
    FIELD_DELIMITER = NONE
    RECORD_DELIMITER = '\\n';

CREATE OR REPLACE TEMPORARY STAGE sf_tut_stage
    FILE_FORMAT = sf_tut_csv_format;

PUT file:///Users/swastik./Downloads/yelp_project_data/yelp_dataset/yelp_user.json @sf_tut_stage;

COPY INTO yelp_user(user_id, name, review_count, yelping_since, useful, funny, cool, elite, friends, fans, average_stars,
                    compliment_hot, compliment_more, compliment_profile, compliment_cute, compliment_list, compliment_note,
                    compliment_plain, compliment_cool, compliment_funny, compliment_writer, compliment_photos)
    FROM (SELECT parse_json($1):user_id,
                 parse_json($1):name,
                 parse_json($1):review_count,
                 to_timestamp_ntz(parse_json($1):yelping_since),
                 parse_json($1):useful,
                 parse_json($1):funny,
                 parse_json($1):cool,
                 parse_json($1):elite,
                 parse_json($1):friends,
                 parse_json($1):fans,
                 parse_json($1):average_stars,
                 parse_json($1):compliment_hot,
                 parse_json($1):compliment_more,
                 parse_json($1):compliment_profile,
                 parse_json($1):compliment_cute,
                 parse_json($1):compliment_list,
                 parse_json($1):compliment_note,
                 parse_json($1):compliment_plain,
                 parse_json($1):compliment_cool,
                 parse_json($1):compliment_funny,
                 parse_json($1):compliment_writer,
                 parse_json($1):compliment_photos
          FROM @sf_tut_stage/yelp_user.json.gz t)
    ON_ERROR = 'continue';

SELECT * from yelp_user LIMIT 1;
