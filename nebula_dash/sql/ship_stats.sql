-- ship types
select generation, model_name, count(*) as ship_count
from ships
group by 1,2
order by 1,2;

-- ship owners + total count
select
 concat(substring(so.owner, 1, 8), '..', substring(so.owner, 34, 24)) as owner,
 count(*) as ship_count
from ships s
 join ship_owners so on s.ship_id = so.ship_id
group by 1
order by 2 desc;
