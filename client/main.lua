local QBCore = exports['qb-core']:GetCoreObject()

-- Spawn the ped and set up the qb-target zone
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
end)

RegisterNetEvent('t-general:starterpack:client:openMenu', function()
    QBCore.Functions.TriggerCallback('t-general:starterpack:server:getPlayerInfo', function(gender, starterpack_umum_received, starterpack_ladies_received)
        local options = {}
        local male = (gender == 0) -- 0 is male, 1 is female

        table.insert(options, {
            title = 'Ambil Starter Pack Umum',
            event = 't-general:starterpack:client:startStarterPack',
            icon = 'fas fa-gift',
            disabled = starterpack_umum_received,
            args = { packType = 'umum' }
        })

        if not male and Config.starterpackladies then
            table.insert(options, {
                title = 'Ambil Starter Pack Ladies',
                event = 't-general:starterpack:client:startStarterPack',
                icon = 'fas fa-gift',
                disabled = starterpack_ladies_received,
                args = { packType = 'ladies' }
            })
        end

        lib.registerContext({
            id = 'starterpack_menu',
            title = 'Starter Pack',
            options = options
        })
        lib.showContext('starterpack_menu')
    end)
end)


RegisterNetEvent('t-general:starterpack:client:startStarterPack', function(data)
    QBCore.Functions.Progressbar('take_starterpack', "Mengambil Starter Pack...", 5000, false, true, {
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
    }, {}, function() -- Done
        TriggerServerEvent('t-general:starterpack:server:giveStarterPack', data.packType)
    end, function() -- Cancel

        QBCore.Functions.Notify('Aksi dibatalkan.', 'error', 5000) 
    end)
end)

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
    SetPedIntoVehicle(playerPed, vehicle, -1)
    exports[Config.FuelResource]:SetFuel(vehicle, 100.0)
    TriggerEvent('vehiclekeys:client:SetOwner', plate)
    SetModelAsNoLongerNeeded(model)
end)
