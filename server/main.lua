local Framework = nil

if Config.Framework == 'QBCore' then
    Framework = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'ESX' then
    TriggerEvent('esx:getSharedObject', function(obj) Framework = obj end)
end

RegisterNetEvent('qb-atmrobbery:giveReward')
AddEventHandler('qb-atmrobbery:giveReward', function(reward)
    local src = source
    if Config.Framework == 'QBCore' then
        local Player = Framework.Functions.GetPlayer(src)
        if Player then
            Player.Functions.AddMoney('cash', reward)
        end
    elseif Config.Framework == 'ESX' then
        local xPlayer = Framework.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.addMoney(reward)
        end
    end
end)
