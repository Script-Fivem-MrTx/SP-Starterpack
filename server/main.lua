local QBCore = exports['qb-core']:GetCoreObject()

-- Callback to get player's gender and starter pack status
QBCore.Functions.CreateCallback('t-general:starterpack:server:getPlayerInfo', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local gender = Player.PlayerData.charinfo.gender -- 0 = male, 1 = female
    local PlayerId = Player.PlayerData.citizenid

    MySQL.Async.fetchAll('SELECT starterpack_umum_received, starterpack_ladies_received FROM players WHERE citizenid = ?', { PlayerId }, function(result)
        if result[1] then
            local starterpack_umum_received = result[1].starterpack_umum_received
            local starterpack_ladies_received = result[1].starterpack_ladies_received
            cb(gender, starterpack_umum_received, starterpack_ladies_received)
        else
            -- If the player record doesn't exist, default to false (hasn't received any starter packs)
            cb(gender, false, false)
        end
    end)
end)

-- Event to give the starter pack
RegisterNetEvent('t-general:starterpack:server:giveStarterPack', function(packType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerId = Player.PlayerData.citizenid

    if packType == 'umum' then
        -- Handle Starter Pack Umum
        MySQL.Async.fetchScalar('SELECT starterpack_umum_received FROM players WHERE citizenid = ?', { PlayerId }, function(received)
            if not received then
                -- Update the starter pack status
                MySQL.Async.execute('UPDATE players SET starterpack_umum_received = ? WHERE citizenid = ?', { true, PlayerId }, function()
                    local items = Config.starterpacks.umum.item
                    local vehicleModel = Config.starterpacks.umum.vehicle

                    -- Give items to the player
                    for itemName, itemData in pairs(items) do
                        if itemName == 'cash' then
                            Player.Functions.AddMoney('cash', itemData.amount)
                        else
                            Player.Functions.AddItem(itemName, itemData.amount)
                        end
                    end

                    -- Insert the vehicle into the database and spawn it for the player
                    local plate = GeneratePlate()
                    MySQL.Async.execute('INSERT INTO player_vehicles (citizenid, license, vehicle, plate, state) VALUES (?, ?, ?, ?, ?)', {
                        Player.PlayerData.citizenid,
                        Player.PlayerData.license,
                        vehicleModel,
                        plate,
                        0
                    }, function(rowsChanged)
                        if rowsChanged > 0 then
                            TriggerClientEvent('t-general:starterpack:client:spawnVehicle', src, vehicleModel, plate)
                            TriggerClientEvent('QBCore:Notify', src, 'Anda telah menerima Starter Pack Umum.', 'success', 5000) -- "You have received the General Starter Pack."
                        else
                            TriggerClientEvent('QBCore:Notify', src, 'Gagal memberikan kendaraan, coba lagi.', 'error', 5000) -- "Failed to give vehicle, please try again."
                        end
                    end)
                end)
            else
                TriggerClientEvent('QBCore:Notify', src, 'Anda sudah pernah mengambil Starter Pack Umum.', 'error', 5000) -- "You have already received the General Starter Pack."
            end
        end)
    elseif packType == 'ladies' then
        -- Handle Starter Pack Ladies
        MySQL.Async.fetchScalar('SELECT starterpack_ladies_received FROM players WHERE citizenid = ?', { PlayerId }, function(received)
            if not received then
                -- Update the starter pack status
                MySQL.Async.execute('UPDATE players SET starterpack_ladies_received = ? WHERE citizenid = ?', { true, PlayerId }, function()
                    local items = Config.starterpacks.ladies.item
                    local vehicleModel = Config.starterpacks.ladies.vehicle

                    -- Give items to the player
                    for itemName, itemData in pairs(items) do
                        if itemName == 'cash' then
                            Player.Functions.AddMoney('cash', itemData.amount)
                        else
                            Player.Functions.AddItem(itemName, itemData.amount)
                        end
                    end

                    -- Insert the vehicle into the database and spawn it for the player
                    local plate = GeneratePlate()
                    MySQL.Async.execute('INSERT INTO player_vehicles (citizenid, license, vehicle, plate, state) VALUES (?, ?, ?, ?, ?)', {
                        Player.PlayerData.citizenid,
                        Player.PlayerData.license,
                        vehicleModel,
                        plate,
                        0
                    }, function(rowsChanged)
                        if rowsChanged > 0 then
                            TriggerClientEvent('t-general:starterpack:client:spawnVehicle', src, vehicleModel, plate)
                            TriggerClientEvent('QBCore:Notify', src, 'Anda telah menerima Starter Pack Ladies.', 'success', 5000) -- "You have received the Ladies Starter Pack."
                        else
                            TriggerClientEvent('QBCore:Notify', src, 'Gagal memberikan kendaraan, coba lagi.', 'error', 5000) -- "Failed to give vehicle, please try again."
                        end
                    end)
                end)
            else
                TriggerClientEvent('QBCore:Notify', src, 'Anda sudah pernah mengambil Starter Pack Ladies.', 'error', 5000) -- "You have already received the Ladies Starter Pack."
            end
        end)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Jenis Starter Pack tidak dikenal.', 'error', 5000) -- "Unknown Starter Pack type."
    end
end)

-- Function to generate a unique vehicle plate
function GeneratePlate()
    local plate
    local result

    repeat
        plate = 'SP' 
            .. QBCore.Shared.RandomStr(1):upper() 
            .. QBCore.Shared.RandomInt(1) 
            .. QBCore.Shared.RandomStr(1):upper() 
            .. QBCore.Shared.RandomStr(1):upper() 
            .. QBCore.Shared.RandomInt(1) 
            .. QBCore.Shared.RandomInt(1)

        result = MySQL.Sync.fetchScalar('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })
    until not result

    return plate
end


local function ResetStarterPack(source, targetPlayerId)
    local src = source
    local TargetPlayer = QBCore.Functions.GetPlayer(targetPlayerId)
    
    if not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Player not found.', 'error', 5000)
        return
    end

    local PlayerId = TargetPlayer.PlayerData.citizenid

    -- Reset the starter pack statuses in the database
    MySQL.Async.execute('UPDATE players SET starterpack_umum_received = ?, starterpack_ladies_received = ? WHERE citizenid = ?', {
        false,
        false,
        PlayerId
    }, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Starter pack status has been reset for ' .. TargetPlayer.PlayerData.charinfo.firstname .. '.', 'success', 5000)
            TriggerClientEvent('QBCore:Notify', TargetPlayer.PlayerData.source, 'Your starter pack status has been reset by an admin.', 'info', 5000)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Failed to reset starter pack status.', 'error', 5000)
        end
    end)
end

-- Register the command for admins
QBCore.Commands.Add('resetstarterpack', 'Reset a player\'s starter pack status (Admin Only)', {{ name = 'id', help = 'Player ID' }}, true, function(source, args)
    local src = source
    local targetId = tonumber(args[1])

    if targetId then
        ResetStarterPack(src, targetId)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Invalid player ID.', 'error', 5000)
    end
end, 'god')