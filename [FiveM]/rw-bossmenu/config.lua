Config = {}

Config.Locale = 'en'
Config.EnableESXIdentity = true
Config.MaxSalary = 1500

Config.AuthorizedVehicles = {
    police = { -- Firma nimi
		{name = 'Ford Crown Victoria',model = 'police3', price = 15000},
    },
    ambulance = { -- Firma nimi
        {name = 'Speedo kaubik',model = 'emsnspeedo', price = 4500},  -- Sõiduki mudel
		{name = 'Dodge Charger 2018',model = 'fd2', price = 8000},
    },
    mechanic = { -- Firma nimi
        {name = 'Flatbed',model = 'flatbed', price = 25000},  -- Sõiduki mudel
        {name = 'Rumpo Custom',model = 'rumpo3', price = 30000}  -- Sõiduki mudel
    },
    mechanic2 = { -- Firma nimi
		{name = 'Flatbed',model = 'flatbed', price = 25000},  -- Sõiduki mudel
		{name = 'Rumpo Custom',model = 'rumpo3', price = 30000}  -- Sõiduki mudel
    },
    taxi = { -- Firma nimi
        {name = 'Takso auto',model = 'taxi', price = 23000}  -- Sõiduki mudel /spawn vehicle Dilettante2
    },
	burgershot = { -- Firma nimi
        {name = 'Muscle Burgershot',model = 'stalion2', price = 23000}  -- Sõiduki mudel /spawn vehicle Dilettante2
    },
    morgan = { -- Firma nimi
        {name = 'Turvatöö auto',model = 'dilettante2', price = 23000},
        {name = 'Rumpo Custom',model = 'rumpo3', price = 40000}  -- Sõiduki mudel  
    },
	properties = { -- Firma nimi
		{name = 'Rumpo Custom',model = 'rumpo3', price = 40000}  -- Sõiduki mudel  
	},
    camo = { -- Firma nimi
        {name = 'Buccaneer Custom',model = 'buccaneer2', price = 43000},
        {name = 'Rumpo Custom',model = 'rumpo3', price = 89000},  -- Sõiduki mudel  
        {name = 'Baller 2',model = 'baller2', price = 70000}
    }, 
    akuma = { -- Firma nimi 
        {name = 'Rumpo Custom',model = 'rumpo3', price = 89000},  -- Sõiduki mudel  
		{name = 'Akuma',model = 'akuma', price = 25000}
    }
}

Config.Garages = {
    ['police1'] = {
		type = 'car',
        job = 'police',
		spawnPos = {x = 374.9, y = -1624.82, z = 29.29},
		spawnPoints = {
			{x = 382.96, y = -1628.38, z = 29.28, h = 49.06},
			{x = 388.99, y = -1612.94, z = 29.28, h = 229.73},
			{x = 384.57, y = -1634.58, z = 29.28, h = 140.14},
			{x = 397.19, y = -1623.85, z = 29.28, h = 50.44},
			{x = 401.1, y = -1619.04, z = 29.28, h = 50.26}
		},
		deletePos = {x = 382.29, y = -1620.45, z = 29.29}
	},
	['police2'] = {
		type = 'helicopter',
		job = 'police',
		spawnPos = {x = 394.11, y = 1639.06, z = 29.29},
		spawnPoints = {
			{x = 402.67, y = -1633.12, z = 29.68, h = 322.04}
		},
		deletePos = {x = 402.67, y = -1633.12, z = 29.68}
	},	
	['ambulance'] = { 
		type = 'car',
		job = 'ambulance',
		spawnPos = {x = 315.73187255859377,y = -559.5164794921875,z = 28.757568359375},
		spawnPoints = {
			{x = 316.46, y = -550.53, z = 28.52, h = 270.613},
			{x = 316.70, y = -545.06, z = 28.52, h = 270.613}
		},
		deletePos = {x = 316.1538391113281,y = -540.8703002929688,z = 28.7406005859375}
	},
	['bennys'] = {
		type = 'car',
		job = 'mechanic', 
		spawnPos = {x = 827.1428833007813, y = -952.2988891601563, z = 25.75830078125},
		spawnPoints = { 
			{x = 814.78, y = -942.97, z = 25.76, h = 240.503}
		},
		deletePos = {x = 829.5296630859375, y = -938.13623046875, z = 25.75830078125}
	},
	['taxi'] = {
		type = 'car',
		job = 'taxi',
		spawnPos = {x = 889.459,y = -153.841,z = 75.891},
		spawnPoints = {
			{x = 896.181,y = -153.874,z = 75.08, h=331.01}
		},
		deletePos = {x = 892.263,y = -160.886,z = 75.412}
	},
	['harmony'] = {
		type = 'car',
		job = 'mechanic2',
		spawnPos = {x = 1188.319,y = 2651.09,z = 36.835},
		spawnPoints = {
			{x = 1179.02,y = 2650.814,z = 36.905, h=277.11}
		},
		deletePos = {x = 1189.716,y = 2659.208,z = 36.823}
	},
	['morgan'] = {
		type = 'car',
		job = 'morgan',
		spawnPos = {x = -53.074,y = -2528.08,z = 5.156},
		spawnPoints = {
			{x = -62.401,y = -2532.12,z = 4.245, h=52.41},
			{x = -68.775,y = -2527.851,z = 4.245, h=56.76}
		},
		deletePos = {x = -43.898,y = -2527.341,z = 5.01}
	}, 
	['burgershot'] = {
		type = 'car',
		job = 'burgershot',
		spawnPos = {x = -1170.9694824219, y = -899.62652587891, z = 13.817688941956},
		spawnPoints = {
			{x = -1163.2534179688, y = -890.92126464844, z = 14.14296913147, h = 123.34873962402},
			{x = -1165.0656738281, y = -887.56439208984, z = 14.14852809906, h = 120.22749328613}
		},
		deletePos = {x = -1160.8916015625, y = -891.44653320313, z = 14.191159248352}
	}, 
	['properties'] = {
		type = 'car',
		job = 'properties',
		spawnPos = {x = -108.94944763183594,y = -602.887939453125,z = 36.2725830078125},
		spawnPoints = {
			{x = -108.56703186035156,y = -614.914306640625,z = 35.5648193359375, h = 220.64},
			{x = -104.29450225830078,y = -603.3757934570313,z = 35.5648193359375, h = 220.64}
		},
		deletePos = {x = -113.14285278320313,y = -630.0791015625,z = 36.053466796875}
	},
} 