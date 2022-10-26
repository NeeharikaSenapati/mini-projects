-- Question 1: Find the top 3 customers who have the maximum number of orders
select * from market_fact;

select * from
(select *,
dense_rank() over(order by counts desc) rnk from
(select cust_id,count(Ord_id) counts
from market_fact
group by Cust_id)t)tt
where rnk<=3;

-- Question 2: Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.
select * from  orders_dimen;
select * from shipping_dimen;
select *,datediff(shipping_date,ordered_date) as difference_between_dates from
(select *,str_to_date(order_date,'%d-%m-%Y')ordered_date,str_to_date(ship_date,'%d-%m-%Y')shipping_date
from orders_dimen od join shipping_dimen sd
using(order_id))t
order by difference_between_dates desc;

-- Question 3: Find the customer whose order took the maximum time to get delivered.
select * from market_fact;

select cust_id,Customer_Name,Province,str_to_date(order_date,'%d-%m-%Y')orderr_date,str_to_date(ship_date,'%d-%m-%Y')shipp_date,datediff(str_to_date(ship_date,'%d-%m-%Y'),str_to_date(order_date,'%d-%m-%Y'))DaysTakenForDelivery 
from orders_dimen join shipping_dimen
using(order_id)
join market_fact
using(ord_id)
join cust_dimen
using(cust_id)
where ord_id='ord_4335'
order by DaysTakenForDelivery desc;

-- dean percer from yunkonis the customer who received the  order which took maximum days to deliver
select * from market_fact;
-- Question 4: Retrieve total sales made by each product from the data (use Windows function)
select * from prod_dimen;
select prod_id,
sum(sales)over(partition by prod_id order by sales desc) total_sales 
from market_fact 
group by Prod_id
order by sales desc;


-- Question 5: Retrieve the total profit made from each product from the data (use windows function)
select prod_id,
sum(profit)over(partition by prod_id ) total_profit
from market_fact
group by Prod_id
order by total_profit desc;
-- Question 6: Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
select year(ordereddate)year_of_orderdate,month(ordereddate)month_of_orderdate,count(distinct(cust_id))unique_customer from
(select *, str_to_date(order_date,'%d-%m-%Y')ordereddate 
from orders_dimen join market_fact
using(ord_id))t
where year(ordereddate) = 2011 and month(ordereddate)=1;
-- total no of unique customer in january 2011 is 99


select * from rating_final;
-- Question 1: - We need to find out the total visits to all restaurants under all alcohol categories available.
select count(userId) total_visits
 from rating_final
where placeID in
(select placeid from geoplaces2
where alcohol not like "%no_alcohol%");

-- Question 2: -Let's find out the average rating according to alcohol and price so that we can understand the rating in respective price categories as well.
select  alcohol,price,avg(rating) overall_avg_rating,avg(food_rating) avg_food_rating,avg(service_rating) avg_service_rating
 from
(select placeid,price,alcohol,rating,food_rating,service_rating 
from geoplaces2 join rating_final 
using(placeid))t
group by alcohol,Price
order by alcohol;


-- Question 3:  Let’s write a query to quantify that what are the parking availability as well in different alcohol categories along with the total number of restaurants.
select parking_lot,count(parking_lot)no_of_parking,alcohol,count(placeId)no_of_restaurents from
(select placeid,parking_lot,alcohol
from chefmozparking join geoplaces2
using(placeid))t
group by parking_lot,alcohol
order by alcohol;
-- Question 4: -Also take out the percentage of different cuisine in each alcohol type.
select alcohol,different_cuisine,total_cuisine,round(different_cuisine *100/total_cuisine,2)percentage from
(select alcohol,count(Rcuisine)different_cuisine,
sum(count(Rcuisine))over() total_cuisine from
(select placeid,rcuisine,alcohol from chefmozcuisine join geoplaces2
using(placeid))t
group by alcohol)tt;
-- Questions 5: - let’s take out the average rating of each state.
select state, avg(rating) avg_rating from
(select placeid,price,alcohol,rating,food_rating,service_rating,state 
from geoplaces2 join  rating_final 
using(placeid))t
group by state
order by avg_rating desc;
-- Questions 6: -' Tamaulipas' Is the lowest average rated state. 
-- Quantify the reason why it is the lowest rated by providing the summary on the basis of State, alcohol, and Cuisine.
select * from (
select 
case
when state like "s.l.p." then "SLP"
When state like "san luis potos" then "San Luis Potosi"
else state
end as corrected_state_name,alcohol,rcuisine from geoplaces2 join chefmozcuisine using(placeid))t
where corrected_state_name <>"?"
group by corrected_state_name,alcohol,rcuisine
order by corrected_state_name;
-- Question 7:  - Find the average weight, food rating, and service rating of the customers who have visited KFC and tried Mexican or Italian types of cuisine, and also their budget level is low.
-- We encourage you to give it a try by not using joins.
select * from Chefmozcuisine;
select * from geoplaces2;
select * from rating_final;

select userid,avg(food_rating) as average_food_rating,avg(service_rating) as average_service_rating
,avg((select weight from userprofile u where u.userid=r.userid)) as average_wght from rating_final as r 
where userid in
(select userid from userprofile where userid in
(select userid from usercuisine where userid in
(select userid from rating_final where placeid =
(select placeid from geoplaces2 where name="kfc"))
and rcuisine in ("mexican","italian"))
and budget="low")
group by userid;
-- -----------------------------------------
-- Question 1:
-- Create two called Student_details and Student_details_backup.

-- Let’s say you are studying SQL for two weeks. In your institute, there is an employee who has been maintaining the student’s details and Student Details Backup tables. He / She is deleting the records from the Student details after the students completed the course and keeping the backup in the student details backup table by inserting the records every time. You are noticing this daily and now you want to help him/her by not inserting the records for backup purpose when he/she delete the records.write a trigger that should be capable enough to insert the student details in the backup table whenever the employee deletes records from the student details table.

-- Note: Your query should insert the rows in the backup table before deleting the records from student details.
create table Student_details
(
Student_id int,
Student_name varchar(20),
Mail_ID varchar(20),
Mobile_NO int
);
create table Student_details_backup
(
Student_id int,
Student_name varchar(20),
Mail_ID varchar(20),
Mobile_NO int
);
create trigger backups
before insert
on student_details
for each row
insert into Student_details_backup(Student_id,Student_name,Mail_ID,Mobile_NO) values 
(new.Student_id,new.Student_name,new.Mail_ID,new.Mobile_NO);