create or replace view vw_item_order_history as
with created_orders as (
  select
   t.tx_id,
   to_timestamp(t.timestamp/1000000)::timestamp as block_dt,
   t.data_method,
   t.from_address as address,
   te.amount_1::int as order_id,
   td.token_id,
   td.params__price::numeric(30,2) as unit_price,
   td.params__amount::int as amount,
   t.tx_hash
  from trxn t
   join trxn_data td on t.tx_id = td.tx_data_id
   join trxn_events te on td.tx_hash = te.tx_hash
  where t.to_address = 'cx85954d0dae92b63bf5cba03a59ca4ffe687bad0a' -- multitoken
   and ((t.data_method = 'createbuyorder' and te.indexed like '%CreateBuyOrder%')
     or (t.data_method = 'createsellorder' and te.indexed like '%CreateSellOrder%'))
), cancelled_orders as (
  select
   t.tx_id,
   to_timestamp(t.timestamp/1000000)::timestamp as block_dt,
   t.data_method,
   t.from_address as address,
   td.params__order_id::int as order_id,
   t.tx_hash
  from trxn t
   join trxn_data td on t.tx_id = td.tx_data_id
  where t.to_address = 'cx85954d0dae92b63bf5cba03a59ca4ffe687bad0a' -- multitoken
   and t.data_method = 'cancelorder'
), buy_orders as (
  select
   t.tx_id,
   to_timestamp(t.timestamp/1000000)::timestamp as block_dt,
   t.data_method,
   t.from_address as buyer,
   te.address_1 as seller,
   --te.address_2 as buyer,
   td.params__order_id::int as order_id,
   te.amount_2::int as token_id,
   (te.amount_4::numeric(30,2) / power(10, 18))::numeric(30,2) as unit_price,
   td.params__amount::int as amount,
   t.value::numeric(30,2) as full_price,
   t.tx_hash
  from trxn t
   join trxn_data td on t.tx_id = td.tx_data_id
   join trxn_events te on td.tx_hash = te.tx_hash
  where t.to_address = 'cx85954d0dae92b63bf5cba03a59ca4ffe687bad0a' -- multitoken
   and t.data_method = 'buytokens'
   and te.indexed like '%BuyTokens%'
), sell_orders as (
  select
   t.tx_id,
   to_timestamp(t.timestamp/1000000)::timestamp as block_dt,
   t.data_method,
   t.from_address as seller,
   --te.address_1 as seller,
   te.address_2 as buyer,
   td.params__order_id::int as order_id,
   te.amount_2::int as token_id,
   (te.amount_4::numeric(30,2) / power(10, 18))::numeric(30,2) as unit_price,
   td.params__amount::int as amount,
   (te.amount_4::numeric(30,2) / power(10, 18))::numeric(30,2) * td.params__amount::int as full_price,
   t.tx_hash
  from trxn t
   join trxn_data td on t.tx_id = td.tx_data_id
   join trxn_events te on td.tx_hash = te.tx_hash
  where t.to_address = 'cx85954d0dae92b63bf5cba03a59ca4ffe687bad0a' -- multitoken
   and t.data_method = 'selltokens'
   and te.indexed like '%SellTokens%'
), combined_orders as (
  select
   tx_id,
   block_dt,
   data_method,
   case when data_method = 'createsellorder' then address end as seller,
   case when data_method = 'createbuyorder' then address end as buyer,
   order_id,
   token_id,
   unit_price,
   amount,
   unit_price * amount as full_price,
   tx_hash
  from created_orders
  union all
  select
   tx_id,
   block_dt,
   data_method,
   address as seller,
   address as buyer,
   order_id,
   null as token_id,
   null as unit_price,
   null as amount,
   null as full_price,
   tx_hash
  from cancelled_orders
  union all
  select
   tx_id,
   block_dt,
   data_method,
   seller,
   buyer,
   order_id,
   token_id,
   unit_price,
   amount,
   full_price,
   tx_hash
  from buy_orders
  union all
  select
   tx_id,
   block_dt,
   data_method,
   seller,
   buyer,
   order_id,
   token_id,
   unit_price,
   amount,
   full_price,
   tx_hash
  from sell_orders
)
select
 *,
 concat('<a href="https://tracker.icon.foundation/transaction/', tx_hash, '" target="_blank" >', 'ICON Tracker', '</a>') as tx_link,
 concat('<a href="https://tracker.icon.foundation/transaction/', tx_hash, '" target="_blank" >', tx_hash, '</a>') as tx_hash_link,
 row_number() over (partition by order_id order by tx_id desc) as rn
from combined_orders;

create or replace view vw_item_order_history_details as
select
 ioh.*,
 i.type as item_type,
 i.name as item_name,
 i.type_color as item_type_color,
 i.description as item_description,
 i.flavor_text as item_flavor_text,
 i.effect as item_effect
from vw_item_order_history ioh
 join items i on ioh.token_id = i.item_id;
