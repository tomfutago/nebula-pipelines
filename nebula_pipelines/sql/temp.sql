select table_name from information_schema.views where table_name like 'vw_%' order by 1
select owner, count(*) from vw_planet_owners group by 1 order by 2 desc;

-- owners/supply
select count(distinct owner) as total_owners, count(*) as total_planets
from vw_planet_owners
where owner not in ('cx4bfc45b11cf276bb58b3669076d99bc6b3e4e3b8', 'hx888ed0ff5ebc119e586b5f3d4a0ef20eaa0ed123')

select * from vw_trxn;
select data_method, count(*) from vw_trxn group by 1 order by 1;
select to_address, count(*) from vw_trxn group by 1 order by 2 desc;


select * 
from vw_trxn
where data_method in (
    'create_auction', 'place_bid', 'finalize_auction', 'return_unsold_item', 
    'list_token', 'delist_token', 'purchase_token',
    'createSellOrder', 'createBuyOrder', 'buyTokens', 'sellTokens', 'cancelOrder'
  )
 and to_address in (
    'cx57d7acf8b5114b787ecdd99ca460c2272e4d9135',
    'cx943cf4a4e4e281d82b15ae0564bbdcbf8114b3ec',
    'cx85954d0dae92b63bf5cba03a59ca4ffe687bad0a'
  )
 and block_height = 25828615
;

-- purchase token
select * from trxn_events where block_height = 25828615;



-- test
--create index idx_trxn_events_blockheight_txhash on trxn_events(block_height, tx_hash);

/*
select x'3cc878365ce6bd0000'::bit(18)::bigint
select x'deadbeefdeadbeefdeadbeef'::bit(24)::text;
select x'deadbeef'::bit(16)::bigint;
*/

select t.tx_id, t.block_height, t.data_method, t.value, t.from_address, tr.*
 --count(distinct t.tx_id) as tx_count, count(*) ev_count
from trxn t
 join trxn_data td on t.tx_id = td.tx_data_id
 left join lateral (
   select
    te.indexed,
    split_part(te.indexed, ',', 5) as address,
    trim(trailing '}' from split_part(te.indexed, ',', 6)) as price_hex
    --('x' || lpad(trim(leading '0x' from trim(trailing '}' from split_part(te.indexed, ',', 6))), 32, '0'))::bit(64)::bigint as price_loop
   from trxn_events te
   where t.block_height = te.block_height
    and t.tx_hash = te.tx_hash
    and te.indexed like '%"ICXTransfer(Address,Address,int)"%'
    --and te.indexed like '%"ICXTransfer(Address,Address,int)",cx57d7acf8b5114b787ecdd99ca460c2272e4d9135,cx57d7acf8b5114b787ecdd99ca460c2272e4d9135,%'
  ) a on true
 left join lateral (
   select
    te.indexed,
    split_part(te.indexed, ',', 4) as seller,
    split_part(te.indexed, ',', 5) as buyer
   from trxn_events te
   where t.block_height = te.block_height
    and t.tx_hash = te.tx_hash
    and te.indexed like '%"Transfer(Address,Address,int)"%'
  ) tr on true
where t.to_address = 'cx57d7acf8b5114b787ecdd99ca460c2272e4d9135' -- planets
 and t.data_method in (
    --'create_auction', 'place_bid', 'return_unsold_item', 
    --'list_token', 'delist_token', 
    --'purchase_token'
    'finalize_auction'
  )
order by 1 desc
--group by 1,2
--order by 4 desc
