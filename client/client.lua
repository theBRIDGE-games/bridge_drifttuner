local QBCore = exports['qb-core']:GetCoreObject()
local driftMode = false
local InProgress = false
local playerPed, playerCoords, inVehicle, playerVehicle, vehicleClass, driverSeat
local engines = {"engine", "engine_a", "bumper_f"}
local isChipped = false
local handleMods = {
	{"fInitialDragCoeff", 90.22},
	{"fDriveInertia", .31},
	{"fSteeringLock", 22},
	{"fTractionCurveMax", -1.1},
	{"fTractionCurveMin", -.4},
	{"fTractionCurveLateral", 2.5},
	{"fLowSpeedTractionLossMult", -.57}
}

Citizen.CreateThread( function()
	while true do
        Citizen.Wait(500)
        playerPed = PlayerPedId()
        playerCoords = GetEntityCoords(playerPed)
        inVehicle = IsPedInAnyVehicle(playerPed)
        if inVehicle then
            playerVehicle = GetVehiclePedIsIn(playerPed, false)
            vehiclePlate = GetVehicleNumberPlateText(playerVehicle)
            vehicleClass = GetVehicleClass(playerVehicle)
            driverSeat = GetPedInVehicleSeat(playerVehicle, -1) == playerPed
        else
            playerVehicle, vehicleClass, driverSeat = 0, 0, 0
        end
        QBCore.Functions.TriggerCallback('bridge_drifttuner:isChiped', function(chiped)
            isChipped = chiped
        end, vehiclePlate)
    end
end)

Citizen.CreateThread( function()
	while true do
		Wait(1)
		playerPed = GetPlayerPed(-1)
		if inVehicle then
			if driverSeat then			 
				if GetVehicleHandlingFloat(playerVehicle, "CHandlingData", "fDriveBiasFront") ~= 1 and IsVehicleOnAllWheels(playerVehicle) and IsControlJustReleased(0, config.changeDriftMode) then
                    if isChipped then
                        if InProgress == false then
                            InProgress = true
                            ToggleDrift(playerVehicle)
                        else
                            driftalerts("Safety features already disabling!", 'error')
                        end
                    else
                        driftalerts("No drift chip present.", 'error')
                    end
                end
				if GetVehicleHandlingFloat(playerVehicle, "CHandlingData", "fInitialDragCoeff") < 90 then
					SetVehicleEnginePowerMultiplier(playerVehicle, 0.0)
				else
					if GetVehicleHandlingFloat(playerVehicle, "CHandlingData", "fDriveBiasFront") == 0.0 then
						SetVehicleEnginePowerMultiplier(playerVehicle, 190.0)
					else
						SetVehicleEnginePowerMultiplier(playerVehicle, 100.0)
					end
				end
            end
		end
	end
end)

--############################################################################################################################################################################

-- Add tuner chip
RegisterNetEvent("bridge_drifttuner:chipAddClient", function()
	if inVehicle then
        driftalerts("You cannot do this in the vehicle!", 'error')
		return
    end

    local vehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 5.0, 0, 71)	
    if IsVehicleClassWhitelisted(GetVehicleClass(vehicle)) then
        local engine = nil
        for i=1, #engines do
            local getEngineIndex = GetEntityBoneIndexByName(vehicle, engines[i])
            if getEngineIndex ~= -1 then
                engine = getEngineIndex
                break
            end
        end
        if #(playerCoords - GetWorldPositionOfEntityBone(vehicle, engine)) <= 2.3 then
            if DoesEntityExist(vehicle) then
                TriggerServerEvent("bridge_drifttuner:chipAdd", GetVehicleNumberPlateText(vehicle))
                SetVehicleDoorOpen(vehicle, 4, 0, 0)
                TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)

                QBCore.Functions.Progressbar("tunerchip", "Installing Drift Tuning Chip", config.chipInstallTime, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                Citizen.Wait(2000)
                driftalerts("Drift Tuning Chip Installed", 'success')
                ClearPedTasksImmediately(playerPed)
                SetVehicleDoorShut(vehicle, 4, 0)
                
            end, function() -- Cancelled
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            end, "drifttuner")

        end
        else
            driftalerts("You are too far from engine!", 'error')
        end
    else
        driftalerts("You cannot drift this vehicle!", 'error')
    end
end)

function ToggleDrift(vehicle)
    local modifier = 1
    if GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDragCoeff") > 90 then
        driftMode = true
        dtoggle = 'Disabling'
        modifier = -1
    else 
        driftMode = false
        dtoggle = 'Enabling'
    end  
    QBCore.Functions.Progressbar("driftmode", dtoggle.." Drift Mode ..", 30000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done    
    for index, value in ipairs(handleMods) do
        SetVehicleHandlingFloat(vehicle, "CHandlingData", value[1], GetVehicleHandlingFloat(vehicle, "CHandlingData", value[1]) + value[2] * modifier)
        InProgress = false
    end   
    if driftMode then       
        -- PrintDebugInfo("stock")
        driftalerts("TCS, ABS, ESP is on!  Drift Mode DISABLED", 'success')
    else        
        -- PrintDebugInfo("drift")
        driftalerts("TCS, ABS, ESP is OFF! Drift Mode ENABLED", 'success')
    end
    end, function()
        InProgress = false
        driftalerts("Cancelled drift mode change.", 'error')
    end, "fa-solid fa-gear" )
end

function PrintDebugInfo(mode)
	playerPed = GetPlayerPed(-1)
	local vehicle = GetVehiclePedIsIn(playerPed, false)
	print(mode)
	for index, value in ipairs(handleMods) do
		print(GetVehicleHandlingFloat(vehicle, "CHandlingData", value[1]))
	end
end

function IsVehicleClassWhitelisted(vehicleClass)
	for index, value in ipairs(config.vehicleClassWhitelist) do
		if value == vehicleClass then
			return true
		end
	end
	return false
end

--Drift/Performance Mod vehicle check
RegisterNetEvent('bridge_drifttuner:TuneStatus', function()
        local ped = PlayerPedId()
        local closestVehicle = GetClosestVehicle(GetEntityCoords(ped), 5.0, 0, 70)
        local plate = QBCore.Functions.GetPlate(closestVehicle)
        local vehModel = GetEntityModel(closestVehicle)
        turbo = IsToggleModOn(closestVehicle, 18)
        if vehModel ~= 0 then
            if turbo == 1 then
                driftalerts("Performance Tune present.", 'success')
            else
                driftalerts("No performance mods present.", 'error')
            end
            QBCore.Functions.TriggerCallback('bridge_drifttuner:isChiped', function(chiped) 
                if chiped then
                    driftalerts("Drift Tune present.", 'success')
                else
                    driftalerts("No drift mods present.", 'error')
                end
            end, plate)
        else
            driftalerts("No Vehicle Nearby", 'error')
        end
    end)
