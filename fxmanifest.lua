fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'ESX Vehicle Shop | Rebuild With OX By Rozir - https://github.com/rozirwobari'
version '1.0.0'

shared_script {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
	'config/*.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}

client_scripts {
	'client/*.lua'
}

dependency {
	'es_extended',
	'ox_lib',
	'ox_target',
}

export 'GeneratePlate'
