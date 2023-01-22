return { plateamph = {
  unitname                      = [[plateamph]],
  name                          = [[Amphbot Plate]],
  description                   = [[Parallel Unit Production]],
  buildCostMetal                = Shared.FACTORY_PLATE_COST,
  buildDistance                 = Shared.FACTORY_PLATE_RANGE,
  builder                       = true,
  buildingGroundDecalDecaySpeed = 30,
  buildingGroundDecalSizeX      = 10,
  buildingGroundDecalSizeY      = 10,
  buildingGroundDecalType       = [[plateamph_aoplane.dds]],

  buildoptions     = {
    [[amphcon]],
    [[amphraid]],
    [[amphimpulse]],
    [[amphfloater]],
    [[amphriot]],
    [[amphsupport]],
    [[amphassault]],
    [[amphlaunch]],
    [[amphaa]],
    [[amphbomb]],
    [[amphtele]],
  },

  buildPic                      = [[plateamph.png]],
  canMove                       = true,
  canPatrol                     = true,
  category                      = [[UNARMED SINK]],
  collisionVolumeOffsets        = [[0 10 -2]],
  collisionVolumeScales         = [[42 45 42]],
  collisionVolumeType           = [[box]],
  selectionVolumeOffsets        = [[0 15 26]],
  selectionVolumeScales         = [[70 40 96]],
  selectionVolumeType           = [[box]],
  corpse                        = [[DEAD]],

  customParams                  = {
    modelradius        = [[50]],
    aimposoffset       = [[0 18 -26]],
    midposoffset       = [[0 0 -26]],
    sortName           = [[8]],
    solid_factory      = [[3]],
    default_spacing    = 4,
    unstick_help       = 1,
    selectionscalemult = 1,
    child_of_factory   = [[factoryamph]],
    cus_noflashlight   = 1,
    buggeroff_offset   = 45,

    outline_x = 165,
    outline_y = 165,
    outline_yoff = 27.5,
  },

  energyUse                     = 0,
  explodeAs                     = [[FAC_PLATEEX]],
  footprintX                    = 5,
  footprintZ                    = 7,
  iconType                      = [[padamph]],
  maxDamage                     = Shared.FACTORY_PLATE_HEALTH,
  maxSlope                      = 15,
  moveState                     = 1,
  noAutoFire                    = false,
  objectName                    = [[plate_amph.s3o]],
  script                        = "plateamph.lua",
  selfDestructAs                = [[FAC_PLATEEX]],
  showNanoSpray                 = false,
  sightDistance                 = 273,
  useBuildingGroundDecal        = true,
  workerTime                    = Shared.FACTORY_BUILDPOWER,
  yardMap                       = [[ooooo ooooo ooooo yyyyy yyyyy yyyyy yyyyy]],

  featureDefs      = {

    DEAD  = {
      blocking         = true,
      featureDead      = [[HEAP]],
      footprintX       = 5,
      footprintZ       = 7,
      object           = [[plate_amph_dead.s3o]],
      collisionVolumeOffsets = [[0 0 -16]],
      collisionVolumeScales  = [[104 70 36]],
      collisionVolumeType    = [[box]],
    },

    HEAP  = {
      blocking         = false,
      footprintX       = 5,
      footprintZ       = 7,
      object           = [[debris4x4c.s3o]],
    },

  },

} }
