create table if not exists probes (
    id integer not null constraint pk_probes primary key,
    item_id smallint not null,
    material_rarity varchar(30) not null,
    item_name varchar(50) not null,
    workshop varchar(10) not null,
    probe varchar(10) not null, 
    build_time time not null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp null
);

insert into probes(id, item_id, material_rarity, item_name, workshop, probe, build_time)
select t.id, t.item_id, t.material_rarity, t.item_name, t.workshop, t.probe, t.build_time::time
from (select distinct item_id, material_rarity, item_name from planet_deposits_discovered) pdd
 join (
    select 1, 42, 'Abundant', 'Base Minerals', 'Cat-A1', 'Ba-PL1', '02:00' union
    select 2, 105, 'Abundant', 'Silicates', 'Cat-A1', 'Si-PL1', '02:00' union
    select 3, 106, 'Abundant', 'Elastomers', 'Cat-A2', 'El-PL1', '02:00' union
    select 4, 107, 'Abundant', 'H2O', 'Cat-A2', 'Ho-PL1', '02:00' union
    select 5, 109, 'Common', 'Titanium', 'Cat-C1', 'TP-PL1', '05:48' union
    select 6, 40, 'Common', 'Polymetals', 'Cat-C1', 'TP-PL1', '05:48' union
    select 7, 115, 'Common', 'Nanofluids', 'Cat-C1', 'NP-PL1', '05:48' union
    select 8, 110, 'Common', 'Plutonium', 'Cat-C1', 'NP-PL1', '05:48' union
    select 9, 113, 'Common', 'Aerogens', 'Cat-C2', 'OA-PL1', '05:42' union
    select 10, 52, 'Common', 'Organic Compounds', 'Cat-C2', 'OA-PL1', '05:42' union
    select 11, 114, 'Common', 'Ectopolymers', 'Cat-C2', 'AE-PL1', '05:42' union
    select 12, 112, 'Common', 'Amphoteric Substances', 'Cat-C2', 'AE-PL1', '05:42' union
    select 13, 123, 'Uncommon', 'Neolysium', 'Cat-U1', 'PN-PL1', '09:18' union
    select 14, 118, 'Uncommon', 'Platinyx', 'Cat-U1', 'PN-PL1', '09:18' union
    select 15, 117, 'Uncommon', 'Yprasium', 'Cat-U1', 'YN-PL1', '08:54' union
    select 16, 119, 'Uncommon', 'Novis Compounds', 'Cat-U1', 'YN-PL1', '08:54' union
    select 17, 120, 'Uncommon', 'Metamagnetic Ore', 'Cat-U2', 'MH-PL1', '09:36' union
    select 18, 121, 'Uncommon', 'Hypoatomic Substances', 'Cat-U2', 'MH-PL1', '09:36' union
    select 19, 41, 'Uncommon', 'Xensium', 'Cat-U2', 'HX-PL1', '09:36' union
    select 20, 54, 'Uncommon', 'Hyperspecular Crystals', 'Cat-U2', 'HX-PL1', '09:36' union
    select 21, 126, 'Rare', 'Bruma Particles', 'Cat-R1', 'Bp-PL1', '10:18' union
    select 22, 53, 'Rare', 'Ignis Ore', 'Cat-R1', 'Io-PL1', '11:30' union
    select 23, 127, 'Rare', 'Microorganisms', 'Cat-R2', 'Mi-PL1', '11:42' union
    select 24, 128, 'Rare', 'Tchaikovium', 'Cat-R2', 'Tc-PL1', '11:24'
 ) t (id, item_id, material_rarity, item_name, workshop, probe, build_time) on pdd.item_id = t.item_id
--where pdd.item_name != t.item_name
order by t.id;
