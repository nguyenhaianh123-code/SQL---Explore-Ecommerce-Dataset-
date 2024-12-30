# SQL---Explore-Ecommerce-Dataset- 

# I. Introduction

This project explores an eCommerce dataset collected from Google Analytics in 2017. 
The dataset contains detailed information about user sessions on a website of an ecommerce company, and I will be using SQL on Google BigQuery to perform various analyses.
The dataset is organized in an array format to optimize storage costs and improve query performance.

## II. The Goal of Creating This Project

The primary goal of this project is to analyze and gain insights from the eCommerce dataset using SQL on Google BigQuery. The specific objectives of this project are:

- **Overview of Website Activity**: Understand overall website traffic and user engagement based on the available data.
- **Bounce Rate Analysis**: Evaluate the bounce rate by traffic source to understand how effectively the website retains visitors.
- **Revenue Analysis**: Analyze revenue generation by different traffic sources to identify high-performing channels.
- **Transactions Analysis**: Investigate transaction patterns to determine conversion rates and identify user behavior trends.
- **Products Analysis**: Perform an analysis of products viewed, added to carts, and purchased to better understand product performance and customer interest.

## III. Dataset description table 
https://docs.google.com/spreadsheets/d/1xT0opGBiewOLDdmjgOXVF5HI0-EMsLkPWqtBGiKoX-w/edit?usp=sharing

## IV. Explore dataset 


1. Count total number of row in this dataset

```
SELECT COUNT(fullVisitorId) row_num,
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
```
| Row	| row_num |
|-------|--------|
| 1	 | 467260 |

  
2. Count total number of row in July 2017
```
SELECT COUNT(fullVisitorId) row_num,
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
```

| Row	| row_num |
|-------|--------|
| 1	 | 71812 |



3. Calculate the total sessions for each month and the percentage contribution of each month to the total sessions.
```
SELECT EXTRACT(MONTH FROM PARSE_DATE("%Y%m%d",date)) month
,COUNT(*) AS counts
,ROUND((COUNT(*)/(SELECT COUNT(*) 
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`))*100,1) pct
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
GROUP BY EXTRACT(MONTH FROM PARSE_DATE("%Y%m%d",date))
```
| Month | Total Sessions (`counts`) | Percentage (`pct`) |
|-------|---------------------------|--------------------|
| 6     | 63,578                    | 13.6%             |
| 3     | 69,931                    | 15.0%             |
| 8     | 2,556                     | 0.5%              |
| 2     | 62,192                    | 13.3%             |
| 4     | 67,126                    | 14.4%             |
| 1     | 64,694                    | 13.8%             |
| 7     | 71,812                    | 15.4%             |
| 5     | 65,371                    | 14.0%             |


4. Unnest Hits and Products record
```
SELECT date, 
fullVisitorId,
eCommerceAction.action_type,
product.v2ProductName,
product.productRevenue,
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
UNNEST(hits) AS hits,
UNNEST(hits.product) as product
```
| Date       | Full Visitor ID         | Action Type | Product Name                      | Product Revenue |
|------------|--------------------------|-------------|------------------------------------|-----------------|
| 20170712   | 4080810487624198636     | 1           | YouTube Custom Decals             |                 |
| 20170712   | 4080810487624198636     | 2           | YouTube Custom Decals             |                 |
| 20170712   | 7291695423333449793     | 1           | Keyboard DOT Sticker              |                 |
| 20170712   | 7291695423333449793     | 2           | Keyboard DOT Sticker              |                 |
| 20170712   | 3153380067864919818     | 2           | Google Baby Essentials Set         |                 |
| 20170712   | 3153380067864919818     | 1           | Google Baby Essentials Set         |                 |
| 20170712   | 5615263059272956391     | 0           | Android Lunch Kit                 |                 |
| 20170712   | 5615263059272956391     | 0           | Android Rise 14 oz Mug            |                 |
| 20170712   | 5615263059272956391     | 0           | Android Sticker Sheet Ultra Removable |             |
| 20170712   | 5615263059272956391     | 0           | Windup Android                    |                 |

---
   
## V. Ask questions and solve it
### 5.1  Calculate total visits, pageview, transaction, and revenue for Jan, Feb, and March 2017

``` 
    SELECT 
    FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) month_extract
    ,SUM(totals.visits) visits
    ,SUM(totals.pageviews) pageviews
    ,SUM(totals.transactions) transactions
    ,ROUND(SUM(totals.totalTransactionRevenue)/POW(10,6),2) revenue
   FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
   WHERE _table_suffix BETWEEN '0101' AND '0331'
   GROUP BY month_extract 
```
   
| month |	visits |	pageviews |	transactions |	revenue|
|-------|--------|------|--------|------|
|201701	|64694	|257708	|713	|106248.15|
|201702	|62192	|233373	|733	|116111.6|
|201703	|69931	|259522	|993	|150224.7|

***Steps explaination***

The table provides a snapshot of The eCommerce website performance over the first quarter of 2017, including visits, pageviews, transactions, and revenue metrics. 
- Extract the month (%Y%m) from the date column (formatted as YYYYMMDD in STRING type) using the PARSE_DATE function.
- Calculate the total number of visits, page views, and transactions for each month.
- Compute the total transaction revenue for each month and normalize the values (convert to millions of currency units) by POW(10,6)
- Filter the data to include only records within the time range from January 1 to March 31, 2017, using the _table_suffix condition.

***Insights from the provided monthly data:***
- **Traffic and Engagement Patterns**: The number of visits and pageviews increased from January (201701) to March (201703), suggesting a growing website interest over time. Besides that, the increase in pageviews is a positive sign, indicating that users explore multiple pages during their visits, potentially finding the content engaging.

- **Conversion and Revenue Trends**:The number of transactions and total revenue also steadily increased from January to March. This demonstrates that more users are engaging with the site, and a growing proportion of them are also making transactions, contributing to increased revenue. Moreover, the substantial jump in transactions and revenue from January to March (201703) suggests that efforts made during this period might have been particularly effective in driving user conversions.

- **Seasonal or Marketing Influence**:The consistent growth in both transactions and revenue over the three months could indicate the influence of seasonality, marketing campaigns, or optimizations implemented during this time.

- **Future Strategy and Focus**: Consider further investigating what strategies, campaigns, or changes were implemented between January and March that contributed to the significant increase in transactions and revenue. These insights can inform future marketing and optimization efforts.

---
### 5.2 Bounce rate per traffic source in July 2017
```
SELECT trafficSource.source
       ,COUNT(visitNumber) total_visits
       ,SUM(totals.bounces) total_no_of_bounces
       ,ROUND((SUM(totals.bounces)/COUNT(visitNumber))*100,2) bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY trafficSource.source
ORDER BY total_visits DESC;
```
| Source                      | Total Visits | Total No. of Bounces | Bounce Rate (%) |
|-----------------------------|--------------|-----------------------|-----------------|
| google                     | 38400        | 19798                | 51.56           |
| (direct)                   | 19891        | 8606                 | 43.27           |
| youtube.com                | 6351         | 4238                 | 66.73           |
| analytics.google.com       | 1972         | 1064                 | 53.96           |
| Partners                   | 1788         | 936                  | 52.35           |
| m.facebook.com             | 669          | 430                  | 64.28           |
| google.com                 | 368          | 183                  | 49.73           |
| dfa                        | 302          | 124                  | 41.06           |
| sites.google.com           | 230          | 97                   | 42.17           |
| facebook.com               | 191          | 102                  | 53.4            |
| reddit.com                 | 189          | 54                   | 28.57           |
| qiita.com                  | 146          | 72                   | 49.32           |
| baidu                      | 140          | 84                   | 60              |
| quora.com                  | 140          | 70                   | 50              |
| bing                       | 111          | 54                   | 48.65           |
| mail.google.com            | 101          | 25                   | 24.75           |
| yahoo                      | 100          | 41                   | 41              |
| blog.golang.org            | 65           | 19                   | 29.23           |
| l.facebook.com             | 51           | 45                   | 88.24           |
| groups.google.com          | 50           | 22                   | 44              |
| t.co                       | 38           | 27                   | 71.05           |
| google.co.jp               | 36           | 25                   | 69.44           |
| m.youtube.com              | 34           | 22                   | 64.71           |
| dealspotr.com              | 26           | 12                   | 46.15           |
| productforums.google.com   | 25           | 21                   | 84              |
| ask                        | 24           | 16                   | 66.67           |
| support.google.com         | 24           | 16                   | 66.67           |
| int.search.tb.ask.com      | 23           | 17                   | 73.91           |
| optimize.google.com        | 21           | 10                   | 47.62           |
| docs.google.com            | 20           | 8                    | 40              |
| lm.facebook.com            | 18           | 9                    | 50              |
| l.messenger.com            | 17           | 6                    | 35.29           |
| adwords.google.com         | 16           | 7                    | 43.75           |
| duckduckgo.com             | 16           | 14                   | 87.5            |
| google.co.uk               | 15           | 7                    | 46.67           |
| sashihara.jp               | 14           | 8                    | 57.14           |
| lunametrics.com            | 13           | 8                    | 61.54           |
| search.mysearch.com        | 12           | 11                   | 91.67           |
| tw.search.yahoo.com        | 10           | 8                    | 80              |
| outlook.live.com           | 10           | 7                    | 70              |
| phandroid.com              | 9            | 7                    | 77.78           |
| connect.googleforwork.com  | 8            | 5                    | 62.5            |
| plus.google.com            | 8            | 2                    | 25              |
| m.yz.sm.cn                 | 7            | 5                    | 71.43           |
| google.co.in               | 6            | 3                    | 50              |
| search.xfinity.com         | 6            | 6                    | 100             |
| google.ru                  | 5            | 1                    | 20              |
| online-metrics.com         | 5            | 2                    | 40              |
| hangouts.google.com        | 5            | 1                    | 20              |
| s0.2mdn.net                | 5            | 3                    | 60              |
| m.sogou.com                | 4            | 3                    | 75              |
| in.search.yahoo.com        | 4            | 2                    | 50              |
| googleads.g.doubleclick.net| 4            | 1                    | 25              |
| away.vk.com                | 4            | 3                    | 75              |

***Steps explaination***
- Identify the total number of visits (visitNumber) for each traffic source.
- Count the total number of bounces (totals.bounces) for each source.
- Calculate the bounce rate: Bounce Rate = (Total Bounces/Total Visits)×100, which is the percentage of visits that resulted in a bounce.

- ROUND(..., 2) ensures the result is rounded to two decimal places.
- Order the traffic sources by the total number of visits in descending order.

***Traffic Insights:***

1. **Main Traffic Sources**:
Google and Direct bring the highest traffic (38,400 and 19,891 visits, respectively), but Google has a high bounce rate (51.56%). This suggests that while Google brings a large volume of traffic, a significant portion of users do not engage deeply. Users coming directly to the site often have clearer intentions.

2. **High Bounce Rate Sources**:
- YouTube.com:
Despite having only 6,351 visits, YouTube has a bounce rate of 66.73%, significantly higher than Google and Direct. This may suggest that users from YouTube do not find the content relevant or engaging enough to continue interacting.

- L.facebook.com and DuckDuckGo.com:
These sources have bounce rates of 88.24% and 87.5%, respectively, indicating that they may not deliver a suitable target audience or that the landing pages are not optimized for these users.

3. **High-Quality Sources**:
Mail.google.com (24.75%) and Reddit.com (28.57%) have low bounce rates, offering promising traffic potential.

4. **Uneffective Sources** :
Sources like Search.mysearch.com, wap.sogou.com, and github.com have extremely high bounce rates (≥ 90%) and are not effective.

***Improvement Suggestions***
1. Optimize Landing Pages:
Review the content or design of landing pages related to high bounce rate sources such as YouTube.com, m.facebook.com, and L.facebook.com to improve user experience.

2. Leverage Low Bounce Rate Sources:
Focus on sources like mail.google.com, plus.google.com, and reddit.com, as they provide high-quality traffic.

3. Analyze Target Audience:
Assess the relevance of content for audiences from sources with extremely high bounce rates (≥ 90%) to decide whether to continue or reduce investment in these sources.

4. Maximize Google and Direct Traffic:
Continue prioritizing Google and Direct traffic as the main sources, while optimizing their bounce rates by improving content or increasing on-site engagement.

### 5.3. Revenue by traffic source by week, by month in June 2017
```
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
```
***Steps explaination***  

**Step 1**: Data Preparation
- The data is split into two sections: monthly analysis and weekly analysis.
- Use two CTEs (GET_RE_MONTH and GET_RE_WEEK) to process the data separately.
  
**Step 2**: Revenue Calculation
  
- For monthly revenue (GET_RE_MONTH):
Use a window function (OVER(PARTITION BY trafficSource.source) to calculate the cumulative revenue for each traffic source.  

- For weekly revenue (GET_RE_WEEK):
Use GROUP BY to calculate total revenue per traffic source for each week.  

**Step 3**: Combining Results
- Use UNION ALL to merge the results of the two analyses into a single dataset.
Step 4: Sorting Results
- The final combined dataset is sorted by revenue in descending order to highlight the most significant revenue sources.

| time_type | time   | source             | revenue    |
|-----------|--------|--------------------|------------|
| Month     | 201706 | (direct)           | 97231.62   |
| WEEK      | 201724 | (direct)           | 30883.91   |
| WEEK      | 201725 | (direct)           | 27254.32   |
| Month     | 201706 | google             | 18757.18   |
| WEEK      | 201723 | (direct)           | 17302.68   |
| WEEK      | 201726 | (direct)           | 14905.81   |
| WEEK      | 201724 | google             | 9217.17    |
| Month     | 201706 | dfa                | 8841.23    |
| WEEK      | 201722 | (direct)           | 6884.9     |
| WEEK      | 201726 | google             | 5330.57    |
| WEEK      | 201726 | dfa                | 3704.74    |
| Month     | 201706 | mail.google.com    | 2563.13    |
| WEEK      | 201724 | mail.google.com    | 2486.86    |
| WEEK      | 201724 | dfa                | 2341.56    |
| WEEK      | 201722 | google             | 2119.39    |
| WEEK      | 201722 | dfa                | 1670.65    |
| WEEK      | 201723 | dfa                | 1124.28    |
| WEEK      | 201723 | google             | 1083.95    |
| WEEK      | 201725 | google             | 1006.1     |
| WEEK      | 201723 | search.myway.com   | 105.94     |
| Month     | 201706 | search.myway.com   | 105.94     |
| Month     | 201706 | groups.google.com  | 101.96     |
| WEEK      | 201725 | mail.google.com    | 76.27      |
| Month     | 201706 | chat.google.com    | 74.03      |
| WEEK      | 201723 | chat.google.com    | 74.03      |
| WEEK      | 201724 | dealspotr.com      | 72.95      |
| Month     | 201706 | dealspotr.com      | 72.95      |
| WEEK      | 201725 | mail.aol.com       | 64.85      |
| Month     | 201706 | mail.aol.com       | 64.85      |
| WEEK      | 201726 | groups.google.com  | 63.37      |
| Month     | 201706 | phandroid.com      | 52.95      |
| WEEK      | 201725 | phandroid.com      | 52.95      |
| Month     | 201706 | sites.google.com   | 39.17      |
| WEEK      | 201725 | groups.google.com  | 38.59      |
| WEEK      | 201725 | sites.google.com   | 25.19      |
| Month     | 201706 | google.com         | 23.99      |
| WEEK      | 201725 | google.com         | 23.99      |
| Month     | 201706 | yahoo              | 20.39      |
| WEEK      | 201726 | yahoo              | 20.39      |
| WEEK      | 201723 | youtube.com        | 16.99      |
| Month     | 201706 | youtube.com        | 16.99      |
| WEEK      | 201724 | bing               | 13.98      |
| Month     | 201706 | bing               | 13.98      |
| WEEK      | 201722 | sites.google.com   | 13.98      |
| WEEK      | 201724 | l.facebook.com     | 12.48      |
| Month     | 201706 | l.facebook.com     | 12.48      |
| WEEK      | 201724 | t.co               |            |
| WEEK      | 201724 | groups.google.com  |            |
| WEEK      | 201724 | Partners           |            |
| WEEK      | 201724 | qiita.com          |            |
| WEEK      | 201724 | sashihara.jp       |            |
| WEEK      | 201724 | yahoo              |            |

---
### 5.4. Average number of product pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017
```
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

```
***Steps explaination***    
1. **Definitions**:
- Purchasers:
Users who made at least one transaction (totals.transactions >= 1).
- Non-Purchasers:
Users who made no transactions (totals.transactions IS NULL).

2. **Approach**:

- Use two Common Table Expressions (CTEs) to calculate the total pageviews and distinct user counts for both purchaser types in June and July.
- Combine results from both months using UNION ALL.
- Calculate the average pageviews per user for both purchasers and non-purchasers by dividing total pageviews by the number of users.
- Sort results by month for clarity.


3. **Steps in the code**
   
   **Step 1**: CTE for June (GET_6_MONTH)
   
   - Define the Month: Creates a fixed column labeled 201706 to represent June 2017.
   - Calculate Total Pageviews for Purchurser and Non-purchaser with CASE WHEN
   - Count Unique Users for Purchurser and Non-purchaser with CASE WHEN

   **Step 2**: CTE for July (GET_7_MONTH)
   
   - Similar to GET_6_MONTH, except the fixed value for the MONTH column is "201707", and the data is queried from the July dataset
  
   **Step 3**: Combine Results
   
   - Use UNION ALL to combine the results from GET_6_MONTH and GET_7_MONTH:
   
   | month   | avg_pageviews_purchase | avg_pageviews_non_purchase |
|---------|-------------------------|----------------------------|
| 201706  | 25.73                  | 4.07                       |
| 201707  | 27.72                  | 4.19                       |

***Insights***  
1. Purchasers have significantly higher pageviews
   
- June 2017: On average, purchasers viewed 25.73 pages, while non-purchasers only viewed 4.07 pages.
- July 2017: Purchasers continued to have higher pageviews (27.72 pages) compared to non-purchasers (4.19 pages).
  
**-->**:  

- Purchasers tend to interact more deeply with the website, browsing through more pages to explore products or complete their transactions.
- Non-purchasers are more likely to leave the website early or fail to find appealing products.
  
2. Average pageviews increased slightly from June to July

- Purchasers:  
Pageviews increased from 25.73 (June) to 27.72 (July), representing a growth of approximately 7.7%.
- Non-Purchasers:  
Pageviews increased from 4.07 (June) to 4.19 (July), representing a slight growth of approximately 2.9%.


**-->**:

- The website may have improved its user experience or content in July, leading to an increase in pageviews for both groups.
- Purchasers, in particular, showed greater interaction in July, possibly due to promotional campaigns or the introduction of new products.

**Recommendations**:
- For Non-Purchasers:
They may not be the right target audience or face challenges in finding the desired products. Enhancing content or improving website navigation for this group could help boost conversion rates.
- For July Performance: Analyze the changes in July (content, products, campaigns) that led to increased interaction in both groups and replicate successful strategies.

---
### 5.5 Average amount of money spent per session. Only include purchaser data in July 2017

```
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
```
***Steps explaination** 
1. Filter for sessions in July 2017 where:
- Revenue (product.productRevenue) is recorded.
- Transactions (totals.transactions) are not null.

2. Aggregate data by month to calculate the total revenue and total visits.
3. Divides total revenue by total visits to calculate the average revenue per visit.
Divides by 1,000,000 to normalize the result to millions of currency units.
Rounds the result to two decimal places for readability.

5. The dataset contains nested fields (hits and hits.product), which need to be flattened using UNNEST to access individual rows of data.

| Month   | Avg_total_transactions_per_user |
|---------|----------------------------------|
| 201707  | 43.86                           |

---
### 5.6 Other products purchased by customers who purchased product” Youtube Men’s Vintage Henley” in July 2017
```
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
```
***Steps Explaination***
1. Use a Common Table Expression (CTE) to identify all customers (fullVisitorId) who purchased “YouTube Men's Vintage Henley” in July 2017.
3. RIGHT JOIN: Matches the list of customers (GET_CUS_ID) with all their transactions (TAB_A.fullVisitorId).
4. Exclude the specified product itself (YouTube Men's Vintage Henley) from the results.
5. Aggregate the quantity of other products purchased and sort the results by total quantity in descending order.

| other_purchased_products                              | quantity |
|-------------------------------------------------------|----------|
| Google Sunglasses                                     | 20       |
| Google Womens Vintage Hero Tee Black                 | 7        |
| SPF-15 Slim & Slender Lip Balm                       | 6        |
| Google Womens Short Sleeve Hero Tee Red Heather      | 4        |
| YouTube Mens Fleece Hoodie Black                     | 3        |
| Google Mens Short Sleeve Badge Tee Charcoal          | 3        |
| YouTube Twill Cap                                    | 2        |
| Red Shine 15 oz Mug                                  | 2        |
| Google Doodle Decal                                  | 2        |
| Recycled Mouse Pad                                   | 2        |
| Google Mens Short Sleeve Hero Tee Charcoal           | 2        |
| Android Womens Fleece Hoodie                         | 2        |
| 22 oz YouTube Bottle Infuser                         | 2        |
| Android Mens Vintage Henley                          | 2        |
| Crunch Noise Dog Toy                                 | 2        |
| Android Wool Heather Cap Heather/Black               | 2        |
| Google Mens Vintage Badge Tee Black                  | 1        |
| Google Twill Cap                                     | 1        |
| Google Mens Long & Lean Tee Grey                     | 1        |
| Google Mens Long & Lean Tee Charcoal                 | 1        |
| Google Laptop and Cell Phone Stickers                | 1        |
| Google Mens Bike Short Sleeve Tee Charcoal           | 1        |
| Google 5-Panel Cap                                   | 1        |
| Google Toddler Short Sleeve T-shirt Grey             | 1        |
| Android Sticker Sheet Ultra Removable                | 1        |
| YouTube Custom Decals                                | 1        |
| Four Color Retractable Pen                           | 1        |
| Google Mens Long Sleeve Raglan Ocean Blue            | 1        |
| Google Mens Vintage Badge Tee White                  | 1        |
| Google Mens 100% Cotton Short Sleeve Hero Tee Red    | 1        |
| Android Mens Vintage Tank                            | 1        |
| Google Mens Performance Full Zip Jacket Black        | 1        |
| 26 oz Double Wall Insulated Bottle                   | 1        |
| Google Mens Zip Hoodie                               | 1        |
| YouTube Womens Short Sleeve Hero Tee Charcoal        | 1        |
| Google Mens Pullover Hoodie Grey                     | 1        |
| YouTube Mens Short Sleeve Hero Tee White             | 1        |
| Android Mens Short Sleeve Hero Tee White             | 1        |
| Android Mens Pep Rally Short Sleeve Tee Navy         | 1        |
| YouTube Mens Short Sleeve Hero Tee Black             | 1        |
| Google Slim Utility Travel Bag                       | 1        |
| Android BTTF Moonshot Graphic Tee                    | 1        |
| Google Mens Airflow 1/4 Zip Pullover Black           | 1        |
| Google Womens Long Sleeve Tee Lavender               | 1        |
| 8 pc Android Sticker Sheet                           | 1        |
| YouTube Hard Cover Journal                           | 1        |
| Android Mens Short Sleeve Hero Tee Heather           | 1        |
| YouTube Womens Short Sleeve Tri-blend Badge Tee Charcoal | 1    |
| Google Mens Performance 1/4 Zip Pullover Heather/Black | 1    |
| YouTube Mens Long & Lean Tee Charcoal                | 1        |

---
### 5.7 Calculate cohort map from product view to add_to_cart/number_product_view.
```
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
```
***Steps Explaination***  

1.Divide the query into logical steps using Common Table Expressions (CTEs) to:
- Count product views (CTE: ```productview```): Filters data to only include events where the action type is 2 (product view).
- Count add-to-cart actions.(CTE: ```addtocart```): Filters data to only include events where the action type is 3 (add-to-cart).
- Count purchases with recorded revenue. (CTE: ```id_purchase_revenue```): Filters data to only include events where the action type is 6 (purchase).
2. Joins the results from the productview, addtocart, and purchase CTEs by month
3. Calculate conversion rates:
- Add-to-Cart Rate = (num_addtocart/num_product_view)×100
- Purchase Rate = (num_purchase/num_product_view)×100
4. Display the data in a month-by-month breakdown.
  - month: The month of the cohort.
  - num_product_view: Total product views for the month.
  - num_addtocart: Total add-to-cart actions for the month.
  - num_purchase: Total purchases for the month.
  - add_to_cart_rate: Conversion rate from product views to add-to-cart.
  - purchase_rate: Conversion rate from product views to purchase.

| month   | num_product_view | num_addtocart | num_purchase | add_to_cart_rate | purchase_rate |
|---------|------------------|---------------|--------------|------------------|---------------|
| 201701  | 25787            | 7342          | 4328         | 28.47%           | 16.78%        |
| 201702  | 21489            | 7360          | 4141         | 34.25%           | 19.27%        |
| 201703  | 23549            | 8782          | 6018         | 37.29%           | 25.56%        |

***Insights from Cohort table***
1. The add-to-cart rate increased steadily over the three months
- This indicates that users were increasingly engaging with the products and adding them to their carts.
- Possible reasons could include better product selection, enhanced user experience, or effective marketing campaigns.
2. The purchase rate also showed significant growth:
- A substantial increase in purchase rates suggests that more users were completing their purchases after viewing products.
- Improvements in checkout processes, targeted promotions, or discounts may have contributed to this trend.
3. March 2017 had the highest conversion rates for both:
- Add-to-Cart Rate: 37.29%
- Purchase Rate: 25.56%
  
-->
  
- March was the best-performing month, possibly due to promotional events or campaigns.
- This could reflect the effectiveness of specific seasonal strategies.

***Recommendations***   

**Maintain Momentum from March:**

- Analyze what worked well in March and replicate those strategies in future campaigns.

**Focus on Add-to-Cart Optimization:**  

- Since the add-to-cart rate directly impacts purchase rates, improving this step further can lead to higher overall conversions.
  
**Investigate January's Performance:**
- January had the lowest conversion rates. Analyzing user behavior and possible friction points in that month can provide opportunities for improvement.






   


