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

    local screenToWorldConversion = zposUtility.screenToWorldConversion
    local worldToScreenConversion = zposUtility.worldToScreenConversion

    -- Register Callbacks
    function ZPOS_LIBRARY:ApplyRenderOffset(npc, vectorOffset)
        -- Instantiate NPC data
        local npcData = zposData:GenerateData(npc)

        local canUpdate, reflection = zposUtility.canUpdate()
        if canUpdate then
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

            -- Update the previous position and velocity for next frame
            npcData.PreviousVelocity = Vector(npc.Velocity.X, npc.Velocity.Y)
            npcData.PreviousPosition = Vector(npc.Position.X, npc.Position.Y)
        end
        -- Calculate and Display the visual offset of the player
        local reflectionVector = vFac.Vector3D(1, 1, (reflection and -1) or 1)
        return (npcData.Position:To2D() - (npcData.Position * reflectionVector):Flatten())
    end
    ZPOS_LIBRARY:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, CallbackPriority.LATE, ZPOS_LIBRARY.ApplyRenderOffset)
    ZPOS_LIBRARY:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_RENDER, CallbackPriority.LATE, ZPOS_LIBRARY.ApplyRenderOffset)
    ZPOS_LIBRARY:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_RENDER, CallbackPriority.LATE, ZPOS_LIBRARY.ApplyRenderOffset)

    function ZPOS_LIBRARY:GetParentHeight(entity)
        local parent = (entity.SpawnerEntity or entity.Parent)
        local parentData = parent and zposData:GenerateData(parent)
        if parentData then
            return (parentData.Position:Flatten() - parentData.Position:To2D()).Y
        end
        return 0
    end

    function ZPOS_LIBRARY:ApplySimpleOffset(entity)
        return -Vector(0, self:GetParentHeight(entity))
    end
    ZPOS_LIBRARY:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, ZPOS_LIBRARY.ApplySimpleOffset)

    -- Tear Height Callbacks
    function ZPOS_LIBRARY:ProjectileApplyHeight(projectile)
        local heightOffset = self:GetParentHeight(projectile)
        if (heightOffset > 0) or (heightOffset < 0) then
            if projectile:ToTear() then
                print(heightOffset)
                heightOffset = heightOffset * 3.95 / screenToWorldConversion.Y
            else
                -- Ensure we can handle collisions later on ourselves if the tear height is offset
                projectile:AddProjectileFlags(ProjectileFlags.ANY_HEIGHT_ENTITY_HIT)
                projectile.ChangeFlags = projectile.ChangeFlags | ProjectileFlags.ANY_HEIGHT_ENTITY_HIT
            end
            projectile.Height = projectile.Height - (heightOffset * screenToWorldConversion.Y)
        end
    end
    ZPOS_LIBRARY:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, ZPOS_LIBRARY.ProjectileApplyHeight)
    ZPOS_LIBRARY:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, ZPOS_LIBRARY.ProjectileApplyHeight)

    ZPOS_LIBRARY:AddCallback(zposCallbacks.ZPOS_PRE_APPLY_VELOCITY, function(_, npc, npcData)
        if Input.IsButtonTriggered(Keyboard.KEY_H, 0) then
            npcData.Gravity = 0.35 * screenToWorldConversion.Y
            npcData.Velocity.Z = 6.5 * screenToWorldConversion.Y
            -- npcData.Position.Z = npcData.Position.Z + zposUtility.GRID_HEIGHT
        end
        -- return true
    end)

    function ZPOS_LIBRARY:HandleAerialState(npc, npcData)
        local hasLanded, landPosition = zposUtility:HasLanded(npcData)
        if hasLanded then
            -- Detect the player is landing
            npcData.Position.Z = landPosition or 0
            npcData.Velocity.Z = 0
            if not npcData.OnGround then
                zposUtility.evaluateCallbacks(
                    zposCallbacks.ZPOS_POST_ENTITY_LAND, 
                    true, npc, npcData
                )
                -- Set the gridcollision to the original gridcollision
                if npcData.Position.Z < zposUtility.GRID_HEIGHT then
                    npc.GridCollisionClass = npcData.OriginalGridCollision
                end
                -- Count the player as having landed
                npcData.OnGround = true
            end
            -- Always constantly reset original grid collision class if on ground
            if npcData.Position.Z < zposUtility.GRID_HEIGHT then
                npcData.OriginalGridCollision = npc.GridCollisionClass
            end
        else
            -- Air Velocity
            npcData.OnGround = false
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

            -- Outside Grid Collision Types
            if npcData.Position.Z >= zposUtility.GRID_HEIGHT then
                npc.GridCollisionClass = GridCollisionClass.COLLISION_WALL
            else
                npc.GridCollisionClass = npcData.OriginalGridCollision
            end
        end
    end
    ZPOS_LIBRARY:AddCallback(zposCallbacks.ZPOS_POST_APPLY_VELOCITY, ZPOS_LIBRARY.HandleAerialState)

    ZPOS_LIBRARY:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd)
        if cmd == "teardebug" then
            local collectiveHeight = -50
            local tear = Isaac.Spawn(2, 0, 0, Game():GetRoom():GetCenterPos(), Vector.Zero, nil):ToTear()
            tear.FallingSpeed = 0
            tear.FallingAcceleration = -0.1
            tear.Height = collectiveHeight * math.sqrt(2)

            local projectile = Isaac.Spawn(9, 0, 0, Game():GetRoom():GetCenterPos(), Vector.Zero, nil):ToProjectile()
            projectile.FallingSpeed = 0
            projectile.FallingAccel = -0.1
            projectile.Height = collectiveHeight
        end
    end)
end
return ZPOS_LIBRARY