-- planet owners + total count
select
 concat(substring(po.owner, 1, 8), '..', substring(po.owner, 34, 24)) as owner,
 count(*) as planet_count
from planets p
 join planet_owners po on p.planet_id = po.planet_id
group by 1
order by 2 desc;

-- planet owners + total count per rarity
select
 concat(substring(po.owner, 1, 8), '..', substring(po.owner, 34, 24)) as owner,
 sum(case when p.rarity = 'common' then 1 else 0 end) as common,
 sum(case when p.rarity = 'uncommon' then 1 else 0 end) as uncommon,
 sum(case when p.rarity = 'rare' then 1 else 0 end) as rare,
 sum(case when p.rarity = 'legendary' then 1 else 0 end) as legendary,
 sum(case when p.rarity = 'mythic' then 1 else 0 end) as mythic,
 count(*) as planet_count
from planets p
 join planet_owners po on p.planet_id = po.planet_id
group by 1
order by planet_count desc;

-- planet owners + total count per type
select
 concat(substring(po.owner, 1, 8), '..', substring(po.owner, 34, 24)) as owner,
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
 join planet_owners po on p.planet_id = po.planet_id
group by 1
order by planet_count desc;

-- planets per region and sector
select region, sector, count(*) as planet_count
from planets
group by 1,2
order by 1,2;

-- planet specials - list
select
 ps.planet_id,
 max(case when right(ps.id::varchar(20), 1) = '1' then ps.name end) as special_1,
 max(case when right(ps.id::varchar(20), 1) = '2' then ps.name end) as special_2,
 max(case when right(ps.id::varchar(20), 1) = '3' then ps.name end) as special_3,
 max(case when right(ps.id::varchar(20), 1) = '4' then ps.name end) as special_4,
 max(case when right(ps.id::varchar(20), 1) = '5' then ps.name end) as special_5,
 max(case when right(ps.id::varchar(20), 1) = '6' then ps.name end) as special_6
from planet_owners po
 join planets p on po.planet_id = p.planet_id
 join planet_specials ps on p.planet_id = ps.planet_id
where po.owner = 'hxxxxx'
group by 1;

-- planet specials - user totals
select ps.name, count(*) as special_total
from planet_owners po
 join planets p on po.planet_id = p.planet_id
 join planet_specials ps on p.planet_id = ps.planet_id
where po.owner = 'hxxxxx'
group by 1
order by 1;

-- planet specials
select
 planet_id,
 max(case when right(rn::varchar(10), 1) = '1' then upgrade_slot_type end) as upgrade_slot_type_1,
 max(case when right(rn::varchar(10), 1) = '1' then upgrade_name end) as upgrade_name_1,
 max(case when right(rn::varchar(10), 1) = '2' then upgrade_slot_type end) as upgrade_slot_type_2,
 max(case when right(rn::varchar(10), 1) = '2' then upgrade_name end) as upgrade_name_2,
 max(case when right(rn::varchar(10), 1) = '3' then upgrade_slot_type end) as upgrade_slot_type_3,
 max(case when right(rn::varchar(10), 1) = '3' then upgrade_name end) as upgrade_name_3,
 max(case when right(rn::varchar(10), 1) = '4' then upgrade_slot_type end) as upgrade_slot_type_4,
 max(case when right(rn::varchar(10), 1) = '4' then upgrade_name end) as upgrade_name_4,
 max(case when right(rn::varchar(10), 1) = '5' then upgrade_slot_type end) as upgrade_slot_type_5,
 max(case when right(rn::varchar(10), 1) = '5' then upgrade_name end) as upgrade_name_5,
 max(case when right(rn::varchar(10), 1) = '6' then upgrade_slot_type end) as upgrade_slot_type_6,
 max(case when right(rn::varchar(10), 1) = '6' then upgrade_name end) as upgrade_name_6,
 max(case when right(rn::varchar(10), 1) = '7' then upgrade_slot_type end) as upgrade_slot_type_7,
 max(case when right(rn::varchar(10), 1) = '7' then upgrade_name end) as upgrade_name_7,
 max(case when right(rn::varchar(10), 1) = '8' then upgrade_slot_type end) as upgrade_slot_type_8,
 max(case when right(rn::varchar(10), 1) = '8' then upgrade_name end) as upgrade_name_8,
 max(case when right(rn::varchar(10), 1) = '9' then upgrade_slot_type end) as upgrade_slot_type_9,
 max(case when right(rn::varchar(10), 1) = '9' then upgrade_name end) as upgrade_name_9,
 max(case when right(rn::varchar(10), 1) = '10' then upgrade_slot_type end) as upgrade_slot_type_10,
 max(case when right(rn::varchar(10), 1) = '10' then upgrade_name end) as upgrade_name_10
from (
    select
     row_number() over (partition by pu.planet_id order by pu.upgrade_slot_id) as rn,
     pu.planet_id,
     pu.upgrade_slot_type,
     pu.upgrade_name
    from planet_owners po
     join planets p on po.planet_id = p.planet_id
     join planet_upgrades pu on p.planet_id = pu.planet_id
    where po.owner = 'hxxxxx'
  ) t
group by 1;

-- planet collectibles
select
 pc.planet_id,
 max(case when pc.type = 'artwork' then pc.name end) as artwork,
 max(case when pc.type = 'music' then pc.name end) as music,
 max(case when pc.type = 'lore' then pc.name end) as lore
from planet_owners po
 join planets p on po.planet_id = p.planet_id
 join planet_collectibles pc on p.planet_id = pc.planet_id
where po.owner = 'hxxxxx'
group by 1;

-- planets overview per address
select
 p.planet_id,
 generation,
 sector,
 region,
 name,
 type,
 rarity,
 credits,
 industry,
 research,
 special_1,
 special_2,
 special_3,
 special_4,
 special_5,
 upgrade_slot_type_1,
 upgrade_name_1,
 upgrade_slot_type_2,
 upgrade_name_2,
 upgrade_slot_type_3,
 upgrade_name_3,
 upgrade_slot_type_4,
 upgrade_name_4,
 upgrade_slot_type_5,
 upgrade_name_5,
 upgrade_slot_type_6,
 upgrade_name_6,
 upgrade_slot_type_7,
 upgrade_name_7,
 upgrade_slot_type_8,
 upgrade_name_8,
 upgrade_slot_type_9,
 upgrade_name_9,
 upgrade_slot_type_10,
 upgrade_name_10,
 artwork,
 music,
 lore,
 image,
 external_link
from planet_owners po
 join planets p on po.planet_id = p.planet_id
 left join (     
    select
     planet_id,
     max(case when right(id::varchar(20), 1) = '1' then name end) as special_1,
     max(case when right(id::varchar(20), 1) = '2' then name end) as special_2,
     max(case when right(id::varchar(20), 1) = '3' then name end) as special_3,
     max(case when right(id::varchar(20), 1) = '4' then name end) as special_4,
     max(case when right(id::varchar(20), 1) = '5' then name end) as special_5,
     max(case when right(id::varchar(20), 1) = '6' then name end) as special_6
    from planet_specials
    group by 1
  ) ps on p.planet_id = ps.planet_id
 left join (
    select
     planet_id,
     max(case when right(rn::varchar(10), 1) = '1' then upgrade_slot_type end) as upgrade_slot_type_1,
     max(case when right(rn::varchar(10), 1) = '1' then upgrade_name end) as upgrade_name_1,
     max(case when right(rn::varchar(10), 1) = '2' then upgrade_slot_type end) as upgrade_slot_type_2,
     max(case when right(rn::varchar(10), 1) = '2' then upgrade_name end) as upgrade_name_2,
     max(case when right(rn::varchar(10), 1) = '3' then upgrade_slot_type end) as upgrade_slot_type_3,
     max(case when right(rn::varchar(10), 1) = '3' then upgrade_name end) as upgrade_name_3,
     max(case when right(rn::varchar(10), 1) = '4' then upgrade_slot_type end) as upgrade_slot_type_4,
     max(case when right(rn::varchar(10), 1) = '4' then upgrade_name end) as upgrade_name_4,
     max(case when right(rn::varchar(10), 1) = '5' then upgrade_slot_type end) as upgrade_slot_type_5,
     max(case when right(rn::varchar(10), 1) = '5' then upgrade_name end) as upgrade_name_5,
     max(case when right(rn::varchar(10), 1) = '6' then upgrade_slot_type end) as upgrade_slot_type_6,
     max(case when right(rn::varchar(10), 1) = '6' then upgrade_name end) as upgrade_name_6,
     max(case when right(rn::varchar(10), 1) = '7' then upgrade_slot_type end) as upgrade_slot_type_7,
     max(case when right(rn::varchar(10), 1) = '7' then upgrade_name end) as upgrade_name_7,
     max(case when right(rn::varchar(10), 1) = '8' then upgrade_slot_type end) as upgrade_slot_type_8,
     max(case when right(rn::varchar(10), 1) = '8' then upgrade_name end) as upgrade_name_8,
     max(case when right(rn::varchar(10), 1) = '9' then upgrade_slot_type end) as upgrade_slot_type_9,
     max(case when right(rn::varchar(10), 1) = '9' then upgrade_name end) as upgrade_name_9,
     max(case when right(rn::varchar(10), 1) = '10' then upgrade_slot_type end) as upgrade_slot_type_10,
     max(case when right(rn::varchar(10), 1) = '10' then upgrade_name end) as upgrade_name_10
    from (
        select
         row_number() over (partition by planet_id order by upgrade_slot_id) as rn,
         planet_id,
         upgrade_slot_type,
         upgrade_name
        from planet_upgrades
     ) t
    group by 1
  ) pu on p.planet_id = pu.planet_id
 left join (
    select
     planet_id,
     max(case when type = 'artwork' then name end) as artwork,
     max(case when type = 'music' then name end) as music,
     max(case when type = 'lore' then name end) as lore
    from planet_collectibles
    group by 1
 ) pc on p.planet_id = pc.planet_id
where po.owner = 'hxxxxx'
order by p.generation, p.name

-- planet surveying - totals
select
 pdd.material_rarity,
 pdd.item_name,
 count(*) as total_count,
 sum(pdd.total_amount) as total_amount,
 sum(pdd.prepared_amount) as prepared_amount,
 sum(pdd.extracted_amount) as extracted_amount,
 sum(pdd.preparable_amount) as preparable_amount,
 sum(pdd.extractable_amount) as extractable_amount
from planet_owners po
 join planets p on po.planet_id = p.planet_id
 join planet_deposits pd on p.planet_id = pd.planet_id
 join planet_deposits_discovered pdd on pd.planet_layer_id = pdd.planet_layer_id
where po.owner = 'hxxxxx'
group by 1,2
order by 1,2;

-- planet surveying - list
select
 p.planet_id,
 p.generation,
 p.name,
 pd.layer_number,
 s.size,
 pdd.item_name,
 pdd.total_amount,
 pdd.prepared_amount,
 pdd.extracted_amount,
 pdd.preparable_amount,
 pdd.extractable_amount
from planet_owners po
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
 ) pdd on pd.planet_layer_id = pdd.planet_layer_id and s.size = pdd.size
where po.owner = 'hxxxxx'
order by p.generation, p.name, pd.layer_number, s.rn;

