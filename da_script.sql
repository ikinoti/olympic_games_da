-- 1- How many olympics games have been held?
SELECT COUNT(DISTINCT(Games)) AS Total_Games
FROM olympics.athlete_events;

-- 2- List down all Olympics games held so far.
SELECT DISTINCT(Games)
FROM olympics.athlete_events
-- WHERE Games IS NOT NULL
ORDER BY Games;

-- ADDITIONAL:- List the year, Seaso and city where each olympic was held 
SELECT DISTINCT(Games), Year, Season, City
FROM olympics.athlete_events
-- WHERE Games IS NOT NULL
ORDER BY Games;

-- 3- Mention the total no of nations who participated in each olympics game?
SELECT a.Games, COUNT(DISTINCT(r.region)) AS Total_Countries
FROM olympics.athlete_events AS a
INNER JOIN olympics.regions AS r
	ON 	a.NOC = r.NOC
GROUP BY a.Games;

-- 4- Which year saw the highest and lowest no of countries participating in olympics
WITH total_countries AS (
	SELECT a.Games, COUNT(DISTINCT(r.region)) AS Total_Countries
	FROM olympics.athlete_events AS a
	INNER JOIN olympics.regions AS r
		ON 	a.NOC = r.NOC
	GROUP BY a.Games
    )
SELECT DISTINCT
	concat(FIRST_VALUE(Games) OVER(ORDER BY Total_Countries), ' - ', FIRST_VALUE(Total_Countries) OVER(ORDER BY Total_countries)) as Lowest_Countries_turnup,
    concat(FIRST_VALUE(Games) OVER(ORDER BY Total_Countries DESC), ' - ', FIRST_VALUE(Total_Countries) OVER(ORDER BY Total_countries DESC)) as Highest_Countries_turnup
FROM total_countries;

-- 5- Which nation has participated in all of the olympic games
WITH total_countries AS(
	SELECT count(DISTINCT(Games)) as Total_Olympic_Games
	FROM olympics.athlete_events
    ),
total_game_participated AS (
	SELECT r.region AS country, count(DISTINCT(Games)) AS Total_participted_games
	FROM olympics.athlete_events AS a
	INNER JOIN olympics.regions AS r
		ON a.NOC = r.NOC
	GROUP BY country
    )
SELECT tg.*
FROM total_game_participated AS tg
JOIN total_countries AS tc
	ON tc.Total_Olympic_Games = tg.Total_participted_games;

-- 6-  Identify the sport which was played in all summer olympics.
WITH total_summer_games AS(
-- query the total no of olympic summer games
	SELECT COUNT(DISTINCT(Games)) AS total_games
    FROM olympics.athlete_events
    WHERE Season = "Summer"
    ),
 -- query the count of sports that were played in every summer games
 sport_in_summer_games AS(
	SELECT Sport,  COUNT(DISTINCT(Games)) AS No_of_Sport_sGames
    FROM olympics.athlete_events
    WHERE Season = "Summer"
    GROUP BY Sport
    -- ORDER BY Games
    )
SELECT Sport, t2.No_of_Sport_sGames, t1.total_games
FROM sport_in_summer_games AS t2
JOIN  total_summer_games AS t1
	ON t2.No_of_Sport_sGames = t1.total_games;
    
-- 7- Which Sports were just played only once in the olympics.
WITH t1 AS(
	SELECT DISTINCT(Games), Sport
	FROM olympics.athlete_events
	ORDER BY Games
    ),
t2 AS(
	SELECT Sport, count(DISTINCT(Games)) AS No_of_Games
	FROM olympics.athlete_events
	GROUP BY Sport
    )
SELECT t1.Sport, No_of_Games, Games
FROM t2
JOIN t1
	ON t2.Sport = t1.Sport
WHERE No_of_Games = 1;

-- 8- Fetch the total no of sports played in each olympic games.
SELECT Games, COUNT(DISTINCT(Sport)) AS no_of_sports
FROM olympics.athlete_events
GROUP BY Games
ORDER BY no_of_sports DESC;

-- 9- Fetch oldest athletes to win a gold medal
WITH t1 AS(
	SELECT *,
		RANK() OVER(ORDER BY Age DESC) AS Ranks
	FROM olympics.athlete_events
	WHERE Age <> "NA" AND Medal = "Gold"
	)
SELECT *
FROM t1
WHERE Ranks = 1;

-- 10- Find the Ratio of male and female athletes participated in all olympic games.
WITH t1 AS(
	SELECT Sex, COUNT(1) as cnt
	FROM olympics.athlete_events
	GROUP BY Sex
    ),
t2 AS (
	SELECT *,
    ROW_NUMBER() OVER(ORDER BY cnt) as rnk
    FROM t1
    WHERE Sex IS NOT NULL
    ),
min_count AS (
	SELECT cnt 
    FROM t2
    WHERE rnk = 1
    ),
max_count AS (
	SELECT cnt 
    FROM t2
    WHERE rnk = 2
    )
SELECT concat('1 : ', round(max_count.cnt/min_count.cnt, 2)) AS Ratio
FROM min_count, max_count;

-- 11- Fetch the top 5 athletes who have won the most gold medals.
WITH t1 AS(
	SELECT Name, Team, COUNT(Medal) Total_Gold_Medal
	FROM olympics.athlete_events
	WHERE Medal = 'Gold'
	GROUP BY Name, Team
    ),
t2 AS(
	SELECT *,
		DENSE_RANK() OVER(ORDER BY Total_Gold_Medal DESC) D_Rank
    FROM t1
    )
SELECT Name, Team, Total_Gold_Medal
FROM t2
WHERE D_Rank <= 5;

-- 12- Fetch the top 5 athletes who have won the most medals (gold/silver/bronze)
WITH t1 AS (
    SELECT Name, Team, COUNT(Medal) TotaL_Medal
	FROM olympics.athlete_events
    WHERE Medal <> 'NA'
	GROUP BY Name, Team
	ORDER BY Total_Medal DESC
    ),
t2 AS (
	SELECT *,
		DENSE_RANK() OVER(ORDER BY TotaL_Medal DESC) as drnk
	FROM t1
    )
SELECT Name, Team, TotaL_Medal
FROM t2
WHERE drnk <= 5;

-- 13- Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
WITH t1 AS(
	SELECT region, COUNT(Medal) AS Total_Medal
	FROM olympics.athlete_events AS a
	JOIN olympics.regions AS r
		ON a.NOC = r.NOC
	WHERE Medal <> 'NA'
	GROUP BY region
	ORDER BY Total_Medal DESC
    ),
t2 AS (
	SELECT *,
		DENSE_RANK() OVER(ORDER BY Total_Medal DESC) AS drnk
	FROM t1
	)
SELECT *
FROM t2
WHERE drnk <= 5;

-- 14- List down total gold, silver and bronze medals won by each country.
WITH t1 AS (
	SELECT region, Medal
	FROM olympics.athlete_events AS a
	JOIN olympics.regions AS r
		ON a.NOC = r.NOC
	WHERE Medal <> 'NA'
    )
SELECT region,
	COUNT(CASE WHEN Medal = 'Gold' THEN Medal END) AS Gold,
    COUNT(CASE WHEN Medal = 'Silver' THEN Medal END) AS Silver,
    COUNT(CASE WHEN Medal = 'Bronze' THEN Medal END) AS Bronze
FROM t1
GROUP BY region
ORDER BY Gold DESC, Silver DESC, Bronze DESC;

-- 15- List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
WITH t1 AS (
	SELECT Games, region, Medal
	FROM olympics.athlete_events AS a
	JOIN olympics.regions AS r
		ON a.NOC = r.NOC
	WHERE Medal != 'NA'
    )
SELECT Games, region,
	COUNT(CASE WHEN Medal = 'Gold' THEN 'Gold' END) AS Gold,
    COUNT(CASE WHEN Medal = 'Silver' THEN 'Silver' END) AS Silver,
    COUNT(CASE WHEN Medal = 'Bronze' THEN 'Bronze' END) AS Bronze   
FROM t1
GROUP BY Games, region
ORDER BY Games;

-- 16- Identify which country won the most gold, most silver and most bronze medals in each olympic games.
WITH t1 AS(
	SELECT a.NOC, a.Games, r.region, a.Medal
	FROM olympics.athlete_events AS a
	JOIN olympics.regions AS r
		ON a.NOC = r.NOC
        ),
	t2 AS(
	SELECT region, Games,
		SUM(CASE WHEN Medal in ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS medal,
		SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
		SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
		SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
        
	FROM t1
	GROUP BY region, Games
    )
SELECT DISTINCT(Games),
concat(FIRST_VALUE(region) OVER(PARTITION BY Games ORDER BY gold DESC),
	'-', FIRST_VALUE(gold) OVER(PARTITION BY Games ORDER BY gold DESC)) AS Max_Gold,
concat(FIRST_VALUE(region) OVER(PARTITION BY Games ORDER BY silver DESC),
	'-', FIRST_VALUE(silver) OVER(PARTITION BY Games ORDER BY silver DESC)) AS Max_bronze,
concat(FIRST_VALUE(region) OVER(PARTITION BY Games ORDER BY bronze DESC),
	'-', FIRST_VALUE(bronze) OVER(PARTITION BY Games ORDER BY bronze DESC)) AS Max_bronze
FROM t2;

-- 17- Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
WITH t1 AS(
	SELECT a.NOC, a.Games, r.region, a.Medal
	FROM olympics.athlete_events AS a
	JOIN olympics.regions AS r
		ON a.NOC = r.NOC
        ),
	t2 AS(
	SELECT region, Games,
		SUM(CASE WHEN Medal in ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS medal,
		SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
		SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
		SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
        
	FROM t1
	GROUP BY region, Games
    )
SELECT DISTINCT(Games),
concat(FIRST_VALUE(region) OVER(PARTITION BY Games ORDER BY gold DESC),
	'-', FIRST_VALUE(gold) OVER(PARTITION BY Games ORDER BY gold DESC)) AS Max_Gold,
concat(FIRST_VALUE(region) OVER(PARTITION BY Games ORDER BY silver DESC),
	'-', FIRST_VALUE(silver) OVER(PARTITION BY Games ORDER BY silver DESC)) AS Max_bronze,
concat(FIRST_VALUE(region) OVER(PARTITION BY Games ORDER BY bronze DESC),
	'-', FIRST_VALUE(bronze) OVER(PARTITION BY Games ORDER BY bronze DESC)) AS Max_bronze,
concat(FIRST_VALUE(region) OVER(PARTITION BY Games ORDER BY medal DESC),
	'-', FIRST_VALUE(medal) OVER(PARTITION BY Games ORDER BY medal DESC)) AS Max_medals
FROM t2;

-- 18- Which countries have never won gold medal but have won silver/bronze medals?
WITH t1 AS(
	SELECT r.region, a.Medal
	FROM olympics.athlete_events AS a
	JOIN olympics.regions AS r
		ON a.NOC = r.NOC
	),
t2 AS(
	SELECT region,
		SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
		SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
		SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
	FROM t1
	GROUP BY region
	-- ORDER BY 1
	)
SELECT *
FROM t2
WHERE gold = 0
ORDER BY 1;

-- 19- n which Sport/event, India has won highest medals.
WITH t1 AS(
	SELECT a.NOC, r.region, a.Sport, COUNT(a.Medal) as total_medal
	FROM olympics.athlete_events AS a
	JOIN olympics.regions AS r
		ON a.NOC = r.NOC
	WHERE Medal <> 'NA' and region = "India"
	GROUP BY 3,2,1
    ),
t2 AS(
	SELECT Sport, total_medal,
		RANK() OVER(ORDER BY total_medal DESC) rnk
	FROM t1
    )
SELECT Sport, total_medal
FROM t2
WHERE rnk = 1;

-- 20- Break down all olympic games where India won medal for Hockey and how many medals in each olympic games
SELECT Games, Sport, region, COUNT(Medal)
FROM olympics.athlete_events AS a
JOIN olympics.regions AS r
	ON a.NOC = r.NOC
WHERE region = "India" AND Medal <> "NA" AND Sport = "Hockey"
GROUP BY 1, 2, 3
ORDER BY 4 DESC;

