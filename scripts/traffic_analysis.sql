-- traffic_analysis.sql

-- Find out the page view sessions
USE mavenfuzzyfactory;

SELECT
pageview_url,
COUNT(DISTINCT website_pageview_id) AS page_view_sessions
FROM
website_pageviews
WHERE website_pageview_id < 1000
GROUP BY pageview_url
ORDER BY 2 DESC;

-- Find the entry page
USE mavenfuzzyfactory;

CREATE TEMPORARY TABLE first_pageview AS
SELECT
website_session_id,
MIN(website_pageview_id) AS min_pageview_id
FROM
website_pageviews
WHERE
website_pageview_id < 1000
GROUP BY
website_session_id;

SELECT
website_pageviews.pageview_url AS landing_page,
COUNT(DISTINCT first_pageview.website_session_id) AS sessions_hitting_this_lander
FROM first_pageview
LEFT JOIN website_pageviews
ON website_pageview_id = first_pageview.min_pageview_id
GROUP BY
website_pageviews.pageview_url;

