-- Enable LOAD DATA LOCAL INFILE (server side; resets on MySQL restart)
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

-- Database and table for reviews
CREATE DATABASE IF NOT EXISTS airbnb_capstone;
USE airbnb_capstone;

DROP TABLE IF EXISTS reviews;

CREATE TABLE reviews (
  listing_id   BIGINT UNSIGNED NOT NULL,
  city         VARCHAR(10)     NOT NULL,
  review_date  DATE            NOT NULL
);

-- Load Florence reviews
LOAD DATA LOCAL INFILE 'C:/Users/ffanc/Desktop/CAPSTONE_FINALE/raw/reviews_Firenze.csv'
INTO TABLE reviews
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(listing_id, @review_date)
SET city        = 'Firenze',
    review_date = @review_date;
    
-- Quality checks: Florence
-- 1. Overview
SELECT
  COUNT(*)                    AS total_reviews,
  COUNT(DISTINCT listing_id)  AS distinct_listings,
  MIN(review_date)            AS first_review,
  MAX(review_date)            AS last_review
FROM reviews
WHERE city = 'Firenze';

-- 2. Reviews per year
SELECT
  YEAR(review_date) AS review_year,
  COUNT(*)          AS total_reviews
FROM reviews
WHERE city = 'Firenze'
GROUP BY review_year
ORDER BY review_year;

-- Load Rome reviews
LOAD DATA LOCAL INFILE 'C:/Users/ffanc/Desktop/CAPSTONE_FINALE/raw/reviews_Roma.csv'
INTO TABLE reviews
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(listing_id, @review_date)
SET city        = 'Roma',
    review_date = @review_date;

-- Load Milan reviews
LOAD DATA LOCAL INFILE 'C:/Users/ffanc/Desktop/CAPSTONE_FINALE/raw/reviews_Milano.csv'
INTO TABLE reviews
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(listing_id, @review_date)
SET city        = 'Milano',
    review_date = @review_date;
    
-- Quality checks: all cities
-- 1. Overview per city
SELECT
  city,
  COUNT(*)                    AS total_reviews,
  COUNT(DISTINCT listing_id)  AS distinct_listings,
  MIN(review_date)            AS first_review,
  MAX(review_date)            AS last_review
FROM reviews
GROUP BY city;

-- 2. Reviews per year and city
SELECT
  YEAR(review_date) AS review_year,
  SUM(city = 'Roma')     AS roma,
  SUM(city = 'Milano')   AS milano,
  SUM(city = 'Firenze')  AS firenze
FROM reviews
GROUP BY review_year
ORDER BY review_year;

-- Aggregate: reviews per listing per month (2023-2025)
DROP TABLE IF EXISTS reviews_monthly;

CREATE TABLE reviews_monthly AS
SELECT
  listing_id,
  city,
  CAST(DATE_FORMAT(review_date, '%Y-%m-01') AS DATE) AS review_month,
  COUNT(*) AS n_reviews
FROM reviews
WHERE review_date >= '2023-01-01'
  AND review_date <  '2026-01-01'
GROUP BY listing_id, city, review_month;

-- Check: totals must match 2023+2024+2025 per city
SELECT
  city,
  COUNT(*)        AS listing_month_rows,
  SUM(n_reviews)  AS total_reviews
FROM reviews_monthly
GROUP BY city;