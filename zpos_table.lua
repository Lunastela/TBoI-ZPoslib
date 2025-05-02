local zposData = {}
zposData.Data = {}

local zposVector = ZPOS_LIBRARY.VectorFactory

-- Definitions
local DEFAULT_GRAVITY = 0.5
local DEFAULT_AIR_DRAG = 0 --0.125
local DEFAULT_AIR_MOVEMENT_FACTOR = 0.25

---Returns an entity's instantiated data
---@return table entityData
function zposData:GenerateData(entity)
    local ptrHash = GetPtrHash(entity)
    if not zposData.Data[ptrHash] then
        -- Instantiate the Entity table
        zposData.Data[ptrHash] = {}
        local entityData = zposData.Data[ptrHash]
        entityData.Pointer = EntityPtr(entity)
        -- Define Position Data
        if not entityData.Position then
            entityData.Position = zposVector.Vector3D(
                entity.Position.X, entity.Position.Y, 0
            )
        end
        -- Define Velocity Data
        if not entityData.Velocity then
            entityData.Velocity = zposVector.Vector3D(
                entity.Velocity.X, entity.Velocity.Y, 0
            )
        end
        -- Internal storage variables for tracking data about collisions
        entityData.Internal = {
            onGround = false,
            lastCollisionClass = entity.CollisionClass
        }
        -- Default variables for aerial definitions. Can be changed 
        entityData.Gravity = DEFAULT_GRAVITY
        entityData.AirDrag = DEFAULT_AIR_DRAG
        entityData.AirMovement = DEFAULT_AIR_MOVEMENT_FACTOR
    end
    return zposData.Data[ptrHash]
end

-- Clear entities in the table that do not have references
ZPOS_LIBRARY:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(_)
    for ptrHash, entityData in pairs(zposData.Data) do
        local entityPointer = (entityData and entityData.Pointer)
        if not (entityPointer and entityPointer.Ref) then
            zposData.Data[ptrHash] = nil
        end
    end
end)

return zposData