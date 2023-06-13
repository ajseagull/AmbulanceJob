fx_version 'cerulean'
games { 'gta5' }

author 'Coevect'
description 'NPC Ambulance Work'
version '1.0.0'
lua54 'yes'

client_script 'client/client.lua'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}