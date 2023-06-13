local ragdoll = true
local reviving = false

RegisterNetEvent("cvt-ambulance:notify", function(title, description, group)
    lib.notify({
        title = title,
        description = description,
        type = group
    })
end)

RegisterNetEvent("cvt-ambulance:createblip", function(x, y, z, sprite, text)
    blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, sprite)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
      
    SetBlipRoute(blip, true)
end)

RegisterNetEvent("cvt-ambulance:spawnped", function(x, y, z, randomModel)
    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local npcCoords = vector3(x, y, z)
    local dist = #(playerCoords - npcCoords)
    local hash = GetHashKey(randomModel)
    RequestAnimDict("missheistfbi3b_ig8_2")
    RequestAnimDict("misslamar1dead_body")
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(100)
    end
    print("Spawning")
    if dist < 150 then
        npc = CreatePed(0, hash, vector3(x, y, z - 1), heading, false, true)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        TaskPlayAnim(npc, "misslamar1dead_body", "dead_idle", 1.0, 1.0, -1, 1, 0, 0, 0, 0)
        CreateThread(function()
            while not reviving do
                Wait(0)
                local ped = PlayerPedId()
                local playerCoords = GetEntityCoords(ped)
                local npcCoords = vector3(x, y, z)
                local dist = #(playerCoords - npcCoords)
                if dist < 2.5 then
                    reviving = true
                    TaskPlayAnim(ped, "missheistfbi3b_ig8_2", "cpr_loop_paramedic", 8.0, -8.0, -1, 0, 0, false, false, false)
                    TaskPlayAnim(npc, "missheistfbi3b_ig8_2", "cpr_loop_victim", 8.0, -8.0, -1, 0, 0, false, false, false)
                    while IsEntityPlayingAnim(ped, "missheistfbi3b_ig8_2", "cpr_loop_paramedic", 3) do
                        Citizen.Wait(0)
                        DisableAllControlActions(0)
                    end
                    SetTimeout(5000, function()
                        ClearPedTasks(ped)
                        local chanceOfDeath = math.random(1, 1)
                        if chanceOfDeath == 1 then
                            ClearPedTasks(npc)
                            StopAnimTask(npc, "missheistfbi3b_ig8_2", "cpr_loop_victim", 0)
                            FreezeEntityPosition(npc, false)
                            SetEntityInvincible(npc, false)
                            SetBlockingOfNonTemporaryEvents(npc, false)
                            SetTimeout(7500, function()
                                DeletePed(npc)
                            end)
                        else
                            ClearPedTasks(npc)
                            StopAnimTask(npc, "missheistfbi3b_ig8_2", "cpr_loop_victim", 0)
                            TaskPlayAnim(npc, "misslamar1dead_body", "dead_idle", 1.0, 1.0, -1, 1, 0, 0, 0, 0)
                            SetTimeout(7500, function()
                                DeletePed(npc)
                            end)
                        end
                        StopAnimTask(ped, "missheistfbi3b_ig8_2", "cpr_loop_paramedic", 0)
                        ragdoll = false
                        reviving = false
                    end)
                end
            end
        end)
    end
end)