local widgetName = "Stored Build Queue";

function widget:GetInfo()
    return {
        name      = widgetName,
        version   = '0.9.0',
        desc      = "Factories start with a customized stored build queue. Recommended setup: Start skirmish -> plop fac -> pause game -> enter your build queue -> press Ctrl+Alt+Shift+S with the fac selected -> exit. To delete the stored queue, do the same with an empty queue.",
        author    = "dunno",
        date      = "January 7, 2022",
        license   = "MIT",
        layer     = 0,
        enabled   = true
    }
end

local GetMyTeamID         = Spring.GetMyTeamID
local GiveOrderToUnit     = Spring.GiveOrderToUnit

local EMPTY_TABLE = {}

local storeBuildQueueButtonName = 'Store build queue'

local myTeamID

-- { facId = buildQ, ... }
-- buildQ = { 1 = { unitDefID = count }, ... }
local buildQsByFacUnitDefID = {}

local invalidQsFromConfigData = {}

local function FormatBuildQueue(buildQ)
    local strings = {}

    for _, item in ipairs(buildQ) do
        local unitDefID, count = next(item, nil)
        local name = UnitDefs[unitDefID].humanName

        if count == 1 then
            table.insert(strings, name)
        else
            table.insert(strings, name..' x'..tostring(count))
        end

    end

    return table.concat(strings, ', ')
end

local function StoreBuildQueue()
    local success = false

    for _,selectedUnit in pairs(Spring.GetSelectedUnits()) do

        local buildQ = Spring.GetFullBuildQueue(selectedUnit)
        local facUnitDefId = Spring.GetUnitDefID(selectedUnit)

        if buildQ and #buildQ > 0 then
            buildQsByFacUnitDefID[facUnitDefId] = buildQ
            Spring.Echo("game_message: Stored the current build queue for "..UnitDefs[facUnitDefId].humanName..": "..FormatBuildQueue(buildQ))
            success = true
        elseif buildQsByFacUnitDefID[facUnitDefId] then
            buildQsByFacUnitDefID[facUnitDefId] = nil
            Spring.Echo("game_message: Deleted the stored build queue for "..UnitDefs[facUnitDefId].humanName)
            success = true
        end
    end

    if not success then
        Spring.Echo("game_message: You pressed the '"..storeBuildQueueButtonName.."' hotkey, but none of the selected units has a build queue.")
    end
end

options_path = 'Settings/Unit Behaviour'

options = {
    store_build_queue = { 
        type = 'button',
        name = storeBuildQueueButtonName,
        desc = 'Saves the current build queue of the selected factory. When you build this type of factory in the future, the queue will be ordered automatically. Persists across games.',
        hotkey = { key = 'S', mod = 'C+A+S+'},
        OnChange = function(self) StoreBuildQueue() end,
    },
}

local function NamifyBuildQueue(buildQ)
    local result = {}

    for i, item in pairs(buildQ) do
        local unitDefID, count = next(item, nil)
        result[i] = { [UnitDefs[unitDefID].name] = count }
    end

    return result
end

local function UnNamifyBuildQueue(namedBuildQ)
    local result = {}

    for i, item in pairs(namedBuildQ) do
        local unitName, count = next(item, nil)
        local unitDef = UnitDefNames[unitName]
        if unitDef and unitDef.id then
            result[i] = { [unitDef.id] = count }
        else
            return false, unitName
        end
    end

    return true, result
end

function widget:GetConfigData()
    local buildQsByFacName = {}

    for facUnitDefID, buildQ in pairs(buildQsByFacUnitDefID) do
        local facName = UnitDefs[facUnitDefID].name
        buildQsByFacName[facName] = NamifyBuildQueue(buildQ)
    end

    return { buildQueues = buildQsByFacName }
end

function widget:SetConfigData(data)
    local buildQsByFacName = data.buildQueues or {}

    buildQsByFacUnitDefID = {}

    for facName, namedBuildQ in pairs(buildQsByFacName) do
        local unitDef = UnitDefNames[facName];

        if unitDef then
            local ok, buildQOrInvalidName = UnNamifyBuildQueue(namedBuildQ)
            if ok then
                buildQsByFacUnitDefID[unitDef.id] = buildQOrInvalidName
            else
                Spring.Echo(widgetName..': Build queue for factory '..facName..' contains invalid unit name '..buildQOrInvalidName)
            end
        else
            Spring.Echo(widgetName..': Invalid factory name: '..facName)
        end
    end
end

function widget:UnitFinished(unitID, unitDefID, unitTeam)
    if (unitTeam ~= myTeamID) then
            return
        end

    local buildQ = buildQsByFacUnitDefID[unitDefID]

    if not buildQ then
        return
    end

    for _, item in ipairs(buildQ) do
        local qUnitDefID, count = next(item, nil)

        local negID = -qUnitDefID;

        for rep = 1, count do

            GiveOrderToUnit(unitID, negID, EMPTY_TABLE, EMPTY_TABLE)

            -- Possible improvement: To decrease the number of issued commands
            -- for large counts, use command modifiers, e.g. shift to queue 5
        end
    end
end

function widget:Initialize()
    myTeamID = GetMyTeamID()
end
