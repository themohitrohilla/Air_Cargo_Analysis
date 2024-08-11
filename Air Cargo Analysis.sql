/* Task 1: Write a query to create route_details table using suitable data types for the fields, such as route_id, flight_num, origin_airport, 
destination_airport, aircraft_id, and distance_miles. Implement the check constraint for the flight number and unique constraint for the route_id fields. 
Also, make sure that the distance miles field is greater than 0.
*/

create table route_details (route_id int primary key, 
flight_num varchar(10) not null, origin_airport varchar(40) not null, destination_airport varchar(40) not null, 
aircraft_id int not null, distance_miles decimal(10, 2) check (distance_miles >0));
select * from route_details;

/* Task 3: Write a query to display all the passengers (customers) who have travelled in routes 01 to 25. 
Take data  from the passengers_on_flights table.
*/
select * from passengers_on_flights;
select * from passengers_on_flights where route_id between 1 and 25;

/* Task 4: Write a query to identify the number of passengers and total revenue in business class from the ticket_details table.
*/

select * from ticket_details;
select sum(price_per_ticket) as total_price, count(customer_id) as business_customber from ticket_details where class_id="Bussiness";

/* Task 5: Write a query to display the full name of the customer by extracting the first name and last name from the customer table.
*/
select * from customer;
select concat(first_name, " ", last_name) as full_name from customer;

/* Task 6: Write a query to extract the customers who have registered and booked a ticket. 
Use data from the customer and ticket_details tables.
*/
select * from ticket_details;
select * from customer where customer_id in (select customer_id from ticket_details);

# same problem can be solved by using join function
select * from customer join ticket_details on customer.customer_id = ticket_details.customer_id;

/* Task 7: Write a query to identify the customer’s first name and last name based on their customer ID and brand (Emirates) from the ticket_details table.
*/
select * from customer;
select customer_id, first_name, last_name from customer where customer_id in (select customer_id from ticket_details where brand="emirates");

#same query using join function
select distinct customer.customer_id, customer.first_name, customer.last_name
from customer join ticket_details on customer.customer_id = ticket_details.customer_id
where ticket_details.brand = 'emirates';

/* Task 8: Write a query to identify the customers who have travelled by Economy Plus class using Group By and Having clause on the passengers_on_flights table.
*/
select * from customer;
select * from ticket_details;
select * from passengers_on_flights;
select customer_id from passengers_on_flights where class_id = "economy plus"
group by customer_id having count(distinct class_id) = 1;

/* Task 9: Write a query to identify whether the revenue has crossed 10000 using the IF clause on the ticket_details table.
*/
select * from ticket_details;
select if (sum(no_of_tickets * price_per_ticket)>10000, "Revenue has crossed 10K", "Revenue has not crossed 1oK") as revenue from ticket_details;

/* Task 10: Write a query to create and grant access to a new user to perform operations on a database.
*/
CREATE USER 'new_user'@'localhost' IDENTIFIED BY 'password';

/* Task 11: Write a query to find the maximum ticket price for each class using window functions on the ticket_details table.
*/
select * from ticket_details;
select customer_id, class_id, max(price_per_ticket) over (partition by class_id) as max_price_per_class from ticket_details;

select customer_id, class_id, price_per_ticket
from ( select customer_id, class_id, price_per_ticket, rank() over (partition by class_id order by price_per_ticket desc) 
as rnk from ticket_details) as ranked where rnk = 1;

/* Task 12: Write a query to extract the passengers whose route ID is 4 by improving the speed and performance of the passengers_on_flights table.
*/
select * from passengers_on_flights;
CREATE INDEX i1 ON passengers_on_flights(route_id);
select * from passengers_on_flights where route_id="4";

/* Task 13: For the route ID 4, write a query to view the execution plan of the passengers_on_flights table.
*/
DROP INDEX i1 ON passengers_on_flights;
explain select * from passengers_on_flights where route_id = "4";

/*Task 14: Write a query to calculate the total price of all tickets booked by a customer across different aircraft IDs using rollup function.
*/
select customer_id, aircraft_id, sum(price_per_ticket * no_of_tickets) as total_price 
from ticket_details group by customer_id, aircraft_id with rollup;

/*Task 15: Write a query to create a view with only business class customers along with the brand of airlines.
*/
select * from customer;
select * from passengers_on_flights;
select * from ticket_details;
CREATE VIEW business_class_customers AS
SELECT customer.customer_id, customer.first_name, customer.last_name, ticket_details.brand FROM customer
JOIN ticket_details ON customer.customer_id = ticket_details.customer_id WHERE ticket_details.class_id = 'Bussiness';
SELECT * FROM air_cargo_analysis.business_class_customers;


/* Task 16: Write a query to create a stored procedure to get the details of all passengers flying between a range of routes defined in run time.
Also, return an error message if the table doesn't exist.
*/
DELIMITER $$
CREATE PROCEDURE GetPassengerDetailsByRouteRange(IN start_route_id INT, IN end_route_id INT)
BEGIN
    DECLARE table_exists INT;

    -- Check if the table exists
    SET table_exists = (SELECT COUNT(*) 
                        FROM information_schema.tables 
                        WHERE table_schema = DATABASE() 
                          AND table_name = 'passengers_on_flights');
    
    -- If the table does not exist, return an error message
    IF table_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The table passengers_on_flights does not exist.';
    ELSE
        -- Retrieve passenger details between the specified route range
        SELECT *
        FROM passengers_on_flights
        WHERE route_id BETWEEN start_route_id AND end_route_id;
    END IF;
END$$
DELIMITER ;

/* Task 17: Write a query to create a stored procedure that extracts all the details from the routes table where the travelled distance is more than 2000 miles.
*/
select * from routes;
USE `air_cargo_analysis`;
DROP procedure IF EXISTS `new_procedure`;

DELIMITER $$
USE `air_cargo_analysis`$$
CREATE PROCEDURE `new_procedure` ()
BEGIN
select * from routes where distance_miles>"2000";
END$$

DELIMITER ;

DELIMITER $$


/* Task 18: Write a query to create a stored procedure that groups the distance travelled by each flight into three categories.
The categories are, short distance travel (SDT) for >=0 AND <= 2000 miles, intermediate distance travel (IDT) for >2000 AND <=6500, 
and long-distance travel (LDT) for >6500.
*/
CREATE PROCEDURE GroupFlightDistanceCategories()
BEGIN
    -- Retrieve and categorize distance for each flight
    SELECT
        Flight_num,
        Distance_miles,
        CASE
            WHEN Distance_miles >= 0 AND Distance_miles <= 2000 THEN 'SDT'  -- Short Distance Travel
            WHEN Distance_miles > 2000 AND Distance_miles <= 6500 THEN 'IDT'  -- Intermediate Distance Travel
            WHEN Distance_miles > 6500 THEN 'LDT'  -- Long Distance Travel
        END AS Distance_Category
    FROM
        routes;
END$$

DELIMITER ;
call air_cargo_analysis.GroupFlightDistanceCategories();

/* Task 19: Write a query to extract ticket purchase date, customer ID, class ID and specify if the complimentary services are provided 
for the specific class using a stored function in stored procedure on the ticket_details table.
Condition:
If the class is Business and Economy Plus, then complimentary services are given as Yes, else it is No
*/
DELIMITER $$

CREATE PROCEDURE complimentary_service()
BEGIN
    SELECT 
        p_date, 
        customer_id, 
        class_id, 
        CASE
            WHEN class_id IN ('Business', 'Economy Plus') THEN 'Yes'
            ELSE 'No'
        END AS Complimentary_Services
    FROM 
        ticket_details;
END$$

DELIMITER ;
call complimentary_service();