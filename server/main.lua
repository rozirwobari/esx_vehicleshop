ESX = exports["es_extended"]:getSharedObject()

lib.callback.register('esx-vehicleshop:server:getCategory', function(source)
    local category = MySQL.query.await('SELECT * FROM vehicle_categories', {})
	return category
end)

lib.callback.register('esx-vehicleshop:server:getKendaraan', function(source, category)
    local kendaraan = MySQL.query.await('SELECT * FROM vehicles WHERE category = ?', {
		category
	})
	return kendaraan
end)

lib.callback.register('esx-vehicleshop:server:chekedMoney', function(source, price)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem('money').count >= price then
		return true
	else
		return false
	end
end)

lib.callback.register('esx-vehicleshop:server:setVehicleData', function(source, vehicleProps, type, price)
	local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.query.await('INSERT INTO owned_vehicles (owner, plate, vehicle, type) VALUES (?, ?, ?, ?)', {
		xPlayer.identifier,
		vehicleProps.plate,
		json.encode(vehicleProps),
		type,
	})
	xPlayer.removeInventoryItem('money', price)
end)

lib.callback.register('esx-vehicleshop:server:chekedPlateOwner', function(source, plate)
    local kendaraan = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = ?', {
		plate
	})
	if #kendaraan >= 1 then
		return false
	else
		return true
	end
end)