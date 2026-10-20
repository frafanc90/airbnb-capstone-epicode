USE airbnb_capstone;

-- Seasonal profile per city: share of reviews by calendar month (2023-2025 pooled)
SELECT
  city,
  MONTH(review_month)  AS month_num,
  SUM(n_reviews)       AS reviews,
  ROUND(
    100 * SUM(n_reviews) / SUM(SUM(n_reviews)) OVER (PARTITION BY city),
    2
  ) AS pct_of_total
FROM reviews_monthly
GROUP BY city, month_num
ORDER BY city, month_num;