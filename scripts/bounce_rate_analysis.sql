-- bounce_rate_analysis.sql

USE mavenfuzzyfactory;
-- Bounce rate analysis
-- Step 1: Identify landing pages per session
CREATE TEMPORARY TABLE first_pageviews AS
SELECT
website_pageviews.website_session_id,
MIN(website_pageviews.website_pageview_id) AS first_pageview_id
FROM
website_pageviews
LEFT JOIN website_sessions
ON website_sessions.website_session_id=website_pageviews.website_session_id
WHERE
website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY
website_pageviews.website_session_id;

-- Step 2: Landing pages per session
CREATE TEMPORARY TABLE sessions_w_landing_page AS
SELECT
first_pageviews.website_session_id,
website_pageviews.pageview_url AS landing_page
FROM
first_pageviews
LEFT JOIN website_pageviews
ON website_pageviews.website_pageview_id=first_pageviews.first_pageview_id;

-- Step 3: Sessions to bounce calculation
CREATE TEMPORARY TABLE bounce_sessions AS
SELECT
sessions_w_landing_page.website_session_id,
sessions_w_landing_page.landing_page,
COUNT(DISTINCT website_pageviews.website_pageview_id) AS pps
FROM
sessions_w_landing_page
LEFT JOIN website_pageviews
ON website_pageviews.website_session_id=sessions_w_landing_page.website_session_id
GROUP BY
sessions_w_landing_page.website_session_id,
sessions_w_landing_page.landing_page
HAVING
pps=1;

SELECT
sessions_w_landing_page.landing_page,
COUNT(DISTINCT sessions_w_landing_page.website_session_id) AS sessions,
COUNT(DISTINCT bounce_sessions.website_session_id) AS bounced_sessions,
COUNT(DISTINCT bounce_sessions.website_session_id)/COUNT(DISTINCT sessions_w_landing_page.website_session_id) AS bounce_rate
FROM
sessions_w_landing_page
LEFT JOIN bounce_sessions
ON sessions_w_landing_page.website_session_id=bounce_sessions.website_session_id
GROUP BY
sessions_w_landing_page.landing_page
ORDER BY
sessions_w_landing_page.website_session_id;

