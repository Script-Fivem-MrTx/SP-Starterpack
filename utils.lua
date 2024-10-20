

local Utils = {}
Utils.framework = Config.framework

local FrameworkObject

if IsDuplicityVersion() then
    if Utils.framework == 'esx' then
        FrameworkObject = exports['es_extended']:getSharedObject()
    elseif Utils.framework == 'qbcore' then
        FrameworkObject = exports['qb-core']:GetCoreObject()
    end
else
    if Utils.framework == 'esx' then
        FrameworkObject = exports['es_extended']:getSharedObject()
    elseif Utils.framework == 'qbcore' then
        FrameworkObject = exports['qb-core']:GetCoreObject()
    end
end

Utils.FrameworkObject = FrameworkObject

function Utils.getPlayerIdentifier(player)
    if Utils.framework == 'esx' then
        return player.identifier
    elseif Utils.framework == 'qbcore' then
        return player.PlayerData.citizenid
    end
    return nil
end

function Utils.addMoney(player, amount)
    if Utils.framework == 'esx' then
        player.addMoney(amount)
    elseif Utils.framework == 'qbcore' then
        player.Functions.AddMoney('cash', amount)
    end
end

function Utils.addItem(player, item, amount)
    if Utils.framework == 'esx' then
        player.addInventoryItem(item, amount)
    elseif Utils.framework == 'qbcore' then
        player.Functions.AddItem(item, amount)
    end
end

function Utils.notifyPlayer(playerId, message, type)
    if IsDuplicityVersion() then
        TriggerClientEvent('t-general:starterpack:server:notifyPlayer', playerId, message, type)
    else
        if Utils.framework == 'esx' then
            TriggerEvent('esx:showNotification', message)
        elseif Utils.framework == 'qbcore' then
            FrameworkObject.Functions.Notify(message, type)
        end
    end
end

function Utils.isResourceRunning(resourceName)
    return GetResourceState(resourceName) == 'started'
end

function Utils.generatePlateESX()
    local plate
    local result

    repeat
        plate = "SP" .. math.random(1000, 9999)
        result = MySQL.Sync.fetchScalar('SELECT plate FROM owned_vehicles WHERE plate = ?', { plate })
    until not result

    return plate
end


function Utils.generatePlateQBCore()
    local plate
    local result

    repeat
        plate = 'SP' 
            .. string.upper(string.char(math.random(65, 90))) 
            .. math.random(0, 9) 
            .. string.upper(string.char(math.random(65, 90))) 
            .. string.upper(string.char(math.random(65, 90))) 
            .. math.random(0, 9) 
            .. math.random(0, 9)

        result = MySQL.Sync.fetchScalar('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })
    until not result

    return plate
end

function Utils.generatePlate()
    if Utils.framework == 'esx' then
        return Utils.generatePlateESX()
    elseif Utils.framework == 'qbcore' then
        return Utils.generatePlateQBCore()
    end
    return nil
end

function Utils.registerServerCallback(callbackName, handler)
    if Utils.framework == 'esx' then
        FrameworkObject.RegisterServerCallback(callbackName, handler)
    elseif Utils.framework == 'qbcore' then
        FrameworkObject.Functions.CreateCallback(callbackName, handler)
    end
end

if not IsDuplicityVersion() then
    function Utils.TriggerServerCallback(callbackName, cb, ...)
        if Utils.framework == 'esx' then
            FrameworkObject.TriggerServerCallback(callbackName, cb, ...)
        elseif Utils.framework == 'qbcore' then
            FrameworkObject.Functions.TriggerCallback(callbackName, cb, ...)
        end
    end
end

function Utils.registerCommand(commandName, description, args, restricted, handler, permission)
    if Utils.framework == 'esx' then
        FrameworkObject.RegisterCommand(commandName, permission, handler, restricted)
    elseif Utils.framework == 'qbcore' then
        FrameworkObject.Commands.Add(commandName, description, args, restricted, handler, permission)
    end
end

return Utils
