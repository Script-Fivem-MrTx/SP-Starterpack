fx_version 'cerulean'
game 'gta5'

description 'Starter Pack for QBCORE / ESX'
author 'Store Plane (https://discord.gg/pcAHeuTJHR)'
version '1.0.0'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

shared_scripts {'config.lua', '@ox_lib/init.lua', '@es_extended/imports.lua','utils.lua'}

lua54 'yes'
