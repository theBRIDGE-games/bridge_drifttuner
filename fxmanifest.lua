fx_version 'cerulean'
game 'gta5'
author 'daddyDUBZ'
description 'theBRIDGE - Drift Tuner'

shared_scripts {
	'config.lua'
}

client_scripts {
    'client/*.lua',
} 

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
}

--Credit goes to Moravian Lion for the original script and idea 
--responsible for modifying handling.  This is an adaptation of
--that idea adding database support, storing the drift mod to the
--vehicle plate, functions to toggle drift mode on/off, and
--functions for police to check for turbo/drift modifications.

--https://github.com/MoravianLion/Drift-Script