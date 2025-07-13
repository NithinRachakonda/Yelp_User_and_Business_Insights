---------------------------------- QUERIES ------------------------------------ 

---1---
SELECT EXTRACT(YEAR FROM joined_timestamp) AS joined_year, COUNT(user_id) AS user_count
FROM Users
WHERE EXTRACT(YEAR FROM joined_timestamp) >= 2010
GROUP BY joined_year
ORDER BY joined_year;


---2---
SELECT year, COUNT(user_id) AS elite_user_count
FROM User_elite_years
WHERE year BETWEEN 2012 AND 2021
GROUP BY year
ORDER BY year;


---3---
WITH topusersinfo AS (
	WITH topusers AS (
	    SELECT user_id, count(rating) AS no_of_5star_reviews 
	    FROM Reviews WHERE (rating = 5.0) 
	    GROUP BY user_id 
	    ORDER BY no_of_5star_reviews DESC
	    LIMIT 3
    )
    SELECT users.user_id, users.name, topusers.no_of_5star_reviews, users.joined_timestamp, users.fans, users.useful_votes, users.funny_votes, users.cool_votes 
    FROM topusers
    LEFT JOIN users 
    ON users.user_id = topusers.user_id
)

SELECT name,review
FROM (
    SELECT t.user_id, t.name, r.review, ROW_NUMBER() OVER (PARTITION BY t.user_id ORDER BY r.review_date DESC) AS rn
    FROM topusersinfo AS t
    LEFT JOIN reviews AS r 
    ON t.user_id = r.user_id
) 
AS review_examples
WHERE rn <= 3
ORDER BY user_id, rn;


---4---
--- No data was provided regarding user friends so we cannot complete this query


---5---
SELECT state, count(business_id) AS no_of_businesses
FROM Businesses
GROUP BY state
ORDER BY no_of_businesses DESC
LIMIT 10;


---6---
SELECT category_name, count(business_id) AS no_of_businesses
FROM Businesses_categories
GROUP BY category_name
ORDER BY no_of_businesses DESC
LIMIT 10;

---7---
WITH topcategories AS (
	SELECT category_name, count(business_id) AS no_of_businesses
	FROM Business_categories
	GROUP BY category_name
	ORDER BY no_of_businesses DESC
	LIMIT 10
)

SELECT bc.category_name, avg(b.average_reviews) AS average_rating
FROM Businesses_categories AS bc
LEFT JOIN Businesses AS b ON bc.business_id = b.business_id
WHERE category_name IN (SELECT category_name FROM topcategories)
GROUP BY category_name
ORDER BY average_rating DESC;

---8--- 
WITH restaurants AS (
	SELECT business_id FROM Businesses_categories
	WHERE category_name = 'Restaurants'
)
		--- most funniest
SELECT review_text,funny_markings
FROM Reviews
WHERE business_id IN (SELECT business_id FROM restaurants)
ORDER BY funny_markings DESC
LIMIT 30;
		--- least funny
SELECT review_text,funny_markings
FROM Reviews
WHERE business_id IN (SELECT business_id FROM restaurants)
ORDER BY funny_markings 
LIMIT 30;

--- 9 ---
WITH best_tips AS (
	SELECT no_of_compliments, CHAR_LENGTH(tip_text) AS length_of_tip
	FROM Tips
	ORDER BY compliments_for_tip DESC
	LIMIT 100
),
worst_tips AS (
	SELECT no_of_compliments, CHAR_LENGTH(tip_text) AS length_of_tip
	FROM Tips
	ORDER BY compliments_for_tip
	LIMIT 100
)

SELECT 'Best 100 tips' AS tips_category, avg(length_of_tip) AS average_length_of_tips
FROM best_tips
UNION ALL
SELECT 'Worst 100 tips' AS tips_category, avg(length_of_tip) AS average_length_of_tips
FROM worst_tips;

--- 10 ---
WITH mostreviewed AS (
	SELECT business_id, business_name, no_of_reviews
	FROM Businesses
	ORDER BY no_of_reviews DESC
	LIMIT 10
)
SELECT mr.business_id, mr.business_name, bh.day, bh.closing_time, bh.opening_time
FROM mostreviewed AS mr
LEFT JOIN businesses_hours AS bh ON mr.business_id = bh.business_id
WHERE mr.business_id IN (SELECT business_id FROM mostreviewed)
ORDER BY mr.business_id