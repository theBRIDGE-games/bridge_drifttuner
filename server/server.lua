local QBCore = exports['qb-core']:GetCoreObject()
local isChiped = {}
local removeItem = function(PlayerPed, item, amount)
    return PlayerPed.Functions.RemoveItem(item, amount)
end


Citizen.CreateThread(function()
    Citizen.Wait(1000)
    MySQL.query('SELECT plate FROM bridge_drifttuner', { }, function(result)
            if #result > 0 then
            for i=1, #result do
                isChiped[result[i].plate] = true
            end
        end
    end)
end)

QBCore.Functions.CreateCallback('bridge_drifttuner:isChiped', function(source, cb, plate)
    cb(isChiped[plate])
end)


QBCore.Functions.CreateUseableItem(config.chipItem, function(source, item)
    TriggerClientEvent('bridge_drifttuner:chipAddClient', source)
end)

RegisterServerEvent('bridge_drifttuner:chipAdd')
AddEventHandler('bridge_drifttuner:chipAdd', function(plate)
    local src = source
    local PlayerPed = QBCore.Functions.GetPlayer(src)
    if PlayerPed then
        removeItem(PlayerPed, config.chipItem, 1)
        isChiped[plate] = true
        MySQL.insert('INSERT INTO bridge_drifttuner (plate) VALUES (@plate)',{
            ['plate'] = plate
        })
    end
end)

RegisterServerEvent('bridge_drifttuner:chipRemove')
AddEventHandler('bridge_drifttuner:chipRemove', function(plate)
    isChiped[plate] = nil
    MySQL.query("DELETE FROM bridge_drifttuner WHERE plate=@plate", {
        ['@plate'] = plate,
    })
end)
