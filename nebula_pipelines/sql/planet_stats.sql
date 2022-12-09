/*
drop view if exists vw_planet_owner_deposits_discovered_stats;
*/

-- planets
create or replace view vw_planets as
select
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
 concat('<a href="', p.image, '" target="_blank" >', p.name, '.png</a>') as image_url
from planets p;

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

-- helper view used in delete_from_planet_deposits_undiscovered function
create or replace view vw_planet_deposits_undiscovered as
select pd.planet_id, pdu.planet_layer_id
from planet_deposits pd
 join planet_deposits_undiscovered pdu on pd.planet_layer_id = pdu.planet_layer_id;

-- planet surveying - totals
create or replace view vw_planet_owner_deposit_stats as
select
 po.owner,
 po.owner_o,
 count(distinct case when pdu.planet_layer_id is not null then pdu.id end) as undiscovered_count,
 count(distinct case when pdd.planet_layer_id is not null then pdd.planet_layer_material_id end) as discovered_count,
 sum(case when pdd.prepared_amount = pdd.total_amount then 1 else 0 end) as prepared_count,
 sum(case when pdd.extracted_amount = pdd.total_amount then 1 else 0 end) as extracted_count
from vw_planet_owners po
 join planets p on po.planet_id = p.planet_id
 join planet_deposits pd on p.planet_id = pd.planet_id
 left join planet_deposits_discovered pdd on pd.planet_layer_id = pdd.planet_layer_id
 left join planet_deposits_undiscovered pdu on pd.planet_layer_id = pdu.planet_layer_id
group by 1,2;

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

create or replace view vw_planet_owner_deposit_undiscovered_stats as
select
 pos.owner,
 pos.owner_o,
 pos.planet_count,
 pd.layer_number,
 pdu.size,
 concat(upper(left(pdu.size,1)), '-L', pd.layer_number) as slot_type,
 pos.planet_count - count(*) as deposits_discovered, -- incorrect, no way to know how many extra deposits discovered per size
 count(*) as deposits_undiscovered
from vw_planet_owner_stats pos
 join vw_planet_owners po on pos.owner = po.owner
 join planets p on po.planet_id = p.planet_id
 join planet_deposits pd on p.planet_id = pd.planet_id
 join planet_deposits_undiscovered pdu on pd.planet_layer_id = pdu.planet_layer_id
group by 1,2,3,4,5,6;

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
 concat('<a href="', p.external_link, '" target="_blank" >', p.name, '</a>') as planet_link,
 p.rarity,
 p.type,
 pd.layer_number,
 coalesce(pdu.size, 'unknown') as size,
 pdd.material_rarity,
 pdd.item_name,
 pdd.total_amount,
 pdd.prepared_amount,
 pdd.extracted_amount,
 pdd.preparable_amount,
 pdd.extractable_amount
from vw_planet_owners po
 join planets p on po.planet_id = p.planet_id
 join planet_deposits pd on p.planet_id = pd.planet_id
 left join planet_deposits_discovered pdd on p.planet_id = pdd.planet_id and pd.planet_layer_id = pdd.planet_layer_id
 left join planet_deposits_undiscovered pdu on pd.planet_layer_id = pdu.planet_layer_id;

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

-- planet trades
create or replace view vw_planet_trades as
with auction as (
  select
   t.tx_id, 
   to_timestamp(t.timestamp/1000000)::timestamp as block_dt,
   td.token_id, 
   t.data_method,
   t.value,
   lead(t.from_address) over (
       partition by
        td.token_id,
        case when t.data_method = 'create_auction' then 'finalize_auction' else t.data_method end
       order by t.tx_id desc
    ) as create_auction_address,
   lead(t.value) over (partition by td.token_id order by t.tx_id desc) as prev_value,
   t.from_address, 
   lead(t.from_address) over (partition by td.token_id order by t.tx_id desc) as prev_address,
   --td.params__starting_price, td.params__duration_in_hours,
   t.tx_hash
  from trxn t
   join trxn_data td on t.tx_id = td.tx_data_id
  where t.to_address = 'cx57d7acf8b5114b787ecdd99ca460c2272e4d9135' -- planets
   and t.data_method in (
      'create_auction', 'place_bid', 'finalize_auction' --, 'return_unsold_item'
    )
),
set_price as (
  select
   t.tx_id, 
   to_timestamp(t.timestamp/1000000)::timestamp as block_dt,
   td.token_id, 
   t.data_method,
   t.value,
   t.from_address, 
   lead(t.from_address) over (partition by td.token_id order by t.tx_id desc) as prev_address,
   --td.params__price,
   t.tx_hash
  from trxn t
   join trxn_data td on t.tx_id = td.tx_data_id
  where t.to_address = 'cx57d7acf8b5114b787ecdd99ca460c2272e4d9135' -- planets
   and t.data_method in (
      'list_token', 'purchase_token' --, 'delist_token'
    )
)
select
 tx_id,
 block_dt,
 token_id as planet_id,
 'auction' as trade_type,
 create_auction_address as seller,
 prev_address as buyer,
 prev_value as price,
 tx_hash,
 concat('<a href="https://tracker.icon.foundation/transaction/', tx_hash, '" target="_blank" >', tx_hash, '</a>') as tx_hash_link
from auction
where data_method = 'finalize_auction'
union all
select
 tx_id,
 block_dt,
 token_id as planet_id,
 'set price' as trade_type,
 prev_address as seller,
 from_address as buyer,
 value as price,
 tx_hash,
 concat('<a href="https://tracker.icon.foundation/transaction/', tx_hash, '" target="_blank" >', tx_hash, '</a>') as tx_hash_link
from set_price
where data_method = 'purchase_token'
 and coalesce(value, 0) != 0;

create or replace view vw_planet_detail_trades as
select
 pt.tx_id,
 pt.block_dt,
 pt.planet_id, 
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
 pt.trade_type,
 pt.seller,
 pt.buyer,
 pt.price,
 pt.tx_hash,
 pt.tx_hash_link
from vw_planet_trades pt
 join planets p on pt.planet_id = p.planet_id;

-- planet marketplace
create or replace view vw_planet_marketplace as
with auction_current_state as (
  select
   t.tx_id, 
   row_number() over (partition by td.token_id order by t.tx_id desc) as rn,
   to_timestamp(t.timestamp/1000000)::timestamp as block_dt,
   td.token_id, 
   t.data_method,
   t.value,
   t.from_address, 
   t.tx_hash
  from trxn t
   join trxn_data td on t.tx_id = td.tx_data_id
  where t.to_address = 'cx57d7acf8b5114b787ecdd99ca460c2272e4d9135' -- planets
   and t.data_method in ('create_auction', 'place_bid', 'finalize_auction', 'return_unsold_item', 'cancel_auction')
), auction_create as (
  select
   t.tx_id, 
   row_number() over (partition by td.token_id order by t.tx_id desc) as rn,
   to_timestamp(t.timestamp/1000000)::timestamp as block_dt,
   td.token_id, 
   t.data_method,
   t.from_address as create_auction_address, 
   td.params__starting_price as starting_price,
   td.params__duration_in_hours as duration_in_hours,
   t.tx_hash
  from trxn t
   join trxn_data td on t.tx_id = td.tx_data_id
  where t.to_address = 'cx57d7acf8b5114b787ecdd99ca460c2272e4d9135' -- planets
   and t.data_method = 'create_auction'
), set_price as (
  select
   t.tx_id, 
   row_number() over (partition by td.token_id order by t.tx_id desc) as rn,
   to_timestamp(t.timestamp/1000000)::timestamp as block_dt,
   td.token_id, 
   t.data_method,
   t.from_address, 
   coalesce(td.params__price::numeric(30,2), t.value::numeric(30,2)) as price,
   t.tx_hash
  from trxn t
   join trxn_data td on t.tx_id = td.tx_data_id
  where t.to_address = 'cx57d7acf8b5114b787ecdd99ca460c2272e4d9135' -- planets
   and t.data_method in ('list_token', 'purchase_token', 'delist_token')
)
select
 acs.block_dt,
 acs.token_id as planet_id,
 acs.data_method,
 ac.create_auction_address,
 ac.starting_price::numeric(30,2) as starting_price,
 ac.duration_in_hours,
 t.time_left_epoch as epoch,
 ac.block_dt + ac.duration_in_hours::int * interval '1 hour' as auction_ends_at,
 concat(
     (t.time_left_epoch / (60*60*24))::text || 'd ',
     ((time_left_epoch % (60*60*24)) / 3600)::text || 'h ',
     (((time_left_epoch % (60*60*24)) % 3600) / 60)::text || 'm ',
     (time_left_epoch % 60)::text || 's'
  ) as time_left,
 acs.from_address,
 case when acs.data_method = 'create_auction' then ac.starting_price::numeric(30,2) else acs.value::numeric(30,2) end price,
 acs.tx_hash,
 concat('<a href="https://tracker.icon.foundation/transaction/', acs.tx_hash, '" target="_blank" >', 'ICON Tracker', '</a>') as tx_link,
 concat('<a href="https://tracker.icon.foundation/transaction/', acs.tx_hash, '" target="_blank" >', acs.tx_hash, '</a>') as tx_hash_link
from auction_current_state acs
 join auction_create ac on acs.token_id = ac.token_id
 left join lateral (
     select 
      age(ac.block_dt + ac.duration_in_hours::int * interval '1 hour', current_timestamp) as time_left,
      extract(epoch from ac.block_dt + ac.duration_in_hours::int * interval '1 hour' - current_timestamp)::bigint as time_left_epoch
 ) t on true
where acs.rn = 1
 and acs.data_method in ('create_auction', 'place_bid')
 and ac.rn = 1
 and t.time_left_epoch > 0
union all
select
 block_dt,
 token_id as planet_id,
 data_method,
 null as create_auction_address,
 null as starting_price,
 null as duration_in_hours,
 extract (epoch from block_dt)::bigint as epoch,
 null as auction_ends_at,
 null as time_left,
 from_address,
 price,
 tx_hash,
 concat('<a href="https://tracker.icon.foundation/transaction/', tx_hash, '" target="_blank" >', 'ICON Tracker', '</a>') as tx_link,
 concat('<a href="https://tracker.icon.foundation/transaction/', tx_hash, '" target="_blank" >', tx_hash, '</a>') as tx_hash_link
from set_price
where rn = 1
 and data_method = 'list_token';

create or replace view vw_planet_marketplace_details as
select
 pm.*,
 p.generation,
 p.sector,
 p.region,
 p.name as planet_name,
 concat('<a href="', p.external_link, '" target="_blank" >', p.name, '</a>') as planet_link,
 p.type,
 p.rarity,
 p.credits,
 p.industry,
 p.research
from vw_planet_marketplace pm
 join planets p on pm.planet_id = p.planet_id;

create or replace view vw_planet_marketplace_specials as
select
 pm.*,
 p.generation,
 p.sector,
 p.region,
 p.name as planet_name,
 concat('<a href="', p.external_link, '" target="_blank" >', p.name, '</a>') as planet_link,
 p.type,
 p.rarity,
 ps.name as planet_special
from vw_planet_marketplace pm
 join planets p on pm.planet_id = p.planet_id
 join planet_specials ps on p.planet_id = ps.planet_id;

create or replace view vw_planet_marketplace_collectibles as
select
 pm.*,
 p.generation,
 p.sector,
 p.region,
 p.name as planet_name,
 concat('<a href="', p.external_link, '" target="_blank" >', p.name, '</a>') as planet_link,
 p.type,
 p.rarity,
 pc.collection_id,
 pc.type as collectible_type,
 pc.name as collectible_name,
 pc.title,
 pc.author,
 pc.pieces,
 pc.total_copies,
 pc.item_number,
 pc.copy_number,
 pc.collectible_image,
 concat('"', pc.name, '" (Part ', ltrim(to_char(pc.item_number, 'RN')), ') #', pc.copy_number, ' out of ', pc.total_copies, ' copies') as collectible_description
from vw_planet_marketplace pm
 join planets p on pm.planet_id = p.planet_id
 join planet_collectibles pc on p.planet_id = pc.planet_id;

create or replace view vw_planet_ownership_flow as
select
 t.block_dt,
 po.owner as current_owner,
 t.from_address as to_address,
 t.to_address as from_address,
 'claim - icx' as method,
 -1 * t.value::numeric(20,2) as price,
 p.planet_id, p.generation, p.region, p.sector, p.name, p.rarity,
 concat('<a href="', p.external_link, '" target="_blank" >', p.name, '</a>') as planet_link
from planets p
 join vw_planet_owners po on p.planet_id = po.planet_id
 join vw_trxn t on t.token_id = p.planet_id
where t.to_address = 'cx4bfc45b11cf276bb58b3669076d99bc6b3e4e3b8' -- planet claiming
 and t.data_method = 'claim_token'
union all
select
 t.block_dt,
 po.owner as current_owner,
 tc.address_2 as to_address,
 t.from_address,
 'claim - credits' as method,
 0::numeric(20,2) as price,
 p.planet_id, p.generation, p.region, p.sector, p.name, p.rarity,
 concat('<a href="', p.external_link, '" target="_blank" >', p.name, '</a>') as planet_link
from planets p
 join vw_planet_owners po on p.planet_id = po.planet_id
 join vw_trxn t on t.token_id = p.planet_id
 join trxn_events tc on t.tx_hash = tc.tx_hash
where t.data_method = 'transfer'
 and t.from_address = 'hx888ed0ff5ebc119e586b5f3d4a0ef20eaa0ed123' -- credit claims (non-legendary)
 and tc.indexed like '%Transfer%'
/*
-- covered by trades below
union all
select
 ta.block_dt,
 po.owner as current_owner,
 ta.prev_address as to_address,
 ta.create_auction_address as from_address,
 'auction - 1st post claim' as method,
 -1 * ta.prev_value::numeric(20,2) as price,
 p.planet_id, p.generation, p.region, p.sector, p.name, p.rarity,
 concat('<a href="', p.external_link, '" target="_blank" >', p.name, '</a>') as planet_link
from planets p
 join vw_planet_owners po on p.planet_id = po.planet_id
 join (
   select
    t.token_id, t.block_dt, t.data_method, t.to_address,
    lead(t.value) over (partition by t.token_id order by t.tx_id desc) as prev_value,
    lead(t.from_address) over (partition by t.token_id order by t.tx_id desc) as prev_address,
    lead(t.from_address) over (
       partition by
        t.token_id,
        case when t.data_method = 'create_auction' then 'finalize_auction' else t.data_method end
       order by t.tx_id desc
    ) as create_auction_address,
    row_number() over (partition by t.token_id order by t.tx_id desc) as rn
   from vw_trxn t
   where t.to_address = 'cx57d7acf8b5114b787ecdd99ca460c2272e4d9135' -- planets
    and t.data_method in ('create_auction', 'place_bid', 'finalize_auction')
 ) ta on p.planet_id = ta.token_id
where p.rarity = 'legendary'
 and ta.rn = 1
*/
union all
select
 pdt.block_dt,
 po.owner as current_owner,
 pdt.buyer as to_address,
 pdt.seller as from_address,
 'trade - buy' as method,
 -1 * pdt.price::numeric(20,2) as price,
 pdt.planet_id, pdt.generation, pdt.region, pdt.sector, pdt.planet_name, pdt.rarity,
 pdt.planet_link
from vw_planet_detail_trades pdt
 join vw_planet_owners po on pdt.planet_id = po.planet_id
union all
select
 pdt.block_dt,
 po.owner as current_owner,
 pdt.seller as to_address,
 pdt.buyer as from_address,
 'trade - sell' as method,
 pdt.price::numeric(20,2) as price,
 pdt.planet_id, pdt.generation, pdt.region, pdt.sector, pdt.planet_name, pdt.rarity,
 pdt.planet_link
from vw_planet_detail_trades pdt
 join vw_planet_owners po on pdt.planet_id = po.planet_id;
