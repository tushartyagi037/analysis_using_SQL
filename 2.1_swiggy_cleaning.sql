select *
from swiggy_raw;
select count(*)
from swiggy_raw;
describe swiggy_raw;


create table swiggy_staging
like swiggy_raw;

insert into swiggy_staging
select *
from swiggy_raw;

select *
from swiggy_staging;


# Data Cleaning
-- Handling Duplicates
-- checking if any id is duplicate
with duplicatecte as(
select id, area, city, restaurant, row_number() over(partition by id order by id) row_num
from swiggy_staging
)
select *
from duplicatecte
where row_num > 1;

-- checking if any restaurant is listed multiple times in same area
with duplicatecte as(
select id, restaurant, area, city, price, row_number() over(partition by restaurant, area, city
order by id) row_num
from swiggy_staging
)
select *
from duplicatecte
where row_num > 1;

-- deleting duplicate records
delete s from swiggy_staging s
join(
select id, row_number() over(
partition by restaurant, area, city order by id) row_num
from swiggy_staging
) t on s.id = t.id
where t.row_num >1;

select count(*)
from swiggy_staging;


# Data Standardization
update swiggy_staging
set
city = trim(city),
area = trim(area),
restaurant = trim(restaurant),
address = trim(address);

select city, count(*)
from swiggy_staging
group by city
order by city;


# Handling NULL and Missing Values
select
count(case when id is null then 1 end) null_id,
count(case when restaurant is null or restaurant = '' then 1 end) blank_restaurant,
count(case when area is null or area = '' then 1 end) blank_area,
count(case when city is null or city = '' then 1 end) blank_city,
count(case when price is null then 1 end) null_price,
count(case when `avg ratings` is null then 1 end) null_ratings,
count(case when `total ratings` is null then 1 end) null_total_ratings,
count(case when `food type` is null or `food type` = '' then 1 end) blank_food_type,
count(case when `delivery time` is null then 1 end) null_delivery_time
from swiggy_staging;
-- zero missing values or blank entries


# dropping the unorganised address column
alter table swiggy_staging
drop column address;

describe swiggy_staging;