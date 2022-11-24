/*
-- ship types
select generation, model_name, tier, count(*) as ship_count
from ships
group by 1,2,3
order by 1,3,2;

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
*/

-- ship owners
create or replace view vw_ship_owners as
select
 so.owner,
 concat(substring(so.owner, 1, 8), '..', substring(so.owner, 34, 24)) as owner_o,
 s.ship_id,
 s.generation,
 s.model_name,
 concat('<a href="', s.external_link, '" target="_blank" >', s.model_name, '</a>') as ship_link,
 s.type,
 s.tier,
 s.set_type,
 s.fuel,
 s.movement,
 s.exploration,
 s.colonization,
 s.given_name,
 s.description,
 s.bonus_text
from ship_owners so
 join ships s on so.ship_id = s.ship_id;

-- ship trades
create or replace view vw_ship_trades as
with auction as (
  select
   t.tx_id, 
   t.timestamp,
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
  where t.to_address = 'cx943cf4a4e4e281d82b15ae0564bbdcbf8114b3ec' -- ships
   and t.data_method in (
      'create_auction', 'place_bid', 'finalize_auction' --, 'return_unsold_item'
    )
),
set_price as (
  select
   t.tx_id, 
   t.timestamp,
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
  where t.to_address = 'cx943cf4a4e4e281d82b15ae0564bbdcbf8114b3ec' -- ships
   and t.data_method in (
      'list_token', 'purchase_token' --, 'delist_token'
    )
)
select
 tx_id,
 timestamp,
 block_dt,
 token_id as ship_id,
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
 timestamp,
 block_dt,
 token_id as ship_id,
 'set price' as trade_type,
 prev_address as seller,
 from_address as buyer,
 value as price,
 tx_hash,
 concat('<a href="https://tracker.icon.foundation/transaction/', tx_hash, '" target="_blank" >', tx_hash, '</a>') as tx_hash_link
from set_price
where data_method = 'purchase_token'
 and coalesce(value, 0) != 0;

create or replace view vw_ship_detail_trades as
select
 st.tx_id,
 st.timestamp,
 st.block_dt,
 st.ship_id, 
 st.trade_type,
 st.seller,
 st.buyer,
 st.price,
 s.generation,
 s.model_name,
 concat('<a href="', s.external_link, '" target="_blank" >', s.model_name, '</a>') as ship_link,
 s.type,
 s.tier,
 s.set_type,
 s.fuel,
 s.movement,
 s.exploration,
 s.colonization,
 st.tx_hash,
 st.tx_hash_link
from vw_ship_trades st
 join ships s on st.ship_id = s.ship_id;
