USE sakila; 

-- Display first and last name of all actors 
SELECT first_name, last_name FROM actor; 
-- Display first and last name of each actor in a single column in upper case
SELECT concat(first_name, " ", last_name) FROM actor; 
-- Name the column Actor Name
SELECT concat(first_name, " ", last_name) AS "Actor Name" FROM actor; 
-- You need to find ID number, first name and last name of an actor, for whom you know only the first name, "Joe." Which is the one query you would use to obtain this information?
SELECT * FROM actor WHERE first_name= "Joe"; 
-- Find all actors whose last name contain the letters GEN:
SELECT * FROM actor WHERE last_name LIKE "%GEN%"; 
-- # Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name FROM actor WHERE actor.last_name LIKE "%LI%"
ORDER BY last_name; 
-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country.country IN ("Afghanistan", "Bangladesh", "China"); 
-- You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB:
ALTER TABLE actor
ADD COLUMN `description` BLOB NOT NULL; 
-- Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN `description`; 
-- List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) FROM actor
GROUP BY last_name; 
-- List last names of actors and the number of actors who have that last name, but only for names that are shared by atleast two actors 
SELECT last_name, COUNT(*) FROM actor
GROUP BY last_name HAVING COUNT(*) >= 2;
-- The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO" WHERE actor.first_name = "GROUCHO" AND actor.last_name = "WILLIAMS"; 
-- Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO" WHERE actor.first_name = "HARPO" AND actor.last_name = "WILLIAMS"; 
-- You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address; 
-- Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address, address.address2, address.district
FROM staff LEFT JOIN address ON staff.address_id = address.address_id; 
-- Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, SUM(payment.amount) as Total_Amount FROM payment
LEFT JOIN staff ON staff.staff_id = payment.staff_id
WHERE payment.payment_date LIKE "%2005-08%"
GROUP BY staff.last_name, staff.first_name; 
-- List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id) as number_of_actors_in_movie
FROM film_actor INNER JOIN film ON film_actor.film_id = film.film_id
GROUP BY film.title; 
-- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT * FROM film WHERE title= "Hunchback Impossible";
select * from inventory
where film_id = 439; 
SELECT COUNT(inventory.film_id) FROM inventory WHERE inventory.film_id = 439;  
-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, SUM(payment.amount) as Customer_Total_Payment
FROM payment LEFT JOIN customer ON customer.customer_id = payment.customer_id
GROUP BY customer.first_name, customer.last_name
ORDER BY customer.last_name ASC;
-- The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT film.title FROM film
WHERE film.language_id = (SELECT language_id
FROM language
WHERE language.name = "English")
AND film.title LIKE "K%"
OR film.title LIKE "Q%";
-- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor
WHERE actor_id IN
(
 SELECT actor_id 
 FROM film_actor
 WHERE film_id = 
 (
  SELECT film_id
  FROM film
  WHERE title = "ALONE TRIP"
 )
); 
-- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name, customer.email FROM customer
LEFT JOIN address ON address.address_id = customer.address_id
LEFT JOIN city ON address.city_id = city.city_id
LEFT JOIN country ON city.country_id = country.country_id
WHERE country.country = "Canada";
-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT film.title FROM film, film_category, category
WHERE film.film_id = film_category.film_id AND
category.category_id=film_category.category_id AND 
category.NAME ="Family";
-- Display the most frequently rented movies in descending order
SELECT title, COUNT(rental.inventory_id) as `Number_times_rented` FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY film.title
ORDER BY `Number_times_rented` DESC;
-- Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(payment.amount) AS `Dollars` FROM store
INNER JOIN staff ON store.store_id = staff.store_id
INNER JOIN payment ON payment.staff_id = staff.staff_id
GROUP BY store.store_id; 
-- Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country FROM store
INNER JOIN address ON store.address_id = address.address_id
INNER JOIN city ON address.city_id = city.city_id
INNER JOIN country ON city.country_id = country.country_id;
-- List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name AS Genre, SUM(payment.amount) AS Gross_Revenue FROM category
INNER JOIN film_category ON category.category_id = film_category.category_id
INNER JOIN inventory ON film_category.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY Gross_Revenue DESC LIMIT 5;
-- In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_5_Genres AS
SELECT SUM(payment.amount) AS dollars, category.name FROM payment
INNER JOIN rental ON payment.rental_id = rental.rental_id
INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id
INNER JOIN film_category ON inventory.film_id = film_category.film_id
INNER JOIN category ON film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY dollars DESC LIMIT 5;
-- How would you display the view that you created in 8a?
SELECT * FROM Top_5_Genres; 
-- You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top_5_Genres; 





