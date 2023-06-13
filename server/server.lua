local canChangeDuty = true
local searchWork = false
local inJob = false

local function NotifyPlayer(source, title, description, group)
    local src = source
    TriggerClientEvent("cvt-ambulance:notify", src, title, description, group)
end

local function SpawnPed(source, x, y, z, heading)
    local src = source

    local models = {}
    for key, value in pairs(Config.PedModels) do
        table.insert(models, value[1])
    end
    local randomModelIndex = math.random(1, #models)
    local randomModel = models[randomModelIndex]
    TriggerClientEvent("cvt-ambulance:spawnped", src, x, y, z, randomModel)
end

local function findJob(source)
    local src = source
    local findJob = math.random(1, 1)
    local license = GetPlayerIdentifierByType(src, 'license')
    local grabduty = MySQL.query.await('SELECT onduty FROM ambulancejob WHERE identifier = ?', {license})
    if #grabduty == 1 then
        searchWork = true
        if not inJob then
            NotifyPlayer(src, "Ambulance", "We will contact you when there is a call.", "success")
            inJob = true
            while searchWork do
                Wait(4500)
                if findJob == 1 then
                    searchWork = false
                    NotifyPlayer(src, "Ambulance", "Head to the location on your GPS!", "success")
                    local locations = {}
                    for key, value in pairs(Config.NPCCoords) do
                        table.insert(locations, value[1])
                    end
                    local randomIndex = math.random(1, #locations)
                    local randomLoc = locations[randomIndex]
                    TriggerClientEvent("cvt-ambulance:createblip", src, randomLoc.x, randomLoc.y, randomLoc.z, 51, "Downed Local")
                    SpawnPed(src, randomLoc.x, randomLoc.y, randomLoc.z, randomLoc.w)
                    SetTimeout(60000, function()
                    inJob = false
                    end)
                end
            end
        end
    end 
end

local function ClockOn(source)
    local src = source
    canChangeDuty = false
    local license = GetPlayerIdentifierByType(src, 'license')
    local grabduty = MySQL.query.await('SELECT onduty FROM ambulancejob WHERE identifier = ?', {license})
    if not grabduty then
        local insertquery = MySQL.insert('INSERT INTO ambulancejob (identifier, onduty) values (?, ?)', {license, 1})
    end
    if #grabduty == 0 then
        local insertquery = MySQL.insert('INSERT INTO ambulancejob (identifier, onduty) values (?, ?)', {license, 1})
        NotifyPlayer(src, "Ambulance", "Successfully Clocked On Duty", "success")
    elseif #grabduty == 1 then
        local deleteQuery = MySQL.query.await("DELETE FROM ambulancejob WHERE identifier = ?", {license})
        NotifyPlayer(src, "Ambulance", "Successfully Clocked Off Duty", "error")
    end
    SetTimeout(2500, function()
        canChangeDuty = true
    end)
end

RegisterCommand("duty", function(source)
    local src = source
    if src > 0 then
        if canChangeDuty then
            ClockOn(src)
        end
    end
end, false)

RegisterCommand("ambulancework", function(source)
    local src = source
    if src > 0 then
        findJob(src)
    end
end, false)