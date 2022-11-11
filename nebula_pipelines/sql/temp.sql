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
