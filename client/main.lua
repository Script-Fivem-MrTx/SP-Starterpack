-- client/client.lua

local Config = Config -- Mengasumsikan config.lua dimuat sebagai skrip bersama
local Utils = require('utils') -- Memuat shared/utils.lua

-- Fungsi untuk menggambar teks 3D
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(_World3dToScreen2d(x, y, z))
end

-- Fungsi pembantu untuk mengubah koordinat dunia ke layar
function _World3dToScreen2d(x, y, z)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        return _x, _y
    else
        return 0.0, 0.0
    end
end

-- Fungsi untuk membuka menu starter pack
function openStarterPackMenu(gender, umumReceived, ladiesReceived)
    local options = {}
    local male = (gender == 0) -- 0 adalah laki-laki, 1 adalah perempuan

    table.insert(options, {
        title = 'Ambil Starter Pack Umum',
        event = 't-general:starterpack:client:startStarterPack',
        icon = 'fas fa-gift',
        disabled = umumReceived,
        args = { packType = 'umum' }
    })

    if not male and Config.starterpackladies then
        table.insert(options, {
            title = 'Ambil Starter Pack Ladies',
            event = 't-general:starterpack:client:startStarterPack',
            icon = 'fas fa-gift',
            disabled = ladiesReceived,
            args = { packType = 'ladies' }
        })
    end

    lib.registerContext({
        id = 'starterpack_menu',
        title = 'Starter Pack',
        options = options
    })
    lib.showContext('starterpack_menu')
end

-- Spawn Ped dan Setup Target atau DrawText
CreateThread(function()
    local pedModel = Config.ped
    local pedHash = GetHashKey(pedModel)
    local pedCoords = Config.locationped

    RequestModel(pedHash)
    while not HasModelLoaded(pedHash) do
        Wait(100)
    end

    local ped = CreatePed(4, pedHash, pedCoords.x, pedCoords.y, pedCoords.z - 1, pedCoords.w, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskSetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)

    if Config.target == 'qb-target' then
        exports['qb-target']:AddBoxZone("starterpack", vector3(pedCoords.x, pedCoords.y, pedCoords.z), 1.5, 1.6, {
            name = "starterpack",
            heading = pedCoords.w,
            debugPoly = false,
            minZ = pedCoords.z - 1,
            maxZ = pedCoords.z + 1
        }, {
            options = {
                {
                    type = "client",
                    event = "t-general:starterpack:client:openMenu",
                    icon = 'fas fa-gift',
                    label = 'Ambil Starter Pack'
                }
            },
            distance = 2.5
        })
    elseif Config.target == 'qtarget' then
        exports['qtarget']:AddBoxZone("starterpack", vector3(pedCoords.x, pedCoords.y, pedCoords.z), 1.5, 1.6, {
            name = "starterpack",
            heading = pedCoords.w,
            debugPoly = false,
            minZ = pedCoords.z - 1,
            maxZ = pedCoords.z + 1
        }, {
            options = {
                {
                    type = "client",
                    event = "t-general:starterpack:client:openMenu",
                    icon = 'fas fa-gift',
                    label = 'Ambil Starter Pack'
                }
            },
            distance = 2.5
        })
    elseif Config.target == 'ox_target' then
        exports.ox_target:addBoxZone({
            name = 'starterpack',
            coords = vector3(pedCoords.x, pedCoords.y, pedCoords.z),
            size = vec3(3.6, 3.6, 3.6),
            drawSprite = false,
            options = {
                {
                    name = 'starterpack',
                    event = "t-general:starterpack:client:openMenu",
                    icon = 'fas fa-gift',
                    label = 'Ambil Starter Pack',
                }
            }
        })
    elseif Config.target == 'drawtext' then
        CreateThread(function()
            local sleep = 1000
            while true do
                Wait(sleep) 
                local playerPed = PlayerPedId()
                local coords = GetEntityCoords(playerPed)
                local distance = #(coords - vector3(pedCoords.x, pedCoords.y, pedCoords.z))

                if distance < 2.5 then
                    sleep = 0
                    DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z + 1.0, "[E] Ambil Starter Pack")
                    if IsControlJustReleased(0, 38) then 
                        TriggerEvent('t-general:starterpack:client:openMenu')
                    end
                else
                    sleep = 1000
                end
            end
        end)
    else
        print("Invalid target option in Config.target: " .. Config.target)
    end
end)

-- Event untuk membuka menu starter pack
RegisterNetEvent('t-general:starterpack:client:openMenu', function()
    Utils.TriggerServerCallback('t-general:starterpack:server:getPlayerInfo', function(gender, starterpack_umum_received, starterpack_ladies_received)
        openStarterPackMenu(gender, starterpack_umum_received, starterpack_ladies_received)
    end)
end)

-- Event untuk memulai pemberian starter pack
RegisterNetEvent('t-general:starterpack:client:startStarterPack', function(args)
    local packType = args.packType

    -- Menampilkan progress bar dan memicu event server untuk memberikan starter pack
    if Utils.framework == 'qbcore' then
        Utils.FrameworkObject.Functions.Progressbar('take_starterpack', "Mengambil Starter Pack...", 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },  {
            animDict = 'missfam4',
            anim = 'base',
            flags = 49
        }, {
            model = 'p_amb_clipboard_01',
            bone = 36029,
            coords = vector3(0.160000, 0.080000, 0.100000),
            rotation = vector3(-130.000000, -50.000000, 0.000000)
        }, {}, function() -- Selesai
            TriggerServerEvent('t-general:starterpack:server:giveStarterPack', packType)
            Utils.notifyPlayer(nil, "Mengambil Starter Pack...", "success")
        end, function() -- Batal
            Utils.notifyPlayer(nil, "Aksi dibatalkan.", "error")
        end)
    elseif Utils.framework == 'esx' then
        if lib.progressBar({
            duration = 5000,
            label = "Mengambil Starterpack",
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
                move = true
            },
            anim = {
                dict = 'missfam4',
                clip = 'base'
            },
            prop = {
                model = 'p_amb_clipboard_01',
                pos = vec3(0.0000, 0.0000, 0.1000),
                rot = vec3(0.0, 0.0, -1.5)
            },
        }) then
            TriggerServerEvent('t-general:starterpack:server:giveStarterPack', packType)
            Utils.notifyPlayer(nil, "Mengambil Starter Pack...", "success")
        else
            print('Aksi dibatalkan oleh pemain.')
        end
    end
end)

-- Event untuk spawn kendaraan
RegisterNetEvent('t-general:starterpack:client:spawnVehicle', function(vehicleModel, plate)
    local model = GetHashKey(vehicleModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end

    local playerPed = PlayerPedId()
    local coords = Config.locationvehicle

    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, false)
    SetVehicleNumberPlateText(vehicle, plate)
    SetVehicleOnGroundProperly(vehicle)
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    SetModelAsNoLongerNeeded(model)

    if Utils.isResourceRunning(Config.FuelResource) then
        exports[Config.FuelResource]:SetFuel(vehicle, 100.0)
    else
        print('Fuel resource ' .. Config.FuelResource .. ' tidak berjalan. Melewati pengaturan bahan bakar.')
    end

    if Utils.framework == 'qbcore' then
        if Utils.isResourceRunning('qb-vehiclekeys') then
            TriggerEvent('vehiclekeys:client:SetOwner', plate)
        else
            print('vehiclekeys tidak berjalan')
        end
    end
end)

-- Event untuk menerima notifikasi dari server
RegisterNetEvent('t-general:starterpack:server:notifyPlayer', function(playerId, message, type)
    if playerId == GetPlayerServerId(PlayerId()) then
        -- Untuk keamanan, pastikan hanya pemain yang bersangkutan yang menerima notifikasi
        Utils.notifyPlayer(nil, message, type)
    end
end)
