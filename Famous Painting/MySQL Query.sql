-- Museums which are open on both Sunday and Monday
select m.name as museum_name, m.city, m.museum_id
from museum_hours as mh1
join museum as m on m.museum_id = mh1.museum_id
where mh1.day = 'Sunday'
and exists(select 1 from museum_hours as mh2
		where mh1.museum_id = mh2.museum_id
        and mh2.day = 'Monday');
        -- checks whether the same museum_id in the outer query has a record for Monday

-- Museum that is open for the longest during a day
SELECT * FROM (
	SELECT m.name AS museum_name, m.state, mh.day,
    STR_TO_DATE(open, '%h:%i:%p') AS open_time,
    STR_TO_DATE(close, '%h:%i:%p') AS close_time,
    TIMEDIFF(STR_TO_DATE(close, '%h:%i:%p'),STR_TO_DATE(open, '%h:%i:%p')) AS duration,
    RANK() OVER(ORDER BY TIMEDIFF(STR_TO_DATE(close, '%h:%i:%p'),STR_TO_DATE(open, '%h:%i:%p')) DESC) AS ranks
    -- basically gave the same results as using order by directly
	FROM museum_hours AS mh
	JOIN museum AS m ON mh.museum_id = m.museum_id
    ) AS subquery
WHERE subquery.ranks=1;

-- City and country with the most number of museums
with cte_country as
	(select country, count(1), rank() over(order by count(1) desc) as ranks
    from museum
    group by country),
    cte_city as
    (select city, count(1), rank() over(order by count(1) desc) as ranks
    from museum
    group by city)
select group_concat(country) as country, group_concat(city) as city
from cte_country
cross join cte_city -- use cross join cause we don't have any common column
where cte_country.ranks = 1 and cte_city.ranks = 1

-- paintings which are not displayed on any museums
select work_id
from work
where museum_id IS NULL;

-- museums without any paintings (cara 1)
SELECT m.museum_id, m.name, m.city, m.country
FROM museum AS m
LEFT JOIN work AS w ON m.museum_id = w.museum_id
WHERE w.work_id IS NULL;

-- cara 2
select * from museum m
	where not exists -- find records that don't have a corresponding match in another table
					(select 1 from work AS w
					where w.museum_id=m.museum_id);
                    
-- How many paintings have an asking price of more than their regular price
SELECT * FROM product_size
WHERE sale_price > regular_price;

-- paintings which have asking price less than 50% of its regular price
SELECT * FROM product_size
WHERE sale_price < (0.5*regular_price);

-- which canva size costs the most (cara 1)
SELECT cs.size_id, cs.label, ps.sale_price
FROM canvas_size AS cs
LEFT JOIN product_size AS ps ON cs.size_id = ps.size_id
ORDER BY ps.sale_price desc;

-- cara 2
SELECT cs.size_id, cs.label, ps.sale_price
FROM (SELECT *,
		RANK() OVER(ORDER BY sale_price desc) AS ranks
        FROM product_size) AS ps
JOIN canvas_size AS cs ON cs.size_id = ps.size_id
WHERE ps.ranks=1;

-- check duplicate records
SELECT name, artist_id, style, museum_id, COUNT(*) as duplicate_count
FROM work
GROUP BY 1,2,3,4
HAVING COUNT(*) > 1;

-- Delete duplicate records
SET SQL_SAFE_UPDATES = 0;
DELETE w1
FROM work AS w1
JOIN (
    SELECT work_id
    FROM work
    GROUP BY work_id
    HAVING COUNT(*) > 1
) AS w2 ON w1.work_id = w2.work_id;

-- museums with invalid city information in the given dataset
SELECT * FROM museum
WHERE city REGEXP '^[0-9]+$'; -- city contains only numbers

-- identify 1 invalid entry in museum_hours and remove it
DELETE FROM museum_hours
WHERE open NOT REGEXP '^[0-1]?[0-9]:[0-5][0-9]:(AM|PM)$' OR
	close NOT REGEXP '^[0-1]?[0-9]:[0-5][0-9]:(AM|PM)$';

-- check the other possible invalid entry
SELECT * FROM museum_hours
WHERE day NOT IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
   OR museum_id NOT IN (SELECT museum_id FROM museum);
   
-- turns out there is a typo "Thusday", let's update the table
UPDATE museum_hours
SET day = 'Thursday'
WHERE day = 'Thusday';

-- top 10 most famous painting subject
SELECT * FROM (
	SELECT s.subject, count(*) AS total_paintings,
    RANK() OVER(ORDER BY count(*) DESC) AS ranks
    FROM subject AS s
    JOIN work AS w ON s.work_id = w.work_id
    GROUP BY s.subject
    ) AS subquery
WHERE subquery.ranks <=10;

-- museums that are open every single day
SELECT count(*) FROM (
	SELECT m.museum_id, m.name, m.city, m.country
	FROM museum AS m
	JOIN museum_hours AS mh ON m.museum_id = mh.museum_id
	GROUP BY 1,2,3,4
	HAVING COUNT(DISTINCT mh.day) = 7
    ) AS subquery;

-- top 5 museums with the most no of paintings
SELECT * FROM (
	SELECT m.museum_id, m.name, m.country, count(*) AS total_paintings,
	RANK() OVER(ORDER BY count(*) DESC) AS ranks
	FROM museum AS m
	JOIN work AS w ON m.museum_id = w.museum_id
    GROUP BY  m.museum_id, m.name, m.country
	) AS subquery
	WHERE subquery.ranks <=5;

-- top 5 artists with the most no of paintings
SELECT * FROM (
	SELECT a.artist_id, a.full_name, count(*) AS total_paintings,
	RANK() OVER(ORDER BY count(*) DESC) AS ranks
	FROM artist AS a
	JOIN work AS w ON a.artist_id = w.artist_id
    GROUP BY  a.artist_id, a.full_name
	) AS subquery
	WHERE subquery.ranks <=5;
    
-- 3 least popular canva sizes
SELECT label, ranks, total_paintings FROM (
	SELECT cs.size_id, cs.label, count(*) AS total_paintings,
	DENSE_RANK() OVER(ORDER BY count(*) ASC) AS ranks
	FROM work AS w
    JOIN canvas_size AS cs ON cs.work_id=w.work_id
    JOIN product_size AS ps ON cs.size_id = ps.size_id
    GROUP BY  cs.size_id, cs.label
	) AS subquery
	WHERE subquery.ranks <=3;

-- museum with the most no of most popular painting style
WITH popular_style AS
	(SELECT style, RANK() OVER(ORDER BY count(*) DESC) AS ranks
    FROM work
    GROUP BY style),
    cte AS
    (SELECT w.museum_id, m.name AS museum_name, ps.style AS painting_style, count(*) AS total_paintings,
    RANK() OVER(ORDER BY count(*) DESC) AS ranks
    FROM work AS w
    JOIN museum AS m ON w.museum_id = m.museum_id
    JOIN popular_style AS ps ON w.style = ps.style
    WHERE w.museum_id IS NOT NULL AND ps.ranks = 1
    GROUP BY 1,2,3)
SELECT museum_name, painting_style, total_paintings
FROM cte
WHERE ranks=1;

-- artist whose paintings are displayed in multiple countries
WITH cte AS(
	SELECT DISTINCT a.full_name AS artist_name, a.artist_id, m.country
	FROM work AS w
	JOIN artist AS a ON w.artist_id = a.artist_id
	JOIN museum AS m ON  w.museum_id = m.museum_id)
SELECT artist_name, count(*) as total_countries
FROM cte
GROUP BY 1
HAVING count(*)>1
ORDER BY 2 DESC;

-- artist & museum where the most expensive and least expensive painting is placed
WITH cte AS (SELECT *,
			RANK() OVER(ORDER BY sale_price DESC) AS rank_desc,
            RANK() OVER(ORDER BY sale_price ASC) AS rank_asc
			FROM product_size AS ps)
SELECT 	a.full_name AS 'Artist Name',
		w.name AS 'Painting Name',
        cs.label AS 'Canvas Label',
        cte.sale_price AS 'Painting Price',
        m.name AS 'Museum Name',
        m.city AS 'Museum City'        
FROM cte
JOIN canvas_size AS cs ON cte.size_id = cs.size_id
JOIN work AS w ON cte.work_id = w.work_id
JOIN museum AS m ON m.museum_id = w.museum_id
JOIN artist AS a ON a.artist_id = w.artist_id
WHERE rank_desc = 1 OR rank_asc = 1;

-- country with the 5th highest no of paintings (cara 1)
SELECT * FROM(
		SELECT 	m.country, count(w.work_id) as total_painting,
		RANK() OVER(ORDER BY count(w.work_id) DESC) AS ranks
		FROM museum AS m
		JOIN work AS w ON m.museum_id = w.museum_id
        GROUP BY 1) AS subquery
WHERE ranks=5;

-- cara 2
with cte as 
		(select m.country, count(1) as no_of_paintings
		, rank() over(order by count(1) desc) as rnk
		from work w
		join museum m on m.museum_id=w.museum_id
		group by m.country)
select country, no_of_paintings
from cte 
where rnk=5;

-- 3 most popular and 3 least popular painting styles
WITH cte AS(
        SELECT 	style, count(*) AS 'total paintings',
		RANK() OVER(ORDER BY count(*) DESC) AS rank_desc,
        RANK() OVER(ORDER BY count(*) ASC) AS rank_asc
		FROM work
        WHERE style IS NOT NULL
		GROUP BY style)
SELECT 	style, total_paintings,
		case when rank_desc <=3 then 'Most Popular' else 'Least Popular' end AS remark
FROM cte
WHERE rank_desc<=3 OR rank_asc<=3;

-- cara 2
with cte as 
		(select style, count(1) as cnt
		, rank() over(order by count(1) desc) rnk
		, count(1) over() as no_of_records
		from work
		where style is not null
		group by style)
	select style, case when rnk <=3 then 'Most Popular' else 'Least Popular' end as remarks 
	from cte
	where rnk <=3
	or rnk > no_of_records - 3;

-- artist with the most no of portraits paintings outside USA
WITH cte AS(
		SELECT a.full_name AS artist, a.nationality, count(*) AS total_paintings,
        RANK() OVER(ORDER BY count(*) DESC) AS ranks
        FROM work AS w
        JOIN artist AS a ON w.artist_id = a.artist_id
        JOIN museum AS m ON w.museum_id = m.museum_id
        JOIN subject AS s ON w.work_id = s.work_id
        WHERE s.subject = 'Portraits'
        AND m.country != 'USA'
        GROUP BY 1,2)
SELECT artist, nationality, total_paintings
FROM cte
WHERE ranks=1;
