-- config.lua
Config = {
    framework = 'qbcore', -- Options: 'qbcore', 'esx'
    emote = 'clipboard',
    FuelResource = 'qb-fuel', -- qb-fuel, ps-fuel
    target = 'qb-target', -- Options: 'qb-target', 'qtarget', 'ox_target', 'drawtext'
    locationped = vector4(-1045.74, -2726.3, 20.17, 326.2),
    locationvehicle = vector4(-1043.06, -2723.86, 20.12, 238.63),
    ped = 'a_m_m_hasjew_01',
    starterpackladies = true,
    starterpacks = {
        umum = { -- General Starter Pack
            item = {
                ['cash'] = { amount = 5000 },
                ['sandwich'] = { amount = 10 },
                ['vodka'] = { amount = 2 },
            },
            vehicle = 'sultanrs'
        },
        ladies = {
            item = {
                ['cash'] = { amount = 15000 },
                ['sandwich'] = { amount = 15 },
                ['vodka'] = { amount = 2 },
            },
            vehicle = 'rapidgt'
        }
    }
}
