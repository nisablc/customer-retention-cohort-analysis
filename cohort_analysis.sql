WITH cohort AS (
SELECT 
  customerid,
  DATE_TRUNC(
    'month',
    MIN(TO_TIMESTAMP(invoicedate, 'YYYY-MM-DD'))
  ) AS cohort_month
FROM online_retail
GROUP BY customerid 
),
base as(
SELECT 
o.customerid,
date_trunc('month',to_timestamp(o.invoicedate, 'YYYY-MM-DD')) 
AS purchase_month,
c.cohort_month
FROM online_retail o
JOIN cohort c ON o.customerid=c.customerid 
),
cohort_counts AS(
SELECT
  cohort_month,
  (
    (DATE_PART('year', purchase_month) - DATE_PART('year', cohort_month)) * 12
    +
    (DATE_PART('month', purchase_month) - DATE_PART('month', cohort_month))
  ) AS month_number,
  COUNT(DISTINCT customerid) AS customers
FROM base
GROUP BY cohort_month, month_number
ORDER BY cohort_month, month_number
)
SELECT 
cohort_month,
month_number,
customers,
first_value(customers) over(PARTITION BY cohort_month ORDER BY month_number)
AS cohort_size,
Round(customers * 1.0/first_value(customers) over(PARTITION BY cohort_month ORDER BY month_number),2)
AS retention_rate
FROM cohort_counts 
ORDER BY cohort_month, month_number

