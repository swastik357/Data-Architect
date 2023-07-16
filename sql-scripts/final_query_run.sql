/* Select/use database and schema */
USE DATABASE "UDACITY";
USE SCHEMA "UDACITY"."DWH_SCHEMA";

/*SQL queries code that reports the date,business name,weather_score, and average ratings.*/
/*weather_score is calculated as a weighted average of temperature and precipitation*/
SELECT fr.date, db.name,(dw.min_temp+dw.max_temp+10*dw.precipitation+10*dw.precipitation_normal) as weather_score,AVG(fr.stars) AS avg_stars
FROM fact_review AS fr
INNER JOIN dim_business AS db  ON fr.business_id=db.business_id
INNER JOIN dim_weather AS dw ON fr.date=dw.date
WHERE db.state='NV'
GROUP BY fr.date,db.name,dw.min_temp,dw.max_temp,dw.precipitation,dw.precipitation_normal
ORDER BY db.name,weather_score DESC;
