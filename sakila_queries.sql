
SET SQL_SAFE_UPDATES = 0;

# 1a. Display first and last names of all actors from TABLE actor
SELECT first_name, last_name FROM actor;

#1b. Display the firs and last name of each actor in a single column named Actor Name
ALTER table actor
ADD COLUMN actor_name VARCHAR(50) AFTER last_name;

UPDATE actor SET actor_name = CONCAT(first_name, ' ',last_name);

#2a. Find id, first name, last name for actor names joe
SELECT actor_id, first_name, last_name FROM actor
WHERE  first_name='Joe';

#2b. Find actors whose last name contain letters GEN
SELECT actor_id, first_name, last_name FROM actor
WHERE last_name LIKE '%GEN%';

#2c. Find actors whose last names contain letters LI
SELECT last_name, first_name FROM actor
WHERE last_name LIKE '%LI%';

#2d. Display country_id and country columns of Afghanistan, Bangladesh, China using IN
SELECT country_id, country FROM country
WHERE country IN ('Afghanistan','Bangladesh','China');

#3a.  Add a middle_name column to the table actor between first_name and last_name
SELECT * FROM actor;
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(50) AFTER first_name;

#3b. You realize some actors have long names. Change data type of
#middle name to blobs
ALTER TABLE actor
CHANGE COLUMN middle_name middle_name BLOB;

#3c. Delete middle_name column
ALTER TABLE actor
DROP COLUMN middle_name;

#4a. List the last names of actors, as well as how many actors have that last name
SELECT last_name, 
COUNT(last_name) as CNT
FROM actor 
GROUP BY last_name;

#4b.  List last names of actors and the number of actors who have that last name, 
# but only for names that are shared by at least two actors
SELECT last_name, 
COUNT(last_name) as CNT
FROM actor
GROUP BY last_name
HAVING COUNT(*) >=2;

#4c. Change name of Groucho WIlliams to Harpo Williams
UPDATE actor
SET first_name = 'HARPO', actor_name= 'HARPO WILLIAMS'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
SELECT * FROM actor
WHERE last_name = 'WILLIAMS';

#4d. In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
# Otherwise, change the first name to MUCHO GROUCHO

UPDATE actor SET first_name = CASE 
WHEN first_name = 'GROUCHO' AND last_name = 'WILLIAMS' THEN 'MUCHO GROUCHO' 
WHEN first_name = 'HARPO' AND last_name = 'WILLIAMS' THEN 'GROUCHO'
ELSE first_name
END
WHERE last_name = 'WILLIAMS';

# 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

#or create from scratch

CREATE TABLE address (
  address_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  address VARCHAR(50) NOT NULL,
  address2 VARCHAR(50) DEFAULT NULL,
  district VARCHAR(20) NOT NULL,
  city_id SMALLINT UNSIGNED NOT NULL,
  postal_code VARCHAR(10) DEFAULT NULL,
  phONe VARCHAR(20) NOT NULL,
  /*!50705 locatiON GEOMETRY NOT NULL,*/
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (address_id),
  KEY idx_fk_city_id (city_id),
  /*!50705 SPATIAL KEY `idx_locatiON` (locatiON),*/
  CONSTRAINT `fk_address_city` FOREIGN KEY (city_id) REFERENCES city (city_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
# Use the tables staff and address:
SELECT first_name, last_name, address FROM staff
JOIN(address) ON staff.address_id=address.address_id;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
#Use tables staff and payment.
SELECT username, Sum(amount) FROM staff
JOIN(payment) ON staff.staff_id=payment.staff_id 	
WHERE payment_date BETWEEN '2005-08-01 00:00:00' and '2005-09-01 00:00:00' 
GROUP BY username;


# 6c. List each film and the number of actors who are listed for that film. 
#Use tables `film_actor` and `film`. Use inner JOIN.
SELECT title, COUNT(*) AS Number_of_Actors FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY title;

# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT title, COUNT(inventory_id) FROM inventory JOIN(film) ON inventory.film_id=film.film_id
WHERE title = 'Hunchback Impossible'
GROUP BY title;

#6e. Using the tables payment and customer and the JOIN command, 
# list the total paid by each customer. List the customers alphabetically by last name:
SELECT last_name, first_name, SUM(amount)
FROM payment p
INNER JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY last_name ASC;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
# As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 
SELECT title, name FROM film 
JOIN(language) ON film.language_id=language.language_id
WHERE name = 'English' AND title LIKE 'k%' or title LIKE 'q%';

# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT title, first_name, last_name FROM actor 
JOIN(film_actor) ON actor.actor_id = film_actor.actor_id
JOIN(film) ON film_actor.film_id=film.film_id
WHERE title ='ALONE TRIP';

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names 
# and email addresses of all Canadian customers. Use JOINs to retrieve this information.
SELECT first_name, last_name, email FROM customer 
JOIN(address) ON customer.address_id=address.address_id
JOIN(city) ON address.city_id=city.city_id
JOIN(country) ON city.country_id=country.country_id
WHERE country='Canada';

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
# Identify all movies categorized as famiy films.
SELECT title, name AS Genre FROM film_category
JOIN(category) ON category.category_id=film_category.category_id
JOIN(film) ON film.film_id=film_category.film_id
WHERE name='family';

# 7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(*) FROM payment
JOIN rental ON payment.rental_id=rental.rental_id
JOIN inventory ON rental.inventory_id=inventory.inventory_id
JOIN film ON inventory.film_id=film.film_id
GROUP BY title
ORDER BY COUNT(*) DESC;
		
# 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, concat('$',format(SUM(amount),2)) AS USD FROM staff 
JOIN payment ON staff.staff_id=payment.staff_id
GROUP BY store_id;

# 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country FROM staff
JOIN address ON staff.address_id=address.address_id
JOIN city ON address.city_id=city.city_id
JOIN country ON city.country_id=country.country_id;
    
# 7h. List the top five genres in gross revenue in descending order.
SELECT name AS Genre, concat('$',format(SUM(amount),2)) AS Gross_Revenue FROM category
JOIN film_category ON category.category_id=film_category.category_id
JOIN inventory ON film_category.film_id=inventory.film_id
JOIN rental ON inventory.inventory_id=rental.inventory_id
JOIN payment ON rental.rental_id=payment.rental_id
GROUP BY Genre
ORDER BY SUM(amount) DESC;

# 8a. In your new role as an executive, you would like to have an easy way of
# viewing the Top five genres by gross revenue.
Create View TOP_5_GENRES AS(
SELECT name AS Genre, concat('$',format(SUM(amount),2)) AS Gross_Revenue FROM category
	JOIN film_category ON category.category_id=film_category.category_id
	JOIN inventory ON film_category.film_id=inventory.film_id
	JOIN rental ON inventory.inventory_id=rental.inventory_id
	JOIN payment ON rental.rental_id=payment.rental_id
	GROUP BY Genre
	ORDER BY SUM(amount) DESC
    LIMIT 5
    );




# 8b. How would you display the view that you created in 8a?
SELECT * FROM TOP_5_GENRES;


# 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW TOP_5_GENRES;


