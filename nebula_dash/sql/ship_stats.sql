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

-- ship owners - count per ship model
select
 concat(substring(so.owner, 1, 8), '..', substring(so.owner, 34, 24)) as owner,
 sum(case when generation = 'Lore Set I' then 1 else 0 end) as lore,
 sum(case when model_name = 'Roc' then 1 else 0 end) as roc,
 sum(case when model_name = 'Gargoyle' then 1 else 0 end) as gargoyle,
 sum(case when model_name = 'Stormbird' then 1 else 0 end) as stormbird,
 sum(case when model_name = 'Griffin' then 1 else 0 end) as griffin,
 sum(case when model_name = 'Behemoth' then 1 else 0 end) as behemoth,
 sum(case when model_name = 'Zethus' then 1 else 0 end) as zethus,
 sum(case when model_name = 'Illex' then 1 else 0 end) as illex,
 sum(case when model_name = 'Chrysalis' then 1 else 0 end) as chrysalis,
 count(*) as ship_count
from ships s
 join ship_owners so on s.ship_id = so.ship_id
group by 1
order by ship_count desc;
