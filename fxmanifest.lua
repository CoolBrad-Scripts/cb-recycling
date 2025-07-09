fx_version 'cerulean'
game 'gta5'

author 'Cool Brad Scripts'
version '1.0.1'
description 'A recycling script for FiveM RP servers'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

dependencies {
    'ox_lib',
    'community_bridge',
}

lua54 'yes'