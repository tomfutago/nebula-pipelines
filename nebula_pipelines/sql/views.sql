create or replace view vw_unique_owners as
select distinct owner
from (
    select owner from planet_owners
    union all
    select owner from ship_owners
 ) t;
