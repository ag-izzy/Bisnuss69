fx_version 'adamant'

game 'gta5'

description 'KK Society'

ui_page 'ui/index.html'

shared_scripts {
	'@ox_lib/init.lua',
	'@kk-fw/imports.lua'
} 

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@kk-fw/locale.lua',
    'locales/br.lua',
    'locales/en.lua',
    'locales/es.lua',
    'locales/fi.lua',
    'locales/fr.lua',
    'locales/sv.lua',
    'locales/pl.lua',
    'locales/nl.lua',
    'locales/cs.lua',
    'locales/tr.lua',
    'config.lua',
    'server/main.lua'
}

client_scripts {
    '@kk-fw/locale.lua',
    'locales/br.lua',
    'locales/en.lua',
    'locales/es.lua',
    'locales/fi.lua',
    'locales/fr.lua',
    'locales/sv.lua',
    'locales/pl.lua',
    'locales/nl.lua',
    'locales/cs.lua',
    'locales/tr.lua',
    'config.lua',
    'client/main.lua'
}

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js'
}

lua54 'yes'