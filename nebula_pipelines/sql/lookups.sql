-- ==============================================================================
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

-- ==============================================================================
/*
select
 id,
 planet_type,
 upgrade_slot_type,
 upgrade_id,
 upgrade_name,
 upgrade_description,
 nullif(upgrade_type, 'null') as upgrade_type,
 nullif(upgrade_effect, 'null') as upgrade_effect,
 nullif(upgrade_by_units, 'null') as upgrade_by_units,
 concat(
    'select ', id, ', ', planet_type, ', ', upgrade_slot_type, ', ', upgrade_id, ', ', upgrade_name, ', ', 
    upgrade_description, ', ', upgrade_type, ', ', upgrade_effect, ', ', upgrade_by_units, ' union '
  ) as select_union
from (
    select distinct
     dense_rank() over (order by p.type, pu.upgrade_slot_type, pu.upgrade_id) as id,
     concat('''', p.type, '''') as planet_type,
     concat('''', pu.upgrade_slot_type, '''') as upgrade_slot_type,
     pu.upgrade_id,
     concat('''', pu.upgrade_name, '''') as upgrade_name,
     concat('''', pu.upgrade_description, '''') as upgrade_description,
     case
      when pu.upgrade_description ilike 'increases the credits, industry and research%' then '''all resources'''
      when pu.upgrade_description ilike 'increases%but decreases%' then '''mixed'''
      when pu.upgrade_description ilike 'increases the credits%' or pu.upgrade_description ilike 'increases your maximum credits%' then '''credits'''
      when pu.upgrade_description ilike 'increases the industry%' or pu.upgrade_description ilike 'increases your maximum industry%' then '''industry'''
      when pu.upgrade_description ilike 'increases the research%' then '''research'''
      when pu.upgrade_description ilike '%probe%' then '''workshop'''
      when pu.upgrade_description ilike '%rift%' then '''rift'''
      else 'null'
     end as upgrade_type,
     case
      when pu.upgrade_description ilike '%output%' then '''output'''
      when pu.upgrade_description ilike '%capacity%' then '''capacity'''
      else 'null'
     end as upgrade_effect,
     case
      when position('by ' in pu.upgrade_description) > 0
      then replace(substring(pu.upgrade_description, position('by ' in pu.upgrade_description) + 3, 3), ',', '')
      else 'null'
     end as upgrade_by_units
    from planets p
     join planet_upgrades pu on p.planet_id = pu.planet_id
    where pu.upgrade_name is not null
) t
order by 1;
*/

--drop table if exists upgrades;

create table if not exists upgrades (
    id integer not null constraint pk_upgrades primary key,
    planet_type varchar(20) not null,
    upgrade_slot_type varchar(50) not null,
    upgrade_id integer not null,
    upgrade_name varchar(50) not null,
    upgrade_description varchar(300) not null,
    upgrade_type varchar(30) null,
    upgrade_effect varchar(10) null,
    upgrade_by_units smallint null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp null
);

insert into upgrades(id, planet_type, upgrade_slot_type, upgrade_id, upgrade_name, upgrade_description, upgrade_type, upgrade_effect, upgrade_by_units)
select 1, 'dust', 'basic', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 2, 'dust', 'basic', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 3, 'dust', 'basic', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 4, 'dust', 'basic', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 5, 'dust', 'basic', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 6, 'dust', 'basic', 8, 'Foundational Networks I', 'Increases the Credits, Industry and Research output of this planet by 1', 'all resources', 'output', 1 union 
select 7, 'dust', 'basic', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 8, 'dust', 'basic', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 9, 'dust', 'basic', 40, 'L1 Discovery Probe Workshop', 'Allows you to craft the L1 Discovery Probes', 'workshop', null, null union 
select 10, 'dust', 'basic', 42, 'Category-A1 Probe Workshop', 'Allows you to craft the Ba-PL1 and Si-PL1 Preparation Probes', 'workshop', null, null union 
select 11, 'dust', 'basic', 43, 'Category-A2 Probe Workshop', 'Allows you to craft the El-PL1 and Ho-PL1 Preparation Probes', 'workshop', null, null union 
select 12, 'dust', 'basic', 46, 'Category-U1 Probe Workshop', 'Allows you to craft the PN-PL1 and YN-PL1 Preparation Probes', 'workshop', null, null union 
select 13, 'dust', 'basic', 47, 'Category-U2 Probe Workshop', 'Allows you to craft the MH-PL1 and HX-PL1 Preparation Probes', 'workshop', null, null union 
select 14, 'dust', 'basic', 48, 'Category-R1 Probe Workshop', 'Allows you to craft the Bp-PL1 and Io-PL1 Preparation Probes', 'workshop', null, null union 
select 15, 'dust', 'basic', 49, 'Category-R2 Probe Workshop', 'Allows you to craft the Mi-PL1 and Tc-PL1 Preparation Probes', 'workshop', null, null union 
select 16, 'dust', 'credits', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 17, 'dust', 'credits', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 18, 'dust', 'credits', 12, 'Secure Trade Routes I', 'Increases the Credits output of this planet by 2', 'credits', 'output', 2 union 
select 19, 'dust', 'credits', 13, 'Secure Trade Routes II', 'Increases the Credits output of this planet by 3', 'credits', 'output', 3 union 
select 20, 'dust', 'credits', 14, 'Secure Trade Routes III', 'Increases the Credits output of this planet by 5', 'credits', 'output', 5 union 
select 21, 'dust', 'credits', 26, 'Intergalactic Credit Exchange I', 'Increases your maximum Credits capacity by 30', 'credits', 'capacity', 30 union 
select 22, 'dust', 'credits', 27, 'Intergalactic Credit Exchange II', 'Increases your maximum Credits capacity by 50', 'credits', 'capacity', 50 union 
select 23, 'dust', 'credits', 28, 'Intergalactic Credit Exchange III', 'Increases your maximum Credits capacity by 100', 'credits', 'capacity', 100 union 
select 24, 'dust', 'credits', 30, 'Interplanetary Investment Nexus II', 'Increases the Credits output of this planet by 4, but decreases both Industry and Research output by 1', 'mixed', 'output', 4  union 
select 25, 'dust', 'credits', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 26, 'dust', 'credits', 45, 'Category-C2 Probe Workshop', 'Allows you to craft the OA-PL1 and AE-PL1 Preparation Probes', 'workshop', null, null union 
select 27, 'dust', 'industry', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 28, 'dust', 'industry', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 29, 'dust', 'industry', 15, 'Production Facility I', 'Increases the Industry output of this planet by 2', 'industry', 'output', 2 union 
select 30, 'dust', 'industry', 16, 'Production Facility II', 'Increases the Industry output of this planet by 3', 'industry', 'output', 3 union 
select 31, 'dust', 'industry', 17, 'Production Facility III', 'Increases the Industry output of this planet by 5', 'industry', 'output', 5 union 
select 32, 'dust', 'industry', 23, 'Orbital Storage System I', 'Increases your maximum Industry capacity by 30', 'industry', 'capacity', 30 union 
select 33, 'dust', 'industry', 24, 'Orbital Storage System II', 'Increases your maximum Industry capacity by 50', 'industry', 'capacity', 50 union 
select 34, 'dust', 'industry', 25, 'Orbital Storage System III', 'Increases your maximum Industry capacity by 100', 'industry', 'capacity', 100 union 
select 35, 'dust', 'industry', 33, 'Core Energy Extractor II', 'Increases the Industry output of this planet by 4, but decreases both Credits and Research output by 1', 'mixed', 'output', 4  union 
select 36, 'dust', 'industry', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 37, 'dust', 'industry', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 38, 'dust', 'industry', 41, 'L2 Discovery Probe Workshop', 'Allows you to craft the L2 Discovery Probes', 'workshop', null, null union 
select 39, 'dust', 'industry', 44, 'Category-C1 Probe Workshop', 'Allows you to craft the TP-PL1 and NP-PL1 Preparation Probes', 'workshop', null, null union 
select 40, 'dust', 'research', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 41, 'dust', 'research', 19, 'Advanced Research Lab I', 'Increases the Research output of this planet by 2', 'research', 'output', 2 union 
select 42, 'dust', 'research', 20, 'Advanced Research Lab II', 'Increases the Research output of this planet by 3', 'research', 'output', 3 union 
select 43, 'dust', 'research', 21, 'Advanced Research Lab III', 'Increases the Research output of this planet by 5', 'research', 'output', 5 union 
select 44, 'dust', 'research', 35, 'Celestial Research Academy I', 'Increases the Research output of this planet by 3, but decreases both Credits and Industry output by 1', 'mixed', 'output', 3  union 
select 45, 'dust', 'research', 37, 'Celestial Research Academy III', 'Increases the Research output of this planet by 5, but decreases both Credits and Industry output by 1', 'mixed', 'output', 5  union 
select 46, 'dust', 'research', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 47, 'dust', 'research', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 48, 'dust', 'universal', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 49, 'dust', 'universal', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 50, 'dust', 'universal', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 51, 'dust', 'universal', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 52, 'dust', 'universal', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 53, 'dust', 'universal', 9, 'Foundational Networks II', 'Increases the Credits, Industry and Research output of this planet by 2', 'all resources', 'output', 2 union 
select 54, 'dust', 'universal', 10, 'Foundational Networks III', 'Increases the Credits, Industry and Research output of this planet by 3', 'all resources', 'output', 3 union 
select 55, 'dust', 'universal', 11, 'Foundational Networks IV', 'Increases the Credits, Industry and Research output of this planet by 4', 'all resources', 'output', 4 union 
select 56, 'dust', 'universal', 13, 'Secure Trade Routes II', 'Increases the Credits output of this planet by 3', 'credits', 'output', 3 union 
select 57, 'dust', 'universal', 14, 'Secure Trade Routes III', 'Increases the Credits output of this planet by 5', 'credits', 'output', 5 union 
select 58, 'dust', 'universal', 17, 'Production Facility III', 'Increases the Industry output of this planet by 5', 'industry', 'output', 5 union 
select 59, 'dust', 'universal', 19, 'Advanced Research Lab I', 'Increases the Research output of this planet by 2', 'research', 'output', 2 union 
select 60, 'dust', 'universal', 20, 'Advanced Research Lab II', 'Increases the Research output of this planet by 3', 'research', 'output', 3 union 
select 61, 'dust', 'universal', 21, 'Advanced Research Lab III', 'Increases the Research output of this planet by 5', 'research', 'output', 5 union 
select 62, 'dust', 'universal', 24, 'Orbital Storage System II', 'Increases your maximum Industry capacity by 50', 'industry', 'capacity', 50 union 
select 63, 'dust', 'universal', 25, 'Orbital Storage System III', 'Increases your maximum Industry capacity by 100', 'industry', 'capacity', 100 union 
select 64, 'dust', 'universal', 27, 'Intergalactic Credit Exchange II', 'Increases your maximum Credits capacity by 50', 'credits', 'capacity', 50 union 
select 65, 'dust', 'universal', 28, 'Intergalactic Credit Exchange III', 'Increases your maximum Credits capacity by 100', 'credits', 'capacity', 100 union 
select 66, 'dust', 'universal', 30, 'Interplanetary Investment Nexus II', 'Increases the Credits output of this planet by 4, but decreases both Industry and Research output by 1', 'mixed', 'output', 4  union 
select 67, 'dust', 'universal', 33, 'Core Energy Extractor II', 'Increases the Industry output of this planet by 4, but decreases both Credits and Research output by 1', 'mixed', 'output', 4  union 
select 68, 'dust', 'universal', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 69, 'dust', 'universal', 41, 'L2 Discovery Probe Workshop', 'Allows you to craft the L2 Discovery Probes', 'workshop', null, null union 
select 70, 'exotic', 'basic', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 71, 'exotic', 'basic', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 72, 'exotic', 'basic', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 73, 'exotic', 'basic', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 74, 'exotic', 'basic', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 75, 'exotic', 'basic', 8, 'Foundational Networks I', 'Increases the Credits, Industry and Research output of this planet by 1', 'all resources', 'output', 1 union 
select 76, 'exotic', 'basic', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 77, 'exotic', 'basic', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 78, 'exotic', 'basic', 40, 'L1 Discovery Probe Workshop', 'Allows you to craft the L1 Discovery Probes', 'workshop', null, null union 
select 79, 'exotic', 'basic', 42, 'Category-A1 Probe Workshop', 'Allows you to craft the Ba-PL1 and Si-PL1 Preparation Probes', 'workshop', null, null union 
select 80, 'exotic', 'basic', 43, 'Category-A2 Probe Workshop', 'Allows you to craft the El-PL1 and Ho-PL1 Preparation Probes', 'workshop', null, null union 
select 81, 'exotic', 'basic', 46, 'Category-U1 Probe Workshop', 'Allows you to craft the PN-PL1 and YN-PL1 Preparation Probes', 'workshop', null, null union 
select 82, 'exotic', 'basic', 47, 'Category-U2 Probe Workshop', 'Allows you to craft the MH-PL1 and HX-PL1 Preparation Probes', 'workshop', null, null union 
select 83, 'exotic', 'basic', 48, 'Category-R1 Probe Workshop', 'Allows you to craft the Bp-PL1 and Io-PL1 Preparation Probes', 'workshop', null, null union 
select 84, 'exotic', 'basic', 49, 'Category-R2 Probe Workshop', 'Allows you to craft the Mi-PL1 and Tc-PL1 Preparation Probes', 'workshop', null, null union 
select 85, 'exotic', 'credits', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 86, 'exotic', 'credits', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 87, 'exotic', 'credits', 12, 'Secure Trade Routes I', 'Increases the Credits output of this planet by 2', 'credits', 'output', 2 union 
select 88, 'exotic', 'credits', 13, 'Secure Trade Routes II', 'Increases the Credits output of this planet by 3', 'credits', 'output', 3 union 
select 89, 'exotic', 'credits', 14, 'Secure Trade Routes III', 'Increases the Credits output of this planet by 5', 'credits', 'output', 5 union 
select 90, 'exotic', 'credits', 26, 'Intergalactic Credit Exchange I', 'Increases your maximum Credits capacity by 30', 'credits', 'capacity', 30 union 
select 91, 'exotic', 'credits', 27, 'Intergalactic Credit Exchange II', 'Increases your maximum Credits capacity by 50', 'credits', 'capacity', 50 union 
select 92, 'exotic', 'credits', 28, 'Intergalactic Credit Exchange III', 'Increases your maximum Credits capacity by 100', 'credits', 'capacity', 100 union 
select 93, 'exotic', 'credits', 29, 'Interplanetary Investment Nexus I', 'Increases the Credits output of this planet by 3, but decreases both Industry and Research output by 1', 'mixed', 'output', 3  union 
select 94, 'exotic', 'credits', 30, 'Interplanetary Investment Nexus II', 'Increases the Credits output of this planet by 4, but decreases both Industry and Research output by 1', 'mixed', 'output', 4  union 
select 95, 'exotic', 'credits', 45, 'Category-C2 Probe Workshop', 'Allows you to craft the OA-PL1 and AE-PL1 Preparation Probes', 'workshop', null, null union 
select 96, 'exotic', 'industry', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 97, 'exotic', 'industry', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 98, 'exotic', 'industry', 15, 'Production Facility I', 'Increases the Industry output of this planet by 2', 'industry', 'output', 2 union 
select 99, 'exotic', 'industry', 16, 'Production Facility II', 'Increases the Industry output of this planet by 3', 'industry', 'output', 3 union 
select 100, 'exotic', 'industry', 17, 'Production Facility III', 'Increases the Industry output of this planet by 5', 'industry', 'output', 5 union 
select 101, 'exotic', 'industry', 23, 'Orbital Storage System I', 'Increases your maximum Industry capacity by 30', 'industry', 'capacity', 30 union 
select 102, 'exotic', 'industry', 24, 'Orbital Storage System II', 'Increases your maximum Industry capacity by 50', 'industry', 'capacity', 50 union 
select 103, 'exotic', 'industry', 25, 'Orbital Storage System III', 'Increases your maximum Industry capacity by 100', 'industry', 'capacity', 100 union 
select 104, 'exotic', 'industry', 34, 'Core Energy Extractor III', 'Increases the Industry output of this planet by 5, but decreases both Credits and Research output by 1', 'mixed', 'output', 5  union 
select 105, 'exotic', 'industry', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 106, 'exotic', 'industry', 41, 'L2 Discovery Probe Workshop', 'Allows you to craft the L2 Discovery Probes', 'workshop', null, null union 
select 107, 'exotic', 'industry', 44, 'Category-C1 Probe Workshop', 'Allows you to craft the TP-PL1 and NP-PL1 Preparation Probes', 'workshop', null, null union 
select 108, 'exotic', 'research', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 109, 'exotic', 'research', 19, 'Advanced Research Lab I', 'Increases the Research output of this planet by 2', 'research', 'output', 2 union 
select 110, 'exotic', 'research', 20, 'Advanced Research Lab II', 'Increases the Research output of this planet by 3', 'research', 'output', 3 union 
select 111, 'exotic', 'research', 21, 'Advanced Research Lab III', 'Increases the Research output of this planet by 5', 'research', 'output', 5 union 
select 112, 'exotic', 'research', 22, 'Advanced Research Lab IV', 'Increases the Research output of this planet by 7', 'research', 'output', 7 union 
select 113, 'exotic', 'research', 35, 'Celestial Research Academy I', 'Increases the Research output of this planet by 3, but decreases both Credits and Industry output by 1', 'mixed', 'output', 3  union 
select 114, 'exotic', 'research', 36, 'Celestial Research Academy II', 'Increases the Research output of this planet by 4, but decreases both Credits and Industry output by 1', 'mixed', 'output', 4  union 
select 115, 'exotic', 'research', 37, 'Celestial Research Academy III', 'Increases the Research output of this planet by 5, but decreases both Credits and Industry output by 1', 'mixed', 'output', 5  union 
select 116, 'exotic', 'research', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 117, 'exotic', 'research', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 118, 'exotic', 'universal', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 119, 'exotic', 'universal', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 120, 'exotic', 'universal', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 121, 'exotic', 'universal', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 122, 'exotic', 'universal', 9, 'Foundational Networks II', 'Increases the Credits, Industry and Research output of this planet by 2', 'all resources', 'output', 2 union 
select 123, 'exotic', 'universal', 10, 'Foundational Networks III', 'Increases the Credits, Industry and Research output of this planet by 3', 'all resources', 'output', 3 union 
select 124, 'exotic', 'universal', 11, 'Foundational Networks IV', 'Increases the Credits, Industry and Research output of this planet by 4', 'all resources', 'output', 4 union 
select 125, 'exotic', 'universal', 14, 'Secure Trade Routes III', 'Increases the Credits output of this planet by 5', 'credits', 'output', 5 union 
select 126, 'exotic', 'universal', 17, 'Production Facility III', 'Increases the Industry output of this planet by 5', 'industry', 'output', 5 union 
select 127, 'exotic', 'universal', 20, 'Advanced Research Lab II', 'Increases the Research output of this planet by 3', 'research', 'output', 3 union 
select 128, 'exotic', 'universal', 22, 'Advanced Research Lab IV', 'Increases the Research output of this planet by 7', 'research', 'output', 7 union 
select 129, 'exotic', 'universal', 24, 'Orbital Storage System II', 'Increases your maximum Industry capacity by 50', 'industry', 'capacity', 50 union 
select 130, 'exotic', 'universal', 25, 'Orbital Storage System III', 'Increases your maximum Industry capacity by 100', 'industry', 'capacity', 100 union 
select 131, 'exotic', 'universal', 26, 'Intergalactic Credit Exchange I', 'Increases your maximum Credits capacity by 30', 'credits', 'capacity', 30 union 
select 132, 'exotic', 'universal', 28, 'Intergalactic Credit Exchange III', 'Increases your maximum Credits capacity by 100', 'credits', 'capacity', 100 union 
select 133, 'exotic', 'universal', 36, 'Celestial Research Academy II', 'Increases the Research output of this planet by 4, but decreases both Credits and Industry output by 1', 'mixed', 'output', 4  union 
select 134, 'exotic', 'universal', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 135, 'exotic', 'universal', 40, 'L1 Discovery Probe Workshop', 'Allows you to craft the L1 Discovery Probes', 'workshop', null, null union 
select 136, 'exotic', 'universal', 41, 'L2 Discovery Probe Workshop', 'Allows you to craft the L2 Discovery Probes', 'workshop', null, null union 
select 137, 'exotic', 'universal', 45, 'Category-C2 Probe Workshop', 'Allows you to craft the OA-PL1 and AE-PL1 Preparation Probes', 'workshop', null, null union 
select 138, 'exotic', 'universal', 47, 'Category-U2 Probe Workshop', 'Allows you to craft the MH-PL1 and HX-PL1 Preparation Probes', 'workshop', null, null union 
select 139, 'exotic', 'universal', 49, 'Category-R2 Probe Workshop', 'Allows you to craft the Mi-PL1 and Tc-PL1 Preparation Probes', 'workshop', null, null union 
select 140, 'gas', 'basic', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 141, 'gas', 'basic', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 142, 'gas', 'basic', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 143, 'gas', 'basic', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 144, 'gas', 'basic', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 145, 'gas', 'basic', 8, 'Foundational Networks I', 'Increases the Credits, Industry and Research output of this planet by 1', 'all resources', 'output', 1 union 
select 146, 'gas', 'basic', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 147, 'gas', 'basic', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 148, 'gas', 'basic', 40, 'L1 Discovery Probe Workshop', 'Allows you to craft the L1 Discovery Probes', 'workshop', null, null union 
select 149, 'gas', 'basic', 42, 'Category-A1 Probe Workshop', 'Allows you to craft the Ba-PL1 and Si-PL1 Preparation Probes', 'workshop', null, null union 
select 150, 'gas', 'basic', 43, 'Category-A2 Probe Workshop', 'Allows you to craft the El-PL1 and Ho-PL1 Preparation Probes', 'workshop', null, null union 
select 151, 'gas', 'basic', 46, 'Category-U1 Probe Workshop', 'Allows you to craft the PN-PL1 and YN-PL1 Preparation Probes', 'workshop', null, null union 
select 152, 'gas', 'basic', 47, 'Category-U2 Probe Workshop', 'Allows you to craft the MH-PL1 and HX-PL1 Preparation Probes', 'workshop', null, null union 
select 153, 'gas', 'basic', 48, 'Category-R1 Probe Workshop', 'Allows you to craft the Bp-PL1 and Io-PL1 Preparation Probes', 'workshop', null, null union 
select 154, 'gas', 'basic', 49, 'Category-R2 Probe Workshop', 'Allows you to craft the Mi-PL1 and Tc-PL1 Preparation Probes', 'workshop', null, null union 
select 155, 'gas', 'credits', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 156, 'gas', 'credits', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 157, 'gas', 'credits', 12, 'Secure Trade Routes I', 'Increases the Credits output of this planet by 2', 'credits', 'output', 2 union 
select 158, 'gas', 'credits', 13, 'Secure Trade Routes II', 'Increases the Credits output of this planet by 3', 'credits', 'output', 3 union 
select 159, 'gas', 'credits', 14, 'Secure Trade Routes III', 'Increases the Credits output of this planet by 5', 'credits', 'output', 5 union 
select 160, 'gas', 'credits', 26, 'Intergalactic Credit Exchange I', 'Increases your maximum Credits capacity by 30', 'credits', 'capacity', 30 union 
select 161, 'gas', 'credits', 27, 'Intergalactic Credit Exchange II', 'Increases your maximum Credits capacity by 50', 'credits', 'capacity', 50 union 
select 162, 'gas', 'credits', 28, 'Intergalactic Credit Exchange III', 'Increases your maximum Credits capacity by 100', 'credits', 'capacity', 100 union 
select 163, 'gas', 'credits', 31, 'Interplanetary Investment Nexus III', 'Increases the Credits output of this planet by 5, but decreases both Industry and Research output by 1', 'mixed', 'output', 5  union 
select 164, 'gas', 'credits', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 165, 'gas', 'credits', 45, 'Category-C2 Probe Workshop', 'Allows you to craft the OA-PL1 and AE-PL1 Preparation Probes', 'workshop', null, null union 
select 166, 'gas', 'industry', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 167, 'gas', 'industry', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 168, 'gas', 'industry', 15, 'Production Facility I', 'Increases the Industry output of this planet by 2', 'industry', 'output', 2 union 
select 169, 'gas', 'industry', 16, 'Production Facility II', 'Increases the Industry output of this planet by 3', 'industry', 'output', 3 union 
select 170, 'gas', 'industry', 17, 'Production Facility III', 'Increases the Industry output of this planet by 5', 'industry', 'output', 5 union 
select 171, 'gas', 'industry', 23, 'Orbital Storage System I', 'Increases your maximum Industry capacity by 30', 'industry', 'capacity', 30 union 
select 172, 'gas', 'industry', 24, 'Orbital Storage System II', 'Increases your maximum Industry capacity by 50', 'industry', 'capacity', 50 union 
select 173, 'gas', 'industry', 25, 'Orbital Storage System III', 'Increases your maximum Industry capacity by 100', 'industry', 'capacity', 100 union 
select 174, 'gas', 'industry', 34, 'Core Energy Extractor III', 'Increases the Industry output of this planet by 5, but decreases both Credits and Research output by 1', 'mixed', 'output', 5  union 
select 175, 'gas', 'industry', 41, 'L2 Discovery Probe Workshop', 'Allows you to craft the L2 Discovery Probes', 'workshop', null, null union 
select 176, 'gas', 'industry', 44, 'Category-C1 Probe Workshop', 'Allows you to craft the TP-PL1 and NP-PL1 Preparation Probes', 'workshop', null, null union 
select 177, 'gas', 'research', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 178, 'gas', 'research', 19, 'Advanced Research Lab I', 'Increases the Research output of this planet by 2', 'research', 'output', 2 union 
select 179, 'gas', 'research', 20, 'Advanced Research Lab II', 'Increases the Research output of this planet by 3', 'research', 'output', 3 union 
select 180, 'gas', 'research', 21, 'Advanced Research Lab III', 'Increases the Research output of this planet by 5', 'research', 'output', 5 union 
select 181, 'gas', 'research', 36, 'Celestial Research Academy II', 'Increases the Research output of this planet by 4, but decreases both Credits and Industry output by 1', 'mixed', 'output', 4  union 
select 182, 'gas', 'research', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 183, 'gas', 'research', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 184, 'gas', 'universal', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 185, 'gas', 'universal', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 186, 'gas', 'universal', 9, 'Foundational Networks II', 'Increases the Credits, Industry and Research output of this planet by 2', 'all resources', 'output', 2 union 
select 187, 'gas', 'universal', 10, 'Foundational Networks III', 'Increases the Credits, Industry and Research output of this planet by 3', 'all resources', 'output', 3 union 
select 188, 'gas', 'universal', 11, 'Foundational Networks IV', 'Increases the Credits, Industry and Research output of this planet by 4', 'all resources', 'output', 4 union 
select 189, 'gas', 'universal', 13, 'Secure Trade Routes II', 'Increases the Credits output of this planet by 3', 'credits', 'output', 3 union 
select 190, 'gas', 'universal', 14, 'Secure Trade Routes III', 'Increases the Credits output of this planet by 5', 'credits', 'output', 5 union 
select 191, 'gas', 'universal', 16, 'Production Facility II', 'Increases the Industry output of this planet by 3', 'industry', 'output', 3 union 
select 192, 'gas', 'universal', 17, 'Production Facility III', 'Increases the Industry output of this planet by 5', 'industry', 'output', 5 union 
select 193, 'gas', 'universal', 19, 'Advanced Research Lab I', 'Increases the Research output of this planet by 2', 'research', 'output', 2 union 
select 194, 'gas', 'universal', 21, 'Advanced Research Lab III', 'Increases the Research output of this planet by 5', 'research', 'output', 5 union 
select 195, 'gas', 'universal', 24, 'Orbital Storage System II', 'Increases your maximum Industry capacity by 50', 'industry', 'capacity', 50 union 
select 196, 'gas', 'universal', 25, 'Orbital Storage System III', 'Increases your maximum Industry capacity by 100', 'industry', 'capacity', 100 union 
select 197, 'gas', 'universal', 27, 'Intergalactic Credit Exchange II', 'Increases your maximum Credits capacity by 50', 'credits', 'capacity', 50 union 
select 198, 'gas', 'universal', 28, 'Intergalactic Credit Exchange III', 'Increases your maximum Credits capacity by 100', 'credits', 'capacity', 100 union 
select 199, 'gas', 'universal', 36, 'Celestial Research Academy II', 'Increases the Research output of this planet by 4, but decreases both Credits and Industry output by 1', 'mixed', 'output', 4  union 
select 200, 'gas', 'universal', 49, 'Category-R2 Probe Workshop', 'Allows you to craft the Mi-PL1 and Tc-PL1 Preparation Probes', 'workshop', null, null union 
select 201, 'ice', 'basic', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 202, 'ice', 'basic', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 203, 'ice', 'basic', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 204, 'ice', 'basic', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 205, 'ice', 'basic', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 206, 'ice', 'basic', 8, 'Foundational Networks I', 'Increases the Credits, Industry and Research output of this planet by 1', 'all resources', 'output', 1 union 
select 207, 'ice', 'basic', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 208, 'ice', 'basic', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 209, 'ice', 'basic', 40, 'L1 Discovery Probe Workshop', 'Allows you to craft the L1 Discovery Probes', 'workshop', null, null union 
select 210, 'ice', 'basic', 42, 'Category-A1 Probe Workshop', 'Allows you to craft the Ba-PL1 and Si-PL1 Preparation Probes', 'workshop', null, null union 
select 211, 'ice', 'basic', 43, 'Category-A2 Probe Workshop', 'Allows you to craft the El-PL1 and Ho-PL1 Preparation Probes', 'workshop', null, null union 
select 212, 'ice', 'basic', 46, 'Category-U1 Probe Workshop', 'Allows you to craft the PN-PL1 and YN-PL1 Preparation Probes', 'workshop', null, null union 
select 213, 'ice', 'basic', 47, 'Category-U2 Probe Workshop', 'Allows you to craft the MH-PL1 and HX-PL1 Preparation Probes', 'workshop', null, null union 
select 214, 'ice', 'basic', 48, 'Category-R1 Probe Workshop', 'Allows you to craft the Bp-PL1 and Io-PL1 Preparation Probes', 'workshop', null, null union 
select 215, 'ice', 'basic', 49, 'Category-R2 Probe Workshop', 'Allows you to craft the Mi-PL1 and Tc-PL1 Preparation Probes', 'workshop', null, null union 
select 216, 'ice', 'credits', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 217, 'ice', 'credits', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 218, 'ice', 'credits', 13, 'Secure Trade Routes II', 'Increases the Credits output of this planet by 3', 'credits', 'output', 3 union 
select 219, 'ice', 'credits', 14, 'Secure Trade Routes III', 'Increases the Credits output of this planet by 5', 'credits', 'output', 5 union 
select 220, 'ice', 'credits', 26, 'Intergalactic Credit Exchange I', 'Increases your maximum Credits capacity by 30', 'credits', 'capacity', 30 union 
select 221, 'ice', 'credits', 27, 'Intergalactic Credit Exchange II', 'Increases your maximum Credits capacity by 50', 'credits', 'capacity', 50 union 
select 222, 'ice', 'credits', 28, 'Intergalactic Credit Exchange III', 'Increases your maximum Credits capacity by 100', 'credits', 'capacity', 100 union 
select 223, 'ice', 'credits', 30, 'Interplanetary Investment Nexus II', 'Increases the Credits output of this planet by 4, but decreases both Industry and Research output by 1', 'mixed', 'output', 4  union 
select 224, 'ice', 'credits', 45, 'Category-C2 Probe Workshop', 'Allows you to craft the OA-PL1 and AE-PL1 Preparation Probes', 'workshop', null, null union 
select 225, 'ice', 'industry', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 226, 'ice', 'industry', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 227, 'ice', 'industry', 15, 'Production Facility I', 'Increases the Industry output of this planet by 2', 'industry', 'output', 2 union 
select 228, 'ice', 'industry', 16, 'Production Facility II', 'Increases the Industry output of this planet by 3', 'industry', 'output', 3 union 
select 229, 'ice', 'industry', 17, 'Production Facility III', 'Increases the Industry output of this planet by 5', 'industry', 'output', 5 union 
select 230, 'ice', 'industry', 23, 'Orbital Storage System I', 'Increases your maximum Industry capacity by 30', 'industry', 'capacity', 30 union 
select 231, 'ice', 'industry', 24, 'Orbital Storage System II', 'Increases your maximum Industry capacity by 50', 'industry', 'capacity', 50 union 
select 232, 'ice', 'industry', 25, 'Orbital Storage System III', 'Increases your maximum Industry capacity by 100', 'industry', 'capacity', 100 union 
select 233, 'ice', 'industry', 32, 'Core Energy Extractor I', 'Increases the Industry output of this planet by 3, but decreases both Credits and Research output by 1', 'mixed', 'output', 3  union 
select 234, 'ice', 'industry', 33, 'Core Energy Extractor II', 'Increases the Industry output of this planet by 4, but decreases both Credits and Research output by 1', 'mixed', 'output', 4  union 
select 235, 'ice', 'industry', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 236, 'ice', 'industry', 41, 'L2 Discovery Probe Workshop', 'Allows you to craft the L2 Discovery Probes', 'workshop', null, null union 
select 237, 'ice', 'industry', 44, 'Category-C1 Probe Workshop', 'Allows you to craft the TP-PL1 and NP-PL1 Preparation Probes', 'workshop', null, null union 
select 238, 'ice', 'research', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 239, 'ice', 'research', 19, 'Advanced Research Lab I', 'Increases the Research output of this planet by 2', 'research', 'output', 2 union 
select 240, 'ice', 'research', 20, 'Advanced Research Lab II', 'Increases the Research output of this planet by 3', 'research', 'output', 3 union 
select 241, 'ice', 'research', 21, 'Advanced Research Lab III', 'Increases the Research output of this planet by 5', 'research', 'output', 5 union 
select 242, 'ice', 'research', 36, 'Celestial Research Academy II', 'Increases the Research output of this planet by 4, but decreases both Credits and Industry output by 1', 'mixed', 'output', 4  union 
select 243, 'ice', 'research', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 244, 'ice', 'research', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 245, 'ice', 'universal', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 246, 'ice', 'universal', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 247, 'ice', 'universal', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 248, 'ice', 'universal', 9, 'Foundational Networks II', 'Increases the Credits, Industry and Research output of this planet by 2', 'all resources', 'output', 2 union 
select 249, 'ice', 'universal', 10, 'Foundational Networks III', 'Increases the Credits, Industry and Research output of this planet by 3', 'all resources', 'output', 3 union 
select 250, 'ice', 'universal', 11, 'Foundational Networks IV', 'Increases the Credits, Industry and Research output of this planet by 4', 'all resources', 'output', 4 union 
select 251, 'ice', 'universal', 14, 'Secure Trade Routes III', 'Increases the Credits output of this planet by 5', 'credits', 'output', 5 union 
select 252, 'ice', 'universal', 17, 'Production Facility III', 'Increases the Industry output of this planet by 5', 'industry', 'output', 5 union 
select 253, 'ice', 'universal', 20, 'Advanced Research Lab II', 'Increases the Research output of this planet by 3', 'research', 'output', 3 union 
select 254, 'ice', 'universal', 21, 'Advanced Research Lab III', 'Increases the Research output of this planet by 5', 'research', 'output', 5 union 
select 255, 'ice', 'universal', 24, 'Orbital Storage System II', 'Increases your maximum Industry capacity by 50', 'industry', 'capacity', 50 union 
select 256, 'ice', 'universal', 25, 'Orbital Storage System III', 'Increases your maximum Industry capacity by 100', 'industry', 'capacity', 100 union 
select 257, 'ice', 'universal', 26, 'Intergalactic Credit Exchange I', 'Increases your maximum Credits capacity by 30', 'credits', 'capacity', 30 union 
select 258, 'ice', 'universal', 27, 'Intergalactic Credit Exchange II', 'Increases your maximum Credits capacity by 50', 'credits', 'capacity', 50 union 
select 259, 'ice', 'universal', 28, 'Intergalactic Credit Exchange III', 'Increases your maximum Credits capacity by 100', 'credits', 'capacity', 100 union 
select 260, 'ice', 'universal', 30, 'Interplanetary Investment Nexus II', 'Increases the Credits output of this planet by 4, but decreases both Industry and Research output by 1', 'mixed', 'output', 4  union 
select 261, 'ice', 'universal', 41, 'L2 Discovery Probe Workshop', 'Allows you to craft the L2 Discovery Probes', 'workshop', null, null union 
select 262, 'lava', 'basic', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 263, 'lava', 'basic', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 264, 'lava', 'basic', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 265, 'lava', 'basic', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 266, 'lava', 'basic', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 267, 'lava', 'basic', 8, 'Foundational Networks I', 'Increases the Credits, Industry and Research output of this planet by 1', 'all resources', 'output', 1 union 
select 268, 'lava', 'basic', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 269, 'lava', 'basic', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 270, 'lava', 'basic', 40, 'L1 Discovery Probe Workshop', 'Allows you to craft the L1 Discovery Probes', 'workshop', null, null union 
select 271, 'lava', 'basic', 42, 'Category-A1 Probe Workshop', 'Allows you to craft the Ba-PL1 and Si-PL1 Preparation Probes', 'workshop', null, null union 
select 272, 'lava', 'basic', 43, 'Category-A2 Probe Workshop', 'Allows you to craft the El-PL1 and Ho-PL1 Preparation Probes', 'workshop', null, null union 
select 273, 'lava', 'basic', 46, 'Category-U1 Probe Workshop', 'Allows you to craft the PN-PL1 and YN-PL1 Preparation Probes', 'workshop', null, null union 
select 274, 'lava', 'basic', 47, 'Category-U2 Probe Workshop', 'Allows you to craft the MH-PL1 and HX-PL1 Preparation Probes', 'workshop', null, null union 
select 275, 'lava', 'basic', 48, 'Category-R1 Probe Workshop', 'Allows you to craft the Bp-PL1 and Io-PL1 Preparation Probes', 'workshop', null, null union 
select 276, 'lava', 'basic', 49, 'Category-R2 Probe Workshop', 'Allows you to craft the Mi-PL1 and Tc-PL1 Preparation Probes', 'workshop', null, null union 
select 277, 'lava', 'credits', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 278, 'lava', 'credits', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 279, 'lava', 'credits', 13, 'Secure Trade Routes II', 'Increases the Credits output of this planet by 3', 'credits', 'output', 3 union 
select 280, 'lava', 'credits', 14, 'Secure Trade Routes III', 'Increases the Credits output of this planet by 5', 'credits', 'output', 5 union 
select 281, 'lava', 'credits', 26, 'Intergalactic Credit Exchange I', 'Increases your maximum Credits capacity by 30', 'credits', 'capacity', 30 union 
select 282, 'lava', 'credits', 27, 'Intergalactic Credit Exchange II', 'Increases your maximum Credits capacity by 50', 'credits', 'capacity', 50 union 
select 283, 'lava', 'credits', 28, 'Intergalactic Credit Exchange III', 'Increases your maximum Credits capacity by 100', 'credits', 'capacity', 100 union 
select 284, 'lava', 'credits', 29, 'Interplanetary Investment Nexus I', 'Increases the Credits output of this planet by 3, but decreases both Industry and Research output by 1', 'mixed', 'output', 3  union 
select 285, 'lava', 'credits', 30, 'Interplanetary Investment Nexus II', 'Increases the Credits output of this planet by 4, but decreases both Industry and Research output by 1', 'mixed', 'output', 4  union 
select 286, 'lava', 'credits', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 287, 'lava', 'credits', 45, 'Category-C2 Probe Workshop', 'Allows you to craft the OA-PL1 and AE-PL1 Preparation Probes', 'workshop', null, null union 
select 288, 'lava', 'industry', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 289, 'lava', 'industry', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 290, 'lava', 'industry', 15, 'Production Facility I', 'Increases the Industry output of this planet by 2', 'industry', 'output', 2 union 
select 291, 'lava', 'industry', 16, 'Production Facility II', 'Increases the Industry output of this planet by 3', 'industry', 'output', 3 union 
select 292, 'lava', 'industry', 17, 'Production Facility III', 'Increases the Industry output of this planet by 5', 'industry', 'output', 5 union 
select 293, 'lava', 'industry', 18, 'Production Facility IV', 'Increases the Industry output of this planet by 7', 'industry', 'output', 7 union 
select 294, 'lava', 'industry', 23, 'Orbital Storage System I', 'Increases your maximum Industry capacity by 30', 'industry', 'capacity', 30 union 
select 295, 'lava', 'industry', 24, 'Orbital Storage System II', 'Increases your maximum Industry capacity by 50', 'industry', 'capacity', 50 union 
select 296, 'lava', 'industry', 25, 'Orbital Storage System III', 'Increases your maximum Industry capacity by 100', 'industry', 'capacity', 100 union 
select 297, 'lava', 'industry', 33, 'Core Energy Extractor II', 'Increases the Industry output of this planet by 4, but decreases both Credits and Research output by 1', 'mixed', 'output', 4  union 
select 298, 'lava', 'industry', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 299, 'lava', 'industry', 41, 'L2 Discovery Probe Workshop', 'Allows you to craft the L2 Discovery Probes', 'workshop', null, null union 
select 300, 'lava', 'industry', 44, 'Category-C1 Probe Workshop', 'Allows you to craft the TP-PL1 and NP-PL1 Preparation Probes', 'workshop', null, null union 
select 301, 'lava', 'research', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 302, 'lava', 'research', 19, 'Advanced Research Lab I', 'Increases the Research output of this planet by 2', 'research', 'output', 2 union 
select 303, 'lava', 'research', 20, 'Advanced Research Lab II', 'Increases the Research output of this planet by 3', 'research', 'output', 3 union 
select 304, 'lava', 'research', 21, 'Advanced Research Lab III', 'Increases the Research output of this planet by 5', 'research', 'output', 5 union 
select 305, 'lava', 'research', 35, 'Celestial Research Academy I', 'Increases the Research output of this planet by 3, but decreases both Credits and Industry output by 1', 'mixed', 'output', 3  union 
select 306, 'lava', 'research', 36, 'Celestial Research Academy II', 'Increases the Research output of this planet by 4, but decreases both Credits and Industry output by 1', 'mixed', 'output', 4  union 
select 307, 'lava', 'research', 37, 'Celestial Research Academy III', 'Increases the Research output of this planet by 5, but decreases both Credits and Industry output by 1', 'mixed', 'output', 5  union 
select 308, 'lava', 'research', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 309, 'lava', 'research', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 310, 'lava', 'universal', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 311, 'lava', 'universal', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 312, 'lava', 'universal', 9, 'Foundational Networks II', 'Increases the Credits, Industry and Research output of this planet by 2', 'all resources', 'output', 2 union 
select 313, 'lava', 'universal', 10, 'Foundational Networks III', 'Increases the Credits, Industry and Research output of this planet by 3', 'all resources', 'output', 3 union 
select 314, 'lava', 'universal', 11, 'Foundational Networks IV', 'Increases the Credits, Industry and Research output of this planet by 4', 'all resources', 'output', 4 union 
select 315, 'lava', 'universal', 14, 'Secure Trade Routes III', 'Increases the Credits output of this planet by 5', 'credits', 'output', 5 union 
select 316, 'lava', 'universal', 18, 'Production Facility IV', 'Increases the Industry output of this planet by 7', 'industry', 'output', 7 union 
select 317, 'lava', 'universal', 20, 'Advanced Research Lab II', 'Increases the Research output of this planet by 3', 'research', 'output', 3 union 
select 318, 'lava', 'universal', 21, 'Advanced Research Lab III', 'Increases the Research output of this planet by 5', 'research', 'output', 5 union 
select 319, 'lava', 'universal', 25, 'Orbital Storage System III', 'Increases your maximum Industry capacity by 100', 'industry', 'capacity', 100 union 
select 320, 'lava', 'universal', 26, 'Intergalactic Credit Exchange I', 'Increases your maximum Credits capacity by 30', 'credits', 'capacity', 30 union 
select 321, 'lava', 'universal', 27, 'Intergalactic Credit Exchange II', 'Increases your maximum Credits capacity by 50', 'credits', 'capacity', 50 union 
select 322, 'lava', 'universal', 28, 'Intergalactic Credit Exchange III', 'Increases your maximum Credits capacity by 100', 'credits', 'capacity', 100 union 
select 323, 'lava', 'universal', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 324, 'lava', 'universal', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 325, 'lava', 'universal', 41, 'L2 Discovery Probe Workshop', 'Allows you to craft the L2 Discovery Probes', 'workshop', null, null union 
select 326, 'lava', 'universal', 44, 'Category-C1 Probe Workshop', 'Allows you to craft the TP-PL1 and NP-PL1 Preparation Probes', 'workshop', null, null union 
select 327, 'lava', 'universal', 45, 'Category-C2 Probe Workshop', 'Allows you to craft the OA-PL1 and AE-PL1 Preparation Probes', 'workshop', null, null union 
select 328, 'lava', 'universal', 49, 'Category-R2 Probe Workshop', 'Allows you to craft the Mi-PL1 and Tc-PL1 Preparation Probes', 'workshop', null, null union 
select 329, 'ocean', 'basic', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 330, 'ocean', 'basic', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 331, 'ocean', 'basic', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 332, 'ocean', 'basic', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 333, 'ocean', 'basic', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 334, 'ocean', 'basic', 8, 'Foundational Networks I', 'Increases the Credits, Industry and Research output of this planet by 1', 'all resources', 'output', 1 union 
select 335, 'ocean', 'basic', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 336, 'ocean', 'basic', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 337, 'ocean', 'basic', 40, 'L1 Discovery Probe Workshop', 'Allows you to craft the L1 Discovery Probes', 'workshop', null, null union 
select 338, 'ocean', 'basic', 42, 'Category-A1 Probe Workshop', 'Allows you to craft the Ba-PL1 and Si-PL1 Preparation Probes', 'workshop', null, null union 
select 339, 'ocean', 'basic', 43, 'Category-A2 Probe Workshop', 'Allows you to craft the El-PL1 and Ho-PL1 Preparation Probes', 'workshop', null, null union 
select 340, 'ocean', 'basic', 46, 'Category-U1 Probe Workshop', 'Allows you to craft the PN-PL1 and YN-PL1 Preparation Probes', 'workshop', null, null union 
select 341, 'ocean', 'basic', 47, 'Category-U2 Probe Workshop', 'Allows you to craft the MH-PL1 and HX-PL1 Preparation Probes', 'workshop', null, null union 
select 342, 'ocean', 'basic', 48, 'Category-R1 Probe Workshop', 'Allows you to craft the Bp-PL1 and Io-PL1 Preparation Probes', 'workshop', null, null union 
select 343, 'ocean', 'basic', 49, 'Category-R2 Probe Workshop', 'Allows you to craft the Mi-PL1 and Tc-PL1 Preparation Probes', 'workshop', null, null union 
select 344, 'ocean', 'credits', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 345, 'ocean', 'credits', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 346, 'ocean', 'credits', 12, 'Secure Trade Routes I', 'Increases the Credits output of this planet by 2', 'credits', 'output', 2 union 
select 347, 'ocean', 'credits', 13, 'Secure Trade Routes II', 'Increases the Credits output of this planet by 3', 'credits', 'output', 3 union 
select 348, 'ocean', 'credits', 14, 'Secure Trade Routes III', 'Increases the Credits output of this planet by 5', 'credits', 'output', 5 union 
select 349, 'ocean', 'credits', 26, 'Intergalactic Credit Exchange I', 'Increases your maximum Credits capacity by 30', 'credits', 'capacity', 30 union 
select 350, 'ocean', 'credits', 27, 'Intergalactic Credit Exchange II', 'Increases your maximum Credits capacity by 50', 'credits', 'capacity', 50 union 
select 351, 'ocean', 'credits', 28, 'Intergalactic Credit Exchange III', 'Increases your maximum Credits capacity by 100', 'credits', 'capacity', 100 union 
select 352, 'ocean', 'credits', 29, 'Interplanetary Investment Nexus I', 'Increases the Credits output of this planet by 3, but decreases both Industry and Research output by 1', 'mixed', 'output', 3  union 
select 353, 'ocean', 'credits', 30, 'Interplanetary Investment Nexus II', 'Increases the Credits output of this planet by 4, but decreases both Industry and Research output by 1', 'mixed', 'output', 4  union 
select 354, 'ocean', 'credits', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 355, 'ocean', 'credits', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 356, 'ocean', 'credits', 45, 'Category-C2 Probe Workshop', 'Allows you to craft the OA-PL1 and AE-PL1 Preparation Probes', 'workshop', null, null union 
select 357, 'ocean', 'industry', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 358, 'ocean', 'industry', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 359, 'ocean', 'industry', 16, 'Production Facility II', 'Increases the Industry output of this planet by 3', 'industry', 'output', 3 union 
select 360, 'ocean', 'industry', 17, 'Production Facility III', 'Increases the Industry output of this planet by 5', 'industry', 'output', 5 union 
select 361, 'ocean', 'industry', 23, 'Orbital Storage System I', 'Increases your maximum Industry capacity by 30', 'industry', 'capacity', 30 union 
select 362, 'ocean', 'industry', 24, 'Orbital Storage System II', 'Increases your maximum Industry capacity by 50', 'industry', 'capacity', 50 union 
select 363, 'ocean', 'industry', 25, 'Orbital Storage System III', 'Increases your maximum Industry capacity by 100', 'industry', 'capacity', 100 union 
select 364, 'ocean', 'industry', 32, 'Core Energy Extractor I', 'Increases the Industry output of this planet by 3, but decreases both Credits and Research output by 1', 'mixed', 'output', 3  union 
select 365, 'ocean', 'industry', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 366, 'ocean', 'industry', 41, 'L2 Discovery Probe Workshop', 'Allows you to craft the L2 Discovery Probes', 'workshop', null, null union 
select 367, 'ocean', 'industry', 44, 'Category-C1 Probe Workshop', 'Allows you to craft the TP-PL1 and NP-PL1 Preparation Probes', 'workshop', null, null union 
select 368, 'ocean', 'research', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 369, 'ocean', 'research', 19, 'Advanced Research Lab I', 'Increases the Research output of this planet by 2', 'research', 'output', 2 union 
select 370, 'ocean', 'research', 20, 'Advanced Research Lab II', 'Increases the Research output of this planet by 3', 'research', 'output', 3 union 
select 371, 'ocean', 'research', 21, 'Advanced Research Lab III', 'Increases the Research output of this planet by 5', 'research', 'output', 5 union 
select 372, 'ocean', 'research', 35, 'Celestial Research Academy I', 'Increases the Research output of this planet by 3, but decreases both Credits and Industry output by 1', 'mixed', 'output', 3  union 
select 373, 'ocean', 'research', 36, 'Celestial Research Academy II', 'Increases the Research output of this planet by 4, but decreases both Credits and Industry output by 1', 'mixed', 'output', 4  union 
select 374, 'ocean', 'research', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 375, 'ocean', 'research', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 376, 'ocean', 'universal', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 377, 'ocean', 'universal', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 378, 'ocean', 'universal', 9, 'Foundational Networks II', 'Increases the Credits, Industry and Research output of this planet by 2', 'all resources', 'output', 2 union 
select 379, 'ocean', 'universal', 10, 'Foundational Networks III', 'Increases the Credits, Industry and Research output of this planet by 3', 'all resources', 'output', 3 union 
select 380, 'ocean', 'universal', 11, 'Foundational Networks IV', 'Increases the Credits, Industry and Research output of this planet by 4', 'all resources', 'output', 4 union 
select 381, 'ocean', 'universal', 13, 'Secure Trade Routes II', 'Increases the Credits output of this planet by 3', 'credits', 'output', 3 union 
select 382, 'ocean', 'universal', 14, 'Secure Trade Routes III', 'Increases the Credits output of this planet by 5', 'credits', 'output', 5 union 
select 383, 'ocean', 'universal', 16, 'Production Facility II', 'Increases the Industry output of this planet by 3', 'industry', 'output', 3 union 
select 384, 'ocean', 'universal', 17, 'Production Facility III', 'Increases the Industry output of this planet by 5', 'industry', 'output', 5 union 
select 385, 'ocean', 'universal', 19, 'Advanced Research Lab I', 'Increases the Research output of this planet by 2', 'research', 'output', 2 union 
select 386, 'ocean', 'universal', 21, 'Advanced Research Lab III', 'Increases the Research output of this planet by 5', 'research', 'output', 5 union 
select 387, 'ocean', 'universal', 24, 'Orbital Storage System II', 'Increases your maximum Industry capacity by 50', 'industry', 'capacity', 50 union 
select 388, 'ocean', 'universal', 25, 'Orbital Storage System III', 'Increases your maximum Industry capacity by 100', 'industry', 'capacity', 100 union 
select 389, 'ocean', 'universal', 27, 'Intergalactic Credit Exchange II', 'Increases your maximum Credits capacity by 50', 'credits', 'capacity', 50 union 
select 390, 'ocean', 'universal', 28, 'Intergalactic Credit Exchange III', 'Increases your maximum Credits capacity by 100', 'credits', 'capacity', 100 union 
select 391, 'ocean', 'universal', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 392, 'ocean', 'universal', 42, 'Category-A1 Probe Workshop', 'Allows you to craft the Ba-PL1 and Si-PL1 Preparation Probes', 'workshop', null, null union 
select 393, 'ocean', 'universal', 48, 'Category-R1 Probe Workshop', 'Allows you to craft the Bp-PL1 and Io-PL1 Preparation Probes', 'workshop', null, null union 
select 394, 'rogue', 'basic', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 395, 'rogue', 'basic', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 396, 'rogue', 'basic', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 397, 'rogue', 'basic', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 398, 'rogue', 'basic', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 399, 'rogue', 'basic', 8, 'Foundational Networks I', 'Increases the Credits, Industry and Research output of this planet by 1', 'all resources', 'output', 1 union 
select 400, 'rogue', 'basic', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 401, 'rogue', 'basic', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 402, 'rogue', 'basic', 40, 'L1 Discovery Probe Workshop', 'Allows you to craft the L1 Discovery Probes', 'workshop', null, null union 
select 403, 'rogue', 'basic', 42, 'Category-A1 Probe Workshop', 'Allows you to craft the Ba-PL1 and Si-PL1 Preparation Probes', 'workshop', null, null union 
select 404, 'rogue', 'basic', 43, 'Category-A2 Probe Workshop', 'Allows you to craft the El-PL1 and Ho-PL1 Preparation Probes', 'workshop', null, null union 
select 405, 'rogue', 'basic', 46, 'Category-U1 Probe Workshop', 'Allows you to craft the PN-PL1 and YN-PL1 Preparation Probes', 'workshop', null, null union 
select 406, 'rogue', 'basic', 47, 'Category-U2 Probe Workshop', 'Allows you to craft the MH-PL1 and HX-PL1 Preparation Probes', 'workshop', null, null union 
select 407, 'rogue', 'basic', 48, 'Category-R1 Probe Workshop', 'Allows you to craft the Bp-PL1 and Io-PL1 Preparation Probes', 'workshop', null, null union 
select 408, 'rogue', 'basic', 49, 'Category-R2 Probe Workshop', 'Allows you to craft the Mi-PL1 and Tc-PL1 Preparation Probes', 'workshop', null, null union 
select 409, 'rogue', 'credits', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 410, 'rogue', 'credits', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 411, 'rogue', 'credits', 13, 'Secure Trade Routes II', 'Increases the Credits output of this planet by 3', 'credits', 'output', 3 union 
select 412, 'rogue', 'credits', 14, 'Secure Trade Routes III', 'Increases the Credits output of this planet by 5', 'credits', 'output', 5 union 
select 413, 'rogue', 'credits', 26, 'Intergalactic Credit Exchange I', 'Increases your maximum Credits capacity by 30', 'credits', 'capacity', 30 union 
select 414, 'rogue', 'credits', 27, 'Intergalactic Credit Exchange II', 'Increases your maximum Credits capacity by 50', 'credits', 'capacity', 50 union 
select 415, 'rogue', 'credits', 28, 'Intergalactic Credit Exchange III', 'Increases your maximum Credits capacity by 100', 'credits', 'capacity', 100 union 
select 416, 'rogue', 'credits', 30, 'Interplanetary Investment Nexus II', 'Increases the Credits output of this planet by 4, but decreases both Industry and Research output by 1', 'mixed', 'output', 4  union 
select 417, 'rogue', 'credits', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 418, 'rogue', 'credits', 45, 'Category-C2 Probe Workshop', 'Allows you to craft the OA-PL1 and AE-PL1 Preparation Probes', 'workshop', null, null union 
select 419, 'rogue', 'industry', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 420, 'rogue', 'industry', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 421, 'rogue', 'industry', 16, 'Production Facility II', 'Increases the Industry output of this planet by 3', 'industry', 'output', 3 union 
select 422, 'rogue', 'industry', 17, 'Production Facility III', 'Increases the Industry output of this planet by 5', 'industry', 'output', 5 union 
select 423, 'rogue', 'industry', 23, 'Orbital Storage System I', 'Increases your maximum Industry capacity by 30', 'industry', 'capacity', 30 union 
select 424, 'rogue', 'industry', 24, 'Orbital Storage System II', 'Increases your maximum Industry capacity by 50', 'industry', 'capacity', 50 union 
select 425, 'rogue', 'industry', 25, 'Orbital Storage System III', 'Increases your maximum Industry capacity by 100', 'industry', 'capacity', 100 union 
select 426, 'rogue', 'industry', 32, 'Core Energy Extractor I', 'Increases the Industry output of this planet by 3, but decreases both Credits and Research output by 1', 'mixed', 'output', 3  union 
select 427, 'rogue', 'industry', 34, 'Core Energy Extractor III', 'Increases the Industry output of this planet by 5, but decreases both Credits and Research output by 1', 'mixed', 'output', 5  union 
select 428, 'rogue', 'industry', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 429, 'rogue', 'industry', 41, 'L2 Discovery Probe Workshop', 'Allows you to craft the L2 Discovery Probes', 'workshop', null, null union 
select 430, 'rogue', 'industry', 44, 'Category-C1 Probe Workshop', 'Allows you to craft the TP-PL1 and NP-PL1 Preparation Probes', 'workshop', null, null union 
select 431, 'rogue', 'research', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 432, 'rogue', 'research', 19, 'Advanced Research Lab I', 'Increases the Research output of this planet by 2', 'research', 'output', 2 union 
select 433, 'rogue', 'research', 20, 'Advanced Research Lab II', 'Increases the Research output of this planet by 3', 'research', 'output', 3 union 
select 434, 'rogue', 'research', 21, 'Advanced Research Lab III', 'Increases the Research output of this planet by 5', 'research', 'output', 5 union 
select 435, 'rogue', 'research', 35, 'Celestial Research Academy I', 'Increases the Research output of this planet by 3, but decreases both Credits and Industry output by 1', 'mixed', 'output', 3  union 
select 436, 'rogue', 'research', 36, 'Celestial Research Academy II', 'Increases the Research output of this planet by 4, but decreases both Credits and Industry output by 1', 'mixed', 'output', 4  union 
select 437, 'rogue', 'research', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 438, 'rogue', 'research', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 439, 'rogue', 'universal', 9, 'Foundational Networks II', 'Increases the Credits, Industry and Research output of this planet by 2', 'all resources', 'output', 2 union 
select 440, 'rogue', 'universal', 10, 'Foundational Networks III', 'Increases the Credits, Industry and Research output of this planet by 3', 'all resources', 'output', 3 union 
select 441, 'rogue', 'universal', 11, 'Foundational Networks IV', 'Increases the Credits, Industry and Research output of this planet by 4', 'all resources', 'output', 4 union 
select 442, 'rogue', 'universal', 13, 'Secure Trade Routes II', 'Increases the Credits output of this planet by 3', 'credits', 'output', 3 union 
select 443, 'rogue', 'universal', 14, 'Secure Trade Routes III', 'Increases the Credits output of this planet by 5', 'credits', 'output', 5 union 
select 444, 'rogue', 'universal', 21, 'Advanced Research Lab III', 'Increases the Research output of this planet by 5', 'research', 'output', 5 union 
select 445, 'rogue', 'universal', 23, 'Orbital Storage System I', 'Increases your maximum Industry capacity by 30', 'industry', 'capacity', 30 union 
select 446, 'rogue', 'universal', 25, 'Orbital Storage System III', 'Increases your maximum Industry capacity by 100', 'industry', 'capacity', 100 union 
select 447, 'rogue', 'universal', 26, 'Intergalactic Credit Exchange I', 'Increases your maximum Credits capacity by 30', 'credits', 'capacity', 30 union 
select 448, 'rogue', 'universal', 27, 'Intergalactic Credit Exchange II', 'Increases your maximum Credits capacity by 50', 'credits', 'capacity', 50 union 
select 449, 'rogue', 'universal', 28, 'Intergalactic Credit Exchange III', 'Increases your maximum Credits capacity by 100', 'credits', 'capacity', 100 union 
select 450, 'rogue', 'universal', 41, 'L2 Discovery Probe Workshop', 'Allows you to craft the L2 Discovery Probes', 'workshop', null, null union 
select 451, 'rogue', 'universal', 44, 'Category-C1 Probe Workshop', 'Allows you to craft the TP-PL1 and NP-PL1 Preparation Probes', 'workshop', null, null union 
select 452, 'rogue', 'universal', 45, 'Category-C2 Probe Workshop', 'Allows you to craft the OA-PL1 and AE-PL1 Preparation Probes', 'workshop', null, null union 
select 453, 'rogue', 'universal', 49, 'Category-R2 Probe Workshop', 'Allows you to craft the Mi-PL1 and Tc-PL1 Preparation Probes', 'workshop', null, null union 
select 454, 'terrestrial', 'basic', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 455, 'terrestrial', 'basic', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 456, 'terrestrial', 'basic', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 457, 'terrestrial', 'basic', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 458, 'terrestrial', 'basic', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 459, 'terrestrial', 'basic', 8, 'Foundational Networks I', 'Increases the Credits, Industry and Research output of this planet by 1', 'all resources', 'output', 1 union 
select 460, 'terrestrial', 'basic', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 461, 'terrestrial', 'basic', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 462, 'terrestrial', 'basic', 40, 'L1 Discovery Probe Workshop', 'Allows you to craft the L1 Discovery Probes', 'workshop', null, null union 
select 463, 'terrestrial', 'basic', 42, 'Category-A1 Probe Workshop', 'Allows you to craft the Ba-PL1 and Si-PL1 Preparation Probes', 'workshop', null, null union 
select 464, 'terrestrial', 'basic', 43, 'Category-A2 Probe Workshop', 'Allows you to craft the El-PL1 and Ho-PL1 Preparation Probes', 'workshop', null, null union 
select 465, 'terrestrial', 'basic', 46, 'Category-U1 Probe Workshop', 'Allows you to craft the PN-PL1 and YN-PL1 Preparation Probes', 'workshop', null, null union 
select 466, 'terrestrial', 'basic', 47, 'Category-U2 Probe Workshop', 'Allows you to craft the MH-PL1 and HX-PL1 Preparation Probes', 'workshop', null, null union 
select 467, 'terrestrial', 'basic', 48, 'Category-R1 Probe Workshop', 'Allows you to craft the Bp-PL1 and Io-PL1 Preparation Probes', 'workshop', null, null union 
select 468, 'terrestrial', 'basic', 49, 'Category-R2 Probe Workshop', 'Allows you to craft the Mi-PL1 and Tc-PL1 Preparation Probes', 'workshop', null, null union 
select 469, 'terrestrial', 'credits', 1, 'Trade Route', 'Increases the Credits output of this planet by 1', 'credits', 'output', 1 union 
select 470, 'terrestrial', 'credits', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 471, 'terrestrial', 'credits', 12, 'Secure Trade Routes I', 'Increases the Credits output of this planet by 2', 'credits', 'output', 2 union 
select 472, 'terrestrial', 'credits', 13, 'Secure Trade Routes II', 'Increases the Credits output of this planet by 3', 'credits', 'output', 3 union 
select 473, 'terrestrial', 'credits', 14, 'Secure Trade Routes III', 'Increases the Credits output of this planet by 5', 'credits', 'output', 5 union 
select 474, 'terrestrial', 'credits', 26, 'Intergalactic Credit Exchange I', 'Increases your maximum Credits capacity by 30', 'credits', 'capacity', 30 union 
select 475, 'terrestrial', 'credits', 27, 'Intergalactic Credit Exchange II', 'Increases your maximum Credits capacity by 50', 'credits', 'capacity', 50 union 
select 476, 'terrestrial', 'credits', 28, 'Intergalactic Credit Exchange III', 'Increases your maximum Credits capacity by 100', 'credits', 'capacity', 100 union 
select 477, 'terrestrial', 'credits', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 478, 'terrestrial', 'credits', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 479, 'terrestrial', 'credits', 45, 'Category-C2 Probe Workshop', 'Allows you to craft the OA-PL1 and AE-PL1 Preparation Probes', 'workshop', null, null union 
select 480, 'terrestrial', 'industry', 3, 'Resource Depositories', 'Increases your maximum Industry capacity by 10', 'industry', 'capacity', 10 union 
select 481, 'terrestrial', 'industry', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 482, 'terrestrial', 'industry', 16, 'Production Facility II', 'Increases the Industry output of this planet by 3', 'industry', 'output', 3 union 
select 483, 'terrestrial', 'industry', 17, 'Production Facility III', 'Increases the Industry output of this planet by 5', 'industry', 'output', 5 union 
select 484, 'terrestrial', 'industry', 23, 'Orbital Storage System I', 'Increases your maximum Industry capacity by 30', 'industry', 'capacity', 30 union 
select 485, 'terrestrial', 'industry', 24, 'Orbital Storage System II', 'Increases your maximum Industry capacity by 50', 'industry', 'capacity', 50 union 
select 486, 'terrestrial', 'industry', 25, 'Orbital Storage System III', 'Increases your maximum Industry capacity by 100', 'industry', 'capacity', 100 union 
select 487, 'terrestrial', 'industry', 33, 'Core Energy Extractor II', 'Increases the Industry output of this planet by 4, but decreases both Credits and Research output by 1', 'mixed', 'output', 4  union 
select 488, 'terrestrial', 'industry', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 489, 'terrestrial', 'industry', 41, 'L2 Discovery Probe Workshop', 'Allows you to craft the L2 Discovery Probes', 'workshop', null, null union 
select 490, 'terrestrial', 'industry', 44, 'Category-C1 Probe Workshop', 'Allows you to craft the TP-PL1 and NP-PL1 Preparation Probes', 'workshop', null, null union 
select 491, 'terrestrial', 'research', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 492, 'terrestrial', 'research', 19, 'Advanced Research Lab I', 'Increases the Research output of this planet by 2', 'research', 'output', 2 union 
select 493, 'terrestrial', 'research', 20, 'Advanced Research Lab II', 'Increases the Research output of this planet by 3', 'research', 'output', 3 union 
select 494, 'terrestrial', 'research', 21, 'Advanced Research Lab III', 'Increases the Research output of this planet by 5', 'research', 'output', 5 union 
select 495, 'terrestrial', 'research', 35, 'Celestial Research Academy I', 'Increases the Research output of this planet by 3, but decreases both Credits and Industry output by 1', 'mixed', 'output', 3  union 
select 496, 'terrestrial', 'research', 36, 'Celestial Research Academy II', 'Increases the Research output of this planet by 4, but decreases both Credits and Industry output by 1', 'mixed', 'output', 4  union 
select 497, 'terrestrial', 'research', 38, 'Rift Generator', 'Springboard for Rift Travel', 'rift', null, null union 
select 498, 'terrestrial', 'research', 39, 'Rift Marker', 'Beacon for Rift Travel', 'rift', null, null union 
select 499, 'terrestrial', 'universal', 2, 'Research Habitats', 'Increases the Research output of this planet by 1', 'research', 'output', 1 union 
select 500, 'terrestrial', 'universal', 4, 'Resource Extraction Facilities', 'Increases the Industry output of this planet by 1', 'industry', 'output', 1 union 
select 501, 'terrestrial', 'universal', 5, 'Trade Station', 'Increases your maximum Credits capacity by 10', 'credits', 'capacity', 10 union 
select 502, 'terrestrial', 'universal', 8, 'Foundational Networks I', 'Increases the Credits, Industry and Research output of this planet by 1', 'all resources', 'output', 1 union 
select 503, 'terrestrial', 'universal', 9, 'Foundational Networks II', 'Increases the Credits, Industry and Research output of this planet by 2', 'all resources', 'output', 2 union 
select 504, 'terrestrial', 'universal', 10, 'Foundational Networks III', 'Increases the Credits, Industry and Research output of this planet by 3', 'all resources', 'output', 3 union 
select 505, 'terrestrial', 'universal', 11, 'Foundational Networks IV', 'Increases the Credits, Industry and Research output of this planet by 4', 'all resources', 'output', 4 union 
select 506, 'terrestrial', 'universal', 14, 'Secure Trade Routes III', 'Increases the Credits output of this planet by 5', 'credits', 'output', 5 union 
select 507, 'terrestrial', 'universal', 15, 'Production Facility I', 'Increases the Industry output of this planet by 2', 'industry', 'output', 2 union 
select 508, 'terrestrial', 'universal', 17, 'Production Facility III', 'Increases the Industry output of this planet by 5', 'industry', 'output', 5 union 
select 509, 'terrestrial', 'universal', 19, 'Advanced Research Lab I', 'Increases the Research output of this planet by 2', 'research', 'output', 2 union 
select 510, 'terrestrial', 'universal', 21, 'Advanced Research Lab III', 'Increases the Research output of this planet by 5', 'research', 'output', 5 union 
select 511, 'terrestrial', 'universal', 23, 'Orbital Storage System I', 'Increases your maximum Industry capacity by 30', 'industry', 'capacity', 30 union 
select 512, 'terrestrial', 'universal', 25, 'Orbital Storage System III', 'Increases your maximum Industry capacity by 100', 'industry', 'capacity', 100 union 
select 513, 'terrestrial', 'universal', 27, 'Intergalactic Credit Exchange II', 'Increases your maximum Credits capacity by 50', 'credits', 'capacity', 50 union 
select 514, 'terrestrial', 'universal', 28, 'Intergalactic Credit Exchange III', 'Increases your maximum Credits capacity by 100', 'credits', 'capacity', 100 union 
select 515, 'terrestrial', 'universal', 40, 'L1 Discovery Probe Workshop', 'Allows you to craft the L1 Discovery Probes', 'workshop', null, null union 
select 516, 'terrestrial', 'universal', 41, 'L2 Discovery Probe Workshop', 'Allows you to craft the L2 Discovery Probes', 'workshop', null, null union 
select 517, 'terrestrial', 'universal', 45, 'Category-C2 Probe Workshop', 'Allows you to craft the OA-PL1 and AE-PL1 Preparation Probes', 'workshop', null, null;
