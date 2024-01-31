ESX = exports["es_extended"]:getSharedObject()

local lastSelectedVehicleEntity = nil
local inCam = false
local generatePlateCount = 0

Citizen.CreateThread(function ()
	local pedVehicleShop = CreatePedvehicleShop(ConfigDealer.lokasi)
	exports.ox_target:addLocalEntity(pedVehicleShop, {
		{
			label = 'Akses Dealer',
			icon = 'fa-solid fa-car-tunnel',
			onSelect = function ()
				bukaMenuShop()
			end
		}
	})
end)

function GeneratePlateDealer(panjang)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    local length = tonumber(6+panjang)
    for _ = 1, length do
        local randomIndex = math.random(1, #chars)
        result = result .. string.sub(chars, randomIndex, randomIndex)
    end
    return string.upper(result)
end

function CreatePedvehicleShop(coords)
	local modelHash = GetHashKey('csb_reporter')
	RequestModel(modelHash)
	while not HasModelLoaded(modelHash) do
		Wait(1)
	end
	local buatPedvehicleShop = CreatePed(4, modelHash ,coords.x, coords.y, coords.z, coords.w, true, false)
	SetEntityAsMissionEntity(buatPedvehicleShop, true, true)
	SetBlockingOfNonTemporaryEvents(buatPedvehicleShop, true)
	FreezeEntityPosition(buatPedvehicleShop, true)
	SetEntityInvincible(buatPedvehicleShop, true)
	return buatPedvehicleShop
end

function bukaMenuShop()
	posisiKamera()
	local getCategory  = lib.callback.await('esx-vehicleshop:server:getCategory', false)
	local menuList = {}
	for ab, cd in pairs(getCategory) do
		table.insert(menuList, {
			label = cd.label,
			args = {
				category = cd.name
			}
		})
	end
	lib.registerMenu({
		id = 'vehicle_shop_mal',
		title = 'Dealer Lokal',
		position = 'top-right',
		onClose = function(keyPressed)
			membatalkanDealerKendaraan()
		end,
		options = menuList
	}, function(selected, scrollIndex, args)
		menuVehicle(args.category)
	end)
	Wait(50)
	lib.showMenu('vehicle_shop_mal')
end

function menuVehicle(category)
	local getKendaraan = lib.callback.await('esx-vehicleshop:server:getKendaraan', false, category)
	local menuListKendaraan = {}
	for ab, cd in pairs(getKendaraan) do
		table.insert(menuListKendaraan, {
			label = cd.name,
			args = {
				model = cd.model,
				harga = cd.price,
			}
		})
	end
	lib.registerMenu({
		id = 'vehicle_shop_mal_kendaraan',
		title = 'Dealer Lokal',
		position = 'top-right',
		onSelected = function(selected, secondary, args)
			spawnVehicle(args.model)
		end,
		onClose = function(keyPressed)
			if lastSelectedVehicleEntity ~= nil then
                DeleteEntity(lastSelectedVehicleEntity)
                lastSelectedVehicleEntity = nil
            end
            lib.showMenu('vehicle_shop_mal')
		end,
		options = menuListKendaraan
	}, function(selected, scrollIndex, args)
		local uangSaya = lib.callback.await('esx-vehicleshop:server:chekedMoney', false, args.harga)
		if uangSaya then
			beliKendaraanDealer(args.model, args.harga)
		else
			TriggerEvent('mythic_notify:client:SendAlert', { type = 'error', text = 'Uang Kamu Tidak Cukup...' })
			lib.showMenu('vehicle_shop_mal_kendaraan')
		end
	end)
	Wait(50)
	lib.showMenu('vehicle_shop_mal_kendaraan')
end


function spawnVehicle(vehicle)
    local model = lib.requestModel(vehicle)
    if not model then return end
    if lastSelectedVehicleEntity ~= nil then
        DeleteEntity(lastSelectedVehicleEntity)
    end
	lastSelectedVehicleEntity = CreateVehicle(model, ConfigDealer.spawnShop, false, true)
    local heading = GetEntityHeading(lastSelectedVehicleEntity)
    Citizen.CreateThread(function()
        while inCam do
            Wait(0)
            DisableControlAction(0, 34, true) -- A
            DisableControlAction(0, 30, true) -- D
            if IsControlPressed(0, 9) then    -- Right
                heading = heading + 5
                SetEntityHeading(lastSelectedVehicleEntity, heading)
            elseif IsControlPressed(0, 63) then -- Left
                heading = heading - 5
                SetEntityHeading(lastSelectedVehicleEntity, heading)
            end
        end
    end)
end

function posisiKamera()
    inCam = true
    Citizen.CreateThread(function()
        while inCam do
            Wait(1)
            InfoKeybind()
        end
    end)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    FreezeEntityPosition(cache.ped, true)

    if not DoesCamExist(cam) then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 250, 1, 0)
        SetCamCoord(cam, ConfigDealer.spawnShopCam.x, ConfigDealer.spawnShopCam.y, ConfigDealer.spawnShopCam.z + 1.5)
        SetCamRot(cam, -25.0, 0.0, ConfigDealer.spawnShopCam.w, 0.0)
    else
        kameraNormal()
        Wait(500)
        posisiKamera()
    end
end

function membatalkanDealerKendaraan()
	if lastSelectedVehicleEntity ~= nil then
		DeleteEntity(lastSelectedVehicleEntity)
		lastSelectedVehicleEntity = nil
	end
	kameraNormal()
	lib.hideMenu(true)
end

function kameraNormal()
    FreezeEntityPosition(PlayerPedId(), false)
    RenderScriptCams(false, true, 250, 1, 0)
    DestroyCam(cam, false)
    inCam = false
end

function InfoKeybind()
    Scale = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS");
    while not HasScaleformMovieLoaded(Scale) do
        Citizen.Wait(0)
    end

    BeginScaleformMovieMethod(Scale, "CLEAR_ALL");
    EndScaleformMovieMethod();

    --Right
    BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT");
    ScaleformMovieMethodAddParamInt(0);
    PushScaleformMovieMethodParameterString("~INPUT_MOVE_RIGHT_ONLY~");
    PushScaleformMovieMethodParameterString("Putar Kanan");
    EndScaleformMovieMethod();

    --Left
    BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT");
    ScaleformMovieMethodAddParamInt(1);
    PushScaleformMovieMethodParameterString("~INPUT_MOVE_LEFT_ONLY~");
    PushScaleformMovieMethodParameterString("Putar Kiri");
    EndScaleformMovieMethod();

    BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT");
    ScaleformMovieMethodAddParamInt(2);
    PushScaleformMovieMethodParameterString("~INPUT_CELLPHONE_CANCEL~");
    PushScaleformMovieMethodParameterString("Keluar");
    EndScaleformMovieMethod();


    BeginScaleformMovieMethod(Scale, "DRAW_INSTRUCTIONAL_BUTTONS");
    ScaleformMovieMethodAddParamInt(0);
    EndScaleformMovieMethod();

    DrawScaleformMovieFullscreen(Scale, 255, 255, 255, 255, 0);
end

function beliKendaraanDealer(model, harga)
	lib.hideMenu(true)
	local input = lib.inputDialog("Pilih Warna", {
		{ type = 'color', label = "Pilih Warna", format = 'rgb', default = '#eb4034' }
	})
	if input == nil then
		if lastSelectedVehicleEntity ~= nil then
			DeleteEntity(lastSelectedVehicleEntity)
			lastSelectedVehicleEntity = nil
		end
		lib.showMenu('vehicle_shop_mal')
	end

	local r, g, b = string.match(input[1], "rgb%((%d+), (%d+), (%d+)%)")
	r = tonumber(r)
	g = tonumber(g)
	b = tonumber(b)
	if input then
		local plateNew = GeneratePlateDealer(0)
		membeliKendaraanDealer(model, tonumber(r), tonumber(g), tonumber(b), harga, plateNew)
	end
end

function membeliKendaraanDealer(vehicle, r, g, b, price, plate)
	local chekedPlate = lib.callback.await('esx-vehicleshop:server:chekedPlateOwner', false, plate)
	if chekedPlate then
		membatalkanDealerKendaraan()
		ESX.Game.SpawnVehicle(vehicle, vec3(ConfigDealer.spawnCoordsBuy.x, ConfigDealer.spawnCoordsBuy.y, ConfigDealer.spawnCoordsBuy.z), ConfigDealer.spawnCoordsBuy.w, function(vehicle)
			local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
			vehicleProps.plate = plate
			ClearVehicleCustomPrimaryColour(vehicle)
			SetVehicleCustomPrimaryColour(vehicle, r, g, b)
			SetVehicleExtraColours(vehicle, 0, 0)
			SetVehicleNumberPlateText(vehicle, plate)
			SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
			lib.callback.await('esx-vehicleshop:server:setVehicleData', false, vehicleProps, "car", price)
			generatePlateCount = 0
		end)
	else
		if generatePlateCount > 3 then
			generatePlateCount = generatePlateCount + 1
			membeliKendaraanDealer(vehicle, r, g, b, price, GeneratePlateDealer(1))
		else
			generatePlateCount = generatePlateCount + 1
			membeliKendaraanDealer(vehicle, r, g, b, price, GeneratePlateDealer(0))
		end
	end
end