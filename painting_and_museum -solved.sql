

--QUES. 1 Fetch all the paintings which are not displayed on any museums?

select *
from work
where museum_id is null

--QUES. 2 Are there museums without any paintings?

	select *
	from museum
	where museum_id in

			(select m.museum_id
			from museum m 
	
			except 

			select w.museum_id
			from work w)


			-- (TFQ ANSWER)

	select * from museum m
	where not exists (select 1 from work w
					 where w.museum_id=m.museum_id)



--QUES. 3 How many paintings have an asking price of more than their regular price?


	select *
	from work w inner join product_size p
	on w.work_id = p.work_id
	where sale_price > regular_price



--QUES. 4 Identify the paintings whose asking price is less than 50% of its regular price
	
	select *
	from work w inner join product_size p
	on w.work_id = p.work_id
	where convert(float,sale_price) < (0.5 * convert(float,regular_price))


--QUES. 5 Which canva size costs the most?

	select sub.size_id, sub.work_id, sub.sale_price
	from 
	(
			select p.size_id ,
			p.sale_price ,
			p.work_id ,
			DENSE_RANK() over(order by sale_price desc) [ranks]

			from canvas_size c inner join product_size p
			on convert(varchar,c.size_id) = p.size_id inner join work w
			on p.work_id = w.work_id ) sub

	where sub.ranks = 1 
	order by sub.sale_price desc



	--(Tfq answer)
	select cs.label as canva, ps.sale_price
	from (select *
		  , rank() over(order by sale_price desc) as rnk 
		  from product_size) ps
	join canvas_size cs on convert(varchar,cs.size_id) = ps.size_id
	where ps.rnk=1;	


--QUES. 6  Delete duplicate records from work, product_size, subject and image_link tables
	
	with del_dup_1
		as	(
			select [name] ,
			row_number() over( partition by [name] order by [name] ) [rranks]
			from work w
			)

			delete from work
			where [name] in ( select [name] from del_dup_1 where rranks > 1 )


		with del_dup_2
		as	(
			select p.size_id ,
			row_number() over( partition by size_id order by size_id ) [rranks]
			from product_size p
			)

			delete from product_size
			where size_id in ( select size_id from del_dup_2 where rranks > 1 )


			with del_dup_3
		as	(
			select s.subject,
			row_number() over( partition by subject order by s.work_id ) [rranks]
			from subject s
			)

			delete from subject
			where work_id in ( select work_id from del_dup_3 where rranks > 1 )

			with del_dup_4
		as	(
			select i.url,
			row_number() over( partition by i.url order by i.work_id ) [rranks]
			from image_link i
			)

			delete from subject
			where work_id in ( select work_id from del_dup_4 where rranks > 1 )
		

--QUES. 7 Identify the museums with invalid city information in the given dataset

	select m.*
	from museum m
	where city = '% %' or city = '-' or city like '%"%' or city like '%[0-9]%'


--QUES. 8 Museum_Hours table has 1 invalid entry. Identify it and remove it.

	select *
	from museum_hours

	--Loading..


	
--QUES. 9  Fetch the top 10 most famous painting subject
	
	select *
	from
		(
		select  subject, count(subject) [sub_count], rank() over(order by count(subject) desc) [ranks]
		from subject
		group by subject ) sub
	where ranks <= 10


	
--QUES. 10 Identify the museums which are open on both Sunday and Monday. Display 
--museum name, city.

	select distinct m.name, m.city
	from museum m inner join museum_hours mh
	on m.museum_id = mh.museum_id
	where day = 'Sunday' 
	
	intersect
	
	select distinct m.name, m.city
	from museum m inner join museum_hours mh
	on m.museum_id = mh.museum_id
	where day = 'Monday' 

	

--QUES. 11 How many museums are open every single day?

	select m.museum_id , m.[name] , count(day) [no_of_days]
	from museum_hours mh inner join museum m 
	on mh.museum_id = m.museum_id
	group by m.museum_id , m.[name]
	having count(day) = 7

	



--QUES.12. Which are the top 5 most popular museum? (Popularity is defined based on most 
--no of paintings in a museum)


	select *
	from
			(
			select m.name , count(work_id) [no_of_works], rank() over(order by count(work_id) desc) [ranks]
			from museum m inner join work w
			on m.museum_id = w.museum_id
			group by m.name) sub
	where ranks <= 5
	


	--(TFQ ANSWER)
	select m.name as museum, m.city,m.country,x.no_of_painintgs
	from (	select m.museum_id, count(1) as no_of_painintgs
			, rank() over(order by count(1) desc) as rnk
			from work w
			join museum m on m.museum_id=w.museum_id
			group by m.museum_id) x
	join museum m on m.museum_id=x.museum_id
	where x.rnk<=5;


	


--QUES. 13. Who are the top 5 most popular artist? (Popularity is defined based on most no of 
--paintings done by an artist)


	select *
	from
	(
			select a.full_name, count(w.work_id) [count_of_painting], rank() over(order by count(w.work_id) desc) [drank]
			from artist a inner join work w 
			on convert(varchar,a.artist_id) = convert(varchar,w.artist_id)
			group by a.full_name) sub
	where drank <= 5


	--(TFQ ANSWER)

	select a.full_name as artist, a.nationality,x.no_of_painintgs
	from (	select a.artist_id, count(1) as no_of_painintgs
			, rank() over(order by count(1) desc) as rnk
			from work w
			join artist a on a.artist_id=w.artist_id
			group by a.artist_id) x
	join artist a on a.artist_id=x.artist_id
	where x.rnk<=5;



--QUES.14. Display the 3 least popular canva sizes


	select top 3 c.size_id, c.label ,count(label) [canvas_size_count]
	from canvas_size c inner join product_size p
	on convert(varchar,c.size_id) = convert(varchar,p.size_id)
	group by c.size_id, c.label
	order by canvas_size_count asc

	--(TFQ ANSWER)
	select label,ranking,no_of_paintings
	from (
		select cs.size_id,cs.label,count(1) as no_of_paintings
		, dense_rank() over(order by count(1) ) as ranking
		from work w
		join product_size ps on ps.work_id=w.work_id
		join canvas_size cs on convert(varchar,cs.size_id) = ps.size_id
		group by convert(varchar,cs.size_id),cs.label) x
	where x.ranking<=3; 

--QUES.15. Which museum is open for the longest during a day. Dispay museum name, state 
--and hours open and which day?
	

	with fix_time
	as (
		select m.museum_id [ids], m.name [names], mh.day [days],
		cast(replace(replace([open] , ':AM' , ' AM') , ':PM' , ' PM') as time) [new_open_time] ,
		cast(replace(replace([close] , ':AM' , ' AM') , ':PM' , ' PM') as time) [new_close_time] 
		
		from museum m
		inner join museum_hours mh
		on m.museum_id = mh.museum_id
	)

	select ids , names , days , hours_opened 
	from
		(
		select ids, names , days , hours_opened , rank() over(order by hours_opened desc) [rn]
		from
			(
			select ids , names , days , DATEDIFF(hour, new_open_time , new_close_time) [hours_opened]
			from fix_time ) sub ) sub2
	where rn = 1;


--QUES.16. Which museum has the most no of most popular painting style?	


	select top 1 w.museum_id , m.name, m.address, m.phone , count(style) [count_of_impressionism]
	from work w inner join museum m on w.museum_id = m.museum_id
	where style in 
			(select top 1 style
			from work
			where style != ''
			group by style
			order by count(style) desc) and w.museum_id != ''
	
	group by w.museum_id, m.name , m.address, m.phone
	order by count_of_impressionism desc


	--(TFQ ANSWER)
	with pop_style as 
			(select style
			,rank() over(order by count(1) desc) as rnk
			from work
			group by style),
		cte as
			(select w.museum_id,m.name as museum_name,ps.style, count(1) as no_of_paintings
			,rank() over(order by count(1) desc) as rnk
			from work w
			join museum m on m.museum_id=w.museum_id
			join pop_style ps on ps.style = w.style
			where w.museum_id is not null
			and ps.rnk=1
			group by w.museum_id, m.name,ps.style)
	select museum_name,style,no_of_paintings
	from cte 
	where rnk=1;
	


	--QUES.17  Identify the artists whose paintings are displayed in multiple countries

		select a.artist_id , a.full_name , count(country) [countries]

		from artist a
		inner join work w on convert(varchar,a.artist_id) = convert(varchar,w.artist_id)
		inner join museum m on convert(varchar,w.museum_id) = convert(varchar,m.museum_id)
	
		group by a.artist_id , a.full_name
		having count(country) > 1
		order by countries desc



--(TFQ ANSWER)
		with cte as
		(select distinct a.full_name as artist
		--, w.name as painting, m.name as museum
		, m.country
		from work w
		join artist a on a.artist_id=w.artist_id
		join museum m on m.museum_id=w.museum_id)
	select artist,count(1) as no_of_countries
	from cte
	group by artist
	having count(1)>1
	order by 2 desc;


	--QUES.18 Display the country and the city with most no of museums. Output 2 seperate 
	--columns to mention the city and country. If there are multiple value, seperate them 
	--with comma.


		select top 1 m.country [countries],
		count(m.[name]) over(partition by country) [museum_in_country], 
		m.city [cities],
		count(m.[name]) over(partition by city) [museum_in_city]
		from museum m

		where m.country not like '%[0-9]%'
		  and m.city not like '%0-9%'
		  and m.city not like '%-%'
		  and m.city not like '%"%'
		  
		group by m.country, m.city, m.name
		order by museum_in_country desc, museum_in_city desc




		--TFQ ANSWER ()

		with cte_country as 
			(select country, count(1)
			, rank() over(order by count(1) desc) as rnk
			from museum
			group by country),
		cte_city as
			(select city, count(1)
			, rank() over(order by count(1) desc) as rnk
			from museum
			group by city)
	select string_agg(distinct country.country,', '), string_agg(city.city,', ')
	from cte_country country
	cross join cte_city city
	where country.rnk = 1
	and city.rnk = 1;




--QUES. 19. Identify the artist and the museum where the most expensive and least expensive 
--painting is placed. Display the artist name, sale_price, painting name, museum 
--name, museum city and canvas label

		
	select a.full_name, p.sale_price, w.name [painting_name], m.name [museum_name], m.city, c.label

	from artist a inner join work w
	on convert(varchar,a.artist_id) = convert(varchar,w.artist_id) inner join product_size p
	on convert(varchar,w.work_id) = convert(varchar,p.work_id) inner join museum m on
	convert(varchar,w.museum_id) = convert(varchar,m.museum_id) inner join canvas_size c
	on convert(varchar,p.size_id) = convert(varchar,c.size_id)

	where p.sale_price = ( select max(sale_price) from product_size ) 



	select top 1 a.full_name, p.sale_price, w.name [painting_name], m.name [museum_name], m.city, c.label

	from artist a inner join work w
	on convert(varchar,a.artist_id) = convert(varchar,w.artist_id) inner join product_size p
	on convert(varchar,w.work_id) = convert(varchar,p.work_id) inner join museum m on
	convert(varchar,w.museum_id) = convert(varchar,m.museum_id) inner join canvas_size c
	on convert(varchar,p.size_id) = convert(varchar,c.size_id)

	where p.sale_price = ( select min(sale_price) from product_size ) 


--(TFQ ANSWER)

	with cte as 
		(select *
		, rank() over(order by sale_price desc) as rnk
		, rank() over(order by sale_price ) as rnk_asc
		from product_size )
	select w.name as painting
	, cte.sale_price
	, a.full_name as artist
	, m.name as museum, m.city
	, cz.label as canvas
	from cte
	join work w on w.work_id=cte.work_id
	join museum m on m.museum_id=w.museum_id
	join artist a on a.artist_id=w.artist_id
	join canvas_size cz on cz.size_id = cte.size_id::NUMERIC
	where rnk=1 or rnk_asc=1;





--QUES 20.  Which country has the 5th highest no of paintings?


	select m.country [country] , count(work_id) [no_of_paintings] , rank() over( order by count(work_id) desc ) [rn]
	from work w
	inner join museum m on w.museum_id = m.museum_id
	group by m.country
	order by rank() over( order by count(work_id) desc ) 



--QUES  21. Which are the 3 most popular and 3 least popular painting styles?
	
	select [Most Popular Styles] [Most popular and least popular] , count_of_style
	from
	(
		select style [Most Popular Styles], count_of_style 
		from
			(
			select style ,  count(style) [count_of_style] , rank() over(order by count(style) desc) [rn]
			from work w
			where style is not null
			group by style ) sub
		where rn <= 3 
		union all
		select  style [Least Popular Styles], count_of_style 
		from
			(
			select  style ,  count(style) [count_of_style] , rank() over(order by count(style)) [rn]
			from work w
			where style is not null
			group by style ) sub
		where rn <= 3 ) sub2 ;





--QUES 22. Which artist has the most no of Portraits paintings outside USA?. Display artist 
--name, no of paintings and the artist nationality.


	select full_name , nationality , no_of_portraits
	from
	(
		select full_name [full_name] , nationality [nationality] , count(w.work_id) [no_of_portraits] , rank()over(order by count(w.work_id) desc) [rn]

		from artist a 
		inner join work w 
		on convert(varchar,a.artist_id) = w.artist_id 
		inner join subject s
		on w.work_id = s.work_id
		inner join museum m 
		on w.museum_id = m.museum_id

		where country != 'Usa'
		and subject = 'Portraits'
		group by full_name , nationality) sub
	where rn = 1;


	



	
