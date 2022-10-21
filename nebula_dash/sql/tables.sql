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
drop table if exists ships;
drop table if exists ship_abilities;
drop table if exists ship_owners;
drop table if exists items;
drop table if exists trxn;
drop table if exists trxn_data;
drop table if exists trxn_events;
*/

create table if not exists planets (
    planet_id integer not null constraint pk_planets primary key,
    generation varchar(10) not null,
    name varchar(50) not null,
    region varchar(50) null,
    sector varchar(50) null,
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
    mass varchar(40) not null,
    gravity varchar(40) not null,
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

create table if not exists ships (
    ship_id integer not null constraint pk_ships primary key,
    generation varchar(10) not null,
    model_name varchar(100) not null,
    given_name varchar(100) null,
    type varchar(30) not null,
    tier varchar(10) not null,
    set_type varchar(30) not null,
    fuel smallint not null,
    movement smallint not null,
    exploration smallint not null,
    colonization smallint not null,
    available_fuel integer null,
    deploy_bonus_cooldown varchar(30) null,
    description varchar(500) not null,
    bonus_text varchar(500) null,
    special varchar(200) null,
    image varchar(100) not null,
    external_link varchar(100) not null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp null
);

create table if not exists ship_abilities (
    ship_id integer not null constraint pk_ship_abilities primary key,
    ship_ability_id integer not null,
    name varchar(50) not null,
    description varchar(300) not null,
    type varchar(30) not null,
    value smallint not null,
    image_path varchar(100) not null,
    sound_path varchar(100) null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp null
);

create table if not exists ship_owners (
    ship_id integer not null constraint pk_ship_owners primary key,
    owner varchar(50) null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp null
);

create table if not exists items (
    item_id integer not null constraint pk_items primary key,
    type varchar(50) not null,
    name varchar(100) not null,
    type_color varchar(30) null,
    description varchar(500) not null,
    flavor_text varchar(500) not null,
    effect varchar(100) null,
    image_path varchar(100) not null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp null
);

create table if not exists item_owners (
    item_id integer not null,
    owner varchar(50) not null,
    total smallint null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp null,
    constraint pk_item_owners primary key (item_id, owner)
);

create table if not exists trxn (
    tx_id bigint not null constraint pk_trxn primary key,
    block_height bigint not null,
    tx_hash varchar(200) not null,
    timestamp bigint not null,
    from_address varchar(50) not null,
    to_address varchar(50) not null,
    value numeric(50,0) not null,
    data_method varchar(100) null,
    data_params varchar(1000) null,
    data_type varchar(50) not null,
    nid integer null,
    nonce smallint null,
    step_limit bigint not null,
    signature varchar(200) not null,
    version smallint not null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp null,
    data_content_type varchar(50) null,
    data_content text null
);

create table if not exists trxn_data (
    tx_data_id bigint not null constraint pk_trxn_data primary key,
    block_height bigint not null,
    tx_hash varchar(200) not null,
    method varchar(100) null,
    token_id integer null,
    params__to varchar(50) null,
    params__token_id varchar(50) null,
    params__token_id_2 varchar(50) null,
    params__order_id varchar(50) null,
    params__amount varchar(50) null,
    params__price varchar(50) null,
    params__starting_price varchar(50) null,
    params__duration_in_hours varchar(50) null,
    params__address varchar(50) null,
    params__token_uri varchar(50) null,
    params_tx_hash varchar(200) null,
	created_at timestamp not null default current_timestamp,
    updated_at timestamp null,
    params__id varchar(50) null,
    params__from varchar(50) null,
    params__value varchar(50) null,
    params__owner varchar(50) null,
    params__ids varchar(50) null,
    params__amounts varchar(50) null,
    params__transfer_id varchar(50) null
);

create table if not exists trxn_events (
    tx_event_id bigint not null constraint pk_trxn_events primary key,
    block_height bigint not null,
    tx_hash varchar(200) not null,
    status smallint not null,
    to_address varchar(50) not null,
    score_address varchar(50) not null,
    indexed varchar(1000) null,
    data varchar(1000) null,
    tx_index smallint not null,
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
select * from ships;
select * from ship_abilities;
select * from ship_owners;
select * from items;
select * from trxn;
select * from trxn_data;
select * from trxn_events;
*/
