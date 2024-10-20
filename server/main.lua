-- server/server.lua

local Config = Config -- Mengasumsikan config.lua dimuat sebagai skrip bersama
local Utils = require('utils') -- Memuat shared/utils.lua

-- Mendaftarkan callback untuk mendapatkan informasi pemain
Utils.registerServerCallback('t-general:starterpack:server:getPlayerInfo', function(source, cb)
    local player = Utils.framework == 'esx' and Utils.FrameworkObject.GetPlayerFromId(source) or Utils.FrameworkObject.Functions.GetPlayer(source)
    if not player then
        -- Jika pemain tidak ditemukan, tentukan gender default
        local defaultGender = Utils.framework == 'esx' and 'm' or 0
        cb(defaultGender, false, false)
        return
    end

    local gender = Utils.framework == 'esx' and player.get('sex') or player.PlayerData.charinfo.gender
    local PlayerId = Utils.getPlayerIdentifier(player)

    local tableName = Utils.framework == 'esx' and 'users' or 'players'
    local genderValue = Utils.framework == 'esx' and (gender == 'm' and 0 or 1) or gender

    MySQL.Async.fetchAll(string.format('SELECT starterpack_umum_received, starterpack_ladies_received FROM %s WHERE %s = ?', tableName, Utils.framework == 'esx' and 'identifier' or 'citizenid'), 
    { PlayerId }, function(result)
        if result[1] then
            cb(genderValue, result[1].starterpack_umum_received, result[1].starterpack_ladies_received)
        else
            cb(genderValue, false, false)
        end
    end)
end)

-- Event untuk memberikan starter pack
RegisterNetEvent('t-general:starterpack:server:giveStarterPack', function(packType)
    local src = source
    local player = Utils.framework == 'esx' and Utils.FrameworkObject.GetPlayerFromId(src) or Utils.FrameworkObject.Functions.GetPlayer(src)
    if not player then return end

    local PlayerId = Utils.getPlayerIdentifier(player)
    local tableName = Utils.framework == 'esx' and 'users' or 'players'
    local receivedColumn = packType == 'umum' and 'starterpack_umum_received' or 'starterpack_ladies_received'

    MySQL.Async.fetchScalar(string.format('SELECT %s FROM %s WHERE %s = ?', receivedColumn, tableName, Utils.framework == 'esx' and 'identifier' or 'citizenid'), { PlayerId }, function(received)
        if not received then
            MySQL.Async.execute(string.format('UPDATE %s SET %s = ? WHERE %s = ?', tableName, receivedColumn, Utils.framework == 'esx' and 'identifier' or 'citizenid'), 
            { true, PlayerId }, function()
                local items = Config.starterpacks[packType].item
                local vehicleModel = Config.starterpacks[packType].vehicle

                for itemName, itemData in pairs(items) do
                    if itemName == 'cash' or itemName == 'money' then
                        Utils.addMoney(player, itemData.amount)
                    else
                        Utils.addItem(player, itemName, itemData.amount)
                    end
                end

                local plate = Utils.generatePlate()
                local vehicleTable = Utils.framework == 'esx' and 'owned_vehicles' or 'player_vehicles'
                local query = Utils.framework == 'esx' and 
                    'INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)' or 
                    'INSERT INTO player_vehicles (citizenid, license, vehicle, plate, state) VALUES (?, ?, ?, ?, ?)'

                local params = Utils.framework == 'esx' and { PlayerId, plate, json.encode({ model = vehicleModel }) } or 
                    { PlayerId, player.PlayerData.license, vehicleModel, plate, 0 }

                MySQL.Async.execute(query, params, function()
                    TriggerClientEvent('t-general:starterpack:client:spawnVehicle', src, vehicleModel, plate)
                    Utils.notifyPlayer(src, packType == 'umum' and 'Anda telah menerima Starter Pack Umum.' or 'Anda telah menerima Starter Pack Ladies.', 'success')
                end)
            end)
        else
            Utils.notifyPlayer(src, packType == 'umum' and 'Anda sudah pernah mengambil Starter Pack Umum.' or 'Anda sudah pernah mengambil Starter Pack Ladies.', 'error')
        end
    end)
end)

-- Command untuk mereset Starter Pack
Utils.registerCommand('resetstarterpack', 'Reset a player\'s starter pack status (Admin Only)', {
    { name = 'id', help = 'Player ID' }
}, true, function(source, args)
    local targetId = tonumber(args[1])
    if not targetId then
        Utils.notifyPlayer(source, 'Invalid Player ID.', 'error')
        return
    end

    local targetPlayer = Utils.framework == 'esx' and Utils.FrameworkObject.GetPlayerFromId(targetId) or Utils.FrameworkObject.Functions.GetPlayer(targetId)
    if targetPlayer then
        local PlayerId = Utils.getPlayerIdentifier(targetPlayer)
        local tableName = Utils.framework == 'esx' and 'users' or 'players'
        local query = Utils.framework == 'esx' and 
            'UPDATE users SET starterpack_umum_received = ?, starterpack_ladies_received = ? WHERE identifier = ?' or 
            'UPDATE players SET starterpack_umum_received = ?, starterpack_ladies_received = ? WHERE citizenid = ?'

        local params = { false, false, PlayerId }

        MySQL.Async.execute(query, params, function(affectedRows)
            if affectedRows > 0 then
                Utils.notifyPlayer(source, Utils.framework == 'esx' and 'Starterpack status has been reset.' or 'Starter pack status has been reset.', 'success')
                Utils.notifyPlayer(targetPlayer.source, Utils.framework == 'esx' and 'Starterpack Anda telah direset.' or 'Your starter pack status has been reset by an admin.', 'info')
            else
                Utils.notifyPlayer(source, 'Failed to reset starter pack status.', 'error')
            end
        end)
    else
        Utils.notifyPlayer(source, 'Player not found.', 'error')
    end
end, 'admin')
