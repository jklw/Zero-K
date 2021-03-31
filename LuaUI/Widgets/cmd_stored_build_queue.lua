function widget:GetInfo()
	return {
		name      = "Stored Build Queue",
		desc      = "TODO",
		author    = "dunno",
		date      = "March 7, 2021",
		license   = "MIT",
		layer     = 0,
		enabled   = true
	}
end


---------------------
-- CUSTOMIZE BELOW --
---------------------


local fleaBatchCount = 6

local facConfigs = {
    factoryshield = {
            { name = [[shieldraid]], count = 2 },
            { name = [[shieldcon]], count = 1 },
            { name = [[shieldraid]], count = 1 },
            { name = [[shieldcon]], count = 1 },
            { name = [[shieldassault]], count = 3 },
            { name = [[shieldfelon]], count = 1 },
            { name = [[shieldarty]], count = 1 },
            { name = [[shieldraid]], count = 1 },
            { name = [[shieldaa]], count = 1 },
            { name = [[shieldcon]], count = 1 },
            { name = [[shieldassault]], count = 3 },
            { name = [[shieldshield]], count = 1 },
            { name = [[shieldcon]], count = 1 },
            { name = [[shieldfelon]], count = 1 },
            { name = [[shieldscout]], count = 1 },
            { name = [[shieldskirm]], count = 1 },
            { name = [[shieldcon]], count = 1 },
            { name = [[shieldraid]], count = 1 },
            { name = [[shieldaa]], count = 1 },
            { name = [[shieldarty]], count = 1 },
            { name = [[shieldcon]], count = 1 },
            { name = [[shieldskirm]], count = 1 },
            { name = [[shieldshield]], count = 1 },
            { name = [[shieldassault]], count = 3 },
            { name = [[shieldfelon]], count = 1 },
            { name = [[shieldcon]], count = 1 },
            { name = [[shieldarty]], count = 1 },
            { name = [[shieldassault]], count = 3 },
            { name = [[shieldcon]], count = 1 },
            { name = [[shieldscout]], count = 1 },
    },
    factoryspider = 
        {
            { name = [[spiderscout]], count = 7 },
            { name = [[spidercon]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spideremp]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spideremp]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spidercon]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spideremp]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spideremp]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spiderantiheavy]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spiderskirm]], count = 1 },
            { name = [[spidercon]], count = 1 },
            { name = [[spiderantiheavy]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spidercon]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spideremp]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spiderskirm]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spiderskirm]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spiderskirm]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spiderantiheavy]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spideremp]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spidercon]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spiderskirm]], count = 1 },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spiderscout]], count = fleaBatchCount },
            { name = [[spiderantiheavy]], count = 1 },


            { name = [[spideraa]], count = 0 },
            { name = [[spidercrabe]], count = 0 },
            { name = [[spiderassault]], count = 0 },
            { name = [[spiderriot]], count = 0 },
        },
}





-------------------------------
-- END OF CUSTOMIZATION AREA --
-------------------------------





local EMPTY_TABLE = {}

local GetMyTeamID         = Spring.GetMyTeamID
local GiveOrderToUnit     = Spring.GiveOrderToUnit

local processedFacConfigs = {
}

for facName, facConfig in pairs(facConfigs) do

        local facUnitDef = UnitDefNames[facName]

        local processedFacConfig = {}

        for i, order in ipairs(facConfig) do
            local count = order["count"] 

            if count ~= 0 then
                processedFacConfig[i] = { 
                    id = UnitDefNames[order["name"]].id,
                    count = count
                }
            end
        end

	processedFacConfigs[facUnitDef.id] = processedFacConfig
end

function widget:Initialize()

	if (Spring.GetSpectatingState() or Spring.IsReplay()) and (not Spring.IsCheatingEnabled()) then
		Spring.Echo("StoredBuildQueue widget disabled for spectators")
		widgetHandler:RemoveWidget()
	end

	myTeamID = GetMyTeamID()

end

function widget:UnitFinished(unitID, unitDefID, unitTeam)
	if (unitTeam ~= myTeamID) then
            return
        end

	local facConfig = processedFacConfigs[unitDefID]

	if not facConfig then
		return
	end

--        Spring.Echo("OK")

        for _, order in ipairs(facConfig) do
            -- Spring.Echo("Will build ", entry["count"], entry["id"])
            local negID = -order["id"]

            for rep = 1, order["count"] do

                GiveOrderToUnit(unitID, negID, EMPTY_TABLE, EMPTY_TABLE)

                -- Possible improvement: To decrease the number of issued commands
                -- for large counts, use command modifiers, e.g. shift to queue 5
            end
        end


end

