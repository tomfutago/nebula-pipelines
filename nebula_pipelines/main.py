import os, sys
import requests
import numpy as np
import pandas as pd
import itertools as it
import sqlalchemy as db
from time import sleep
from dotenv import load_dotenv
from typing import Optional, Dict, List
from iconsdk.icon_service import IconService
from iconsdk.providers.http_provider import HTTPProvider
from iconsdk.builder.call_builder import CallBuilder
from discord_webhook import DiscordWebhook

# load env variables
load_dotenv()
db_string = os.getenv("DATABASE_URL").replace("://", "ql://", 1) # workaround as DATABASE_URL env can't be edited on Heroku
db_schema = os.getenv("DB_SCHEMA")
discord_log_webhook = os.getenv("DISCORD_LOG_WEBHOOK")

# create db engine
db_engine = db.create_engine(db_string)

# Project Nebula contracts
NebulaPlanetTokenCx = "cx57d7acf8b5114b787ecdd99ca460c2272e4d9135"
NebulaSpaceshipTokenCx = "cx943cf4a4e4e281d82b15ae0564bbdcbf8114b3ec"
NebulaTokenClaimingCx = "cx4bfc45b11cf276bb58b3669076d99bc6b3e4e3b8"
NebulaMultiTokenCx = "cx85954d0dae92b63bf5cba03a59ca4ffe687bad0a"
# additional wallets
NebulaNonCreditClaim = "hx888ed0ff5ebc119e586b5f3d4a0ef20eaa0ed123"
NebulaMultiTokenTreasurer = "hx82ea662ea6e8484068f0d3c57ebab570cf6ce478"
NebulaMultiTokenMinter = "hxfa1d8823122048bdd171687330d0d52e0c7b3e6b"
# contracts combined:
NebulaCxList = [NebulaPlanetTokenCx, NebulaSpaceshipTokenCx, NebulaTokenClaimingCx, NebulaMultiTokenCx]

# connect to ICON main-net
icon_service = IconService(HTTPProvider("https://ctz.solidwallet.io", 3))


# helper functions
def hex_to_int(hex) -> int:
    try:
        if hex[:2] == "0x":
            return int(hex, 16)
        else:
            return int(hex)
    except:
        return None

def dict_to_str(d):
    try:
        return "[" + str(d) + "]"
    except:
        return None

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

# icon service call
def call(to, method, params):
    call = CallBuilder().to(to).method(method).params(params).build()
    result = icon_service.call(call)
    return result

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

def get_table_max_val(table_name: str, column_name: str):
    """
    Get MAX(column_name) for given table_name
    """
    sql = 'SELECT MAX({}) AS max_val FROM {}.{};'.format(column_name, db_schema, table_name)
    with db_engine.connect() as conn:
        result = conn.execute(statement=sql)
        for row in result:
            max_val = row.max_val
        if max_val is None:
            max_val = 0
    return max_val

# function for sending error msg to discord webhook
def send_log_to_webhook(block_height: int, txHash: str, error: str):
    err_msg = "Nebula Pipelines log"
    err_msg += "\nblock_height: " + str(block_height)
    err_msg += "\ntxHash: " + txHash
    err_msg += "\nERROR: " + error
    err_msg += "\n"
    print("1..")
    webhook = DiscordWebhook(url=discord_log_webhook, rate_limit_retry=True, content=err_msg)
    print("2..")
    response = webhook.execute()
    print("3..")
    return response


############################################
def pull_planet_data():
    # retrieve total supply of tokens and convert hex result to int
    #totalSupply = hex_to_int(call(NebulaPlanetTokenCx, "totalSupply", {}))
    totalSupply = 7000 # temp setting as total doesnt match result from the call ^
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
        
        if tokenInfo["name"] != "Undiscovered Planet":
            df = pd.json_normalize(tokenInfo, max_level=1, sep="_")
            dfu = pd.json_normalize(tokenInfo, record_path=["upgrades"], meta=["id"])
            dfs = pd.json_normalize(tokenInfo, record_path=["specials"], meta=["id"])
            dfp = pd.json_normalize(tokenInfo, record_path=["deposits"], meta=["id"])
            dfpd = pd.json_normalize(tokenInfo["deposits"], record_path=["discoveredDeposits"])
            dfpu = pd.json_normalize(tokenInfo["deposits"], record_path=["undiscoveredDeposits"], meta=["planet_layer_id"])
            
            planet_list.append(df)
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
    #totalSupply = hex_to_int(call(NebulaPlanetTokenCx, "totalSupply", {}))
    totalSupply = 7000 # replace with sqlalchemy view listing all pulled tokenIDs
    # retrieve current owners
    planet_owner_list = []

    for tokenId in range(1, totalSupply + 1):
        try:
            owner = call(NebulaPlanetTokenCx, "ownerOf", {"_tokenId": tokenId})

            print(tokenId, ":", owner)
            planet_owner_list.append([tokenId, owner])
        except:
            # likely reason: >> SCOREError(-30032): E0032:Invalid _tokenId. NFT is burned
            pass

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
    # totalSupply : 1-131 + 10001-10144
    item_list = []

    for tokenId in it.chain(range(1, 131 + 1), range(10001, 10144 + 1)):
        #tokenInfo = requests.get(call(NebulaSpaceshipTokenCx, "tokenURI", {"_tokenId": tokenId})).json()
        api_url = "https://api.projectnebula.app/item/" + str(tokenId)

        try:
            tokenInfo = requests.get(api_url).json()
        except:
            continue
        
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
    # loop through unique list of wallets based on planet and ship owners
    sql = 'select owner from vw_unique_owners;'
    with db_engine.connect() as conn:
        query_results = conn.execute(statement=sql)
        for row in query_results:
            item_owner_list = []
            print(row.owner)
            
            try:
                items = call(NebulaMultiTokenCx, "userTokenBalances", {"_owner": row.owner, "_offset": 0})
            except:
                continue
    
            for i in items:
                print(hex_to_int(i[0]), ":", hex_to_int(i[1]))
                item_owner_list.append([hex_to_int(i[0]), row.owner, hex_to_int(i[1])])

            # write to db
            df_item_owners = pd.DataFrame(item_owner_list, columns=["item_id","owner","total"])
            df_item_owners.to_csv("./tests/samples/item_owners.csv", index=False)

            # prep and upsert data
            data_transform_and_load(
                df_to_load=df_item_owners,
                table_name="item_owners",
                list_of_col_names=[
                    "item_id","owner","total"
                ],
                extra_update_fields={"updated_at": "NOW()"}
            )


############################################
def pull_nebula_txns():
    # latest block height
    block_height = get_table_max_val(table_name="trxn", column_name="block_height")
    #block_height = icon_service.get_block("latest")["height"]

    #blocks = [29338046,29338034,29338021,29338010,29337997,29337985,29337973,29337961,29337928,29337907]
    #blocks.reverse()


    #block_height = 25353586 # first mint
    #block_height = 30593390 # last stop
    
    while True:
    #while block_height == 56861361:
    #for block_height in blocks:
        try:
            block = icon_service.get_block(block_height)
            print("block:", block_height)
        except:
            sleep(2)
            continue
        else:
            try:
                tx_list = []
                tx_data_list = []
                tx_event_list = []
                n = 0

                for tx in block["confirmed_transaction_list"]:
                    if "to" in tx:
                        if tx["to"] in NebulaCxList or tx["from"] in NebulaCxList:
                            try:
                                # trxn counter per block
                                n += 1
                                # check if tx was successful - if not skip and move on
                                txResult = icon_service.get_transaction_result(tx["txHash"])
                                # status : 1 on success, 0 on failure
                                if txResult["status"] == 0:
                                    continue

                                # -----------------------
                                # trxn
                                # -----------------------
                                df_tx = pd.json_normalize(tx, max_level=1, sep="_")
                                df_tx["block_height"] = block_height
                                df_tx["idx"] = block_height * 100000000 + n # generated PK
                                
                                # fields requiring extra attention:
                                if "value" not in df_tx:
                                    df_tx["value"] = 0
                                if "data_params" in df_tx:
                                    df_tx["data_params"] = df_tx["data_params"].apply(dict_to_str) # upsert function won't allow dict values
                                else:
                                    df_tx["data_params"] = None
                                if "data_content" not in df_tx:
                                    df_tx["data_contentType"] = None
                                    df_tx["data_content"] = None
                                
                                tx_list.append(df_tx)

                                # -----------------------
                                df_txns = pd.concat(tx_list)
                                df_txns.to_csv("./tests/samples/txns.csv", index=False)

                                # prep and upsert data
                                data_transform_and_load(
                                    df_to_load=df_tx,
                                    table_name="trxn",
                                    list_of_col_names=[
                                        "tx_id", "tx_hash","block_height","timestamp","from_address","to_address","value","data_method",
                                        "data_type","nid","nonce","step_limit","signature","version","data_params",
                                        "data_content_type","data_content"
                                    ],
                                    rename_mapper={
                                        "idx": "tx_id",
                                        "from": "from_address",
                                        "to": "to_address",
                                        "txHash": "tx_hash",
                                        "dataType": "data_type",
                                        "stepLimit": "step_limit",
                                        "data_contentType": "data_content_type"
                                    },
                                    extra_update_fields={"updated_at": "NOW()"}
                                )

                                # -----------------------
                                # trxn_data
                                # -----------------------
                                if "data" in tx:
                                    df_tx_data = pd.json_normalize(tx["data"], sep="_")
                                    # expected column list:
                                    tx_data_columns=[
                                        "block_height", "txHash", "method", "tokenId",
                                        "params__to", "params__tokenId", "params__token_id", 
                                        "params__orderId", "params__amount", "params__price",
                                        "params__starting_price", "params__duration_in_hours",
                                        "params__address", "params__token_URI", "params_txHash",
                                        "params__id","params__from","params__value","params__owner",
                                        "params__ids","params__amounts","params__transferId"
                                    ]
                                    # add missing columns:
                                    df_tx_data_cols = df_tx_data.columns.to_list()
                                    for c in tx_data_columns:
                                        if c not in df_tx_data_cols:
                                            df_tx_data[c] = None
                                    
                                    df_tx_data["block_height"] = block_height
                                    df_tx_data["idx"] = block_height * 100000000 + n # generated PK
                                    df_tx_data["txHash"] = df_tx["txHash"]
                                    df_tx_data["tokenId"] = df_tx_data["params__tokenId"].replace(np.nan, "") + df_tx_data["params__token_id"].replace(np.nan, "")
                                    df_tx_data["tokenId"] = df_tx_data["tokenId"].apply(hex_to_int)
                                    tx_data_list.append(df_tx_data)
                                
                                    # -----------------------
                                    df_tx_data = pd.concat(tx_data_list)
                                    df_tx_data.to_csv("./tests/samples/tx_data.csv", index=False)

                                    # prep and upsert data
                                    data_transform_and_load(
                                        df_to_load=df_tx_data,
                                        table_name="trxn_data",
                                        list_of_col_names=[
                                            "tx_data_id", "tx_hash","block_height","method","token_id","params__to",
                                            "params__token_id","params__token_id_2","params__order_id","params__amount",
                                            "params__price","params__starting_price","params__duration_in_hours",
                                            "params__address", "params__token_uri", "params_tx_hash",
                                            "params__id","params__from","params__value","params__owner",
                                            "params__ids","params__amounts","params__transfer_id"
                                        ],
                                        rename_mapper={
                                            "idx": "tx_data_id",
                                            "txHash": "tx_hash",
                                            "tokenId": "token_id",
                                            "params__tokenId": "params__token_id_2",
                                            "params__orderId": "params__order_id",
                                            "params__token_URI": "params__token_uri",
                                            "params_txHash": "params_tx_hash",
                                            "params__transferId": "params__transfer_id"
                                        },
                                        extra_update_fields={"updated_at": "NOW()"}
                                    )

                                # -----------------------
                                # trxn_events
                                # -----------------------
                                if "eventLogs" in txResult:
                                    df_tx_events = pd.json_normalize(
                                        txResult,
                                        record_path=["eventLogs"],
                                        meta=["blockHeight", "status", "to", "txHash", "txIndex"],
                                        sep="_"
                                    )
                                    df_tx_events["idx"] = block_height * 100000000 + n * 100 + df_tx_events.index + 1 # generated PK
                                    tx_event_list.append(df_tx_events)

                                    # -----------------------
                                    df_tx_events = pd.concat(tx_event_list)
                                    df_tx_events.to_csv("./tests/samples/txn_events.csv", index=False)

                                    # prep and upsert data
                                    data_transform_and_load(
                                        df_to_load=df_tx_events,
                                        table_name="trxn_events",
                                        list_of_col_names=[
                                            "tx_event_id","block_height","status","to_address","score_address",
                                            "indexed","data","tx_hash","tx_index"
                                        ],
                                        rename_mapper={
                                            "idx": "tx_event_id",
                                            "blockHeight": "block_height",
                                            "to": "to_address",
                                            "scoreAddress": "score_address",
                                            "txHash": "tx_hash",
                                            "txIndex": "tx_index"
                                        },
                                        extra_update_fields={"updated_at": "NOW()"}
                                    )
                            except:
                                #send to log webhook
                                err_msg = "{}. {}, line: {}".format(sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2].tb_lineno)
                                print(err_msg)
                                send_log_to_webhook(block_height, tx["txHash"], err_msg)
                                #continue
                                break
                block_height += 1
            except:
                sleep(2)
                #continue
                break


############################################
#pull_planet_data()
#pull_planet_owners()
#pull_ship_data()
#pull_ship_owners()
#pull_item_data()
#pull_item_owners()
pull_nebula_txns()
