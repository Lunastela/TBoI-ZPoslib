local zposData = {}

local vFac = ZPOS_LIBRARY.VectorFactory

-- Definitions
local DEFAULT_GRAVITY = 0.5
local DEFAULT_AIR_DRAG = 0 --0.125
local DEFAULT_AIR_MOVEMENT_FACTOR = 0.25

---Returns an npc's instantiated data
---@return table npcData
function zposData:GenerateData(npc)
    local ptrHash = GetPtrHash(npc)
    if not zposData[ptrHash] then
        -- Instantiate the Entity table
        zposData[ptrHash] = {}
        local npcData = zposData[ptrHash]
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
        npcData.Gravity = DEFAULT_GRAVITY
        npcData.AirDrag = DEFAULT_AIR_DRAG
        npcData.AirMovement = DEFAULT_AIR_MOVEMENT_FACTOR
    end
    return zposData[ptrHash]
end

return zposData