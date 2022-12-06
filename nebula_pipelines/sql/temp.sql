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
