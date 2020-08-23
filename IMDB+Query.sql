/* PROBLEM STATEMENT: 
RSVP Movies is an Indian film production company which has produced many super-hit movies. 
They have usually released movies for the Indian audience but for their next project, they are 
planning to release a movie for the global audience in 2022.
Analyse the given data and give recommendations to RSVP Movies based on your insights. */

USE imdb;

/* SOLUTION APPROACH: Breaking the analysis into 4 segments.
- SEGMENT 1: Understanding the Data. */


-- 1.1: Finding total no.of rows in each table.
SELECT COUNT(*) AS director_mapping
FROM director_mapping;
-- There are total of 3,867 rows under the table: director_mapping.

SELECT COUNT(*) AS genre
FROM genre;
-- There are total of 14,662 rows under the table: genre.

SELECT COUNT(*) AS movie
FROM movie;
-- There are total of 7,997 rows under the table: movie.

SELECT COUNT(*) AS 'names'
FROM names;
--- There are total of 25,735 rows under the table: names.

SELECT COUNT(*) AS role_mapping
FROM role_mapping;
-- There are total of 15,615 rows under the table: role_mapping.


--  1.2: Idnetifying columns with NULL values under the table MOVIE.
SELECT COUNT(*) AS 'Null Count'
FROM movie
WHERE country IS NULL;
-- The column Country has null value of 20 rows.

SELECT COUNT(*) AS 'Null Count'
FROM movie
WHERE worlwide_gross_income IS NULL;
-- The column worlwide_gross_income has null value of 3,724 rows.

SELECT COUNT(*) AS 'Null Count'
FROM movie
WHERE languages IS NULL;
-- The column languages has null value of 194 rows.

SELECT COUNT(*) AS 'Null Count'
FROM movie
WHERE production_company IS NULL;
-- The column production_company has null value of 528 rows.


-- 1.3: Finding total no.of movies released each year.
SELECT Year,
	COUNT(id) AS number_of_movies
FROM movie
GROUP BY year;

-- 1.4: Finding total no.of movies month wise (Identifying trend in months)
SELECT MONTH(date_published) AS month_num,
	COUNT(id) AS number_of_movies
FROM movie
GROUP BY month_num
ORDER BY month_num;


-- 1.5: Finding total no.of movies released by India or USA for the year 2019.
SELECT COUNT(title) AS Total
FROM movie
WHERE country in ('USA', 'India') AND year = 2019;


-- 1.6: Identifying unique list of genres.
SELECT genre
FROM genre
GROUP BY genre;


-- 1.7: Identifying which genre has the highest no of movie release.
SELECT g.genre,
	COUNT(g.movie_id) AS Total
FROM genre g INNER JOIN movie m
	ON g.movie_id = m.id
WHERE year = 2019
GROUP BY genre
ORDER BY Total DESC
LIMIT 1;


-- 1.8: Indentifying total no of movies which has only one genre.
WITH one_genre AS (
	SELECT movie_id,
		COUNT(genre) AS genres
	FROM genre
	GROUP BY movie_id
	HAVING genres = 1)

SELECT COUNT(movie_id) AS Single_Genre
FROM one_genre;


-- 1.9: Finding the average duration of movies in each genre.
SELECT g.genre,
	ROUND(AVG(m.duration), 2) AS avg_duration
FROM genre g INNER JOIN movie m
	ON g.movie_id = m.id
GROUP BY genre;


-- 1.10 Assigning the ranks to genre based on the no of releases in the year 2019.
SELECT g.genre,
	COUNT(g.movie_id) AS movie_count,
    RANK() OVER(ORDER BY COUNT(g.movie_id) DESC) AS genre_rank
FROM genre g INNER JOIN movie m
	ON g.movie_id = m.id
WHERE year = 2019
GROUP BY genre;



/* SEGMENT 2: Analysing the Data using ratings table. */


-- 2.1: Finding the min and max value of the columns in ratings table.
SELECT MIN(avg_rating) AS min_avg_rating,
	MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM ratings;


-- 2.2: Finding top 10 movies based on average ratings.
SELECT m.title,
	r.avg_rating,
	DENSE_RANK () OVER ( ORDER BY avg_rating DESC) AS movie_rank
FROM movie m INNER JOIN ratings r
	ON m.id = r.movie_id
LIMIT 10;


-- 2.3: Summarizing the ratings table based on movie counts.
SELECT median_rating,
	COUNT(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY movie_count DESC;

-- 2.4: Identifying the best production house which has produced most no.of hit movies. (average rating > 8)
SELECT m.production_company,
	COUNT(r.movie_id) AS movie_count,
    DENSE_RANK () OVER ( ORDER BY COUNT(r.movie_id) DESC) AS prod_company_rank
FROM movie m INNER JOIN ratings r
	ON m.id = r.movie_id
WHERE avg_rating > 8
GROUP BY production_company;


-- 2.5: Identifying the genres having more than 1000 votes for movies released on March 2017 in USA
SELECT g.genre,
	COUNT(r.movie_id) AS movie_count
FROM movie m INNER JOIN genre g
	ON m.id = g.movie_id INNER JOIN ratings r
		ON m.id = r.movie_id
WHERE date_published LIKE '2017-03%' 
	AND country = 'USA' 
	AND total_votes > 1000
GROUP BY genre
ORDER BY movie_count DESC;


-- 2.6: Identifying the movies from each genre whoes name begin with the word 'THE' and which has an average rating > 8.
SELECT m.title,
	r.avg_rating,
	g.genre
FROM movie m INNER JOIN genre g
	ON m.id = g.movie_id INNER JOIN ratings r
		ON m.id = r.movie_id
WHERE title LIKE 'The%'
	AND avg_rating > 8
ORDER BY avg_rating DESC;


-- 2.7: Finding total no of movies having median_rating of 8 and which were released between 1 April 2018 and 1 April 2019.
SELECT COUNT(r.movie_id) AS Total
FROM movie m INNER JOIN ratings r
	ON m.id = r.movie_id
WHERE median_rating = 8 
	AND date_published BETWEEN '2018-04-01' AND '2019-04-01';


-- 2.8: Comparing total_votes between 'German' and 'Italian' movies.
	(SELECT SUM(r.total_votes) AS Total_votes
	FROM movie m INNER JOIN ratings r
		ON m.id = r.movie_id
	WHERE country = 'Germany')
UNION
	(SELECT SUM(r.total_votes) AS Total_votes
	FROM movie m INNER JOIN ratings r
		ON m.id = r.movie_id
	WHERE country = 'Italy');
    
    
    
/* SEGMENT 3: Analysing the data using 'Names' Table */


-- 3.1: Identifying the null columns in name table.
SELECT 
	SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls,
    SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
    SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls,
    SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
FROM names;


-- 3.2: Identifying top 3 directors among top 3 genre whose movie has an average_rating > 8.
SELECT g.genre, COUNT(g.movie_id) AS Total
FROM genre g INNER JOIN ratings r
USING (movie_id)
WHERE avg_rating > 8
GROUP BY genre
ORDER BY total DESC;

SELECT n.name AS director_name,
	COUNT(m.id) AS movie_count
FROM names n INNER JOIN  director_mapping d
	ON n.id = d.name_id INNER JOIN movie m
		ON m.id = d.movie_id INNER JOIN ratings r
			ON m.id = r.movie_id INNER JOIN genre g
				ON m.id = g.movie_id
WHERE avg_rating > 8 AND genre IN ('Drama', 'Action', 'Comedy')
GROUP BY director_name
ORDER BY movie_count DESC
LIMIT 3;

-- 3.3: Identifying top 2 actors whoes movie have a median_rating >= 8.
SELECT n.name AS actor_name,
	COUNT(m.id) AS movie_count
FROM names n INNER JOIN role_mapping ro
	ON n.id = ro.name_id INNER JOIN movie m 
		ON m.id = ro.movie_id INNER JOIN ratings r
			ON m.id = r.movie_id
WHERE median_rating >= 8
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT 2;


-- 3.4: Finding top 3 production houses based on the no. of votes received by their movies.
SELECT m.production_company,
	SUM(r.total_votes) AS vote_count,
    ROW_NUMBER () OVER ( ORDER BY SUM(r.total_votes) DESC) AS prod_comp_rank
FROM movie m INNER JOIN ratings r
	ON m.id = r.movie_id
GROUP BY production_company
LIMIT 3;


-- 3.5: Ranking Indian actors who have acted in atleast 5 indian movies based on their average ratings.
WITH Indian AS (
SELECT n.name AS actor_name,
	r.total_votes,
    m.id,
    r.avg_rating,
    total_votes * avg_rating AS w_avg
FROM names n INNER JOIN role_mapping ro
	ON n.id = ro.name_id INNER JOIN ratings r
		ON ro.movie_id = r.movie_id INNER JOIN movie m 
			ON m.id = r.movie_id
WHERE category = 'Actor' AND country = 'India'
ORDER BY actor_name),

Actor AS(
SELECT *,
	SUM(w_avg) OVER w1 AS rating,
    SUM(total_votes) OVER w2 AS Votes
FROM Indian
WINDOW w1 AS (PARTITION BY actor_name),
	w2 AS (PARTITION BY actor_name))

SELECT actor_name,
	Votes AS total_votes,
    COUNT(id) AS movie_count,
    ROUND(rating/ Votes, 2) AS actor_avg_rating,
    DENSE_RANK () OVER (ORDER BY rating/ Votes DESC) AS actor_rank
FROM Actor
GROUP BY actor_name
HAVING movie_count >= 5;


-- 3.6: Finding top 5 Indian actresses in Hindi language based on their average ratings.
-- Note: The actress should have acted in atleast 3 movies.
WITH Indian AS (
SELECT n.name AS actress_name,
	r.total_votes,
    m.id,
    r.avg_rating,
    total_votes * avg_rating AS w_avg
FROM names n INNER JOIN role_mapping ro
	ON n.id = ro.name_id INNER JOIN ratings r
		ON ro.movie_id = r.movie_id INNER JOIN movie m 
			ON m.id = r.movie_id
WHERE category = 'Actress' AND languages = 'Hindi'
ORDER BY actress_name),

Actress AS(
SELECT *,
	SUM(w_avg) OVER w1 AS rating,
    SUM(total_votes) OVER w2 AS Votes
FROM Indian
WINDOW w1 AS (PARTITION BY actress_name),
	w2 AS (PARTITION BY actress_name))

SELECT actress_name,
	Votes AS total_votes,
    COUNT(id) AS movie_count,
    ROUND(rating/ Votes, 2) AS actress_avg_rating,
    DENSE_RANK () OVER (ORDER BY rating/ Votes DESC) AS actress_rank
FROM Actress
GROUP BY actress_name
HAVING movie_count >= 3;


/* 3.7: Classifying Thriller movies into the following categories based on their ratings.
	Rating > 8: Superhit movies
	Rating between 7 and 8: Hit movies
	Rating between 5 and 7: One-time-watch movies
	Rating < 5: Flop movies */
    
SELECT m.title,
	r.avg_rating,
	CASE
		WHEN avg_rating > 8 THEN 'Superhit'
		WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit'
		WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch'
		ELSE 'Flop movies'
	END AS movie_type
FROM movie m INNER JOIN ratings r
	ON m.id = r.movie_id INNER JOIN genre g
		ON m.id = g.movie_id
WHERE genre = 'thriller';



/* SEGMENT 4: Final Analysis */


-- 4.1: Finding the genre-wise running total and moving average of the average movie duration
WITH Genre AS (
	SELECT g.genre,
		ROUND(AVG(m.duration), 2) AS avg_duration
	FROM movie m INNER JOIN genre g
		ON m.id = g.movie_id
	GROUP BY genre)

SELECT *,
	SUM(avg_duration) OVER w1 AS running_total_duration,
    AVG(avg_duration) OVER w2 AS moving_avg_duration
FROM Genre
WINDOW w1 AS (ORDER BY avg_duration ROWS UNBOUNDED PRECEDING),
	   W2 AS (ORDER BY avg_duration ROWS 3 PRECEDING);
       

-- 4.2: Finding the top 5 highest grossing movies each year which belong to the top 3 genres.
SELECT genre,
	COUNT(movie_id) AS movie_count
FROM genre
GROUP BY genre
ORDER BY movie_count DESC
LIMIT 3;
-- The TOP 3 genre are 'Drama', 'Comedy' and 'Thriller'.

WITH Top AS (
	SELECT g.genre,
		m.year,
		m.title AS movie_name,
		m.worlwide_gross_income,
		DENSE_RANK () OVER ( PARTITION BY year
							 ORDER BY worlwide_gross_income DESC) AS movie_rank
	FROM movie m INNER JOIN genre g
		ON m.id = g.movie_id
	WHERE genre IN ('Drama', 'Comedy', 'Thriller') AND worlwide_gross_income IS NOT NULL)

SELECT *
FROM Top
WHERE movie_rank <= 5
GROUP BY (movie_name);


-- 4.3: Finding top 2 production_company which have produced the highest number of hits among multilingual movies.
WITH Multilingual AS (
	SELECT m.production_company,
		COUNT(m.id) AS movie_count
	FROM movie m INNER JOIN ratings r
		ON m.id = r.movie_id
	WHERE median_rating >= 8 AND languages LIKE '%,%'
	GROUP BY production_company)

SELECT *,
	DENSE_RANK () OVER (ORDER BY movie_count DESC) AS prod_comp_rank
FROM Multilingual
WHERE production_company IS NOT NULL
LIMIT 2;


-- 4.4: Finding the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre
WITH Top AS (
	SELECT n.name AS actress_name,
		r.total_votes,
		m.id,
		r.total_votes * r.avg_rating AS w_avg
	FROM names n INNER JOIN role_mapping ro
		ON n.id = ro.name_id INNER JOIN ratings r
			ON ro.movie_id = r.movie_id INNER JOIN movie m 
				ON m.id = r.movie_id INNER JOIN genre g
					ON m.id = g.movie_id
	WHERE category = 'Actress' AND  genre = 'Drama' AND avg_rating >8),

Actress AS (
	SELECT *,
		SUM(w_avg) OVER w1 AS rating,
		SUM(total_votes) OVER w2 AS votes
	FROM Top
	WINDOW w1 AS (PARTITION BY actress_name),
		w2 AS (PARTITION BY actress_name)),

Rating AS (
	SELECT actress_name,
		votes AS total_votes,
		COUNT(id) AS movie_count,
		ROUND(rating/votes, 2) AS actress_avg_rating
	FROM Actress
	GROUP BY actress_name)

SELECT *,
	DENSE_RANK () OVER (ORDER BY movie_count DESC) AS actress_rank
FROM Rating;
-- LIMIT 3;

-- OR with just avg_rating

With Top AS (
	SELECT n.name AS actress_name,
		SUM(total_votes) AS total_votes,
		COUNT(m.id) AS movie_count,
		r.avg_rating
	FROM names n INNER JOIN role_mapping ro
		ON n.id = ro.name_id INNER JOIN ratings r
			ON ro.movie_id = r.movie_id INNER JOIN movie m 
				ON m.id = r.movie_id INNER JOIN genre g
					ON m.id = g.movie_id
	WHERE category = 'Actress' AND  genre = 'Drama' AND avg_rating > 8
	GROUP BY actress_name)

SELECT *,
	DENSE_RANK () OVER ( ORDER BY movie_count DESC) AS actress_rank
FROM Top
LIMIT 3;




select name,
count(movie_id) as movies
from director_mapping d inner join names n
on n.id = d.name_id
group by name
order by movies desc
limit 9;
-- Top 9 directors are 'A.L. Vijay', 'Andrew Jones', 'Chris Stokes', 'Justin Price', 'Jesse V. Johnson', 'Steven Soderbergh', 'Sion Sono', 'Özgür Bakar', 'Sam Liu'



with a as(
SELECT name,
	date_published
from movie m inner join director_mapping d
on m.id = d.movie_id inner join names n
on n.id = d.name_id
where name in ('A.L. Vijay', 'Andrew Jones', 'Chris Stokes', 'Justin Price', 'Jesse V. Johnson', 
				'Steven Soderbergh', 'Sion Sono', 'Özgür Bakar', 'Sam Liu')),
-- ORDER BY name, date_published),

b as(
select *,
	lead (date_published, 1) over (partition by name
									order by date_published) as next_movie
from a)

SELECT *,
datediff(next_movie, date_published) as days
from b;



/* 4.5: /* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations */

-- Findinng top 9 directors based on no.of movies.
SELECT n.Name,
	COUNT(d.movie_id) AS Movie_Count
FROM names n INNER JOIN director_mapping d
	ON n.id = d.name_id
GROUP BY Name
ORDER BY Movie_Count DESC
LIMIT 9;
 /* Top 9 directors are 'A.L. Vijay', 'Andrew Jones', 'Chris Stokes', 'Justin Price', 
 'Jesse V. Johnson', 'Steven Soderbergh', 'Sion Sono', 'Özgür Bakar', 'Sam Liu' */
 
 -- Fetching the other required details.
 WITH Top AS (
	 SELECT d.name_id AS director_id,
		n.name AS director_name,
		m.id,
		m.date_published,
		r.avg_rating,
		r.total_votes,
		m.duration,
		LEAD (date_published, 1) OVER w1 AS next_movie,
		MIN(avg_rating) OVER w2 AS min_rating,
		MAX(avg_rating) OVER w3 AS max_rating
	FROM names n INNER JOIN director_mapping d
		ON n.id = d.name_id INNER JOIN movie m
			ON m.id = d.movie_id INNER JOIN ratings r
				ON m.id = r.movie_id
	WHERE name IN ('A.L. Vijay', 'Andrew Jones', 'Chris Stokes', 'Justin Price', 'Jesse V. Johnson',
					'Steven Soderbergh', 'Sion Sono', 'Özgür Bakar', 'Sam Liu')
	WINDOW w1 AS ( PARTITION BY name
				   ORDER BY  date_published),
			w2 AS (PARTITION BY name),
			w3 AS (PARTITION BY name)),

Nine AS (
	SELECT *,
		DATEDIFF(next_movie, date_published) AS Days
	FROM Top),

Directors AS (
	SELECT *,
		ROUND(AVG((Days)) OVER (PARTITION BY director_name
						ORDER BY date_published)) AS avg_inter_movie_days
	FROM Nine)

SELECT director_id,
	director_name,
    COUNT(id) AS number_of_movies,
    avg_inter_movie_days,
    avg_rating,
    SUM(total_votes) AS total_votes,
    min_rating,
    max_rating,
    SUM(duration) AS total_duration
FROM Directors
GROUP BY director_name;