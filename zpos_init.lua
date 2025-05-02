--[[
    ZPosLib is a more complex and robust alternative to 3D positions in The Binding of Isaac
    It features the use of 3D Vectors for position calculation, and is meant to only be used with REPENTOGON. 

    ZPosLib is not a lightweight position library. It is an aggressive middleman mod that hijacks other
    alternative position libraries to unify them under one system that allows for complex 3D collision calculations.
    For this reason, ZPosLib is not an extension of JumpLib or Revelations' air movement library.
    
    Unless you plan on leveraging these utilities, JumpLib is a more lightweight alternative.

    Authors:
        @lunastela
--]]

-- The name of the Root file
local rootFolder = "scripts.lib.zposlib"

local CURRENT_VERSION = 0.1
local DEBUG_REBUILD = true
if (not ZPOS_LIBRARY or (ZPOS_LIBRARY.VersionNumber < CURRENT_VERSION)) or DEBUG_REBUILD then
    ZPOS_LIBRARY = RegisterMod("ZPosLib", 1)
    ZPOS_LIBRARY.VersionNumber = CURRENT_VERSION
    print("Initializing ZPosLib Version", ZPOS_LIBRARY.VersionNumber)

    -- Store valuable mod components
    ZPOS_LIBRARY.Constants = include(rootFolder .. "." .. "zpos_const")
    ZPOS_LIBRARY.VectorFactory = include(rootFolder .. "." .. "zpos_vector3d")
    ZPOS_LIBRARY.Callbacks = include(rootFolder .. "." .. "zpos_callbacks")
    ZPOS_LIBRARY.DataHandler = include(rootFolder .. "." .. "zpos_table")

    local zposHandler = include(rootFolder .. "." .. "zpos_handling")
    zposHandler:Init(rootFolder)
end