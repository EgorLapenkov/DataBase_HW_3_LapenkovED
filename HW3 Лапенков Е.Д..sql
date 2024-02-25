-- 1 задание
select job_industry_category , count(customer_id)
from customer
group by job_industry_category 
order by count(customer_id) desc;

-- 2 задание
select 
	job_industry_category
	, sum(list_price) as trans_sum
	, extract(month from transaction_date::date) as month
from transaction
left join customer
on transaction.customer_id = customer.customer_id
group by extract(month from transaction_date::date), job_industry_category
order by extract(month from transaction_date::date), job_industry_category;

-- 3 задание
select brand, count(transaction_id)
from transaction
where online_order = 'True' and order_status = 'Approved' and customer_id in (
	select customer_id
	from customer
	where job_industry_category = 'IT'
	)
group by brand;

-- 4 задание
-- 4.1 через group by
select 
	customer_id
	,sum(list_price)
	, max(list_price)
	, min(list_price)
	, count(transaction_id)
from transaction
group by customer_id
order by sum(list_price) desc, count(transaction_id) desc;

-- 4.2 через оконные функции
select 
	customer_id
	,sum(list_price) over(partition by customer_id) as sum_price
	, max(list_price) over(partition by customer_id) as max_price
	, min(list_price) over(partition by customer_id) as min_price
	, count(transaction_id) over(partition by customer_id) as count_transaction
from transaction
order by sum_price desc, count_transaction desc;

-- 5 задание
-- максимальное значение	
select first_name, last_name
from customer c
right join transaction t ON c.customer_id = t.customer_id
group by c.first_name, c.last_name 
having sum(t.list_price) = (
    select max(total_sum)
    from (
        select SUM(list_price) AS total_sum
        from transaction
        group by customer_id
    ) as total_sums
);

-- минимальное значение
select first_name, last_name
from customer c
right join transaction t ON c.customer_id = t.customer_id
group by c.first_name, c.last_name 
having sum(t.list_price) = (
    select min(total_sum)
    from (
        select SUM(list_price) AS total_sum
        from transaction
        group by customer_id
    ) as total_sums
);

-- 6 задание
with numbered_transaction as( 
	select customer_id, transaction_id, transaction_date
		, row_number() over(partition by customer_id order by transaction_date)
	from transaction
	)
select customer_id, transaction_id
from numbered_transaction
where row_number = 1 

-- 7 задание
select first_name, last_name, job_title
from customer c
right join (
    select customer_id, MAX(transaction_date::date) - MIN(transaction_date::date) as max_interval
    from transaction
    group by customer_id
) t on c.customer_id = t.customer_id
order by t.max_interval desc
limit 1;