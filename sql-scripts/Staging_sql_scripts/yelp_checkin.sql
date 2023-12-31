/* Documentation reference for this script: https://docs.snowflake.com/en/user-guide/script-data-load-transform-json.html */

/* Select/use database and schema */
USE DATABASE "UDACITY";
USE SCHEMA "UDACITY"."STAGING_SCHEMA";

/* Create a target relational table for the JSON data. The table is temporary, meaning it persists only for   */
/* the duration of the user session and is not visible to other users.                                        */

CREATE OR REPLACE TABLE yelp_checkin (
    business_id VARCHAR,
    date VARCHAR
);

/* Create a named file format with the file delimiter set as none and the record delimiter set as the new     */
/* line character.                                                                                            */
/*                                                                                                            */
/* When loading semi-structured data (e.g. JSON), you should set CSV as the file format type (default value). */
/* You could use the JSON file format, but any error in the transformation would stop the COPY operation,     */
/* even if you set the ON_ERROR option to continue or skip the file.                                          */

CREATE OR REPLACE FILE FORMAT sf_tut_csv_format
    FIELD_DELIMITER = NONE
    RECORD_DELIMITER = '\\n';

/* Create a temporary internal stage that references the file format object.                                  */
/* Similar to temporary tables, temporary stages are automatically dropped at the end of the session.         */

CREATE OR REPLACE TEMPORARY STAGE sf_tut_stage
    FILE_FORMAT = sf_tut_csv_format;

/* Stage the data file.                                                                                       */
/*                                                                                                            */
/* Note that the example PUT statement references the macOS or Linux location of the data file.               */

PUT file:///Users/swastik./Downloads/yelp_project_data/yelp_dataset/yelp_checkin.json @sf_tut_stage;

/* Load the JSON data into the relational table.                                                              */
/*                                                                                                            */
/* A SELECT query in the COPY statement identifies a numbered set of columns in the data files you are        */
/* loading from. Note that all JSON data is stored in a single column ($1).                                   */

COPY INTO yelp_checkin(business_id, date)
    FROM (SELECT parse_json($1):business_id,
                 parse_json($1):date
          FROM @sf_tut_stage/yelp_checkin.json.gz t)
    ON_ERROR = 'continue';

/* Query the relational table                                                                                 */
SELECT * from yelp_checkin LIMIT 2;                                        
