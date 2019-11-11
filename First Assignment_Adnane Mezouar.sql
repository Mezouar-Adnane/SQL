-- MOVIE_DB EXERCISE LEVEL 1
 
-- QUESTION 1 
select  
	imdb_id,
	original_title,
	revenue
from movies_metadata_id 
ORDER BY revenue DESC
LIMIT 3; 

-- QUESTION 2 

select  
	imdb_id,
	release_date,
	original_title,
	revenue
from movies_metadata_id 
WHERE YEAR(release_date) = '2016'
ORDER BY revenue DESC
LIMIT 1; 

-- QUESTION 3 
SELECT 
	YEAR(release_date) AS year_date,
	count(*) AS num_movies_released,
	max(revenue),
	SUM(revenue) AS yearly_revenue
FROM movies_metadata_id 
GROUP BY year_date
ORDER BY year_date DESC;

-- EXERCISES LEVEL 2 

-- QUESTION 4) 
-- Create a query to get the top movie (highest revenue) for each year

SELECT 
	sub.year_date, sub.max_revenue,
	mvs.title
FROM (
	SELECT 
		YEAR(release_date)  year_date,
		max(revenue)  max_revenue,
		SUM(revenue)
	FROM movies_metadata_id 
	GROUP BY year_date
	HAVING year_date <= 2017) sub
	
JOIN movies_metadata_id AS mvs
	ON sub.max_revenue = mvs.revenue AND sub.year_date = YEAR(mvs.release_date) 
ORDER BY year_date DESC;


-- QUESTION 5) Who is the main actor who played in movies that brought
-- the most total revenue and what are his top 3 movies 

-- PART ONE: FINDING THE ACTOR NAME 

SELECT
	sub.name, -- EXTRACT NAME FROM SUB-QUERY
	SUM(revenue) AS total_revenue -- AGGREGATE REVENUES BEFORE GROUPING 
FROM (
	SELECT  
		cst.name, -- CAST NAME
		revenue -- REVENUE FROM MOVIES
	FROM movies_metadata_id mvs JOIN cast_id cst
		ON mvs.id = cst.id -- JOINING BOTH TABLES 
	WHERE belongs_to_collection IS NULL AND cst.order = 0 -- OUR CONDITIONS
	ORDER BY REVENUE DESC
	) sub -- RESULT ALIAS
GROUP BY sub.name -- AGGREGATE REVENUE BY CAST NAME 
ORDER BY total_revenue DESC
LIMIT 1; -- We only want #1 It's DiCaprio!

-- PART TWO: RANKING HIS TOP 3 MOVIES BY REVENUE 

SELECT 
	name, 
	title, 
	revenue
FROM movies_metadata_id mvs JOIN cast_id cst 
	ON mvs.id = cst.id
WHERE cst.name like "%diCap%" 
ORDER BY revenue DESC
LIMIT 3; -- Inception, the revenenat, Django unchained

-- QUESTION 6) 
-- Who is the main actor who played at least 5 movies
-- with the highest average revenue per movie (What is his average revenue)

SELECT 
	name,
	count(*) AS num_movies, -- Calculate number of movies
	ROUND(AVG(revenue),2) AS avg_rev -- necessary for grouping by 
FROM (
	SELECT  
		cst.name, -- CAST NAME
		revenue -- REVENUE FROM MOVIES
	FROM movies_metadata_id mvs JOIN cast_id cst
		ON mvs.id = cst.id -- JOINING BOTH TABLES 
	WHERE cst.order = 0 -- OUR CONDITIONS/ add belongs_to_collection IS NOT NULL to find HarryPotter sequels
	ORDER BY REVENUE DESC
	) sub
	
GROUP BY name
HAVING num_movies >= 5 -- at least 5 movies 
ORDER BY avg_rev DESC -- arrange in descending order and daniel is #1 with 15 MOVIES and an average of 522M$

-- QUESTION 7 LEVEL 3
-- For each Movie Genre, for the release since 2015, 
-- give the movie title with the highest revenue and its revenue

SELECT 	
	sub.genre, 
	mvs.title,
	sub.title_revenue,
	sub.genre_revenue
	
FROM ( -- subquery
	SELECT
		grs.name as genre,
		max(mvs.revenue) as title_revenue, -- movie with largest revenue
		sum(mvs.revenue) as genre_revenue 
		
	FROM movies_metadata_id AS mvs JOIN genres_id AS grs
		ON mvs.id = grs.id 
		
	WHERE release_date >= "2015-01-01" -- earlier than 2015 included
	
	GROUP BY genre ) sub -- subquery alias 'sub'
	
JOIN movies_metadata_id AS mvs ON mvs.revenue = sub.title_revenue
ORDER BY title_revenue DESC;

-- QUESTION 8 LEVEL 4
-- PART 1 selecting the right actors

CREATE TABLE right_actors ( -- CREATING THE TABLE 
name varchar(50), 
title varchar(100), 
revenue bigint);

INSERT INTO right_actors -- FILLING THE TABLE 
SELECT 
	cst.name,
	mvs.title,
	mvs.revenue
FROM movies_metadata_id AS mvs JOIN cast_id as cst 
	ON mvs.id = cst.id
WHERE YEAR(release_date) > 2010 AND cst.order < 3 AND cst.character NOT LIKE "%voice%"
ORDER BY mvs.revenue DESC;

-- PART2 CREATE A TABLE FOR 
-- ALL POSSIBLE DUOS FOR each MOVIE WITH TITLES AND REVENUES
CREATE TABLE all_possible_duos ( -- CREATING THE TABLE 
actor_duo varchar(100),
duo_revenue bigint,
title varchar(100)
); 
INSERT INTO all_possible_duos -- FILLING THE TABLE
SELECT 
	concat(sub.duo1, ' ', sub.duo2) AS actor_duo, -- put name together as one column
	sub.revenue AS duo_revenue,
	sub.title
FROM
	(SELECT -- query creates a table with all possible combinations
		r1.name AS duo1, 
		r2.name AS duo2 , 
		r1.title,
		r1.revenue
	FROM right_actors as r1  JOIN right_actors AS r2 -- SELF JOIN 
	ON r1.title = r2.title AND r1.name <> r2.name) -- actors shouldn't match with themselves 
	-- STILL GETTING DUPLICATES 6 duos instead of 3
GROUP BY actor_duo
ORDER BY duo_revenue DESC;

-- PART 3 WHO ARE THEY? 

SELECT 
	actor_duo,
	sum(duo_revenue) AS total_duo_revenue
FROM all_possible_duos
GROUP BY actor_duo
ORDER BY total_duo_revenue DESC; 
-- RESULT GIVES VIN DIESEL AND DWAYNE JOHNSON 
-- DIFFERENT RESULT BECAUSE DIFFERENT VERSIONS IN DATABASE?
-- YAAY I MADE IT !!

