-- Store locals of mod components
local zposConstants = ZPOS_LIBRARY.Constants
local zposCallbacks = ZPOS_LIBRARY.Callbacks
local zposData = ZPOS_LIBRARY.DataHandler
local zposVector = ZPOS_LIBRARY.VectorFactory

function ZPOS_LIBRARY:ApplyRenderOffset(entity, vectorOffset)
    -- Instantiate entity data
    local entityData = zposData:GenerateData(entity)

    local canUpdate, reflection = ZPOS_LIBRARY:canUpdate()
    if canUpdate then
        -- Fetch timescale multiplier for the room
        local timeScale = ZPOS_LIBRARY:GetTimeScale()

        -- Pre Velocity Apply Callback
        local cancelZUpdate = ZPOS_LIBRARY:evaluateCallbacks(zposCallbacks.ZPOS_PRE_APPLY_VELOCITY, true, entity, entityData)

        -- If the previous callbacks haven't cancelled Z position updates
        if not cancelZUpdate then
            -- Only apply velocity to Z position as the game handles the application otherwise
            entityData.Position.Z = entityData.Position.Z + (entityData.Velocity.Z * timeScale)

            -- Apply gravity to velocity
            entityData.Velocity.Z = entityData.Velocity.Z - (entityData.Gravity * timeScale)
        end

        -- Post Velocity Apply 
        ZPOS_LIBRARY:evaluateCallbacks(zposCallbacks.ZPOS_POST_APPLY_VELOCITY, false, entity, entityData)

        -- If a previous position is found
        if entityData.PreviousPosition then
            -- Adjust and set 3D positions to the player's current positions
            entityData.Position = entityData.Position + zposVector.From2D(entity.Position - entityData.PreviousPosition)
            -- Conversely adjust the actual position of the player to match the 3D position
            entity.Position = entity.Position + (entityData.Position:To2D() - entity.Position)
        end
        
        -- If a previous velocity is found
        if entityData.PreviousVelocity then
            -- Adjust the set 3D velocity to the player's current velocity
            entityData.Velocity = entityData.Velocity + zposVector.From2D(entity.Velocity - entityData.PreviousVelocity)

            -- Conversely, adjust the actual velocity of the player to match the 3D velocity
            entity.Velocity = entity.Velocity + (entityData.Velocity:To2D() - entity.Velocity)
        end

        -- Update the previous position and velocity for next frame
        entityData.PreviousVelocity = Vector(entity.Velocity.X, entity.Velocity.Y)
        entityData.PreviousPosition = Vector(entity.Position.X, entity.Position.Y)
    end
    -- Calculate and Display the visual offset of the player
    local reflectionVector = zposVector.Vector3D(1, 1, (reflection and -1) or 1)
    return (entityData.Position:To2D() - (entityData.Position * reflectionVector):Flatten())
end
ZPOS_LIBRARY:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, CallbackPriority.LATE, ZPOS_LIBRARY.ApplyRenderOffset)
ZPOS_LIBRARY:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_RENDER, CallbackPriority.LATE, ZPOS_LIBRARY.ApplyRenderOffset)
ZPOS_LIBRARY:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_RENDER, CallbackPriority.LATE, ZPOS_LIBRARY.ApplyRenderOffset)

ZPOS_LIBRARY:AddCallback(zposCallbacks.ZPOS_PRE_APPLY_VELOCITY, function(_, npc, npcData)
    if Input.IsButtonTriggered(Keyboard.KEY_H, 0) then
        npcData.Gravity = 0.35 * zposConstants.SCREEN_TO_WORLD_CONVERSION.Y
        npcData.Velocity.Z = 6.5 * zposConstants.SCREEN_TO_WORLD_CONVERSION.Y
        -- npcData.Position.Z = npcData.Position.Z + zposUtility.GRID_HEIGHT
    end
    -- return true
end)


function ZPOS_LIBRARY:HandleAerialState(entity, entityData)
    local hasLanded, landPosition = ZPOS_LIBRARY:HasLanded(entityData)
    if hasLanded then
        -- Detect the player is landing
        entityData.Position.Z = landPosition or 0
        entityData.Velocity.Z = 0
        if not entityData.OnGround then
            ZPOS_LIBRARY:evaluateCallbacks(
                zposCallbacks.ZPOS_POST_ENTITY_LAND, 
                true, entity, entityData
            )
            -- Count the player as having landed
            entityData.OnGround = true
        end
    else
        -- Air Velocity
        entityData.OnGround = false
        if entityData.PreviousVelocity then
            local airVector = (entityData.PreviousVelocity - entity.Velocity) * (1 - entityData.AirDrag)
            local player = entity:ToPlayer()
            if player and player:GetMovementVector():LengthSquared() > 0 then
                local rotationDegrees = (player:GetMovementVector():GetAngleDegrees() - airVector:GetAngleDegrees())
                airVector = airVector - (airVector * entityData.AirMovement) + (airVector:Rotated(rotationDegrees) * entityData.AirMovement)
            end
            -- entity.Velocity = entity.Velocity + airVector
            entityData.Velocity = entityData.Velocity + zposVector.From2D(airVector)
        end
    end
end
ZPOS_LIBRARY:AddCallback(zposCallbacks.ZPOS_POST_APPLY_VELOCITY, ZPOS_LIBRARY.HandleAerialState)