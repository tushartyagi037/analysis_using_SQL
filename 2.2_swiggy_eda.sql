-- City-wise analysis for restaurants
select
city, count(*) total_restaurants,
round(avg(price), 2) avg_price,
round(avg(`avg ratings`), 2) overall_avg_ratings,
round(avg(`delivery time`), 1) avg_delivery_time
from swiggy_staging
group by city
order by total_restaurants desc;
-- Kolkata has highest number of restaurants and delivery time

select *
from swiggy_staging;

-- identifying top 5 most popular cuisines
select
sum(case when `food type` like '%North Indian%' then 1 else 0 end) north_indian_count,
sum(case when `food type` like '%South Indian%' then 1 else 0 end) south_indian_count,
sum(case when `food type` like '%Chineses%' then 1 else 0 end) chinese_count,
sum(case when `food type` like '%Briyani%' then 1 else 0 end) briyani_count,
sum(case when `food type` like '%Fast Food%' then 1 else 0 end) fast_food_count,
sum(case when `food type` like '%Desserts%' or `food type` like '%Bakery%' then 1 else 0 end) sweets_count
from swiggy_staging;
-- North Indian is the most popular cuisine


-- Restaurants with high ratings but low prices
select
restaurant, city, area, price, `avg ratings`, `total ratings`
from swiggy_staging
where `avg ratings` >= 4.5
and `total ratings` >= 100
and price < 500
order by `avg ratings` desc, `total ratings` desc
limit 10;


-- areas in city with slowest highest delivery time (change the city name and get the areas with highest delivery time)
select
area, count(*) restaurant_count, round(avg(`delivery time`), 1) avg_delivery_time
from swiggy_staging
where city = 'Bangalore'
group by area
having restaurant_count >= 5
order by avg_delivery_time desc
limit 5;


-- Segregating restaurants based on price range
select
case
when price < 200 then 'budget (<200)'
when price between 200 and 499 then 'mid-range (200 - 499)'
else 'premium (500+)'
end as price_segment,
count(*) restaurant_count,
round(count(*) * 100 / (select count(*) from swiggy_staging), 2) market_percentage
from swiggy_staging
group by 
case
when price < 200 then 'budget (<200)'
when price between 200 and 499 then 'mid-range (200 - 499)'
else 'premium (500+)'
end
order by restaurant_count desc;
-- mid-range restaurants have the highest percentage that is 70.02%


-- Top-rated restaurants per city (as per ratings)
with rankedrestaurants as(
select city, restaurant, `avg ratings`, `total ratings`, price,
dense_rank() over(partition by city order by `avg ratings` desc, `total ratings` desc) rating_rank
from swiggy_staging
where `total ratings` >= 500
)
select city, restaurant, `avg ratings`, `total ratings`, price
from rankedrestaurants
where rating_rank <= 3;


-- Under-performing (high price, low ratings)
select 
city, area, restaurant, price, `avg ratings`, `total ratings`
from swiggy_staging
where price > 400 and `avg ratings` < 3.5
order by price desc;
-- 590 restaurants have high prices and low ratings


-- Top 10 restaurants in demand
select
city, area, restaurant, `avg ratings`, `total ratings`, price,
round((`avg ratings` * `total ratings`), 0) popularity_score
from swiggy_staging
order by popularity_score desc
limit 10;


select count(*)
from swiggy_staging;


