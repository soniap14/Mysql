USE sakila;

#Display the first and last names of all actors from the table actor.

SELECT first_name, last_name
FROM actor;

#Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.


SELECT concat(first_name," ", last_name) AS Actor_Name
FROM actor;

#You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

#Find all actors whose last name contain the letters GEN:

SELECT last_name
FROM actor
WHERE last_name LIKE '%GEN%';

#Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

# Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

# create a column in the table actor named description and use the data type BLOB

ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(25) AFTER first_name;

ALTER TABLE actor
MODIFY COLUMN middle_name BLOB;

# Delete the description column.

ALTER TABLE actor
DROP COLUMN middle_name;

#List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(last_name) as "Count of Last Name"
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >=2;

#List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, COUNT(last_name) as "Count of Last Name"
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >=2;

#The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

UPDATE actor
SET first_name = 'Harpo'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

#if the first name of the actor is currently HARPO, change it to GROUCHO.
 UPDATE actor
 SET first_name = 
 CASE 
 WHEN first_name = 'HARPO' 
 THEN 'GROUCHO'
 ELSE 'MUCHO GROUCHO'
 END
 WHERE actor_id = 172;

#You cannot locate the schema of the address table. Which query would you use to re-create it?

SHOW CREATE TABLE sakila.address;

#Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT first_name, last_name, address
FROM staff s
INNER JOIN address a
ON s.address_id = a.address_id;

#Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT payment.staff_id, staff.first_name, staff.last_name, payment.amount, payment.payment_date
FROM staff INNER JOIN payment ON
staff.staff_id = payment.staff_id AND payment_date LIKE '2005-08%';

#List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT f.title AS 'Film Title', COUNT(fa.actor_id) AS `Number of Actors`
FROM film_actor fa
INNER JOIN film f 
ON fa.film_id= f.film_id
GROUP BY f.title;

#How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT title, (
SELECT COUNT(*) FROM inventory
WHERE film.film_id = inventory.film_id
) AS 'Number of Copies'
FROM film
WHERE title = "Hunchback Impossible";

#Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT c.first_name, c.last_name, sum(p.amount) AS `Total Paid`
FROM customer c
JOIN payment p 
ON c.customer_id= p.customer_id
GROUP BY c.last_name;

#The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
#As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title FROM film
WHERE language_id in
	(SELECT language_id 
	FROM language
	WHERE name = "English" )
AND (title LIKE "K%") OR (title LIKE "Q%");

# Use subqueries to display all actors who appear in the film Alone Trip.

SELECT last_name, first_name
FROM actor
WHERE actor_id in
	(SELECT actor_id FROM film_actor
	WHERE film_id in 
		(SELECT film_id FROM film
		WHERE title = "Alone Trip"));

#You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
#Use joins to retrieve this information.

SELECT country, last_name, first_name, email
FROM country c
LEFT JOIN customer cu
ON c.country_id = cu.customer_id
WHERE country = 'Canada';

#Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as family films.

SELECT title, category
FROM film_list
WHERE category = 'Family';

#Display the most frequently rented movies in descending order.

SELECT i.film_id, f.title, COUNT(r.inventory_id)
FROM inventory i
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
INNER JOIN film_text f 
ON i.film_id = f.film_id
GROUP BY r.inventory_id
ORDER BY COUNT(r.inventory_id) DESC;

#Write a query to display how much business, in dollars, each store brought in.

SELECT store.store_id, SUM(amount)
FROM store
INNER JOIN staff
ON store.store_id = staff.store_id
INNER JOIN payment p 
ON p.staff_id = staff.staff_id
GROUP BY store.store_id
ORDER BY SUM(amount);

#Write a query to display for each store its store ID, city, and country.

SELECT s.store_id, city, country
FROM store s
INNER JOIN customer cu
ON s.store_id = cu.store_id
INNER JOIN staff st
ON s.store_id = st.store_id
INNER JOIN address a
ON cu.address_id = a.address_id
INNER JOIN city ci
ON a.city_id = ci.city_id
INNER JOIN country coun
ON ci.country_id = coun.country_id;
WHERE country = 'CANADA' AND country = 'AUSTRAILA';

#List the top five genres in gross revenue in descending order. 

SELECT name, SUM(p.amount)
FROM category c
INNER JOIN film_category fc
INNER JOIN inventory i
ON i.film_id = fc.film_id
INNER JOIN rental r
ON r.inventory_id = i.inventory_id
INNER JOIN payment p
GROUP BY name
LIMIT 5;

#In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
#Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_grossing_genres AS
SELECT name, SUM(p.amount)
FROM category c
INNER JOIN film_category fc
INNER JOIN inventory i
ON i.film_id = fc.film_id
INNER JOIN rental r
ON r.inventory_id = i.inventory_id
INNER JOIN payment p
GROUP BY name
LIMIT 5;

#How would you display the view that you created in 8a?

SELECT * FROM top_five_grossing_genres;

#You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_five_grossing_genres;

