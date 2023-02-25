if not gadgetHandler:IsSyncedCode() then
	return false
end

function gadget:GetInfo()
	return {
		name = "Disable Buildoptions",
		desc = "Factory UI reflects actual pathability",
		author = "quantum, Sprung",
		date = "2008-05-11 (OG), 2023-02-26 (rewrite)",
		license = "GNU GPL, v2 or later",
		layer = 0,
		enabled = true,
	}
end

local factories = {}

local function ParsePotentialFactory(unitDef)
	if not unitDef.isFactory then
		return
	end

	local buildOptions = unitDef.buildOptions
	if not buildOptions or #buildOptions == 0 then
		return
	end

	return buildOptions
end

for unitDefID, unitDef in pairs(UnitDefs) do
	factories[unitDefID] = ParsePotentialFactory(unitDef)
end

function gadget:UnitCreated(unitID, unitDefID)
	local buildOptions = factories[unitDefID]
	if not buildOptions then
		return
	end

	--[[ Stuff below is not cached in file scope because
	     building factories is generally quite rare. ]]

	local sp = Spring
	local spEditUnitCmdDesc = sp.EditUnitCmdDesc
	local spFindUnitCmdDesc = sp.FindUnitCmdDesc
	local x, _, z = sp.GetUnitPosition(unitID)
	local depth = -sp.GetGroundHeight(x, z)
	local smClasses = Game.speedModClasses
	local smcShip = smClasses.Ship
	local smcHover = smClasses.Hover
	local cmdEditArray = {}

	for i = 1, #buildOptions do
		local buildeeDefID = buildOptions[i]
		local buildeeMoveDef = UnitDefs[buildeeDefID].moveDef
		local smClass = buildeeMoveDef.smClass
		cmdEditArray.disabled = false
		if not smClass then
			-- aircraft or immobile (like nano), not handled atm
		elseif smClass == smcShip then
			if depth < buildeeMoveDef.depth then
				cmdEditArray.disabled = true
			end
		elseif smClass ~= smcHover then
			if depth > buildeeMoveDef.depth then
				cmdEditArray.disabled = true
			end
		end
		spEditUnitCmdDesc(unitID, spFindUnitCmdDesc(unitID, -buildeeDefID), cmdEditArray)
	end
end
