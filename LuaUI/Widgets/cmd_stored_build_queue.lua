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
            { name = [[shieldcon]], count = 1 },
    },
    factoryspider = 
        {
            { name = [[spiderscout]], count = 4 },
            { name = [[spidercon]], count = 1 },
            { name = [[spiderscout]], count = 4 },
            { name = [[spideremp]], count = 3 },
            { name = [[spiderriot]], count = 1 },
            { name = [[spiderscout]], count = 4 },
            { name = [[spideremp]], count = 2 },
            { name = [[spideraa]], count = 1 },
        },
    factoryhover = 
        {
            { name = [[hoverraid]], count = 1 },
            { name = [[hovercon]], count = 1 },
            { name = [[hoverraid]], count = 1 },
            { name = [[hoverheavyraid]], count = 5 },
            { name = [[hoverarty]], count = 1 },
            { name = [[hoverraid]], count = 3 },
            { name = [[hovercon]], count = 1 },
            { name = [[hoveraa]], count = 1 },
            { name = [[hovercon]], count = 2 },
        },
    factoryjump =
        {
            { name = [[jumpscout]], count = 1 },
            { name = [[jumpcon]], count = 1 },
            { name = [[jumpraid]], count = 1 },
            { name = [[jumpblackhole]], count = 1 },
            { name = [[jumpraid]], count = 1 },
            { name = [[jumpskirm]], count = 3 },
            { name = [[jumpcon]], count = 1 },
            { name = [[jumparty]], count = 0 },
            { name = [[jumpblackhole]], count = 1 },
            { name = [[jumpcon]], count = 1 },
            { name = [[jumpskirm]], count = 1 },
            { name = [[jumpaa]], count = 1 },
            { name = [[jumpcon]], count = 1 },
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

-- Unit def name	Human name	In-game description
-- amphaa	Angler	Amphibious Anti-Air Bot
-- amphassault	Grizzly	Heavy Amphibious Assault Walker
-- amphbomb	Limpet	Amphibious Slow Bomb
-- amphcon	Conch	Amphibious Construction Bot, Armored When Idle
-- amphfloater	Buoy	Heavy Amphibious Skirmisher Bot
-- amphimpulse	Archer	Amphibious Raider/Riot Bot
-- amphlaunch	Lobster	Amphibious Launcher Bot
-- amphraid	Duck	Amphibious Raider Bot (Anti-Sub)
-- amphriot	Scallop	Amphibious Riot Bot (Anti-Sub)
-- amphsupport	Bulkhead	Deployable Amphibious Fire Support (must stop to fire)
-- amphtele	Djinn	Amphibious Teleport Bridge
-- assaultcruiser	Vanquisher	Heavy Cruiser (Assault)
-- asteroid	Asteroid	Space Rock
-- athena	Athena	Airborne SpecOps Engineer
-- bomberassault	Eclipse	Assault Bomber (Anti-Static)
-- bomberdisarm	Thunderbird	Disarming Lightning Bomber
-- bomberheavy	Likho	Singularity Bomber
-- bomberprec	Raven	Precision Bomber
-- bomberriot	Phoenix	Saturation Napalm Bomber
-- bomberstrike	Kestrel	Tactical Strike Bomber
-- chicken	Chicken	Swarmer
-- chicken_blimpy	Blimpy	Dodo Bomber
-- chicken_digger	Digger	Burrowing Scout/Raider
-- chicken_dodo	Dodo	Chicken Bomb
-- chicken_dragon	White Dragon	Prime Assault Chicken
-- chicken_drone	Drone	Morphs Into Chicken Structures
-- chicken_drone_starter	Drone	Morphs Into Chicken Structures
-- chicken_leaper	Leaper	Hopping Raider
-- chicken_listener	Listener	Burrowing Mobile Seismic Detector
-- chicken_pigeon	Pigeon	Flying Spore Scout
-- chicken_rafflesia	Rafflesia	Chicken Shield (Static)
-- chicken_roc	Roc	Heavy Attack Flyer
-- chicken_shield	Blooper	Shield/Anti-Air
-- chicken_spidermonkey	Spidermonkey	All-Terrain Support
-- chicken_sporeshooter	Sporeshooter	All-Terrain Spores (Anti-Air/Skirm)
-- chicken_tiamat	Tiamat	Heavy Assault/Riot
-- chickena	Cockatrice	Assault/Anti-Armor
-- chickenblobber	Blobber	Heavy Artillery
-- chickenbroodqueen	Chicken Brood Queen	Tends the Nest
-- chickenc	Basilisk	All-Terrain Riot
-- chickend	Chicken Tube	Defense and energy source
-- chickenf	Talon	Flying Spike Spitter
-- chickenflyerqueen	Chicken Flyer Queen	Clucking Hell!
-- chickenlandqueen	Chicken Queen	Clucking Hell!
-- chickenr	Lobber	Artillery
-- chickens	Spiker	Skirmisher
-- chickenspire	Chicken Spire	Static Artillery
-- chickenwurm	Wurm	Burrowing Flamer (Assault/Riot)
-- cloakaa	Gremlin	Cloaked Anti-Air Bot
-- cloakarty	Sling	Light Artillery Bot
-- cloakassault	Knight	Lightning Assault Bot
-- cloakbomb	Imp	All Terrain EMP Bomb (Burrows)
-- cloakcon	Conjurer	Cloaked Construction Bot
-- cloakheavyraid	Scythe	Cloaked Raider Bot
-- cloakjammer	Iris	Area Cloaker/Jammer Walker
-- cloakraid	Glaive	Light Raider Bot
-- cloakriot	Reaver	Riot Bot
-- cloakskirm	Ronin	Skirmisher Bot (Direct-Fire)
-- cloaksnipe	Phantom	Cloaked Skirmish/Anti-Heavy Artillery Bot
-- damagesink	Damage Sink thing	Does not care if you shoot at it.
-- dronecarry	Gull	Carrier Drone
-- dronefighter	Spicula	Fighter Drone
-- droneheavyslow	Viper	Advanced Battle Drone
-- dronelight	Firefly	Attack Drone
-- empiricaldpser	Empirical DPS thing	Shoot at it for science.
-- empiricaldpsersmall	Empirical DPS thing (small)	Shoot at it for science.
-- empmissile	Shockley	EMP missile
-- energyfusion	Fusion Reactor	Medium Powerplant (+35)
-- energygeo	Geothermal Generator	Medium Powerplant (+25)
-- energyheavygeo	Advanced Geothermal	Large Powerplant (+100) - HAZARDOUS
-- energypylon	Energy Pylon	Extends overdrive grid
-- energysingu	Singularity Reactor	Large Powerplant (+225) - HAZARDOUS
-- energysolar	Solar Collector	Small Powerplant (+2)
-- energywind	Wind/Tidal Generator	Small Powerplant
-- factoryamph	Amphbot Factory	Produces Amphibious Bots
-- factorycloak	Cloakbot Factory	Produces Cloaked, Mobile Robots
-- factorygunship	Gunship Plant	Produces Gunships
-- factoryhover	Hovercraft Platform	Produces Hovercraft
-- factoryjump	Jumpbot Factory	Produces Jumpjet Equipped Robots
-- factoryplane	Airplane Plant	Produces Airplanes
-- factoryshield	Shieldbot Factory	Produces Tough Robots
-- factoryship	Shipyard	Produces Naval Units
-- factoryspider	Spider Factory	Produces Spiders
-- factorytank	Tank Foundry	Produces Heavy Tracked Vehicles
-- factoryveh	Rover Assembly	Produces Light Wheeled Vehicles
-- fakeunit	Fake radar signal	Created by scrambling devices.
-- fakeunit_aatarget	Fake AA target	Used by the jumpjet script.
-- fakeunit_los	LOS Provider	Knows all and sees all
-- generic_tech	Generic Neutral Structure	Unlocks tech
-- grebe	Grebe	Amphibious Raider Bot
-- gunshipaa	Trident	Anti-Air Gunship
-- gunshipassault	Revenant	Heavy Raider/Assault Gunship
-- gunshipbomb	Blastwing	Flying Bomb/Scout (Burrows)
-- gunshipcon	Wasp	Heavy Gunship Constructor
-- gunshipemp	Gnat	Anti-Heavy EMP Drone
-- gunshipheavyskirm	Nimbus	Fire Support Gunship
-- gunshipheavytrans	Hercules	Armed Heavy Air Transport
-- gunshipkrow	Krow	Flying Fortress
-- gunshipraid	Locust	Raider Gunship
-- gunshipskirm	Harpy	Multi-Role Support Gunship
-- gunshiptrans	Charon	Air Transport
-- hoveraa	Flail	Anti-Air Hovercraft
-- hoverarty	Lance	Anti-Heavy Artillery Hovercraft
-- hoverassault	Halberd	Blockade Runner Hover
-- hovercon	Quill	Construction Hovercraft
-- hoverdepthcharge	Claymore	Anti-Sub Hovercraft
-- hoverheavyraid	Bolas	Disruptor Hovercraft
-- hoverminer	Dampener	Minelaying Hover
-- hoverraid	Dagger	Fast Attack Hovercraft
-- hoverriot	Mace	Riot Hover
-- hovershotgun	Punisher	Shotgun Hover
-- hoverskirm	Scalpel	Skirmisher/Anti-Heavy Hovercraft
-- hoverskirm2	Trisula	Light Assault/Battle Hovercraft
-- hoversonic	Morningstar	Antisub Hovercraft
-- jumpaa	Toad	Heavy Anti-Air Jumper
-- jumparty	Firewalker	Saturation Artillery Walker
-- jumpassault	Jack	Melee Assault Jumper
-- jumpblackhole	Placeholder	Black Hole Launcher
-- jumpbomb	Skuttle	Cloaked Jumping Anti-Heavy Bomb
-- jumpcon	Constable	Jumpjet Constructor
-- jumpraid	Pyro	Raider/Riot Jumper
-- jumpscout	Puppy	Walking Missile
-- jumpskirm	Moderator	Disruptor Skirmisher Walker
-- jumpsumo	Jugglenaut	Heavy Riot Jumper
-- mahlazer	Starlight	Planetary Energy Chisel
-- napalmmissile	Inferno	Napalm Missile
-- nebula	Nebula	Atmospheric Mothership
-- planecon	Crane	Construction Aircraft
-- planefighter	Swift	Multi-role Fighter
-- planeheavyfighter	Raptor	Air Superiority Fighter
-- planelightscout	Sparrow	Light Scout Plane
-- planescout	Owl	Area Jammer, Radar/Sonar Plane
-- plateamph	Amphbot Plate	Parallel Unit Production
-- platecloak	Cloakbot Plate	Parallel Unit Production
-- plategunship	Gunship Plate	Parallel Unit Production
-- platehover	Hovercraft Plate	Parallel Unit Production
-- platejump	Jumpbot Plate	Parallel Unit Production
-- plateplane	Airplane Plate	Parallel Unit Production
-- plateshield	Shieldbot Plate	Parallel Unit Production
-- plateship	Ship Plate	Parallel Unit Production
-- platespider	Spider Plate	Parallel Unit Production
-- platetank	Tank Plate	Parallel Unit Production
-- plateveh	Rover Plate	Parallel Unit Production
-- pw_artefact	Ancient Artefact	Mysterious Relic
-- pw_bomberfac	Bomber Factory	Produces bombers
-- pw_dropfac	Dropship Factory	Produces dropships
-- pw_estorage	Energy Storage	Stores energy
-- pw_estorage2	Double Energy Storage	Stores energy
-- pw_garrison	Field Garrison	Reduces Influence gain
-- pw_gaspowerstation	Gas Power Station	Produces Energy
-- pw_generic	Generic Neutral Structure	 
-- pw_grid	Planetary Defense Grid	Defends against everything
-- pw_guerilla	Guerilla Jumpgate	Spreads Influence remotely
-- pw_hq_attacker	Attacker Command	PlanetWars Field HQ (changes influence gain)
-- pw_hq_defender	Defender Command	PlanetWars Field HQ (changes influence gain)
-- pw_inhibitor	Wormhole Inhibitor	Blocks Influence Spread
-- pw_interception	Interception Network	Intercepts planetary bombers
-- pw_metal	Ancient Fabricator	Produces Metal out of thin air (+10)
-- pw_mine	Power Generator Unit	Produces 50 energy/turn
-- pw_mine2	Orbital Solar Array	Produces 100 energy/turn
-- pw_mine3	Planetary Geothermal Tap	Produces 250 energy/turn
-- pw_mstorage2	Metal Storage	Stores metal
-- pw_relay	Communication Relay	Sends messages across the void
-- pw_techlab	Tech Lab	Contains powerful ancient technology
-- pw_warpgate	Warp Gate	Produces warp cores
-- pw_warpgatealt	Warp Gate	Produces warp cores
-- pw_warpjammer	Warp Jammer	Prevents warp attacks
-- pw_wormhole	Wormhole Generator	Links this planet to nearby planets
-- pw_wormhole2	Improved Wormhole	Links this planet to nearby planets
-- raveparty	Disco Rave Party	Destructive Rainbow Projector
-- rocksink	Rocking Damage Sink thing	Rocks when you shoot at it.
-- roost	Roost	Spawns Chicken
-- seismic	Quake	Seismic Missile
-- shieldaa	Vandal	Anti-Air Bot
-- shieldarty	Racketeer	Disarming Artillery
-- shieldassault	Thug	Shielded Assault Bot
-- shieldbomb	Snitch	Crawling Bomb (Burrows)
-- shieldcon	Convict	Shielded Construction Bot
-- shieldfelon	Felon	Shielded Riot/Skirmisher Bot
-- shieldraid	Bandit	Medium-Light Raider Bot
-- shieldriot	Outlaw	Riot Bot
-- shieldscout	Dirtbag	Box of Dirt
-- shieldshield	Aspis	Area Shield Walker
-- shieldskirm	Rogue	Skirmisher Bot (Indirect Fire)
-- shipaa	Zephyr	Anti-Air Frigate
-- shiparty	Envoy	Cruiser (Artillery)
-- shipassault	Siren	Destroyer (Riot/Assault)
-- shipcarrier	Reef	Aircraft Carrier (Bombardment), stockpiles disarm missiles at 5 m/s
-- shipcon	Mariner	Construction Ship
-- shipheavyarty	Shogun	Battleship (Heavy Artillery)
-- shipriot	Corsair	Corvette (Raider/Riot)
-- shipscout	Cutter	Picket Ship (Disarming Scout)
-- shipskirm	Mistral	Rocket Boat (Skirmisher)
-- shiptorpraider	Hunter	Torpedo-Boat (Raider)
-- spideraa	Tarantula	Anti-Air Spider
-- spideranarchid	Anarchid	Riot EMP Spider
-- spiderantiheavy	Widow	Cloaked Scout/Anti-Heavy
-- spiderassault	Hermit	All Terrain Assault Bot
-- spidercon	Weaver	Construction Spider
-- spidercrabe	Crab	Heavy Riot/Skirmish Spider - Curls into Armored Form When Stationary
-- spideremp	Venom	Lightning Riot Spider
-- spiderriot	Redback	Riot Spider
-- spiderscout	Flea	Ultralight Scout Spider (Burrows)
-- spiderskirm	Recluse	Skirmisher Spider (Indirect Fire)
-- starlight_satellite	Glint	Starlight relay satellite
-- staticantinuke	Antinuke	Strategic Nuke Interception System
-- staticarty	Cerberus	Plasma Artillery Battery - Power by connecting to a 50 energy grid
-- staticcon	Caretaker	Construction Assistant
-- staticheavyarty	Big Bertha	Strategic Plasma Cannon
-- staticheavyradar	Advanced Radar	Long-Range Radar
-- staticjammer	Cornea	Area Cloaker/Jammer
-- staticmex	Metal Extractor	Produces Metal
-- staticmissilesilo	Missile Silo	Produces Tactical Missiles
-- staticnuke	Trinity	Strategic Nuclear Launcher, Drains 18 m/s, 3 minute stockpile
-- staticradar	Radar Tower	Early Warning System
-- staticrearm	Airpad	Repairs and Rearms Aircraft, repairs at 2.5 e/s per pad
-- staticshield	Aegis	Area Shield
-- staticsonar	Sonar Station	Locates Water Units
-- staticstorage	Storage	Stores Metal and Energy (500)
-- striderantiheavy	Ultimatum	Cloaked Anti-Heavy/Anti-Strider Walker
-- striderarty	Merlin	Heavy Saturation Artillery Strider
-- striderbantha	Paladin	Ranged Support Strider
-- striderdante	Dante	Assault/Riot Strider
-- striderdetriment	Detriment	Ultimate Assault Strider
-- striderfunnelweb	Funnelweb	Shield Support Strider
-- striderhub	Strider Hub	Constructs Striders
-- striderscorpion	Scorpion	Cloaked Infiltration Strider
-- subraider	Seawolf	Attack Submarine (Stealth Raider)
-- subscout	Lancelet	Scout/Suicide Minisub
-- subtacmissile	Scylla	Tactical Nuke Missile Sub, Drains 20 m/s, 30 second stockpile
-- tacnuke	Eos	Tactical Nuke
-- tankaa	Ettin	Flak Anti-Air Tank
-- tankarty	Emissary	General-Purpose Artillery
-- tankassault	Minotaur	Assault Tank
-- tankcon	Welder	Armed Construction Tank
-- tankheavyarty	Tremor	Heavy Saturation Artillery Tank
-- tankheavyassault	Cyclops	Very Heavy Tank Buster
-- tankheavyraid	Blitz	Lightning Assault/Raider Tank
-- tankraid	Kodachi	Raider Tank
-- tankriot	Ogre	Heavy Riot Support Tank
-- tele_beacon	Lamp	Teleport Bridge Entry Beacon, right click to teleport.
-- terraunit	Terraform	This unit represents an area being terraformed.
-- tiptest	Turn In Place test	Tests turn in place
-- turretaaclose	Hacksaw	Burst Anti-Air Turret
-- turretaafar	Chainsaw	Long-Range Anti-Air Missile Battery
-- turretaaflak	Thresher	Anti-Air Flak Gun
-- turretaaheavy	Artemis	Very Long-Range Anti-Air Missile Tower, Drains 4 m/s, 20 second stockpile
-- turretaalaser	Razor	Hardened Anti-Air Laser
-- turretantiheavy	Lucifer	Tachyon Projector - Power by connecting to a 50 energy grid
-- turretemp	Faraday	EMP Turret
-- turretgauss	Gauss	Gauss Turret, 10 health/s when closed
-- turretheavy	Desolator	Medium Range Defense Fortress - Power by connecting to a 50 energy grid
-- turretheavylaser	Stinger	High-Energy Laser Tower
-- turretimpulse	Newton	Gravity Turret
-- turretlaser	Lotus	Light Laser Tower
-- turretmissile	Picket	Light Missile Tower
-- turretriot	Stardust	Anti-Swarm Turret
-- turretsunlance	Sunlance	Anti-Tank Turret - Requires 25 Power
-- turrettorp	Urchin	Torpedo Launcher
-- vehaa	Crasher	Fast Anti-Air Rover
-- veharty	Badger	Artillery Minelayer Rover
-- vehassault	Ravager	Assault Rover
-- vehcapture	Dominatrix	Capture Rover
-- vehcon	Mason	Construction Rover
-- vehheavyarty	Impaler	Precision Artillery Rover
-- vehraid	Scorcher	Raider Rover
-- vehriot	Ripper	Riot Rover
-- vehscout	Dart	Disruptor Raider/Scout Rover
-- vehsupport	Fencer	Deployable Missile Rover (must stop to fire)
-- wolverine_mine	Claw	Badger Mine
-- zenith	Zenith	Meteor Controller
