import os
import requests
import pandas as pd
import sqlalchemy as db
from dotenv import load_dotenv
from typing import Optional, Dict, List
from iconsdk.icon_service import IconService
from iconsdk.providers.http_provider import HTTPProvider
from iconsdk.builder.call_builder import CallBuilder

# load env variables
load_dotenv()
db_string = os.getenv('DB_STRING')
db_schema = os.getenv('DB_SCHEMA')

# create db engine
db_engine = db.create_engine(db_string)

# Project Nebula contracts
NebulaPlanetTokenCx = "cx57d7acf8b5114b787ecdd99ca460c2272e4d9135"
NebulaSpaceshipTokenCx = "cx943cf4a4e4e281d82b15ae0564bbdcbf8114b3ec"

# connect to ICON main-net
icon_service = IconService(HTTPProvider("https://ctz.solidwallet.io", 3))


def call(to, method, params):
    call = CallBuilder().to(to).method(method).params(params).build()
    result = icon_service.call(call)
    return result

def hex_to_int(hex) -> int:
    if hex[:2] == "0x":
        return int(hex, 16)
    else:
        return int(hex)

def int_to_roman(number: int) -> str:
    num_map = [(1000, 'M'), (900, 'CM'), (500, 'D'), (400, 'CD'), (100, 'C'), (90, 'XC'),
               (50, 'L'), (40, 'XL'), (10, 'X'), (9, 'IX'), (5, 'V'), (4, 'IV'), (1, 'I')]
    result = []
    for (arabic, roman) in num_map:
        (factor, number) = divmod(number, arabic)
        result.append(roman * factor)
        if number == 0:
            break
    return "".join(result)

# source: https://blog.alexparunov.com/upserting-update-and-insert-with-pandas
def create_upsert_method(meta: db.MetaData, extra_update_fields: Optional[Dict[str, str]]):
    """
    Create upsert method that satisfied the pandas's to_sql API.
    """
    def method(table, conn, keys, data_iter):
        # select table that data is being inserted to (from pandas's context)
        sql_table = db.Table(table.name, meta, autoload=True)
        
        # list of dictionaries {col_name: value} of data to insert
        values_to_insert = [dict(zip(keys, data)) for data in data_iter]
        
        # create insert statement using postgresql dialect
        insert_stmt = db.dialects.postgresql.insert(sql_table, values_to_insert)

        # create update statement for excluded fields on conflict
        update_stmt = {exc_k.key: exc_k for exc_k in insert_stmt.excluded if exc_k.key != "created_at"}
        if extra_update_fields:
            update_stmt.update(extra_update_fields)
        
        # create upsert statement
        upsert_stmt = insert_stmt.on_conflict_do_update(
            index_elements=sql_table.primary_key.columns, # index elements are primary keys of a table
            set_=update_stmt # the SET part of an INSERT statement
        )
        
        # execute upsert statement
        conn.execute(upsert_stmt)

    return method

def data_transform_and_load(
    df_to_load: pd.DataFrame, 
    table_name: str,
    list_of_col_names: List, 
    rename_mapper: Optional[Dict[str, str]] = None, 
    extra_update_fields: Optional[Dict[str, str]] = None
):
    """
    Prep given df_to_load and load it to table_name
    """
    # check if DataFrame contains any data, if it doesn't - skip the rest
    if df_to_load.empty:
        return False

    # change json column names to match table column names
    if rename_mapper:
        df_to_load = df_to_load.rename(columns=rename_mapper, inplace=False)

    # include only necessary columns
    df_to_load = df_to_load.filter(list_of_col_names)

    # create DB metadata object that can access table names, primary keys, etc.
    meta = db.MetaData(db_engine, schema=db_schema)

    # create upsert method that is accepted by pandas API
    upsert_method = create_upsert_method(meta, extra_update_fields)

    # perform upsert of DataFrame values to the given table
    df_to_load.to_sql(
        name=table_name,
        con=db_engine,
        schema=db_schema,
        index=False,
        if_exists="append",
        chunksize=200, # it's recommended to insert data in chunks
        method=upsert_method
    )

    # if it got that far without any errors - notify a successful completion
    return True


############################################
def pull_planet_data():
    # retrieve total supply of tokens and convert hex result to int
    totalSupply = hex_to_int(call(NebulaPlanetTokenCx, "totalSupply", {}))
    planet_list = []
    planet_upgrade_list = []
    planet_specials_list = []
    planet_collectibles_list = []
    planet_deposit_list = []
    planet_deposit_discovered_list = []
    planet_deposit_undiscovered_list = []

    for tokenId in range(1, totalSupply + 1):
        #tokenInfo = requests.get(call(NebulaPlanetTokenCx, "tokenURI", {"_tokenId": tokenId})).json()
        api_url = "https://api.projectnebula.app/planets/v3/" + str(tokenId)
        tokenInfo = requests.get(api_url).json()

        if "error" in tokenInfo or "name" not in tokenInfo:
            print(tokenId, "error pulling data from API")
            continue

        print(tokenId, ":", tokenInfo["name"])
        
        df = pd.json_normalize(tokenInfo, max_level=1, sep="_")
        planet_list.append(df)

        if tokenInfo["name"] == "Undiscovered Planet":
            continue

        dfu = pd.json_normalize(tokenInfo, record_path=["upgrades"], meta=["id"])
        dfs = pd.json_normalize(tokenInfo, record_path=["specials"], meta=["id"])
        dfp = pd.json_normalize(tokenInfo, record_path=["deposits"], meta=["id"])
        dfpd = pd.json_normalize(tokenInfo["deposits"], record_path=["discoveredDeposits"])
        dfpu = pd.json_normalize(tokenInfo["deposits"], record_path=["undiscoveredDeposits"], meta=["planet_layer_id"])
        
        planet_upgrade_list.append(dfu)
        planet_specials_list.append(dfs)
        planet_deposit_list.append(dfp)
        planet_deposit_discovered_list.append(dfpd)
        planet_deposit_undiscovered_list.append(dfpu)
        
        # collectibles (odd one)
        dfc = pd.json_normalize(df["collectables_artwork"].to_list())
        if not dfc.empty:
            planet_collectibles_list.append(dfc)
        
        dfc = pd.json_normalize(df["collectables_music"].to_list())
        if not dfc.empty:
            planet_collectibles_list.append(dfc)
        
        dfc = pd.json_normalize(df["collectables_lore"].to_list())
        if not dfc.empty:
            planet_collectibles_list.append(dfc)
        
        # write to db in batches per 1000 records
        if tokenId % 1000 == 0 or tokenId == totalSupply:
            # -----------------------
            df_planets = pd.concat(planet_list)
            #df_planets.to_csv("./tests/samples/planets.csv", index=False)

            # prep and upsert data
            data_transform_and_load(
                df_to_load=df_planets,
                table_name="planets",
                list_of_col_names=[
                    "planet_id","generation","name","region","sector",
                    "type","rarity","credits","industry","research","surface",
                    "atmosphere","moons","temperature","radius","mass","gravity","description",
                    "box_id","box_opened","image","external_link"
                ],
                rename_mapper={
                    "id": "planet_id",
                    "location_region_name": "region",
                    "location_sector_name": "sector",
                    "box_box_id": "box_id"
                },
                extra_update_fields={"updated_at": "NOW()"}
            )

            # -----------------------
            df_planet_upgrades = pd.concat(planet_upgrade_list)
            #df_planet_upgrades.to_csv("./tests/samples/upgrades.csv", index=False)

            # prep and upsert data
            data_transform_and_load(
                df_to_load=df_planet_upgrades,
                table_name="planet_upgrades",
                list_of_col_names=[
                    "upgrade_slot_id","planet_id","upgrade_slot_type","upgrade_id",
                    "upgrade_name","upgrade_description","completion_time","updated_at"
                ]
            )

            # -----------------------
            df_planet_specials = pd.concat(planet_specials_list)
            df_planet_specials.sort_values(by=["id", "name"], inplace=True) # just in case as there's no PK on this dataset
            df_planet_specials["idx"] = df_planet_specials["id"] * 1000000 + df_planet_specials.index + 1 # generated PK
            #df_planet_specials.to_csv("./tests/samples/specials.csv", index=False)

            # prep and upsert data
            data_transform_and_load(
                df_to_load=df_planet_specials,
                table_name="planet_specials",
                list_of_col_names=[
                    "id", "planet_id", "name", "description"
                ],
                rename_mapper={
                    "id": "planet_id",
                    "idx": "id"
                },
                extra_update_fields={"updated_at": "NOW()"}
            )

            # -----------------------
            df_planet_collectibles = pd.concat(planet_collectibles_list)
            #df_planet_collectibles.to_csv("./tests/samples/collectibles.csv", index=False)

            # prep and upsert data
            data_transform_and_load(
                df_to_load=df_planet_collectibles,
                table_name="planet_collectibles",
                list_of_col_names=[
                    "planet_collectible_id","planet_id","collection_id","type","name","item_number",
                    "title","author","pieces","total_copies","copy_number","collectible_image"
                ],
                rename_mapper={
                    "planet_collectable_id": "planet_collectible_id",
                    "collectable_image": "collectible_image"
                },
                extra_update_fields={"updated_at": "NOW()"}
            )

            # -----------------------
            df_planet_deposits = pd.concat(planet_deposit_list)
            #df_planet_deposits.to_csv("./tests/samples/deposits.csv", index=False)

            # prep and upsert data
            data_transform_and_load(
                df_to_load=df_planet_deposits,
                table_name="planet_deposits",
                list_of_col_names=[
                    "planet_id","planet_layer_id","layer_number"
                ],
                rename_mapper={
                    "id": "planet_id",
                    "layerNumber": "layer_number"
                },
                extra_update_fields={"updated_at": "NOW()"}
            )

            df_planet_deposits_discovered = pd.concat(planet_deposit_discovered_list)
            #df_planet_deposits_discovered.to_csv("./tests/samples/deposits_discovered.csv", index=False)

            # prep and upsert data
            data_transform_and_load(
                df_to_load=df_planet_deposits_discovered,
                table_name="planet_deposits_discovered",
                list_of_col_names=[
                    "planet_layer_material_id","planet_id","planet_layer_id","item_id","item_name","item_description","image_path",
                    "material_rarity","total_amount","prepared_amount","extracted_amount","preparable_amount","extractable_amount"
                ],
                extra_update_fields={"updated_at": "NOW()"}
            )

            df_planet_deposits_undiscovered = pd.concat(planet_deposit_undiscovered_list)
            df_planet_deposits_undiscovered["idx"] = df_planet_deposits_undiscovered["planet_layer_id"] * 1000000 + df_planet_deposits_undiscovered.index + 1 # generated PK
            #df_planet_deposits_undiscovered.to_csv("./tests/samples/deposits_undiscovered.csv", index=False)

            # prep and upsert data
            data_transform_and_load(
                df_to_load=df_planet_deposits_undiscovered,
                table_name="planet_deposits_undiscovered",
                list_of_col_names=[
                    "id","planet_layer_id","size","image_path"
                ],
                rename_mapper={
                    "idx": "id"
                },
                extra_update_fields={"updated_at": "NOW()"}
            )


############################################
def pull_planet_owners():
    # retrieve total supply of tokens and convert hex result to int
    totalSupply = hex_to_int(call(NebulaPlanetTokenCx, "totalSupply", {}))
    # retrieve current owners
    planet_owner_list = []

    for tokenId in range(1001, totalSupply + 1):
        try:
            owner = call(NebulaPlanetTokenCx, "ownerOf", {"_tokenId": tokenId})
        except:
            # likely reason: >> SCOREError(-30032): E0032:Invalid _tokenId. NFT is burned
            continue

        print(tokenId, ":", owner)
        planet_owner_list.append([tokenId, owner])

        # write to db in batches per 1000 records
        if tokenId % 1000 == 0 or tokenId == totalSupply:
            df_planet_owners = pd.DataFrame(planet_owner_list, columns=["planet_id","owner"])
            #df_planet_owners.to_csv("./tests/samples/owners.csv", index=False)

            # prep and upsert data
            data_transform_and_load(
                df_to_load=df_planet_owners,
                table_name="planet_owners",
                list_of_col_names=[
                    "planet_id","owner"
                ],
                extra_update_fields={"updated_at": "NOW()"}
            )


############################################
def pull_ship_data():
    # retrieve total supply of tokens and convert hex result to int
    totalSupply = hex_to_int(call(NebulaSpaceshipTokenCx, "totalSupply", {}))
    ship_list = []
    ship_ability_list = []

    for tokenId in range(1, totalSupply + 1):
        #tokenInfo = requests.get(call(NebulaSpaceshipTokenCx, "tokenURI", {"_tokenId": tokenId})).json()
        api_url = "https://api.projectnebula.app/ship/" + str(tokenId)
        tokenInfo = requests.get(api_url).json()

        if "error" in tokenInfo or "model_name" not in tokenInfo:
            print(tokenId, "error pulling data from API")
            continue
        
        print(tokenId, ":", tokenInfo["model_name"])
        
        df = pd.json_normalize(tokenInfo, max_level=1, sep="_")
        dfa = pd.json_normalize(tokenInfo, record_path=["abilities"], meta=["ship_id"])

        ship_list.append(df)
        ship_ability_list.append(dfa)

        # write to db in batches per 1000 records
        if tokenId % 1000 == 0 or tokenId == totalSupply:
            # -----------------------
            df_ships = pd.concat(ship_list)
            #df_ships.to_csv("./tests/samples/ships.csv", index=False)

            # prep and upsert data
            data_transform_and_load(
                df_to_load=df_ships,
                table_name="ships",
                list_of_col_names=[
                    "ship_id","generation","model_name","given_name","type","tier","set_type",
                    "fuel","movement","exploration","colonization","available_fuel","deploy_bonus_cooldown",
                    "description","bonus_text","special","image","external_link"
                ],
                extra_update_fields={"updated_at": "NOW()"}
            )

            # -----------------------
            df_ship_abilities = pd.concat(ship_ability_list)
            #df_ship_abilities.to_csv("./tests/samples/ship_abilities.csv", index=False)

            # prep and upsert data
            data_transform_and_load(
                df_to_load=df_ship_abilities,
                table_name="ship_abilities",
                list_of_col_names=[
                    "ship_id","ship_ability_id","name","description","type","value","image_path","sound_path"
                ],
                extra_update_fields={"updated_at": "NOW()"}
            )


############################################
def pull_ship_owners():
    # retrieve total supply of tokens and convert hex result to int
    totalSupply = hex_to_int(call(NebulaSpaceshipTokenCx, "totalSupply", {}))
    # retrieve current owners
    ship_owner_list = []

    for tokenId in range(1, totalSupply + 1):
        try:
            owner = call(NebulaSpaceshipTokenCx, "ownerOf", {"_tokenId": tokenId})
        except:
            continue

        print(tokenId, ":", owner)
        ship_owner_list.append([tokenId, owner])

        # write to db in batches per 1000 records
        if tokenId % 1000 == 0 or tokenId == totalSupply:
            df_ship_owners = pd.DataFrame(ship_owner_list, columns=["ship_id","owner"])
            df_ship_owners.to_csv("./tests/samples/ship_owners.csv", index=False)

            # prep and upsert data
            data_transform_and_load(
                df_to_load=df_ship_owners,
                table_name="ship_owners",
                list_of_col_names=[
                    "ship_id","owner"
                ],
                extra_update_fields={"updated_at": "NOW()"}
            )


############################################
def pull_item_data():
    totalSupply = 131 # ???
    item_list = []

    for tokenId in range(1, 6): # range(1, totalSupply + 1):
        #tokenInfo = requests.get(call(NebulaSpaceshipTokenCx, "tokenURI", {"_tokenId": tokenId})).json()
        api_url = "https://api.projectnebula.app/item/" + str(tokenId)
        tokenInfo = requests.get(api_url).json()
        print(tokenId, ":", tokenInfo["name"])
        
        df = pd.json_normalize(tokenInfo, max_level=1, sep="_")
        item_list.append(df)

    # -----------------------
    df_items = pd.concat(item_list)
    df_items.to_csv("./tests/samples/items.csv", index=False)

    # prep and upsert data
    data_transform_and_load(
        df_to_load=df_items,
        table_name="items",
        list_of_col_names=[
            "item_id","type","name","type_color","description","flavor_text","effect","image_path"
        ],
        extra_update_fields={"updated_at": "NOW()"}
    )


############################################
def pull_item_owners():
    pass
    # userTokenBalances (address, offset=0) - loop through unique list of wallets based on planet and ship owners


############################################
#pull_planet_data()
#pull_planet_owners()
#pull_ship_data()
#pull_ship_owners()
#pull_item_data()
