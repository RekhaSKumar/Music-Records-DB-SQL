--goal: to return the email, first name, last name, & Genre of all Rock Music listeners--
--Returning alphabetically by first name of customer--


SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Jazz'
)
ORDER BY first_name;

--Goal: to invite artists who have written the most rock music in the dataset--
--a query that returns the Artist name and total track count of the top 20 rock bands--

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS no_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY no_of_songs DESC
LIMIT 20;

--top 5 customers with max invoice--

SELECT c.customer_id, c.country, c.first_name, c.last_name, i.total
FROM invoice i
	join customer c on i.customer_id = c.customer_id
    ORDER BY i.total DESC, c.country asc
	limit 5
	
-- returning the senior most employee based on job title

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1

--countries have the most Invoices?--

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC


--city with best customers. ( best customer = spent most; best city = made the most money) 
--returning top city that has the highest sum of invoice totals--

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;


-- Write a query that returns the person who has spent the most money.(best customer = spent more money)--

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;


--Returning all the track names and milliseconds that have a song length longer than the average song length. Ordering by the song length with the longest songs listed first--
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    a.name AS artist_name, 
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM 
    invoice i
    JOIN customer c ON c.customer_id = i.customer_id
    JOIN invoice_line il ON il.invoice_id = i.invoice_id
    JOIN track t ON t.track_id = il.track_id
    JOIN album alb ON alb.album_id = t.album_id
    JOIN artist a ON a.artist_id = alb.artist_id
GROUP BY 
    1, 
    2, 
    3, 
    4
ORDER BY 
    5 DESC;

--Finding most popular music genre for each country. writing query to return each country along with top genre--

with genre_popular as (
	select count(il.quantity) as no_of_purchases, c.country, g.name, row_number() over (partition by c.country order by
	count(il.quantity) desc) as Row_numb
from invoice i
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
	join customer c on i.customer_id = c.customer_id
  
group by c.country, g.name, il.quantity
order by c.country asc, no_of_purchases desc)

select *
	from genre_popular
where row_numb <= 1

--querying to determine customers who have spent most on music in each country in desceding order--

WITH RECURSIVE 
    customer_with_country AS (
        SELECT 
            customer.customer_id,
            first_name,
            last_name,
            billing_country,
            SUM(total) AS total_spending
        FROM 
            invoice
        JOIN 
            customer ON customer.customer_id = invoice.customer_id
        GROUP BY 
            customer.customer_id, first_name, last_name, billing_country
    ),
    country_max_spending AS (
        SELECT 
            billing_country,
            MAX(total_spending) AS max_spending
        FROM 
            customer_with_country
        GROUP BY 
            billing_country
    )

SELECT 
    cc.billing_country,
    cc.total_spending,
    cc.first_name,
    cc.last_name,
    cc.customer_id
FROM 
    customer_with_country cc
JOIN 
    country_max_spending ms
ON 
    cc.billing_country = ms.billing_country
AND 
    cc.total_spending = ms.max_spending
ORDER BY 
    cc.billing_country;


