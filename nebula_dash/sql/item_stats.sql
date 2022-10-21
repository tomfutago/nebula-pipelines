-- items
select
 concat(substring(ito.owner, 1, 8), '..', substring(ito.owner, 34, 24)) as owner,
 i.type,
 i.name,
 ito.total
from item_owners ito
 join items i on ito.item_id = i.item_id
where ito.total > 0
order by 1,2,3;

-- zones
select
 concat(substring(ito.owner, 1, 8), '..', substring(ito.owner, 34, 24)) as owner,
 i.type,
 i.name,
 ito.total
from item_owners ito
 join items i on ito.item_id = i.item_id
where ito.total > 0
 and i.type = 'deed'
order by ito.total desc;
