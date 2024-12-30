-- Câu 1: Calculate total visit, pageview, transaction and revenue for January, February and March 2017 order by month

    SELECT 
    FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) month_extract
    ,SUM(totals.visits) visits
    ,SUM(totals.pageviews) pageviews
    ,SUM(totals.transactions) transactions
    ,ROUND(SUM(totals.totalTransactionRevenue)/POW(10,6),2) revenue
   FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
   WHERE _table_suffix BETWEEN '0101' AND '0331'
   GROUP BY month_extract 

-- Câu 2: Bounce rate per traffic source in July 2017
SELECT trafficSource.source
       ,COUNT(visitNumber) total_visits
       ,SUM(totals.bounces) total_no_of_bounces
       ,ROUND((SUM(totals.bounces)/COUNT(visitNumber))*100,2) bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY trafficSource.source
ORDER BY total_visits DESC;

-- Câu 3: Revenue by traffic source by week, by month in June 2017
WITH GET_RE_MONTH AS 
(
    SELECT DISTINCT
        CASE WHEN 1=1 THEN "Month" END time_type,
        FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS time ,
        trafficSource.source AS source,
        ROUND(SUM(totals.totalTransactionRevenue/1000000) OVER(PARTITION BY trafficSource.source),2) revenue
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
),

GET_RE_WEEK AS 
(
    SELECT
        CASE WHEN 1=1 THEN "WEEK" END time_type,
        FORMAT_DATE("%Y%W", PARSE_DATE("%Y%m%d", date)) AS time,
        trafficSource.source AS source,
        SUM(totals.totalTransactionRevenue)/1000000 revenue
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    WHERE _table_suffix BETWEEN '0601' AND '0630'
    GROUP BY 1,2,3
)

SELECT * FROM GET_RE_MONTH
UNION ALL 
SELECT * FROM GET_RE_WEEK
ORDER BY revenue DESC;

-- Câu 4: Average number of product pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017
WITH GET_6_MONTH AS (
    SELECT
        CASE WHEN 1=1 THEN "201706" END AS MONTH,
        SUM(CASE WHEN totals.transactions >= 1 THEN totals.pageviews END) AS TOTAL_PUR_PAGEVIEWS,
        SUM(CASE WHEN totals.transactions IS NULL THEN totals.pageviews END) AS TOTAL_NON_PUR_PAGEVIEWS,
        COUNT(DISTINCT(CASE WHEN totals.transactions >= 1 THEN fullVisitorId END)) AS NUM_PUR,
        COUNT(DISTINCT(CASE WHEN totals.transactions IS NULL THEN fullVisitorId END)) AS NUM_NON_PUR
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
),
GET_7_MONTH AS (
    SELECT
        CASE WHEN 1=1 THEN "201707" END AS MONTH,
        SUM(CASE WHEN totals.transactions >= 1 THEN totals.pageviews END) AS TOTAL_PUR_PAGEVIEWS,
        SUM(CASE WHEN totals.transactions IS NULL THEN totals.pageviews END) AS TOTAL_NON_PUR_PAGEVIEWS,
        COUNT(DISTINCT(CASE WHEN totals.transactions >= 1 THEN fullVisitorId END)) AS NUM_PUR,
        COUNT(DISTINCT(CASE WHEN totals.transactions IS NULL THEN fullVisitorId END)) AS NUM_NON_PUR
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
)

SELECT MONTH AS month,
       TOTAL_PUR_PAGEVIEWS / NUM_PUR AS avg_pageviews_purchase,
       TOTAL_NON_PUR_PAGEVIEWS / NUM_NON_PUR AS avg_pageviews_non_purchase
FROM GET_6_MONTH
UNION ALL
SELECT MONTH AS month,
       TOTAL_PUR_PAGEVIEWS / NUM_PUR AS avg_pageviews_purchase,
       TOTAL_NON_PUR_PAGEVIEWS / NUM_NON_PUR AS avg_pageviews_non_purchase
FROM GET_7_MONTH
ORDER BY MONTH;

-- Câu 5: Average number of transactions per user that made a purchase in July 2017
SELECT 
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month,
  ROUND((SUM(product.productRevenue) / SUM(totals.visits))/1000000,2) AS Avg_revenue_by_user_per_visit
FROM 
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`, 
  UNNEST(hits) AS hits, 
  UNNEST(hits.product) AS product
WHERE 
  _TABLE_SUFFIX BETWEEN '20170701' AND '20170731'
  AND product.productRevenue IS NOT NULL
  AND totals.transactions IS NOT NULL
GROUP BY month;

-- Câu 6: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017
WITH GET_CUS_ID AS (SELECT DISTINCT fullVisitorId as Henley_CUSTOMER_ID
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
UNNEST(hits) AS hits,
UNNEST(hits.product) as product
WHERE product.v2ProductName = "YouTube Men's Vintage Henley"
AND product.productRevenue IS NOT NULL)

SELECT product.v2ProductName AS other_purchased_products,
       SUM(product.productQuantity) AS quantity
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*` TAB_A 
RIGHT JOIN GET_CUS_ID
ON GET_CUS_ID.Henley_CUSTOMER_ID=TAB_A.fullVisitorId,
UNNEST(hits) AS hits,
UNNEST(hits.product) as product
WHERE TAB_A.fullVisitorId IN (SELECT * FROM GET_CUS_ID)
    AND product.v2ProductName <> "YouTube Men's Vintage Henley"
    AND product.productRevenue IS NOT NULL
GROUP BY product.v2ProductName
ORDER BY QUANTITY DESC;

-- Câu 7: Calculate cohort map from pageview to addtocart to purchase
WITH addtocart AS
(
       SELECT
       FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) AS month
       ,COUNT(eCommerceAction.action_type) AS num_addtocart
       FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`   
               ,UNNEST (hits) AS hits
       WHERE _table_suffix BETWEEN '0101' AND '0331'
               AND eCommerceAction.action_type = '3'
       GROUP BY month 
)
   , productview AS
(
       SELECT
       FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) AS month
       ,COUNT(eCommerceAction.action_type) AS num_product_view
       FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`   
               ,UNNEST (hits) AS hits
       WHERE _table_suffix BETWEEN '0101' AND '0331'
               AND eCommerceAction.action_type = '2'
       GROUP BY month 
)
   , id_purchase_revenue AS -- this is the first step to inspect the purchase step
(
               SELECT
       FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) AS month
       ,fullVisitorId
       ,eCommerceAction.action_type
       ,product.productRevenue -- notice that not every purchase step that an ID made that the revenue was recorded (maybe refund?).
       FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`   
               ,UNNEST (hits) AS hits
               ,UNNEST (hits.product) AS product -- productrevenue 
       WHERE _table_suffix BETWEEN '0101' AND '0331'
               AND eCommerceAction.action_type = '6'
)
   , purchase AS
(
       SELECT 
           month
           ,COUNT(action_type) AS num_purchase
       FROM id_purchase_revenue 
       WHERE productRevenue IS NOT NULL
       GROUP BY month
)
SELECT 
       month
       ,num_product_view
       ,num_addtocart
       ,num_purchase
       ,ROUND(num_addtocart / num_product_view * 100.0, 2) AS add_to_cart_rate
       ,ROUND(num_purchase / num_product_view * 100.0, 2) AS purchase_rate
FROM productview
JOIN addtocart
USING (month)
JOIN purchase
USING (month)
ORDER BY month;