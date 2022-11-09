/*
drop view if exists vw_planet_owner_deposits_discovered_stats;
*/

-- planet owners
create or replace view vw_planet_owners as
select
 po.planet_id,
 po.owner,
 concat(substring(po.owner, 1, 8), '..', substring(po.owner, 34, 24)) as owner_o
from planet_owners po;

-- planet owners + total count
create or replace view vw_planet_owner_stats as
select
 po.owner,
 po.owner_o,
 count(*) as planet_count
from planets p
 join vw_planet_owners po on p.planet_id = po.planet_id
group by 1,2;

-- planet owners + rarity pivot stats
create or replace view vw_planet_owner_rarity_pivot_stats as
select
 po.owner,
 po.owner_o,
 sum(case when p.rarity = 'common' then 1 else 0 end) as common,
 sum(case when p.rarity = 'uncommon' then 1 else 0 end) as uncommon,
 sum(case when p.rarity = 'rare' then 1 else 0 end) as rare,
 sum(case when p.rarity = 'legendary' then 1 else 0 end) as legendary,
 sum(case when p.rarity = 'mythic' then 1 else 0 end) as mythic,
 count(*) as planet_count
from planets p
 join vw_planet_owners po on p.planet_id = po.planet_id
group by 1,2;

-- planet owners + rarity list stats
create or replace view vw_planet_owner_rarity_list_stats as
select
 po.owner,
 po.owner_o,
 p.rarity,
 count(*) as planet_count
from planets p
 join vw_planet_owners po on p.planet_id = po.planet_id
group by 1,2,3;

-- planet owners + gen rarity pivot stats
create or replace view vw_planet_owner_gen_rarity_pivot_stats as
select
 po.owner,
 po.owner_o,
 p.generation,
 sum(case when p.rarity = 'common' then 1 else 0 end) as common,
 sum(case when p.rarity = 'uncommon' then 1 else 0 end) as uncommon,
 sum(case when p.rarity = 'rare' then 1 else 0 end) as rare,
 sum(case when p.rarity = 'legendary' then 1 else 0 end) as legendary,
 sum(case when p.rarity = 'mythic' then 1 else 0 end) as mythic,
 count(*) as planet_count
from planets p
 join vw_planet_owners po on p.planet_id = po.planet_id
group by 1,2,3;

-- planet owners + gen rarity list stats
create or replace view vw_planet_owner_gen_rarity_list_stats as
select
 po.owner,
 po.owner_o,
 p.generation,
 p.rarity,
 count(*) as planet_count
from planets p
 join vw_planet_owners po on p.planet_id = po.planet_id
group by 1,2,3,4;

-- planet owners + type pivot stats
create or replace view vw_planet_owner_type_pivot_stats as
select
 po.owner,
 po.owner_o,
 sum(case when p.type = 'terrestrial' then 1 else 0 end) as terrestrial,
 sum(case when p.type = 'dust' then 1 else 0 end) as dust,
 sum(case when p.type = 'ocean' then 1 else 0 end) as ocean,
 sum(case when p.type = 'lava' then 1 else 0 end) as lava,
 sum(case when p.type = 'ice' then 1 else 0 end) as ice,
 sum(case when p.type = 'gas' then 1 else 0 end) as gas,
 sum(case when p.type = 'exotic' then 1 else 0 end) as exotic,
 sum(case when p.type = 'rogue' then 1 else 0 end) as rogue,
 count(*) as planet_count
from planets p
 join vw_planet_owners po on p.planet_id = po.planet_id
group by 1,2;

-- planet owners + type list stats
create or replace view vw_planet_owner_type_list_stats as
select
 po.owner,
 po.owner_o,
 p.type,
 count(*) as planet_count
from planets p
 join vw_planet_owners po on p.planet_id = po.planet_id
group by 1,2,3;

-- planets per region and sector
create or replace view vw_planet_region_sector_stats as
select
 region,
 sector,
 count(*) as planet_count
from planets
group by 1,2;

-- planet specials - generic stats
create or replace view vw_planet_gen_special_stats as
select
 p.generation,
 ps.name as special_name,
 count(*) as special_count
from planets p
 join planet_specials ps on p.planet_id = ps.planet_id
group by 1,2;

-- planet specials - pivot
create or replace view vw_planet_specials as
select
 planet_id,
 max(case when right(id::varchar(20), 1) = '1' then name else '' end) as special_1,
 max(case when right(id::varchar(20), 1) = '2' then name else '' end) as special_2,
 max(case when right(id::varchar(20), 1) = '3' then name else '' end) as special_3,
 max(case when right(id::varchar(20), 1) = '4' then name else '' end) as special_4,
 max(case when right(id::varchar(20), 1) = '5' then name else '' end) as special_5,
 max(case when right(id::varchar(20), 1) = '6' then name else '' end) as special_6
from planet_specials
group by 1;

-- planet upgrades - pivot
create or replace view vw_planet_upgrades as
select
 planet_id,
 max(case when right(rn::varchar(10), 1) = '1' then upgrade_slot_type else '' end) as upgrade_slot_type_1,
 max(case when right(rn::varchar(10), 1) = '1' then upgrade_name else '' end) as upgrade_name_1,
 max(case when right(rn::varchar(10), 1) = '2' then upgrade_slot_type else '' end) as upgrade_slot_type_2,
 max(case when right(rn::varchar(10), 1) = '2' then upgrade_name else '' end) as upgrade_name_2,
 max(case when right(rn::varchar(10), 1) = '3' then upgrade_slot_type else '' end) as upgrade_slot_type_3,
 max(case when right(rn::varchar(10), 1) = '3' then upgrade_name else '' end) as upgrade_name_3,
 max(case when right(rn::varchar(10), 1) = '4' then upgrade_slot_type else '' end) as upgrade_slot_type_4,
 max(case when right(rn::varchar(10), 1) = '4' then upgrade_name else '' end) as upgrade_name_4,
 max(case when right(rn::varchar(10), 1) = '5' then upgrade_slot_type else '' end) as upgrade_slot_type_5,
 max(case when right(rn::varchar(10), 1) = '5' then upgrade_name else '' end) as upgrade_name_5,
 max(case when right(rn::varchar(10), 1) = '6' then upgrade_slot_type else '' end) as upgrade_slot_type_6,
 max(case when right(rn::varchar(10), 1) = '6' then upgrade_name else '' end) as upgrade_name_6,
 max(case when right(rn::varchar(10), 1) = '7' then upgrade_slot_type else '' end) as upgrade_slot_type_7,
 max(case when right(rn::varchar(10), 1) = '7' then upgrade_name else '' end) as upgrade_name_7,
 max(case when right(rn::varchar(10), 1) = '8' then upgrade_slot_type else '' end) as upgrade_slot_type_8,
 max(case when right(rn::varchar(10), 1) = '8' then upgrade_name else '' end) as upgrade_name_8,
 max(case when right(rn::varchar(10), 1) = '9' then upgrade_slot_type else '' end) as upgrade_slot_type_9,
 max(case when right(rn::varchar(10), 1) = '9' then upgrade_name else '' end) as upgrade_name_9,
 max(case when right(rn::varchar(10), 1) = '10' then upgrade_slot_type else '' end) as upgrade_slot_type_10,
 max(case when right(rn::varchar(10), 1) = '10' then upgrade_name else '' end) as upgrade_name_10
from (
    select
     row_number() over (partition by planet_id order by upgrade_slot_id) as rn,
     planet_id,
     upgrade_slot_type,
     upgrade_name
    from planet_upgrades
 ) t
group by 1;

-- planet collectibles - pivot
create or replace view vw_planet_collectibles as
select
 planet_id,
 max(case when type = 'artwork' then name else '' end) as artwork,
 max(case when type = 'music' then name else '' end) as music,
 max(case when type = 'lore' then name else '' end) as lore
from planet_collectibles
group by 1;

-- planet specials - user totals
create or replace view vw_planet_owner_special_stats as
select
 po.owner,
 po.owner_o,
 ps.name as special_name,
 count(*) as special_total
from vw_planet_owners po
 join planet_specials ps on po.planet_id = ps.planet_id
group by 1,2,3;

-- planet specials - list per address
create or replace view vw_planet_owner_specials as
select
 po.owner,
 po.owner_o,
 po.planet_id,
 p.name as planet_name,
 ps.special_1,
 ps.special_2,
 ps.special_3,
 ps.special_4,
 ps.special_5,
 ps.special_6
from vw_planet_owners po
 join vw_planet_specials ps on po.planet_id = ps.planet_id
 join planets p on ps.planet_id = p.planet_id;

-- planet upgrades - list per address
create or replace view vw_planet_owner_upgrades as
select
 po.owner,
 po.owner_o,
 po.planet_id,
 p.name as planet_name,
 pu.upgrade_slot_type_1,
 pu.upgrade_name_1,
 pu.upgrade_slot_type_2,
 pu.upgrade_name_2,
 pu.upgrade_slot_type_3,
 pu.upgrade_name_3,
 pu.upgrade_slot_type_4,
 pu.upgrade_name_4,
 pu.upgrade_slot_type_5,
 pu.upgrade_name_5,
 pu.upgrade_slot_type_6,
 pu.upgrade_name_6,
 pu.upgrade_slot_type_7,
 pu.upgrade_name_7,
 pu.upgrade_slot_type_8,
 pu.upgrade_name_8,
 pu.upgrade_slot_type_9,
 pu.upgrade_name_9,
 pu.upgrade_slot_type_10,
 pu.upgrade_name_10
from vw_planet_owners po
 join vw_planet_upgrades pu on po.planet_id = pu.planet_id
 join planets p on pu.planet_id = p.planet_id;

-- planet upgrades with suggestions
create or replace view vw_planet_owner_upgrades_suggested as
select
 po.owner,
 po.owner_o,
 po.planet_id,
 p.name as planet_name,
 concat('<a href="', p.external_link, '" target="_blank" >', p.name, '</a>') as planet_link,
 p.type as planet_type,
 pu.upgrade_slot_type,
 pu.upgrade_name,
 u.upgrade_type,
 u.upgrade_effect,
 u.upgrade_by_units,
 su.upgrade_name as suggested_upgrade_name,
 su.upgrade_by_units as suggested_upgrade_by_units
from vw_planet_owners po
 join planets p on po.planet_id = p.planet_id
 join planet_upgrades pu on po.planet_id = pu.planet_id
 left join upgrades u
   on p.type = u.planet_type
  and pu.upgrade_slot_type = u.upgrade_slot_type
  and pu.upgrade_name = u.upgrade_name
 left join lateral (
    select
     up.upgrade_name,
     up.upgrade_by_units
    from upgrades up
    where u.planet_type = up.planet_type
     and u.upgrade_slot_type = up.upgrade_slot_type
     and u.upgrade_type = up.upgrade_type
     and u.upgrade_effect = up.upgrade_effect
     and u.upgrade_by_units < up.upgrade_by_units
    order by up.upgrade_by_units
    limit 1
  ) su on true;

-- collectibles - list
create or replace view vw_collectibles as
select distinct p.generation, pc.collection_id, pc.type, pc.name, pc.title, pc.author, pc.pieces, pc.total_copies
from planet_collectibles pc
 join planets p on pc.planet_id = p.planet_id;

-- planet owner - collectible list
create or replace view vw_planet_owner_collectibles as
select
 po.owner,
 po.owner_o,
 po.planet_id,
 p.generation,
 p.name as planet_name,
 concat('<a href="', p.external_link, '" target="_blank" >', p.name, '</a>') as planet_link,
 pc.collection_id,
 pc.type,
 pc.name,
 pc.title,
 pc.author,
 pc.pieces,
 pc.total_copies,
 pc.item_number,
 pc.copy_number,
 pc.collectible_image,
 concat('"', pc.name, '" (Part ', ltrim(to_char(pc.item_number, 'RN')), ') #', pc.copy_number, ' out of ', pc.total_copies, ' copies') as collectible_description
from vw_planet_owners po
 join planets p on po.planet_id = p.planet_id
 join planet_collectibles pc on p.planet_id = pc.planet_id;

-- planets overview per address
create or replace view vw_planet_owner_overview as
select
 po.owner,
 po.owner_o,
 p.planet_id,
 p.generation,
 p.sector,
 p.region,
 p.name as planet_name,
 concat('<a href="', p.external_link, '" target="_blank" >', p.name, '</a>') as planet_link,
 p.type,
 p.rarity,
 p.credits,
 p.industry,
 p.research,
 coalesce(ps.special_1, '') as special_1,
 coalesce(ps.special_2, '') as special_2,
 coalesce(ps.special_3, '') as special_3,
 coalesce(ps.special_4, '') as special_4,
 coalesce(ps.special_5, '') as special_5,
 pu.upgrade_slot_type_1,
 pu.upgrade_name_1,
 pu.upgrade_slot_type_2,
 pu.upgrade_name_2,
 pu.upgrade_slot_type_3,
 pu.upgrade_name_3,
 pu.upgrade_slot_type_4,
 pu.upgrade_name_4,
 pu.upgrade_slot_type_5,
 pu.upgrade_name_5,
 pu.upgrade_slot_type_6,
 pu.upgrade_name_6,
 pu.upgrade_slot_type_7,
 pu.upgrade_name_7,
 pu.upgrade_slot_type_8,
 pu.upgrade_name_8,
 pu.upgrade_slot_type_9,
 pu.upgrade_name_9,
 pu.upgrade_slot_type_10,
 pu.upgrade_name_10,
 coalesce(pc.artwork, '') as artwork,
 coalesce(pc.music, '') as music,
 coalesce(pc.lore, '') as lore,
 concat('<a href="', p.image, '" target="_blank" >', p.name, '.png</a>') as image_url
from vw_planet_owners po
 join planets p on po.planet_id = p.planet_id
 left join vw_planet_specials ps on p.planet_id = ps.planet_id
 left join vw_planet_upgrades pu on p.planet_id = pu.planet_id
 left join vw_planet_collectibles pc on p.planet_id = pc.planet_id;

-- planet fun facts
create or replace view vw_planet_owner_fun_facts as
with ff_cte as (
  select
   po.owner,
   po.owner_o,
   concat('<a href="', p.external_link, '" target="_blank" >', p.name, '</a>') as planet_link,
   p.moons,
   row_number() over (partition by po.owner order by p.moons desc) as rn_moon,
   p.temperature,
   row_number() over (partition by po.owner order by p.temperature) as rn_temp_low,
   row_number() over (partition by po.owner order by p.temperature desc) as rn_temp_high,
   p.radius,
   row_number() over (partition by po.owner order by p.radius desc) as rn_radius,
   p.mass,
   row_number() over (partition by po.owner order by p.mass::numeric(50,5) desc) as rn_mass,
   p.gravity,
   row_number() over (partition by po.owner order by p.gravity::numeric(30,5) desc) as rn_gravity
  from vw_planet_owners po
   join planets p on po.planet_id = p.planet_id
)
select 1 as rn, owner, owner_o, concat('most moons - ', planet_link, ': ', moons) as description from ff_cte where rn_moon = 1 union
select 2, owner, owner_o, concat('lowest temp on ', planet_link, ': ', temperature, '°C') from ff_cte where rn_temp_low = 1 union
select 3, owner, owner_o, concat('highest temp on ', planet_link, ': ', temperature, '°C') from ff_cte where rn_temp_high = 1 union
select 4, owner, owner_o, concat('largest radius - ', planet_link, ': ', radius, 'km') from ff_cte where rn_radius = 1 union
select 5, owner, owner_o, concat('biggest mass - ', planet_link, ': ', mass, 'kg') from ff_cte where rn_mass = 1 union
select 6, owner, owner_o, concat('greatest gravity - ', planet_link, ': ', gravity, 'm/s^2') from ff_cte where rn_gravity = 1;

-- planet surveying - totals
create or replace view vw_planet_owner_deposit_discovered_stats as
select
 po.owner,
 po.owner_o,
 pdd.material_rarity,
 pdd.item_name,
 count(*) as total_count,
 sum(pdd.total_amount) as total_amount,
 sum(pdd.prepared_amount) as prepared_amount,
 sum(pdd.extracted_amount) as extracted_amount,
 sum(pdd.preparable_amount) as preparable_amount,
 sum(pdd.extractable_amount) as extractable_amount
from vw_planet_owners po
 join planets p on po.planet_id = p.planet_id
 join planet_deposits pd on p.planet_id = pd.planet_id
 join planet_deposits_discovered pdd on pd.planet_layer_id = pdd.planet_layer_id
group by 1,2,3,4;

-- planet surveying - discovered vs undiscovered
create or replace view vw_planet_deposit_stats as
select
 p.generation,
 pd.layer_number,
 s.size,
 sum(case when pdd.planet_layer_id is not null then 1 else 0 end) as discovered_count,
 sum(case when pdd.planet_layer_id is null then 1 else 0 end) as undiscovered_count,
 count(*) - case when p.generation = 'GEN-0' then 1100 when p.generation = 'GEN-1' then 5000 else 0 end as extras_total,
 count(*) as grand_total
from planets p
 join planet_deposits pd on p.planet_id = pd.planet_id
 cross join (
    select 1, 'small' union
    select 2, 'medium' union
    select 3, 'large'
  ) s (rn, size)
 left join (
    select
     planet_id,
     planet_layer_id,
     item_name,
     material_rarity,
     total_amount,
     prepared_amount,
     extracted_amount,
     preparable_amount,
     extractable_amount,
     case
       when total_amount < 2000 then 'small'
       when total_amount >= 2000 and total_amount < 4000 then 'medium'
       when total_amount >= 4000 then 'large'
     end as size
    from planet_deposits_discovered
 ) pdd on pd.planet_layer_id = pdd.planet_layer_id and s.size = pdd.size
group by p.generation, pd.layer_number, s.size, s.rn;

-- planet surveying - list
create or replace view vw_planet_owner_deposits_overview as
select
 po.owner,
 po.owner_o,
 p.planet_id,
 p.generation,
 p.name as planet_name,
 pd.layer_number,
 s.size,
 pdd.item_name,
 pdd.total_amount,
 pdd.prepared_amount,
 pdd.extracted_amount,
 pdd.preparable_amount,
 pdd.extractable_amount
from vw_planet_owners po
 join planets p on po.planet_id = p.planet_id
 join planet_deposits pd on p.planet_id = pd.planet_id
 cross join (
    select 1, 'small' union
    select 2, 'medium' union
    select 3, 'large'
  ) s (rn, size)
 left join (
    select
     planet_id,
     planet_layer_id,
     item_name,
     material_rarity,
     total_amount,
     prepared_amount,
     extracted_amount,
     preparable_amount,
     extractable_amount,
     case
       when total_amount < 2000 then 'small'
       when total_amount >= 2000 and total_amount < 4000 then 'medium'
       when total_amount >= 4000 then 'large'
     end as size
    from planet_deposits_discovered
 ) pdd on pd.planet_layer_id = pdd.planet_layer_id and s.size = pdd.size;

-- materials - list
create or replace view vw_material_list as
select distinct
 item_id,
 material_rarity,
 item_name as material_name
from planet_deposits_discovered;

-- probes
create or replace view vw_planet_owner_deposit_probes_stats as
with cte_probes as (
    select
     po.owner,
     po.owner_o,
     p.id as probe_rn,
     p.material_rarity,
     p.item_name as material_name,
     p.workshop,
     p.probe,
     p.build_time,
     sum(case when total_amount < 2000 then 1 else 0 end) as in_s,
     sum(case when total_amount >= 2000 and total_amount < 4000 then 1 else 0 end) as in_m,
     sum(case when total_amount >= 4000 then 1 else 0 end) as in_l,
     count(*) as in_total,
     sum(total_amount) as discovered_total,
     sum(prepared_amount) as prepared_total,
     sum(extracted_amount) as extracted_total
    from probes p
     join planet_deposits_discovered pdd on p.item_id = pdd.item_id
     join vw_planet_owners po on pdd.planet_id = po.planet_id
    group by 1,2,3,4,5,6,7,8
)
select
 owner, owner_o,
 probe_rn, material_rarity, material_name, workshop, probe, build_time,
 in_s, in_m, in_l, in_total,
 in_s * 5 as need_s,
 in_m * 8 as need_m,
 in_l * 10 as need_l,
 in_s * 5 + in_m * 8 + in_l * 10 as need_total,
 (in_s * 5 + in_m * 8 + in_l * 10) * build_time as build_time_total,
 discovered_total, prepared_total, extracted_total
from cte_probes;
