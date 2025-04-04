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

    ZPOS_LIBRARY.VectorFactory = include(rootFolder .. ".zpos_vector3d")
    local vFac = ZPOS_LIBRARY.VectorFactory

    local zposData = include(rootFolder .. ".zpos_table")
    local zposUtility = include(rootFolder .. ".zpos_utility")
    local zposCallbacks = include(rootFolder .. ".zpos_callbacks")

    -- Register Callbacks
    function ZPOS_LIBRARY:applyRenderOffset(npc, vectorOffset)
        -- Instantiate NPC data
        local npcData = zposData:GenerateData(npc)

        -- Fetch timescale multiplier for the room
        local timeScale = zposUtility:GetTimeScale()

        -- Pre Velocity Apply Callback
        local cancelZUpdate = zposUtility.evaluateCallbacks(zposCallbacks.ZPOS_PRE_APPLY_VELOCITY, true, npc, npcData)

        -- If the previous callbacks haven't cancelled Z position updates
        if not cancelZUpdate then
            -- Only apply velocity to Z position as the game handles the application otherwise
            npcData.Position.Z = npcData.Position.Z + (npcData.Velocity.Z * timeScale)

            -- Apply gravity to velocity
            npcData.Velocity.Z = npcData.Velocity.Z - (npcData.Gravity * timeScale)
        end

        -- Post Velocity Apply 
        zposUtility.evaluateCallbacks(zposCallbacks.ZPOS_POST_APPLY_VELOCITY, false, npc, npcData)

        -- If a previous position is found
        if npcData.PreviousPosition then
            -- Adjust and set 3D positions to the player's current positions
            npcData.Position = npcData.Position + vFac.From2D(npc.Position - npcData.PreviousPosition)
            -- Conversely adjust the actual position of the player to match the 3D position
            npc.Position = npc.Position + (npcData.Position:To2D() - npc.Position)
        end
        
        -- If a previous velocity is found
        if npcData.PreviousVelocity then
            -- Adjust the set 3D velocity to the player's current velocity
            npcData.Velocity = npcData.Velocity + vFac.From2D(npc.Velocity - npcData.PreviousVelocity)
            -- Conversely, adjust the actual velocity of the player to match the 3D velocity
            npc.Velocity = npc.Velocity + (npcData.Velocity:To2D() - npc.Velocity)
        end

        npcData.PreviousVelocity = Vector(npc.Velocity.X, npc.Velocity.Y)
        npcData.PreviousPosition = Vector(npc.Position.X, npc.Position.Y)

        -- Calculate and Display the visual offset of the player
        return (npc.Position - npcData.Position:Flatten())
    end
    ZPOS_LIBRARY:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, CallbackPriority.LATE, ZPOS_LIBRARY.applyRenderOffset)
    ZPOS_LIBRARY:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_RENDER, CallbackPriority.LATE, ZPOS_LIBRARY.applyRenderOffset)

    ZPOS_LIBRARY:AddCallback(zposCallbacks.ZPOS_PRE_APPLY_VELOCITY, function(_, npc, npcData)
        if Input.IsButtonTriggered(Keyboard.KEY_H, 0) then
            local worldToScreenConversion = Isaac.ScreenToWorldDistance(Vector.One)
            npcData.Gravity = 0.35 * worldToScreenConversion.Y
            npcData.Velocity.Z = 6.5 * worldToScreenConversion.Y
        end
    end)

    ZPOS_LIBRARY:AddCallback(zposCallbacks.ZPOS_POST_APPLY_VELOCITY, function(_, npc, npcData)
        if zposUtility:HasLanded(npcData) then
            npcData.Position.Z = 0
            npcData.Velocity.Z = 0
            return true
        else
            -- Air Velocity
            if npcData.PreviousVelocity then
                local airVector = (npcData.PreviousVelocity - npc.Velocity) * (1 - npcData.AirDrag)
                local player = npc:ToPlayer()
                if player and player:GetMovementVector():LengthSquared() > 0 then
                    local rotationDegrees = (player:GetMovementVector():GetAngleDegrees() - airVector:GetAngleDegrees())
                    airVector = airVector - (airVector * npcData.AirMovement) + (airVector:Rotated(rotationDegrees) * npcData.AirMovement)
                end
                -- npc.Velocity = npc.Velocity + airVector
                npcData.Velocity = npcData.Velocity + vFac.From2D(airVector)
            end
        end
    end)
end
return ZPOS_LIBRARY