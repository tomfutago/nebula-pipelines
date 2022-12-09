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
