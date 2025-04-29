local zposData = {}
zposData.Data = {}

local vFac = ZPOS_LIBRARY.VectorFactory

-- Definitions
local DEFAULT_GRAVITY = 0.5
local DEFAULT_AIR_DRAG = 0 --0.125
local DEFAULT_AIR_MOVEMENT_FACTOR = 0.25

---Returns an npc's instantiated data
---@return table npcData
function zposData:GenerateData(npc)
    local ptrHash = GetPtrHash(npc)
    if not zposData.Data[ptrHash] then
        -- Instantiate the Entity table
        zposData.Data[ptrHash] = {}
        local npcData = zposData.Data[ptrHash]
        npcData.Pointer = EntityPtr(npc)
        -- Define Position Data
        if not npcData.Position then
            npcData.Position = vFac.Vector3D(
                npc.Position.X, npc.Position.Y, 0
            )
        end
        -- Define Velocity Data
        if not npcData.Velocity then
            npcData.Velocity = vFac.Vector3D(
                npc.Velocity.X, npc.Velocity.Y, 0
            )
        end
        
        npcData.OnGround = true
        npcData.Gravity = DEFAULT_GRAVITY
        npcData.AirDrag = DEFAULT_AIR_DRAG
        npcData.AirMovement = DEFAULT_AIR_MOVEMENT_FACTOR

        npcData.OriginalGridCollision = npc.GridCollisionClass
    end
    return zposData.Data[ptrHash]
end

-- Clear entities in the table that do not have references
ZPOS_LIBRARY:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(_)
    for ptrHash, npcData in pairs(zposData.Data) do
        local entityPointer = (npcData and npcData.Pointer)
        if not (entityPointer and entityPointer.Ref) then
            zposData.Data[ptrHash] = nil
        end
    end
end)

return zposData