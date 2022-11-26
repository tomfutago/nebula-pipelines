update trxn_data set params__order_id = replace(params__order_id, '.0', '') where params__order_id is not null;
update trxn_data set params__amount = replace(params__amount, '.0', '') where params__amount is not null;
update trxn_data set params__duration_in_hours = replace(params__duration_in_hours, '.0', '') where params__duration_in_hours is not null;
update trxn_data set params__id = replace(params__id, '.0', '') where params__id is not null;
update trxn_data set params__transfer_id = replace(params__transfer_id, '.0', '') where params__transfer_id is not null;
