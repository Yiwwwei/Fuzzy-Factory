-- ab_testing.sql

-- Landing pages A/B testing for '/billing' vs '/billing-2'
CREATE TEMPORARY TABLE session_pages AS
WITH sessions_on_lander AS (
SELECT
website_pageviews.website_session_id
FROM
website_pageviews
INNER JOIN
website_sessions
ON website_sessions.website_session_id=website_pageviews.website_session_id
WHERE
website_pageviews.pageview_url IN ('/billing', '/billing-2')
AND website_pageviews.created_at < '2012-11-10'
AND website_pageviews.created_at > '2012-09-10'
GROUP BY
website_pageviews.website_session_id
)
SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at,
CASE WHEN pageview_url ='/billing' THEN 1 ELSE 0 END AS billing_page,
CASE WHEN pageview_url ='/billing-2' THEN 1 ELSE 0 END AS billing_2_page,
CASE WHEN pageview_url ='/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_page
FROM
website_pageviews
WHERE
website_pageviews.website_session_id IN (
SELECT website_session_id
FROM sessions_on_lander
)
AND website_pageviews.pageview_url IN (
'/billing', '/billing-2', '/thank-you-for-your-order'
);

-- Final output for A/B test results
WITH sessions_funnels AS (
SELECT
website_session_id,
MAX(billing_page) AS billing_page_it,
MAX(billing_2_page) AS billing_2_page_it,
MAX(thank_page) AS thank_page_it
FROM
session_pages
GROUP BY
website_session_id)

SELECT
CASE
WHEN billing_page_it = 1 THEN 'Billing Page'
WHEN billing_2_page_it = 1 THEN 'Billing-2 Page'
END AS page,
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT CASE WHEN thank_page_it = 1 THEN website_session_id ELSE NULL END) AS orders,
COUNT(DISTINCT CASE WHEN thank_page_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS billing_to_orders
FROM sessions_funnels
GROUP BY
CASE
WHEN billing_page_it = 1 THEN 'Billing Page'
WHEN billing_2_page_it = 1 THEN 'Billing-2 Page';
