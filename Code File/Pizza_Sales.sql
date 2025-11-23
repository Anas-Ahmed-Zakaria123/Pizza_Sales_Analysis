--1. Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS Total_Orders
FROM orders

--Output: 21350


--Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(OD.quantity * P.price) , 2) AS Total_Revenue
FROM order_details AS OD 
INNER JOIN pizzas AS P
ON P.pizza_id = OD.pizza_id

--Output: 817860.05


--2. Identify the highest-priced pizza.
SELECT TOP(1) PT.pizza_type_id AS Pizza_Name , ROUND(P.price , 2) AS Highest_Priced
FROM pizza_types AS PT 
INNER JOIN pizzas AS P
ON PT.pizza_type_id = P.pizza_type_id
ORDER BY P.price DESC

--Output: the_greek	 35.95


--3. Identify the most common pizza size ordered.
SELECT P.size AS Size , COUNT(OD.order_details_id) AS Total_Orders
FROM pizzas AS P
INNER JOIN order_details AS OD
ON P.pizza_id = OD.pizza_id
GROUP BY P.size

--Output: 
--L	 18526
--M	 15385
--S	 14137
--XL 544
--XXL 28


--4. List the top 5 most ordered pizza types along with their quantities.
SELECT TOP(5)
     PT.name AS Pizza_Name ,
     SUM(OD.quantity) AS Total_Quantity
FROM pizza_types AS PT
INNER JOIN pizzas AS P
ON PT.pizza_type_id = P.pizza_type_id
INNER JOIN order_details AS OD
ON P.pizza_id = OD.pizza_id
GROUP BY PT.name 
ORDER BY SUM(OD.quantity) DESC

--Output: 

--The Classic Deluxe Pizza	    2453
--The Barbecue Chicken Pizza	2432
--The Hawaiian Pizza	        2422
--The Pepperoni Pizza	        2418
--The Thai Chicken Pizza	    2371


--5. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
       PT.category AS "Pizza Category" , 
       SUM(OD.quantity) AS "Total Quantity"
FROM pizza_types AS PT
INNER JOIN pizzas AS P
ON PT.pizza_type_id = p.pizza_type_id
INNER JOIN order_details AS OD 
ON P.pizza_id = OD.pizza_id
GROUP BY PT.category
ORDER BY SUM(OD.quantity) DESC

--Output:

--Classic	14888
--Supreme	11987
--Veggie	11649
--Chicken	11050



--6. Determine the distribution of orders by hour of the day.
SELECT DATEPART(HOUR,time) AS "Order Hour" , COUNT(order_id) AS "Total Orders"
FROM orders
GROUP BY DATEPART(HOUR,time)
ORDER BY COUNT(order_id) DESC

--Output:

--12	2520
--13	2455
--18	2399
--17	2336
--19	2009
--16	1920
--20	1642
--14	1472
--15	1468
--11	1231
--21	1198
--22	663
--23	28
--10	8
--9	    1


--7. Find the category-wise distribution of pizzas.
SELECT category , COUNT(name) AS "Total Pizza Types"
FROM pizza_types
GROUP BY category
ORDER BY COUNT(name) DESC

--Output: 

--Supreme	9
--Veggie	9
--Classic	8
--Chicken	6


--8. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(Quantity),0) AS "Average Quantity Per Day"
FROM(
     SELECT 
           O.date ,
           SUM(OD.quantity) AS Quantity
FROM orders AS O
INNER JOIN order_details AS OD
ON O.order_id = OD.order_id
GROUP BY O.date) AS Order_Qty

--Output: 138


--9. Determine the top 3 most ordered pizza types based on revenue.
SELECT TOP(3)
      PT.pizza_type_id , 
      ROUND(SUM(OD.quantity * P.price),0) AS "Total Revenue"
FROM pizza_types AS PT
INNER JOIN pizzas AS P
ON PT.pizza_type_id = P.pizza_type_id
INNER JOIN order_details AS OD
ON P.pizza_id = OD.pizza_id
GROUP BY PT.pizza_type_id
ORDER BY ROUND(SUM(OD.quantity * P.price),0) DESC

--Output:

--thai_ckn	43434
--bbq_ckn	42768
--cali_ckn	41410


--10. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
       PT.pizza_type_id AS Pizza_Type , 
       ROUND(SUM(OD.quantity * P.price),0) AS Total_Revenue ,
       ROUND((SUM(OD.quantity * P.price) * 100) / SUM(SUM(OD.quantity * P.price)) OVER (), 2) AS Percentage_Contribution
FROM pizza_types AS PT
INNER JOIN pizzas AS P
ON PT.pizza_type_id = P.pizza_type_id
INNER JOIN order_details AS OD
ON P.pizza_id = OD.pizza_id
GROUP BY PT.pizza_type_id
ORDER BY ROUND(SUM(OD.quantity * P.price),0) DESC


--11. Analyze the cumulative revenue generated over time.
SELECT Order_Date ,
       Total_Revenue , 
       SUM(Total_Revenue) OVER(ORDER BY Order_Date) AS "Cumulative Revenue"
FROM (
      SELECT 
            O.date AS Order_Date ,
            ROUND(SUM(OD.quantity * P.price),0) AS Total_Revenue 
      FROM orders AS O
      INNER JOIN order_details AS OD
      ON O.order_id = OD.order_id
      INNER JOIN pizzas AS P
      ON P.pizza_id = OD.pizza_id
      GROUP BY O.date) AS Nested_Query


--12. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT *
FROM( 
     SELECT 
            PT.category , 
            PT.pizza_type_id , 
            SUM(OD.quantity * P.price) AS "Total Revenue" , 
            ROW_NUMBER() OVER(PARTITION BY (PT.category) ORDER BY (SUM(OD.quantity * P.price)) DESC) AS Ranking
     FROM pizza_types AS PT
     INNER JOIN pizzas AS P
     ON PT.pizza_type_id = P.pizza_type_id
     INNER JOIN order_details AS OD 
     ON P.pizza_id = OD.pizza_id
     GROUP BY PT.category , PT.pizza_type_id) AS Sub_Query
WHERE Ranking <=3

--Output:

--Chicken	thai_ckn	 43434.25	1
--Chicken	bbq_ckn	        42768	2
--Chicken	cali_ckn	  41409.5	3
--Classic	classic_dlx	  38180.5	1
--Classic	hawaiian	 32273.25	2
--Classic	pepperoni	 30161.75	3
--Supreme	spicy_ital	 34831.25	1
--Supreme	ital_supr	 33476.75	2
--Supreme	sicilian	 30940.5	3
--Veggie	four_cheese	 32265.3	1
--Veggie	mexicana	26780.75	2
--Veggie	five_cheese	 26066.5	3