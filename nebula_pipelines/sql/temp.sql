create table if not exists planet_deposits_undiscovered_stage (
    id bigint not null constraint pk_planet_deposits_undiscovered_stage primary key,
    planet_layer_id integer not null,
    size varchar(20) not null,
    image_path varchar(100) null,
    created_at timestamp not null default current_timestamp,
    updated_at timestamp null
);
