--Add your custom app events here!
emergency_warningMessages = {}

RegisterServerEvent('ng_smartphoneapp:emergency_sendWarningMessage')
AddEventHandler('ng_smartphoneapp:emergency_sendWarningMessage', function(data)
    emergency_warningMessages[data.uniqueId] = data
    TriggerClientEvent('ng_smartphoneapp:emergency_receiveWarningMessage', -1, data)
end)

RegisterServerEvent('ng_smartphoneapp:emergency_getWarningMessage')
AddEventHandler('ng_smartphoneapp:emergency_getWarningMessage', function()
    for k, v in pairs(emergency_warningMessages) do
        Citizen.Trace(json.encode(k) .. " | " .. json.encode(v) .. "\n")
        TriggerClientEvent('ng_smartphoneapp:emergency_receiveWarningMessage', source, v)
    end
end)

RegisterServerEvent('ng_smartphoneapp:emergency_clearMessage')
AddEventHandler('ng_smartphoneapp:emergency_clearMessage', function(data)
    emergency_warningMessages[data.uniqueId] = nil
    TriggerClientEvent('ng_smartphoneapp:emergency_clearMessage', -1, data)
end)

RegisterServerEvent('ng_smartphoneapp:emergency_sendPagerMessage')
AddEventHandler('ng_smartphoneapp:emergency_sendPagerMessage', function(data)
    TriggerClientEvent('ng_smartphoneapp:emergency_receivePagerMessage', -1, data)
end)

PHONE_DEFAULT_SETTINGS = {
    notifications = {
        warning_1 = true,
        warning_2 = true,
        warning_3 = true,
        pager = true,
    }
}

ESX.RegisterServerCallback('ng_smartphoneapp:getSettings', function(src, cb, identifier)
    MySQL.Async.fetchAll('SELECT data from datastore_data WHERE name = "ng_smartphoneapp" AND owner = @owner', {
        ['@owner'] = identifier,
    }, function(result)
        if (#result == 0) then
            MySQL.Async.execute('INSERT INTO datastore_data (name, owner, data) VALUES ("ng_smartphoneapp", @owner, @data)', {
                ['@owner'] = identifier,
                ['@data'] = json.encode(PHONE_DEFAULT_SETTINGS),
            })
            cb(PHONE_DEFAULT_SETTINGS)
        else
            cb(json.decode(result[1].data))
        end
    end)
end)

RegisterServerEvent('ng_smartphoneapp:updateSettings')
AddEventHandler('ng_smartphoneapp:updateSettings', function(identifier, data)
    MySQL.Async.execute('UPDATE datastore_data SET data = @data WHERE name = "ng_smartphoneapp" AND owner = @owner', {
        ['@owner'] = identifier,
        ['@data'] = json.encode(data),
    })
end)