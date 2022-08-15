local Jobs = {}
local invitations = {}
local accounts = {}

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    MySQL.Async.fetchAll('SELECT name, money FROM jobs', {}, function(result)
        for k,v in pairs(result) do
            accounts[v.name] = {}
            accounts[v.name].money = v.money
        end
    end)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    for k,v in pairs(accounts) do
        MySQL.Sync.execute('UPDATE jobs SET money = ? WHERE name = ?', {
            v.money,
            k
        })
    end
end)

MySQL.ready(function()
	local result = MySQL.Sync.fetchAll('SELECT * FROM jobs', {})

	for i=1, #result, 1 do
		Jobs[result[i].name] = result[i]
		Jobs[result[i].name].grades = {}
		Jobs[result[i].name].label = result[i].label
	end

	local result2 = MySQL.Sync.fetchAll('SELECT * FROM job_grades', {})

	for i=1, #result2, 1 do
		Jobs[result2[i].job_name].grades[tostring(result2[i].grade)] = result2[i]
	end
end)

AddEventHandler('kk-society:getJobInfo', function(sentJob, cb) cb(Jobs[sentJob]) end)

exports('getName', function(sentJob)
	local returnable = nil

	MySQL.Async.fetchAll('SELECT label, type FROM jobs WHERE name = ?', { sentJob }, function(result)
		if result and result[1] then
			if result[1].type == 'illegal' then
				returnable = 'Töötu'
			else
				returnable = result[1].label
			end
		else
			returnable = 'Töötu'
		end
	end)

	while returnable == nil do Wait(50) end; return returnable
end)

local function refreshJobs()
	Jobs = {}
	Wait(0)
	local result = MySQL.Sync.fetchAll('SELECT * FROM jobs', {})

	for i=1, #result, 1 do
		Jobs[result[i].name] = result[i]
		Jobs[result[i].name].grades = {}
	end

	local result2 = MySQL.Sync.fetchAll('SELECT * FROM job_grades', {})

	for i=1, #result2, 1 do
		Jobs[result2[i].job_name].grades[tostring(result2[i].grade)] = result2[i]
	end
end

lib.callback.register('kk-society:getOnlineMembers', function(source, jobName)
	return ESX.GetDutyCount(jobName)
end)

RegisterNetEvent('kk-society:server:editBadge')
AddEventHandler('kk-society:server:editBadge', function(pid, data)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer then
		MySQL.Async.fetchAll('SELECT * FROM users WHERE pid = @pid', {
			['@pid'] = pid
		}, function(result)
			if result[1] then
				MySQL.Sync.execute('UPDATE users SET badge = @badge WHERE pid = @pid', {
					['@pid'] = pid,
					['@badge'] = data.serial
				})

				MySQL.Sync.execute('UPDATE users SET department = @department WHERE pid = @pid', {
					['@pid'] = pid,
					['@department'] = data.department
				})

				TriggerClientEvent('kk-scripts:client:SendAlert', xPlayer.source, { type = 'success', text = 'Ametitõendi andmete uuendamine õnnestus! Seeria NR: ' .. data.serial .. '!'})
			else
				TriggerClientEvent('kk-scripts:client:SendAlert', xPlayer.source, { type = 'error', text = 'Tundub, et midagi läks valesti!'})
			end
		end)
	end
end)

AddEventHandler('KKF.Player.Loaded', function(src, xPlayer)
	if xPlayer then 
		if xPlayer.job.onDuty then
			if xPlayer.job.name == 'police' then
                MySQL.Async.fetchAll('SELECT department FROM users WHERE pid = @pid', {
                    ['@pid'] = xPlayer.identifier
                }, function(result)
                    if result[1].department == 'BCSO' then
                        TriggerEvent('eblips:add', {name = xPlayer.job.grade_label..' '..xPlayer.name, src = xPlayer.source, color = 25})
                    else
                        TriggerEvent('eblips:add', {name = xPlayer.job.grade_label..' '..xPlayer.name, src = xPlayer.source, color = 29})
                    end
                end)
			elseif xPlayer.job.name == 'ambulance' then
				TriggerEvent('eblips:add', {name = xPlayer.job.grade_label..' '..xPlayer.name, src = xPlayer.source, color = 1})
			end
		end
	end
end)

lib.callback.register('kk-society:getEmployees', function(source, society)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local returnable = nil

    if xPlayer then
		local employees = {}
		local society = tostring(society)
		refreshJobs()
	
		MySQL.Async.fetchAll('SELECT * FROM users WHERE job = @job', {
			['@job'] = society
		}, function(result)
			for k,v in pairs(result) do
				table.insert(employees, {
					name = v.firstname .. ' ' .. v.lastname,
					serial = 'Seeria NR: ' .. '[' .. v.badge .. ']',
					lastwork = v.lastwork,
					identifier = v.pid,
					job = {
						name = society,
						label = Jobs[society].label or 'Lae leht uuesti!',
						grade = v.job_grade or 'Lae leht uuesti!',
						grade_name = Jobs[society].grades[tostring(v.job_grade)].name or 'Lae leht uuesti!',
						grade_label = Jobs[society].grades[tostring(v.job_grade)].label or 'Lae leht uuesti!'
					}
				})
			end
	
			returnable = employees
		end)
    else
        returnable = {}
    end

    while returnable == nil do Wait(50) end; return returnable
end)

local function tryEmployeing(society)
	local canJoin = nil

	MySQL.Async.fetchAll('SELECT * FROM users WHERE job = ?', { society }, function(result)
		MySQL.Async.fetchAll('SELECT max_count FROM jobs WHERE name = ?', { society }, function(result2)
			if result2[1].max_count == #result then canJoin = false end -- EI KOMMENTAARI
			if result2[1].max_count > #result then canJoin = true end -- EI KOMMENTAARI
			if result2[1].max_count < #result then canJoin = false end -- EI KOMMENTAARI
		end)
	end)

	while canJoin == nil do Wait(50) end; return canJoin
end

lib.callback.register('kk-society:loadHome', function(source, society)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local returnable = nil

    if xPlayer then
		society = tostring(society)
	
		MySQL.Async.fetchAll('SELECT * FROM users WHERE job = ?', { society }, function(result)
			MySQL.Async.fetchAll('SELECT max_count FROM jobs WHERE name = ?', { society }, function(result2)
				returnable = {members = #result, max = result2[1].max_count, name = Jobs[society].label, grade = xPlayer.job.grade_label, playername = xPlayer.name, ctime = os.date('%Y-%m-%d %X'), salary = xPlayer.job.grade_salary}
			end)
		end)
    else
        returnable = {}
    end

    while returnable == nil do Wait(50) end; return returnable
end)


lib.callback.register('kk-society:loadRanks', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local returnable = nil

    if xPlayer then
        MySQL.Async.fetchAll('SELECT * FROM job_grades WHERE job_name = ?', {
			xPlayer.job.name, 
		}, function(result)
			local grades = {}

			for k, v in pairs(result) do
				table.insert(grades, v)
			end

            returnable = grades
        end)
    else
        returnable = {}
    end

    while returnable == nil do Wait(50) end; return returnable
end)

function isPlayerBoss(playerId, job)
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if xPlayer.job.name == job and xPlayer.job.permissions.leaderMenu then
		return true
	else
		print(('kk-society: %s attempted open a society boss menu!'):format(xPlayer.identifier))
		return false
	end
end

function getPriceFromHash(vehicleHash, society)
	local vehicles = Config.AuthorizedVehicles[society]

	for k,v in ipairs(vehicles) do
		if GetHashKey(v.model) == vehicleHash then
			return v.price
		end
	end

	return 0
end

RegisterNetEvent('kk-society:server:buyVehicle')
AddEventHandler('kk-society:server:buyVehicle', function(model, plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = getPriceFromHash(GetHashKey(model), xPlayer.job.name)

	if xPlayer.job.permissions.leaderMenu then

		-- vehicle model not found
		if price == 0 then
			print(('kk-society: %s attempted to exploit the shop! (invalid vehicle model)'):format(xPlayer.identifier))
		else
			TriggerEvent('Society.GetMoney', xPlayer.job.name, function(money)
				if money >= price then
					TriggerEvent('Society.RemoveMoney', xPlayer.job.name, price)
					exports['kk-scripts']:sendSocietyLog(xPlayer.source, 'SÕIDUKI OST', 'Sõiduki REG.NR ' .. plate .. '; HIND: $' .. price .. '.')

					local vehicleProps = {
						model = GetHashKey(model),
						plate = plate
					}
					if model == "polmav" then 
						MySQL.Async.execute('INSERT INTO user_vehicles (owner, vehicle, plate, type, ownername, stored) VALUES (@owner, @vehicle, @plate, @type, @ownername, @stored)', {
							['@owner'] = 'society_' .. xPlayer.job.name,
							['@vehicle'] = json.encode(vehicleProps),
							['@plate'] = plate,
							['@type'] = "helicopter",
							['@ownername'] = xPlayer.job.label,
							['@stored'] = true
						})
					else
						MySQL.Async.execute('INSERT INTO user_vehicles (owner, vehicle, plate, type, ownername, stored) VALUES (@owner, @vehicle, @plate, @type, @ownername, @stored)', {
							['@owner'] = 'society_' .. xPlayer.job.name,
							['@vehicle'] = json.encode(vehicleProps),
							['@plate'] = plate,
							['@type'] = "car",
							['@ownername'] = xPlayer.job.label,
							['@stored'] = true
						})
					end

					TriggerClientEvent('kk-society:client:showNotify', xPlayer.source, 'Sõidukid', 'Soetasite sõiduki '..getLabel(model, xPlayer.job.name)..' hinnaga $'..price..'!', 'success')
				else
					TriggerClientEvent('kk-society:client:showNotify', xPlayer.source, 'Sõidukid', 'fraktsioonil ei ole antud sõiduki ostuks piisavalt raha!', 'error')
				end
			end)
		end
	end
end)

function getLabel(model, job)
	local place = Config.AuthorizedVehicles[job]

	for k,v in pairs(place) do
		if v.model == model then
			return v.name
		end
	end

	return ' '
end

lib.callback.register('kk-society:loadLogs', function(source, pid, context)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local returnable = nil

    if xPlayer then
		local sql = 'WHERE society = @society ORDER BY `id` DESC LIMIT 50'

		if pid ~= '' and context ~= '' then
			sql = 'WHERE society = @society AND pid LIKE @pid AND text LIKE @context ORDER BY `id` DESC'
		elseif pid ~= '' and context == '' then
			sql = 'WHERE society = @society AND pid LIKE @pid ORDER BY `id` DESC'
		elseif pid == '' and context ~= '' then
			sql = 'WHERE society = @society AND text LIKE @context ORDER BY `id` DESC'
		end

		MySQL.Async.fetchAll('SELECT * FROM society_logs ' .. sql, {
			['@society'] = xPlayer.job.name,
			['@pid'] = '%' .. pid .. '%',
			['@context'] = '%' .. context .. '%'
		}, function(result)
			if result and result[1] then
				local logs = {}
	
				for index, data in ipairs(result) do
					table.insert(logs, data)
				end
	
				returnable = logs
			else
				returnable = {}
			end
		end)
    else
        returnable = {}
    end

    while returnable == nil do Wait(50) end; return returnable
end)

lib.callback.register('kk-society:loadRanks', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local returnable = nil

    if xPlayer then
        MySQL.Async.fetchAll('SELECT * FROM job_grades WHERE job_name = ?', {
			xPlayer.job.name, 
		}, function(result)
			local grades = {}

			for k, v in pairs(result) do
				table.insert(grades, v)
			end

            returnable = grades
        end)
    else
        returnable = {}
    end

    while returnable == nil do Wait(50) end; return returnable
end)

lib.callback.register('kk-society:loadBills', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local returnable = nil

    if xPlayer then
        MySQL.Async.fetchAll('SELECT identifier, label, amount, sender FROM billing WHERE target=@target', {
			['@target'] = xPlayer.job.name 
		}, function(result)
			local bills = {}

			for index, data in ipairs(result) do
				MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE pid=@pid', {
					['@pid'] = data.identifier
				}, function(result2)
					if result2[1] ~= nil then 
						MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE pid=@pid', {
							['@pid'] = data.sender
						}, function(result3)
							if result3[1] ~= nil then 
								local inserting = {
									name = result2[1].firstname..' '..result2[1].lastname,
									sender = result3[1].firstname..' '..result3[1].lastname,
									amount = data.amount,
									reason = data.label
								}

								table.insert(bills, inserting)
							end
						end)
					end
				end)
			end

			Wait(750)

			returnable = bills
        end)
    else
        returnable = {}
    end

    while returnable == nil do Wait(50) end; return returnable
end)

lib.callback.register('kk-society:getVehicles', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local returnable = nil

    if xPlayer then
		local shopElements = {}
		local authorizedVehicles = Config.AuthorizedVehicles[xPlayer.job.name]

		if authorizedVehicles then
			if #authorizedVehicles > 0 then
				for k,vehicle in ipairs(authorizedVehicles) do
					table.insert(shopElements, { 
						label = vehicle.model,
						name  = vehicle.name,
						model = vehicle.model,
						price = '$'..vehicle.price,
						props = vehicle.props,
						type  = type
					})
				end

				Wait(500)

				returnable = shopElements 
			end
		end
    else
        returnable = {}
    end

    while returnable == nil do Wait(50) end; return returnable
end)

RegisterNetEvent('kk-society:server:createNewRank')
AddEventHandler('kk-society:server:createNewRank', function(label)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer then 
		if xPlayer.job.permissions.leaderMenu then
			if label ~= '' then
				MySQL.Async.fetchAll('SELECT * FROM job_grades WHERE label = ?', {label}, function(result)
					if result[1] then 
						TriggerClientEvent('kk-society:client:showNotify', xPlayer.source, 'Auastmed', 'Antud auaste juba eksisteerib!', 'error')
					else
						local grades = MySQL.Sync.fetchAll('SELECT * FROM job_grades WHERE job_name = ?', {xPlayer.job.name})

						MySQL.insert('INSERT INTO job_grades (job_name, grade, name, label, salary) VALUES (?, ?, ?, ?, ?) ', {xPlayer.job.name, grades[#grades].grade + 1, string.lower(label), label, 1}, function(result)
							exports['kk-scripts']:sendSocietyLog(xPlayer.source, 'AUASTMED', 'tegi uue auastme ' .. label .. '.')
							TriggerClientEvent('kk-society:client:showNotify', xPlayer.source, 'Auastmed', 'Lisasite uue auastme nimega ' .. label .. '!', 'success')

							ESX.ReloadJobs(function()
								local Players = ESX.GetPlayers()
			
								for k, v in pairs(Players) do
									local xTarget = ESX.GetPlayerFromId(v)
				
									if xTarget.job.name == xPlayer.job.name then
										xTarget.setJob(xTarget.job.name, xTarget.job.grade)
				
										xTarget.setDuty(false, true)
										Wait(5)
										xTarget.setDuty(true, true)
									end
								end
							end)
						end)
					end 
				end)
			else
				TriggerClientEvent('kk-society:client:showNotify', xPlayer.source, 'Auastmed', 'Te ei saa tühja auastet luua!', 'error')
			end
		end
	end
end) 

RegisterNetEvent('kk-society:server:deleteRank')
AddEventHandler('kk-society:server:deleteRank', function(rid)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer then 
		if xPlayer.job.permissions.leaderMenu then
			if rid == 99 then
				TriggerClientEvent('kk-society:client:showNotify', xPlayer.source, 'Auastmed', 'Admini astet ei saa eemaldada!', 'error')
				return
			end

			if rid then
				MySQL.Async.fetchAll('SELECT * FROM users WHERE job = ? AND job_grade = ?', {xPlayer.job.name, rid}, function(result)
					if result[1] then
						for k,v in pairs(result) do
							local xTarget = ESX.GetPlayerFromIdentifier(v.pid)

							if xTarget then
								xTarget.setJob(xTarget.job.name, 0)
								xTarget.setDuty(false, true)
								Wait(5)
								xTarget.setDuty(true, true)
							else
								MySQL.update.await('UPDATE users SET job_grade = ? WHERE pid = ?', {0, xTarget.identifier})
							end
						end
					end
					
					MySQL.Async.execute('DELETE FROM job_grades WHERE grade = ? AND job_name = ?', {rid, xPlayer.job.name}, function(rowsChanged)
						if rowsChanged then
							TriggerClientEvent('kk-society:client:showNotify', xPlayer.source, 'Auastmed', 'Eemaldasite auastme ' .. rid ..'!', 'success')
							exports['kk-scripts']:sendSocietyLog(xPlayer.source, 'AUASTME EEMALDAMINE', 'Auaste: ' .. rid .. '.')
						end
					end)
				end)
			end
		end
	end
end)

RegisterServerEvent('kk-society:server:inviteToCompany', function(pid)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer then 
		if xPlayer.job.permissions.leaderMenu then
			if tryEmployeing(xPlayer.job.name) then
				if pid then
					MySQL.Async.fetchAll('SELECT * FROM users WHERE pid = ?', { pid }, function(result)
						if result[1] ~= nil then 
							local xTarget = ESX.GetPlayerFromIdentifier(pid)

							if xTarget then
								if xTarget.source == xPlayer.source then return end
								invitations[xTarget.source] = xPlayer.job.name
								exports['kk-scripts']:sendSocietyLog(xPlayer.source, 'LIIKMED', 'kutsus fraktsiooni isiku ' .. xTarget.name .. '.')
								TriggerClientEvent('kk-society:client:sendInvitation', xTarget.source, {xPlayer.job.name, xPlayer.job.label})
							else
								TriggerClientEvent('kk-society:client:showNotify', xPlayer.source, 'Liikmed', 'Antud isik ei ole hetkel linnas!', 'error')
							end
						else
							TriggerClientEvent('kk-society:client:showNotify', xPlayer.source, 'Liikmed', 'Antud isik ei eksisteeri andmebaasis!', 'error')
						end 
					end)
				end
			else
				TriggerClientEvent('kk-society:client:showNotify', xPlayer.source, 'Liikmed', 'Fraktsioonis on liiga palju liikmeid!', 'error')
			end 
		end
	end
end)

RegisterNetEvent('kk-society:server:declineInvitation', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer then
		invitations[xPlayer.source] = nil
	end
end)

RegisterServerEvent('kk-society:server:acceptInvitation', function(job)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer then
		if tryEmployeing(job) then 
			if invitations[xPlayer.source] == job then
				invitations[xPlayer.source] = nil
				local grades = MySQL.Sync.fetchAll('SELECT * FROM job_grades WHERE job_name = ?', {job})

				xPlayer.setDuty(false)
				Wait(5)
				xPlayer.setJob(job, grades[1].grade)
				
				for k,v in pairs(ESX.GetPlayers()) do
					local sPlayer = ESX.GetPlayerFromId(v)

					sPlayer.setDuty(false, true)
					Wait(5)
					sPlayer.setDuty(true, true)
				end

				exports['kk-scripts']:sendSocietyLog(xPlayer.source, 'LIIKMED', 'Liitus fraktsiooniga.')
			end
		else
			TriggerClientEvent('kk-scripts:client:SendAlert', xPlayer.source, { type = 'error', text = 'Antud fraktsioonis on liiga palju liikmeid, seega te ei saanud liituda.'})
			invitations[xPlayer.source] = nil
		end
	end
end)

RegisterNetEvent('kk-society:server:leaveFromCompany')
AddEventHandler('kk-society:server:leaveFromCompany', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer then
		exports['kk-scripts']:sendSocietyLog(xPlayer.source, 'LIIKMED', 'Lahkus fraktsioonist.')
		Wait(350)
		xPlayer.setDuty(false)
		Wait(5)
		xPlayer.setJob('unemployed', 0)
	end
end) 

RegisterNetEvent('kk-society:server:changeRank')
AddEventHandler('kk-society:server:changeRank', function(identifier, grade)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer then 
		if xPlayer.job.permissions.leaderMenu then
			if tonumber(grade) == 99 then
				TriggerClientEvent('kk-society:client:showNotify', xPlayer.source, 'Auastmed', 'Te ei saa kedagi määrata adminiks!', 'error')
				return
			end

			if identifier then
				local xTarget = ESX.GetPlayerFromIdentifier(identifier)

				if xTarget then
					xTarget.setJob(xPlayer.job.name, grade)
					xTarget.setDuty(false)
					Wait(5)
					xTarget.setDuty(true)
					exports['kk-scripts']:sendSocietyLog(xPlayer.source, 'AMETIKÕRGENDUS', 'LIIGE ' .. xTarget.name .. '; UUS ASTE: ' .. grade .. '.')
				else
					MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE pid=@pid', {
						['@pid'] = identifier
					}, function(result)
						MySQL.Sync.execute('UPDATE users SET job = @job WHERE pid = @pid', {
							['@pid'] = identifier,
							['@job'] = xPlayer.job.name
						})

						MySQL.Sync.execute('UPDATE users SET job_grade = @job_grade WHERE pid = @pid', {
							['@pid'] = identifier,
							['@job_grade'] = grade
						})

						MySQL.Sync.execute('UPDATE users SET duty = @duty WHERE pid = @pid', {
							['@pid'] = identifier,
							['@duty'] = 0
						})

						exports['kk-scripts']:sendSocietyLog(xPlayer.source, 'AMETIKÕRGENDUS', 'LIIGE ' .. result[1].firstname .. ' ' .. result[1].lastname .. '; UUS ASTE: ' .. grade .. '.')
					end)
				end
			end
		end
	end
end)

RegisterNetEvent('kk-society:server:removeFromCompany')
AddEventHandler('kk-society:server:removeFromCompany', function(identifier)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer then 
		if xPlayer.job.permissions.leaderMenu then
			if identifier then
				local xTarget = ESX.GetPlayerFromIdentifier(identifier)

				if xTarget then
					xTarget.setDuty(false)
					Wait(5)
					xTarget.setJob('unemployed', 0)
					exports['kk-scripts']:sendSocietyLog(xPlayer.source, 'VALLANDAMINE', 'LIIGE ' .. xTarget.name .. '.')
				else
					MySQL.Async.fetchAll('SELECT firstname, lastname FROM users WHERE pid=@pid', {
						['@pid'] = identifier
					}, function(result)
						MySQL.Sync.execute('UPDATE users SET job = @job WHERE pid = @pid', {
							['@pid'] = identifier,
							['@job'] = 'unemployed'
						})

						MySQL.Sync.execute('UPDATE users SET job_grade = @job_grade WHERE pid = @pid', {
							['@pid'] = identifier,
							['@job_grade'] = 0
						})

						exports['kk-scripts']:sendSocietyLog(xPlayer.source, 'VALLANDAMINE', 'LIIGE ' .. result[1].firstname .. ' ' .. result[1].lastname .. '.')
					end)
				end
			end
		end
	end
end)

lib.callback.register('kk-society:getMoneyCompany', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local returnable = nil

    if xPlayer then
		if xPlayer.job.permissions.leaderMenu then
			TriggerEvent('Society.GetMoney', xPlayer.job.name, function(money) returnable = money end)
		else
			returnable = 0
		end
    else
        returnable = 0
    end

    while returnable == nil do Wait(50) end; return returnable
end)

RegisterServerEvent('kk-society:server:moneyActions')
AddEventHandler('kk-society:server:moneyActions', function(amount, type)
    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	amount = ESX.Math.Round(tonumber(amount))

	if xPlayer.job.permissions.leaderMenu then
        if type == "insert" then
            if amount > 0 and xPlayer.getMoney() >= amount then
				xPlayer.removeMoney(amount)
				exports['kk-scripts']:sendSocietyLog(xPlayer.source, 'RAHA SISESTAMINE', 'SUMMA: $' .. amount .. '.')
				xPlayer.showNotification(_U('have_deposited', ESX.Math.GroupDigits(amount)))
				TriggerEvent('Society.AddMoney', xPlayer.job.name, amount)
            else
                xPlayer.showNotification(_U('invalid_amount'))
            end
        elseif type == "remove" then
			TriggerEvent('Society.GetMoney', xPlayer.job.name, function(money)
				if amount > 0 and money >= amount then
					TriggerEvent('Society.RemoveMoney', xPlayer.job.name, amount)
					exports['kk-scripts']:sendSocietyLog(xPlayer.source, 'RAHA VÄLJASTAMINE', 'SUMMA: $' .. amount .. '.')
                    xPlayer.addMoney(amount)
                    xPlayer.showNotification(_U('have_withdrawn', ESX.Math.GroupDigits(amount)))
				else
					xPlayer.showNotification(_U('invalid_amount'))
				end
			end)
        end
	end
end)

lib.callback.register('kk-society:loadEditRank', function(source, rankId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local returnable = nil

    if xPlayer then
		MySQL.Async.fetchAll('SELECT * FROM job_grades WHERE job_name = @job_name AND grade = @grade', {
			['@job_name'] = xPlayer.job.name,
			['@grade'] = rankId
		}, function(result)
			local data = {
				permissions = json.decode(result[1].permissions),
				salary = result[1].salary
			}

			returnable = data
		end)
    else
        returnable = {}
    end

    while returnable == nil do Wait(50) end; return returnable
end)

RegisterNetEvent('kk-society:server:saveRank')
AddEventHandler('kk-society:server:saveRank', function(rankId, salary, permissions)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer.job.permissions.leaderMenu then
		if rankId == 99 then
			TriggerClientEvent('kk-society:client:showNotify', xPlayer.source, 'Auastmed', 'Te ei saa redigeerida admin ranki!', 'error')
			return
		end

		if salary <= Config.MaxSalary then
			MySQL.Async.execute('UPDATE job_grades SET salary = @salary, permissions = @permissions WHERE job_name = @job_name AND grade = @grade', {
				['@salary']   = salary,
				['@permissions'] = json.encode(permissions),
				['@job_name'] = xPlayer.job.name,
				['@grade']    = rankId
			}, function(rowsChanged)
				exports['kk-scripts']:sendSocietyLog(xPlayer.source, 'AUASTME REDIGEERIMINE', 'ASTE: ' .. rankId .. '; UUS PALK: $' .. salary .. '.')

				ESX.ReloadJobs(function()
					local Players = ESX.GetPlayers()

					for k, v in pairs(Players) do
						local xTarget = ESX.GetPlayerFromId(v)
	
						if xTarget.job.name == xPlayer.job.name then
							xTarget.setJob(xTarget.job.name, xTarget.job.grade)
	
							xTarget.setDuty(false, true)
							Wait(5)
							xTarget.setDuty(true, true)
						end
					end
				end)
			end)
		else
			TriggerClientEvent('kk-society:client:showNotify', xPlayer.source, 'Palgad', 'Maksimaalne palk on $' .. Config.MaxSalary .. '!', 'error')
		end
	else
		print(('kk-society: %s attempted to setJobSalary'):format(xPlayer.identifier))
	end
end)

RegisterServerEvent('kk-society:server:activatePanic', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer then
		if xPlayer.job.name == 'ambulance' or xPlayer.job.name == 'police' and xPlayer.job.onDuty then
			local xPlayers = ESX.GetPlayers()

			for k,v in pairs(xPlayers) do
				local xTarget = ESX.GetPlayerFromId(v)
		
				if xTarget.job.name == 'police' or xTarget.job.name == 'ambulance' and xTarget.job.onDuty then
					TriggerClientEvent('InteractSound_CL:PlayOnOne', xTarget.source, 'panicbutton', 1.0)
				end
			end
	
			TriggerClientEvent('kk-dispatch:client:sendDispatch', xPlayer.source, 'ambulance', '^8[10-48]RIIGITÖÖTAJA PAANIKAALARM')
			Wait(500)
			TriggerClientEvent('kk-dispatch:client:sendDispatch', xPlayer.source, 'police', '^8[10-48]RIIGITÖÖTAJA PAANIKAALARM')
		end
	end
end)

AddEventHandler('Society.GetMoney', function(society, cb)
    local society = accounts[society]

    if society then
        cb(society.money)
    else
        cb(0)
    end
end)

AddEventHandler('Society.RemoveMoney', function(society, amount)
    local society = accounts[society]

    if society then
        society.money = society.money - amount
    end
end)

AddEventHandler('Society.AddMoney', function(society, amount)
    local society = accounts[society]

    if society then
        society.money = society.money + amount
    end
end)