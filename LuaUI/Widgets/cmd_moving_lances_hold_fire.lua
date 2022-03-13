local widgetName = "Moving Lances Hold Fire";

function widget:GetInfo()
    return {
        name      = widgetName,
        version   = '0.1.0',
        desc      = "Reduces Lance friendly fire",
        author    = "dunno",
        date      = "February 12, 2022",
        license   = "MIT",
        layer     = 0,
        enabled   = true
    }
end

local Echo                = Spring.Echo
local GetMyTeamID         = Spring.GetMyTeamID
local GiveOrderToUnit     = Spring.GiveOrderToUnit
local GetUnitStates       = Spring.GetUnitStates
local GetUnitVelocity     = Spring.GetUnitVelocity
local GetTeamUnitsByDefs  = Spring.GetTeamUnitsByDefs
local CMD_FIRE_STATE      = CMD.FIRE_STATE
local CMD_STOP            = CMD.STOP

local myTeamID
local lanceUnitDefID
local areWeSettingFireState = false

-- State machine per lance:
-- New lance starts at state F if on Fire At Will, N otherwise

-- State F (Fire at Will)
--   Lance moving => R; firestate := Return Fire
--   Firestate changed by player => N
local State_F = 1

-- State R (Widget-induced Return Fire):
--   Lance not moving => F; firestate := Fire at Will
--   Firestate changed by player => M
local State_R = 2

-- State N (Not Fire At Will)
--   Firestate changed to Fire at Will => F
local State_N = 3

-- State M (Manual Override):
--   Stop command => F or N
local State_M = 4

-- State F or R
local moveMonitoredLances = {} 

-- State N or M
local otherLances = {} 

local EMPTY_TABLE = {}
local paramTableReturnFire = { CMD.FIRESTATE_RETURNFIRE }
local paramTableFireAtWill = { CMD.FIRESTATE_FIREATWILL }

local function trace(msg)
    Echo("[Lances widget] "..msg)
end

local function traceLance(lanceId, msg)
    trace("Lance "..lanceId..": "..msg)
end

local function traceStateChange(lanceId, old, new)
    traceLance(lanceId, old.." => "..new)
end

local function UnitAdded(unitID, unitDefID, unitTeam)
    if not (unitDefID == lanceUnitDefID and unitTeam == myTeamID) then 
        return 
    end

    if GetUnitStates(unitID).firestate == CMD.FIRESTATE_FIREATWILL
    then
        moveMonitoredLances[unitID] = State_F
        traceStateChange(unitID, "Unmanaged", "F")
    else
        otherLances[unitID] = State_N
        traceStateChange(unitID, "Unmanaged", "N")
    end
end

local function UnitRemoved(unitID, unitDefID, unitTeam)
    if not (unitDefID == lanceUnitDefID and unitTeam == myTeamID) then 
        return 
    end

    if moveMonitoredLances[unitID] then trace("Unmanaging lance "..unitID.." (State "..moveMonitoredLances[unitID]..")")
    elseif otherLances[unitID] then trace("Unmanaging lance "..unitID.." (State "..otherLances[unitID]..")")
    else trace("Destroyed/captured lance was unexpectedly not managed by widget: "..unitID)
    end

    moveMonitoredLances[unitID] = nil
    otherLances[unitID] = nil
end

local function InitLances()
    for _, lanceID in pairs(GetTeamUnitsByDefs(myTeamID, lanceUnitDefID)) do
        UnitAdded(lanceID, lanceUnitDefID, myTeamID)
    end
end

local function SetFireState(lanceId, paramTable)
    areWeSettingFireState = true
    GiveOrderToUnit(lanceId, CMD_FIRE_STATE, paramTable, 0)
    areWeSettingFireState = false
end

local function State_F_to_R(unitID)
    moveMonitoredLances[unitID] = State_R
    traceStateChange(unitID, "F", "R")
end

local function State_F_to_N(unitID)
    moveMonitoredLances[unitID] = nil
    assert(otherLances[unitID] == nil)
    otherLances[unitID] = State_N
    traceStateChange(unitID, "F", "N")
end

local function State_F_to_M(unitID)
    moveMonitoredLances[unitID] = nil
    assert(otherLances[unitID] == nil)
    otherLances[unitID] = State_M
    traceStateChange(unitID, "F", "M")
end

local function State_R_to_F(unitID)
    moveMonitoredLances[unitID] = State_F
    traceStateChange(unitID, "R", "F")
end

local function State_R_to_M(unitID)
    moveMonitoredLances[unitID] = nil
    assert(otherLances[unitID] == nil)
    otherLances[unitID] = State_M
    traceStateChange(unitID, "R", "M")
end

local function State_N_to_F(unitID)
    otherLances[unitID] = nil
    assert(moveMonitoredLances[unitID] == nil)
    moveMonitoredLances[unitID] = State_F
    traceStateChange(unitID, "N", "F")
end

local function State_M_to_F(unitID)
    otherLances[unitID] = nil
    assert(moveMonitoredLances[unitID] == nil)
    moveMonitoredLances[unitID] = State_F
    traceStateChange(unitID, "M", "F")
end

local function State_M_to_N(unitID)
    otherLances[unitID] = State_N
    traceStateChange(unitID, "M", "N")
end

local function OnLanceFirestateChanged(unitID, firestate)
    local state = moveMonitoredLances[unitID]

    if state == State_F then
        if firestate ~= CMD.FIRESTATE_FIREATWILL
        then
            State_F_to_N(unitID)
        end

    elseif state == State_R then
        if firestate ~= CMD.FIRESTATE_RETURNFIRE
        then
            State_R_to_M(unitID)
        end
    else
        assert(state == nil)

        state = otherLances[unitID]

        if state == State_N then
            if firestate == CMD.FIRESTATE_FIREATWILL then
                State_N_to_F(unitID)
            end
        elseif state == State_M then
            -- Do nothing
        else
            assert(state == nil)
            -- traceLance(unitID, "Unexpectedly not managed by widget")
        end
    end
end

local function OnLanceStopCommand(unitID)
    local state = otherLances[unitID]
    if state == State_M then
        if GetUnitStates(unitID).firestate == CMD.FIRESTATE_FIREATWILL then
            State_M_to_F(unitID)
        else
            State_M_to_N(unitID)
        end
    end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Callins

function widget:Initialize()
    lanceUnitDefID = UnitDefNames.hoverarty and UnitDefNames.hoverarty.id
    if not lanceUnitDefID then
        Echo("Lance UnitDef not found; unloading widget")
		widgetHandler:RemoveWidget()
		return false
    end
    myTeamID = GetMyTeamID()

    InitLances()
end

function widget:UnitFinished(unitID, unitDefID, unitTeam)
    UnitAdded(unitID, unitDefID, unitTeam)
end

function widget:UnitGiven(unitID, unitDefID, newTeam, oldTeam)
    UnitAdded(unitID, unitDefID, newTeam)
end

function widget:UnitDestroyed(unitID, unitDefID, unitTeam)
    UnitRemoved(unitID, unitDefID, unitTeam)
end

function widget:UnitTaken(unitID, unitDefID, oldTeam, newTeam)
    UnitRemoved(unitID, unitDefID, oldTeam)
end


function widget:GameFrame(f)
    local speed

    for lanceId, state in pairs(moveMonitoredLances) do
        _, _, _, speed = GetUnitVelocity(lanceId)

        if state == State_F then
            if speed > 0.5 then
                local firestate = GetUnitStates(lanceId).firestate 
                if GetUnitStates(lanceId).firestate == CMD.FIRESTATE_FIREATWILL then
                    State_F_to_R(lanceId)
                    SetFireState(lanceId, paramTableReturnFire)
                else
                    traceLance(lanceId, "Unexpected: Is in state F, but firestate is not Fire At Will, but "..firestate)
                    State_F_to_M(lanceId)
                end
            end
        elseif state == State_R then
            if speed < 0.4 then
                local firestate = GetUnitStates(lanceId).firestate 
                if firestate == CMD.FIRESTATE_RETURNFIRE then
                    State_R_to_F(lanceId)
                    SetFireState(lanceId, paramTableFireAtWill)
                else
                    traceLance(lanceId, "Unexpected: Is in state R, but firestate is not Return Fire but "..firestate)
                    State_R_to_M(lanceId)
                end
            end
        else
            assert(false)
        end
    end
end

function widget:UnitCommand(unitID, unitDefID, unitTeam, cmdId, cmdParams, cmdOpts, cmdTag)
    if not (unitDefID == lanceUnitDefID and unitTeam == myTeamID) then 
        return 
    end

    if cmdId == CMD_FIRE_STATE then
        if areWeSettingFireState then 
            trace("UnitCommand handler suppressed because areWeSettingFireState is true")
            return
        end

        --local firestate = GetUnitStates(unitID).firestate
        local firestate = cmdParams[1]

        --[[
        traceLance(unitID, " UnitCommand "..
            Spring.Utilities.TableToString({cmdParams = cmdParams, cmdOpts = cmdOpts, cmdTag = cmdTag})..
            " , firestate = "..firestate)
            ]]--

        OnLanceFirestateChanged(unitID, firestate)
    elseif cmdId == CMD_STOP then
        OnLanceStopCommand(unitID)
    end
end