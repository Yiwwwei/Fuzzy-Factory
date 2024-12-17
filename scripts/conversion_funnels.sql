-- conversion_funnels.sql

-- Step 1: Identify sessions landing on "/lander-1"
CREATE TEMPORARY TABLE session_level_pages AS
WITH sessions_on_lander AS (
SELECT
website_pageviews.website_session_id
FROM
website_pageviews
INNER JOIN
website_sessions
ON website_sessions.website_session_id=website_pageviews.website_session_id
WHERE
website_pageviews.pageview_url = '/lander-1'
AND website_pageviews.created_at < '2012-09-05'
AND website_pageviews.created_at > '2012-08-05'
AND website_sessions.utm_source ='gsearch'
AND website_sessions.utm_campaign ='nonbrand'
GROUP BY
website_pageviews.website_session_id
)
SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at,
CASE WHEN pageview_url ='/products' THEN 1 ELSE 0 END AS products_page,
CASE WHEN pageview_url ='/cart' THEN 1 ELSE 0 END AS cart_page,
CASE WHEN pageview_url ='/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_page
FROM
website_pageviews
WHERE
website_pageviews.website_session_id IN (
SELECT website_session_id
FROM sessions_on_lander
)
AND website_pageviews.pageview_url IN (
'/lander-1', '/products', '/cart', '/thank-you-for-your-order'
);

-- Step 2: Analyze conversion funnels
SELECT
website_session_id,
MAX(products_page) AS products_page_it,
MAX(cart_page) AS cart_page_it,
MAX(thank_page) AS thank_page_it
FROM
session_level_pages
GROUP BY
website_session_id;

WITH sessions_funnels AS (
SELECT
website_session_id,
MAX(products_page) AS products_page_it,
MAX(cart_page) AS cart_page_it,
MAX(thank_page) AS thank_page_it
FROM
session_level_pages
GROUP BY
website_session_id)

SELECT
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT CASE WHEN products_page_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
COUNT(DISTINCT CASE WHEN cart_page_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
COUNT(DISTINCT CASE WHEN thank_page_it = 1 THEN website_session_id ELSE NULL END) AS to_thank
FROM sessions_funnels;

