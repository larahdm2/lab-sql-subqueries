USE sakila;

-- Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT COUNT(inventory_id) AS 'Number of copies'
FROM sakila.inventory
WHERE film_id = (
	SELECT film_id
	FROM sakila.film
	WHERE title = 'Hunchback Impossible'
	)
;

-- List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT * FROM sakila.film
WHERE length > (SELECT AVG(length) FROM sakila.film);

-- Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT actor_id, first_name FROM sakila.actor
WHERE actor_id IN (
	SELECT actor_id FROM sakila.film_actor
    WHERE film_id = (
		SELECT film_id FROM sakila.film 
		WHERE title = "Alone Trip"
	)
);

-- Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT film_id, title FROM sakila.film
WHERE film_id IN
	(SELECT film_id FROM sakila.film_category
	WHERE category_id =
		(SELECT category_id FROM sakila.category
		WHERE name = 'family'));


-- Retrieve the name and email of customers from Canada using both subqueries and joins. 

-- Subqueries
SELECT customer_id, first_name, email FROM sakila.customer
WHERE address_id IN (
	SELECT address_id FROM sakila.address
    WHERE city_id IN (
		SELECT city_id FROM sakila.city
        WHERE country_id = (
			SELECT country_id FROM sakila.country
            WHERE country = 'Canada'
		)
	)
);

-- Joins
SELECT customer_id, first_name, email 
FROM sakila.customer c
JOIN sakila.address a
USING(address_id)
JOIN sakila.city ci
USING(city_id)
JOIN sakila.country co
USING(country_id)
WHERE co.country = 'Canada';

-- Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. 
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
SELECT film_id, title FROM sakila.film
WHERE film_id IN (
	SELECT film_id FROM sakila.film_actor
	WHERE actor_id = (
		SELECT actor_id FROM sakila.film_actor
		GROUP BY actor_id
		ORDER BY COUNT(film_id) DESC
		LIMIT 1
	)
);

-- Find the films rented by the most profitable customer in the Sakila database. 
-- You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

SELECT film_id FROM sakila.inventory
WHERE inventory_id IN (
	SELECT inventory_id FROM sakila.rental
	WHERE customer_id = (
		SELECT customer_id FROM sakila.payment
		GROUP BY customer_id
		ORDER BY SUM(amount) DESC
		LIMIT 1
	)
)
;

-- Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
SELECT sub1.customer_id AS client_id, sub1.total_amount AS total_amount
FROM (
    SELECT customer_id, SUM(amount) AS total_amount 
    FROM sakila.payment
    GROUP BY customer_id
) sub1
JOIN (
    SELECT AVG(total_amount) AS avg_total_amount
    FROM (
        SELECT customer_id, SUM(amount) AS total_amount 
        FROM sakila.payment
        GROUP BY customer_id
    ) sub2
) avg_sub ON sub1.total_amount > avg_sub.avg_total_amount;


