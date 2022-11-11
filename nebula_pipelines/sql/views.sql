create or replace view vw_unique_owners as
select distinct t.owner
from (
    select owner from planet_owners
    union all
    select owner from ship_owners
 ) t;

-- combined trxn and trxn_data
create or replace view vw_trxn as
select
 t.tx_id, t.block_height, t.timestamp, to_timestamp(t.timestamp/1000000)::timestamp as block_dt,
 t.from_address, t.to_address, t.value, t.data_method,
 td.token_id,
 td.params__to,
 td.params__token_id,
 td.params__token_id_2,
 td.params__order_id,
 td.params__amount,
 td.params__price,
 td.params__starting_price,
 td.params__duration_in_hours,
 td.params__address,
 td.params__token_uri,
 td.params_tx_hash,
 td.params__id,
 td.params__from,
 td.params__value,
 td.params__owner,
 td.params__ids,
 td.params__amounts,
 td.params__transfer_id,
 t.tx_hash
from trxn t
 join trxn_data td on t.tx_id = td.tx_data_id;
