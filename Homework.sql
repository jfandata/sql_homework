use sakila;

# 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

# 1b. Display the first and last name of each actor in a single column in upper case letters. 
# Name the column Actor Name.
select concat(first_name,' ', last_name) as 'Actor Name' from actor;

# 2a. You need to find the ID number, first name, and last name of an actor, 
# of whom you know only the first name, "Joe." What is one query would you use 
# to obtain this information?
select actor_id, first_name, last_name
from actor
where first_name = "Joe";

# 2b. Find all actors whose last name contain the letters GEN:
select actor_id, first_name, last_name
from actor
where last_name like "%GEN%";

# 2c. Find all actors whose last names contain the letters LI. 
# This time, order the rows by last name and first name, in that order:
select last_name, first_name
from actor
where last_name like "%LI%";

# 2d. Using IN, display the country_id and country columns of the following countries: 
# Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

# 3a. You want to keep a description of each actor. 
# You don't think you will be performing queries on a description, 
# so create a column in the table actor named description and use the data type BLOB 
# (Make sure to research the type BLOB, as the difference between it and VARCHAR are 
# significant).
ALTER TABLE actor
ADD COLUMN description blob AFTER last_update;

# 3b. Very quickly you realize that entering descriptions for each actor is too much effort.
# Delete the description column.
ALTER TABLE actor
DROP description;

# 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) 
from actor
group by last_name;

# 4b. List last names of actors and the number of actors who have that last name, 
# but only for names that are shared by at least two actors
select last_name, count(last_name) as cnt
from actor
group by last_name
having cnt >2;

# 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as 
# GROUCHO WILLIAMS. Write a query to fix the record.

select actor_id, first_name, last_name
from actor
where first_name = "groucho" and last_name ="williams";

update actor
set 
	first_name = "HARPO"
WHERE
	actor_id = 172;

select actor_id, first_name, last_name
from actor
where last_name ="williams";

# 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
# It turns out that GROUCHO was the correct name after all! 
# In a single query, if the first name of the actor is currently HARPO, 
# change it to GROUCHO.
update actor
set 
	first_name = "GROUCHO"
WHERE
	actor_id = 172;

select actor_id, first_name, last_name
from actor
where last_name ="williams";

# 5a. You cannot locate the schema of the address table. Which query would you use to 
# re-create it?
# Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;

# 6a. Use JOIN to display the first and last names, as well as the address, 
# of each staff member. Use the tables staff and address:
SELECT s.address_id, s.first_name, s.last_name, a.address, a.district, a.city_id        
FROM  staff s          
LEFT JOIN address a ON s.address_id=a.address_id;
  
# 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
# Use tables staff and payment.
SELECT s.staff_id, s.first_name, s.last_name, sum(p.amount) as total      
FROM staff s          
LEFT JOIN payment p ON s.staff_id=p.staff_id
WHERE p.payment_date like "2005-08%"
GROUP BY s.staff_id;

# 6c. List each film and the number of actors who are listed for that film. 
# Use tables film_actor and film. Use inner join.
SELECT f.title, fa.film_id, count(fa.actor_id) as number_of_actor     
FROM film_actor fa         
INNER JOIN film f ON fa.film_id=f.film_id
GROUP BY f.title;

# 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select title, film_id from film
where title like "Hunchback%";

select f.title, f.film_id, count(i.film_id) as copies
from inventory i
left join film f on i.film_id = f.film_id
where i.film_id = 439;

# 6e. Using the tables payment and customer and the JOIN command, 
# list the total paid by each customer. List the customers alphabetically by last name:
select c.first_name, c.last_name, c.customer_id, sum(p.amount) as total_paid
from customer c
join payment p on c.customer_id=p.customer_id
group by c.customer_id
order by c.last_name;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
# As an unintended consequence, films starting with the letters K and Q have also 
# soared in popularity. Use subqueries to display the titles of movies starting with 
# the letters K and Q whose language is English.
SELECT *
FROM film
WHERE (title like "k%") or (title like "q%") and language_id IN
(
	SELECT language_id
	FROM language
	WHERE name = "English"
);

# 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT *
FROM actor
WHERE actor_id IN
	(
		SELECT actor_id
		FROM film_actor
		WHERE film_id IN
		(
			SELECT film_id
			FROM film
			WHERE title = "Alone Trip"
			));


# 7c. You want to run an email marketing campaign in Canada, for which you will need 
# the names and email addresses of all Canadian customers. Use joins to retrieve this 
# information.
select c.first_name, c.last_name, c.email
from customer c
left join address a
on (c.address_id=a.address_id)
left join city cy
on (cy.city_id=a.city_id)
left join country co
on (co.country_id=cy.country_id)
where co.country="Canada";

# 7d. Sales have been lagging among young families, and you wish to target all family 
# movies for a promotion. Identify all movies categorized as family films.
select f.film_id, f.title
from film f
left join film_category fc
on (f.film_id=fc.film_id)
left join category c
on (fc.category_id=c.category_id)
where c.name="Family";

# 7e. Display the most frequently rented movies in descending order.
select f.film_id, f.title, count(r.inventory_id) as total_rentals 
from film f
left join inventory i
on (f.film_id=i.film_id)
left join rental r
on (i.inventory_id=r.inventory_id)
group by f.film_id
order by total_rentals desc;

# 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(p.amount) as total_dollars
from store s
left join payment p
on (s.manager_staff_id=p.staff_id)
group by s.store_id;

# 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, c.city, co.country
from store s
left join address a
on (s.address_id=a.address_id)
left join city c
on (a.city_id=c.city_id)
left join country co
on (c.country_id=co.country_id);

# 7h. List the top five genres in gross revenue in descending order. 
# (Hint: you may need to use the following tables: category, film_category, 
# inventory, payment, and rental.)
select c.category_id, c.name, sum(p.amount) as Gross
from category c
left join film_category fc
on (c.category_id=fc.category_id)
left join inventory i
on (fc.film_id=i.film_id)
left join rental r
on (i.inventory_id=r.inventory_id)
left join payment p
on (r.rental_id=p.rental_id)
group by c.name
order by Gross desc limit 5;

# 8a. In your new role as an executive, you would like to have an easy way of viewing the 
# Top five genres by gross revenue. Use the solution from the problem above to create a 
# view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_5_genres as
select c.category_id, c.name, sum(p.amount) as Gross
from category c
left join film_category fc
on (c.category_id=fc.category_id)
left join inventory i
on (fc.film_id=i.film_id)
left join rental r
on (i.inventory_id=r.inventory_id)
left join payment p
on (r.rental_id=p.rental_id)
group by c.name
order by Gross desc limit 5;

# 8b. How would you display the view that you created in 8a?
select * from top_5_genres;

# 8c. You find that you no longer need the view top_five_genres. 
# Write a query to delete it.
drop view if exists top_5_genres;