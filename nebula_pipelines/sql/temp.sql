create or replace view vw_planet_deposits_undiscovered as
select pd.planet_id, pdu.planet_layer_id
from planet_deposits pd
 join planet_deposits_undiscovered pdu on pd.planet_layer_id = pdu.planet_layer_id;
