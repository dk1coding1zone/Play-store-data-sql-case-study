CREATE TABLE playstoredata (
    App VARCHAR(255),
    Category VARCHAR(50),
    Rating DECIMAL(3, 1),
    Reviews INT,
    Size VARCHAR(20),
    Installs INT,
    Type VARCHAR(20),
    Price DECIMAL(10, 2),
    Content_Rating TEXT,
    Genres VARCHAR(50),
    Last_Updated DATE,
    Current_Ver VARCHAR(50),
    Android_Ver VARCHAR(50)
);

select count(*) from playstoredata

select * from playstoredata;
truncate table playstoredata;

-- 1.You're working as a market analyst for a mobile app development company. Your task is to identify the most promising categories(TOP 5) for 
-- launching new free apps based on their average ratings.
	
select category, round(avg(rating),2) as average  from playstoredata where type='Free' 
group by category
order by average desc
limit 5;




LOAD DATA INFILE "C:/ProgramData/MySQL/playstore.csv"
INTO TABLE playstoredata
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- 2. As a business strategist for a mobile app company, your objective is to pinpoint the three categories that generate the most revenue from paid apps.
-- This calculation is based on the product of the app price and its number of installations.

select category, round(sum(revenue),2) as rev from
(
select *,Installs*Price as revenue from playstoredata where  type='Paid'
)t  group by category 
order by rev desc
limit 3;

-- 3. As a data analyst for a gaming company, you're tasked with calculating the percentage of games within each category. 
-- This information will help the company understand the distribution of gaming apps across different categories.
select * , (cnt/(select count(*) from playstoredata))*100 as 'percentage' from
(
select category , count(category) as 'cnt' from playstoredata group by category
)m

-- 4. As a data analyst at a mobile app-focused market research firm, 
-- you'll recommend whether the company should develop paid or free apps for each category based on the  ratings of that category.

with freeapp as
(
 select category, round(avg(rating),2) as 'avg_rating_free' from playstoredata where type ='Free'
 group by category
),
paidapp as
( 
 select category, round(avg(rating),2) as 'avg_rating_paid' from playstoredata where type ='Paid'
 group by category
)

select *, if(avg_rating_free>avg_rating_paid,'Develop Free app','Develop Paid app') as 'Development' from
(
select f.category,f.avg_rating_free, p.avg_rating_paid  from freeapp as f inner join paidapp  as p on f.category = p.category
)k

-- 5.Suppose you're a database administrator, your databases have been hacked  and hackers are changing price of certain apps on the database , its taking long for IT team to 
-- neutralize the hack , however you as a responsible manager  dont want your data to be changed , do some measure where the changes in price can be recorded as you cant 
-- stop hackers from making changes

-- creating table.
CREATE TABLE PriceChangeLog (
    App VARCHAR(255),
    Old_Price DECIMAL(10, 2),
    New_Price DECIMAL(10, 2),
    Operation_Type VARCHAR(10),
    Operation_Date TIMESTAMP
);

create table play as
SELECT * FROM PLAYSTORE

-- for update
DELIMITER //   
CREATE TRIGGER price_change_update
AFTER UPDATE ON play
FOR EACH ROW
BEGIN
    INSERT INTO pricechangelog (app, old_price, new_price, operation_type, operation_date)
    VALUES (NEW.app, OLD.price, NEW.price, 'update', CURRENT_TIMESTAMP);
END;
//
DELIMITER ;

SET SQL_SAFE_UPDATES = 0;
UPDATE play
SET price = 4
WHERE app = 'Infinite Painter';

UPDATE play
SET price = 5
WHERE app = 'Sketch - Draw & Paint';


select * from play where app='Sketch - Draw & Paint'

