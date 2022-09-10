config = {}

config.chipItem = "drifttuner"
config.chipInstallTime = 5000

--keys (https://docs.fivem.net/docs/game-references/controls/)
config.changeDriftMode = 170 --F3

config.vehicleClassWhitelist = {0, 1, 2, 3, 4, 5, 6, 7, 9}

config.alerttype = 'qb' --'qb', 'custom' //Insert 'qb' to use qb notifications.  For all others enter anything else and modify the function below to suit your need.



local QBCore = exports['qb-core']:GetCoreObject()

function driftalerts(text, type)
    if config.alerttype == 'qb' then
        QBCore.Functions.Notify(text, type)
    else
        --Insert Custom Notification String

        exports['okokNotify']:Alert("Vehicle Tuner", text, 5000, type)

        --Insert Custom Notification String
	end
end