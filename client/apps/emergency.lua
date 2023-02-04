ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

end)

-- Configure Dispatch Options
Config.EmergencyDispatch = {
    [1] = { job = 'police', display = 'LSPD' },
    [2] = { job = 'ambulance', display = 'LSMD' },
    [3] = { job = 'doj', display = 'DoJ' },
    [4] = { job = 'regierung', display = 'Regierung' },
}
-- Configure Access to Menus
Config.EmergencyAccess = {
    ['police'] = {
        warning = true,
        pager = true,
        pagerOptions = {
            [1] = {display = 'Off-Duty LSPD', jobs = {'offpolice','police'}},
            [2] = {display = 'Off-Duty LSMD', jobs = {'offambulance','ambulance'}},
        }
    },
    ['ambulance'] = {
        warning = true,
        pager = true,
        pagerOptions = {
            [1] = {display = 'Off-Duty LSMD', jobs = {'offambulance','ambulance'}},
            [2] = {display = 'Off-Duty LSPD', jobs = {'offpolice','police'}},
        }
    },
    ['regierung'] = {
        warning = true,
        pager = false,
        pagerOptions = {}
    }
}

function checkAccess(configItem, job)
    if(Config.EmergencyAccess[job.name] == nil) then return false end
    if(Config.EmergencyAccess[job.name][configItem] == nil) then return false end
    return Config.EmergencyAccess[job.name][configItem]
end

--Add your custom app events here!
RegisterNUICallback('getPlayerJob', function(data, cb)
    local playerJob = ESX.GetPlayerData().job
    cb(playerJob.name)
end)

RegisterNUICallback('getDispatchOptions', function(data, cb)
    cb(json.encode(Config.EmergencyDispatch))
end)

RegisterNUICallback('getPagerOptions', function(data, cb)
    local playerJob = ESX.GetPlayerData().job
    if(Config.EmergencyAccess[playerJob.name].pagerOptions == nil) then 
        cb({})
    else
        cb(json.encode(Config.EmergencyAccess[playerJob.name].pagerOptions))
    end
end)

RegisterNUICallback('checkAccess', function(data, cb)
    local playerJob = ESX.GetPlayerData().job
    local ret = checkAccess(data.configItem, playerJob)
    cb(ret)
end)

RegisterNUICallback('sendDispatch', function(data, cb)

    local dispatch = exports['cd_dispatch']:GetPlayerInfo()

    TriggerServerEvent('cd_dispatch:AddNotification', {
        job_table = data.jobs, -- Data of job
        coords = dispatch.coords,
        title = '['..data.respondString..'] Dispatch '..dispatch.street_2,
        message = data.message, -- Data of messages
        flash = 0,
        unique_id = tostring(math.random(0000000,9999999)),
        blip = {
            sprite = 57, 
            scale = 0.8, 
            colour = 3,
            flashes = false, 
            text = '['..data.respondString..'] Dispatch '..dispatch.street,
            time = (5*60*1000),
            sound = 1,
        }
    })
    cb(200)
end)

RegisterNUICallback('sendWarningMessage', function(data, cb)
    local xPlayer = ESX.GetPlayerData()
    if checkAccess("warning", xPlayer.job) then
        data.job = xPlayer.job.label
        TriggerServerEvent('ng_smartphoneapp:emergency_sendWarningMessage', data)
        cb(200)
    else
        cb(401)
    end
end)

RegisterNetEvent('ng_smartphoneapp:emergency_receiveWarningMessage')
AddEventHandler('ng_smartphoneapp:emergency_receiveWarningMessage', function(data)

    --Citizen.Trace("received data "..json.encode(data).."\n")
    data.action = 'emergencyWarningMessage'
    SendNUIMessage(data)
end)

RegisterNUICallback('clearMessage', function(data, cb)
    --Citizen.Trace("clear requested\n")
    TriggerServerEvent('ng_smartphoneapp:emergency_clearMessage', data)
end)

RegisterNetEvent('ng_smartphoneapp:emergency_clearMessage')
AddEventHandler('ng_smartphoneapp:emergency_clearMessage', function(data)

    --Citizen.Trace("clear message "..json.encode(data).."\n")
    data.action = 'clearMessage'
    SendNUIMessage(data)
end)

AddEventHandler('esx:playerLoaded', function()
    --Get all stored messages from the server
    Citizen.Wait(5*1000)
    TriggerServerEvent('ng_smartphoneapp:emergency_getWarningMessage')

    ESX.TriggerServerCallback('ng_smartphoneapp:getSettings', function(data)
        Citizen.Trace("getSettings received: "..json.encode(data).."\n")
        data.action = 'emergencySettings'
        SendNUIMessage(data)
    end, ESX.GetPlayerData().identifier)
end)

RegisterNUICallback('updateSettings', function(data, cb)
    Citizen.Trace("updateSettings: "..json.encode(data).."\n")
    TriggerServerEvent("ng_smartphoneapp:updateSettings",ESX.GetPlayerData().identifier, data)
    cb(200)
end)

RegisterNUICallback('sendPagerMessage', function(data, cb)
    local xPlayer = ESX.GetPlayerData()
    if checkAccess("pager", xPlayer.job) then
        TriggerServerEvent('ng_smartphoneapp:emergency_sendPagerMessage', data)
        cb(200)
    else
        cb(401)
    end
end)

RegisterNetEvent('ng_smartphoneapp:emergency_receivePagerMessage')
AddEventHandler('ng_smartphoneapp:emergency_receivePagerMessage', function(data)

    data.action = 'emergencyPagerMessage'
    local xPlayer = ESX.GetPlayerData()
    for k, v in pairs(data.jobs) do
        if(xPlayer.job.name == v) then
            SendNUIMessage(data)
            break
        end
    end
end)