set schema 'public';

/*
drop table if exists planets;
drop table if exists planet_specials;
drop table if exists planet_upgrades;
drop table if exists planet_collectibles;
drop table if exists planet_deposits;
drop table if exists planet_deposits_discovered;
drop table if exists planet_deposits_undiscovered;
drop table if exists planet_owners;
*/

create table if not exists planets (
    planet_id integer not null constraint pk_planets primary key,
    generation varchar(10) not null,
    name varchar(50) not null,
    region varchar(50) not null,
    sector varchar(50) not null,
    type varchar(20) not null,
    rarity varchar(10) not null,
    credits integer not null,
    industry integer not null,
    research integer not null,
    surface varchar(30) not null,
    atmosphere varchar(30) not null,
    moons integer not null,
    temperature integer not null,
    radius integer not null,
    mass varchar(20) not null,
    gravity numeric(5,2) not null,
    description varchar(500) not null,
    box_id integer null,
    box_opened boolean null,
    image varchar(100) not null,
    external_link varchar(100) not null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp null
);

create table if not exists planet_specials (
    id bigint not null constraint pk_planet_specials primary key,
    planet_id integer not null,
    name varchar(50) not null,
    description varchar(300) not null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp null
);

create table if not exists planet_upgrades (
    upgrade_slot_id integer not null constraint pk_planet_upgrades primary key,
    planet_id integer not null,
    upgrade_slot_type varchar(50) not null,
    upgrade_id integer null,
    upgrade_name varchar(50) null,
    upgrade_description varchar(300) null,
    completion_time timestamp null,
    updated_at timestamp null
);

create table if not exists planet_collectibles (
    planet_collectible_id integer not null constraint pk_planet_collectibles primary key,
    planet_id integer not null,
    collection_id integer not null,
    type varchar(10) not null,
    name varchar(50) not null,
    item_number smallint not null,
    title varchar(50) null,
    author varchar(50) not null,
    pieces smallint not null,
    total_copies smallint not null,
    copy_number smallint not null,
    collectible_image varchar(100) null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp null
);

create table if not exists planet_deposits (
    planet_layer_id integer not null constraint pk_planet_deposits primary key,
    planet_id integer not null,
    layer_number smallint not null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp null
);

create table if not exists planet_deposits_discovered (
    planet_layer_material_id integer not null constraint pk_planet_deposits_discovered primary key,
    planet_id integer not null,
    planet_layer_id integer not null,
    item_id smallint not null,
    item_name varchar(50) not null,
    item_description varchar(300) not null,
    image_path varchar(100) not null,
    material_rarity varchar(20) not null,
    total_amount integer not null,
    prepared_amount integer not null,
    extracted_amount integer not null,
    preparable_amount integer not null,
    extractable_amount integer not null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp null
);

create table if not exists planet_deposits_undiscovered (
    id bigint not null constraint pk_planet_deposits_undiscovered primary key,
    planet_layer_id integer not null,
    size varchar(20) not null,
    image_path varchar(100) null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp null
);

create table if not exists planet_owners (
    planet_id integer not null constraint pk_planet_owners primary key,
    owner varchar(50) null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp null
);

/*
select * from planets;
select * from planet_upgrades;
select * from planet_specials;
select * from planet_collectibles;
select * from planet_deposits;
select * from planet_deposits_discovered;
select * from planet_deposits_undiscovered;
select * from planet_owners;
*/
