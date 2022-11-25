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
),
upgrades as (
  select
   t.tx_id, 
   t.timestamp,
   to_timestamp(t.timestamp/1000000)::timestamp as block_dt,
   td.token_id, 
   t.data_method,
   t.value,
   t.from_address,
   t.to_address,
   t.tx_hash
  from trxn t
   join trxn_data td on t.tx_id = td.tx_data_id
  where t.to_address = 'hxd46d44827c10876ee8c5464d7882205d6c3a492f' -- PN team special wallet
   and t.data_method = 'upgrade_ship'
   and t.tx_hash != '0x112540175c5b44bfebf2a5ad12f7c720931e88a6fe3d9c413d964fe187d8aa92' -- ship_id=1969 upgraded twice somehow
)
select
 t.tx_id,
 t.timestamp,
 t.block_dt,
 t.token_id as ship_id,
 'auction' as trade_type,
 t.create_auction_address as seller,
 t.prev_address as buyer,
 t.prev_value as price,
 t.tx_hash,
 concat('<a href="https://tracker.icon.foundation/transaction/', t.tx_hash, '" target="_blank" >', t.tx_hash, '</a>') as tx_hash_link,
 u.block_dt as upgraded_dt
from auction t
 left join upgrades u on t.token_id = u.token_id
where t.data_method = 'finalize_auction'
union all
select
 t.tx_id,
 t.timestamp,
 t.block_dt,
 t.token_id as ship_id,
 'set price' as trade_type,
 t.prev_address as seller,
 t.from_address as buyer,
 t.value as price,
 t.tx_hash,
 concat('<a href="https://tracker.icon.foundation/transaction/', t.tx_hash, '" target="_blank" >', t.tx_hash, '</a>') as tx_hash_link,
 u.block_dt as upgraded_dt
from set_price t
 left join upgrades u on t.token_id = u.token_id
where t.data_method = 'purchase_token'
 and coalesce(t.value, 0) != 0
union all
select
 t.tx_id,
 t.timestamp,
 t.block_dt,
 t.token_id as ship_id,
 'ship upgrade' as trade_type,
 t.to_address as seller,
 t.from_address as buyer,
 t.value as price,
 t.tx_hash,
 concat('<a href="https://tracker.icon.foundation/transaction/', t.tx_hash, '" target="_blank" >', t.tx_hash, '</a>') as tx_hash_link,
 t.block_dt as upgraded_dt
from upgrades t
where t.data_method = 'upgrade_ship';

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
 case
   when s.model_name = 'Lunaris Zethus' and st.block_dt < st.upgraded_dt then 'Zethus'
   when s.model_name = 'Aethon Illex' and st.block_dt < st.upgraded_dt then 'Illex'
   when s.model_name = 'Vanguard Chrysalis' and st.block_dt < st.upgraded_dt then 'Chrysalis'
   else s.model_name
 end::varchar(100) as model_name,
 concat('<a href="', s.external_link, '" target="_blank" >', s.model_name, '</a>') as ship_link,
 s.type,
 case
   when s.model_name in ('Lunaris Zethus', 'Aethon Illex', 'Vanguard Chrysalis') and st.block_dt < st.upgraded_dt then 'I'
   else s.tier
 end::varchar(10) as tier,
 s.set_type,
 case
   when s.model_name in ('Lunaris Zethus', 'Aethon Illex', 'Vanguard Chrysalis') and st.block_dt < st.upgraded_dt then s.fuel - 100
   else s.fuel
 end::smallint as fuel,
 case
   when s.model_name = 'Lunaris Zethus' and st.block_dt < st.upgraded_dt then s.movement - 1
   else s.movement
 end::smallint as movement,
 case
   when s.model_name = 'Aethon Illex' and st.block_dt < st.upgraded_dt then s.exploration - 1
   else s.exploration
 end::smallint as exploration,
 case
   when s.model_name = 'Vanguard Chrysalis' and st.block_dt < st.upgraded_dt then s.colonization - 1
   else s.colonization
 end::smallint as colonization,
 st.tx_hash,
 st.tx_hash_link
from vw_ship_trades st
 join ships s on st.ship_id = s.ship_id;
