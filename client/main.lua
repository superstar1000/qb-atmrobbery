local Framework = nil

if Config.Framework == 'QBCore' then
    Framework = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'ESX' then
    TriggerEvent('esx:getSharedObject', function(obj) Framework = obj end)
end

-- Player cooldowns
local playerCooldowns = {}

-- Register the ATM targets
Citizen.CreateThread(function()
    for _, model in ipairs(Config.ATMModels) do
        exports['qb-target']:AddTargetModel(model, {
            options = {
                {
                    type = "client",
                    event = "qb-atmrobbery:attemptRobbery",
                    icon = "fas fa-dollar-sign",
                    label = "Rob ATM",
                },
            },
            distance = 2.0
        })
    end
end)

-- Check cooldown
local function isOnCooldown(playerId)
    if playerCooldowns[playerId] then
        local currentTime = GetGameTimer() / 1000
        return (currentTime - playerCooldowns[playerId]) < Config.CooldownTime
    else
        return false
    end
end

-- Attempt robbery event
RegisterNetEvent('qb-atmrobbery:attemptRobbery')
AddEventHandler('qb-atmrobbery:attemptRobbery', function()
    local playerId = PlayerId()
    if isOnCooldown(playerId) then
        Framework.Functions.Notify("You need to wait before robbing another ATM.", "error")
        return
    end
    
    local playerPed = PlayerPedId()

    -- Start the minigame
    local success = false
    if Config.Minigame == 'qb-minigames' then
        success = exports['qb-minigames']:Skillbar('medium')
    elseif Config.Minigame == 'ps-ui' then
        success = exports['ps-ui']:StartMinigame({
            difficulty = 'medium'
        })
    end

    if success then
        Framework.Functions.Notify("Success! Now completing the robbery.", "success")
        TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_ATM', 0, true)
        Citizen.Wait(Config.RobberyTime * 1000)
        ClearPedTasksImmediately(playerPed)
        
        local reward = math.random(Config.RewardMin, Config.RewardMax)
        TriggerServerEvent('qb-atmrobbery:giveReward', reward)

        playerCooldowns[playerId] = GetGameTimer() / 1000
    else
        Framework.Functions.Notify("You failed to hack the ATM.", "error")
        ClearPedTasksImmediately(playerPed)
    end
end)
