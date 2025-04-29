local zposUtility = {}

zposUtility.screenToWorldConversion = Isaac.ScreenToWorldDistance(Vector.One)
zposUtility.worldToScreenConversion = Isaac.WorldToScreenDistance(Vector.One)

zposUtility.GRID_HEIGHT = (zposUtility.worldToScreenConversion.Y * 15)

---@class Room locally stored room instance for utilities
local roomInstance = (Game() and Game():GetRoom())
ZPOS_LIBRARY:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(_)
    roomInstance = Game():GetRoom()
end)

function zposUtility:HasLanded(npcData)
    if npcData.Position.Z <= zposUtility.GRID_HEIGHT then
        -- Attempt to find Baseline Grid Entity
        local gridEntityStanding = roomInstance:GetGridEntityFromPos(npcData.Position:To2D())
        if gridEntityStanding and (gridEntityStanding.CollisionClass >= GridCollisionClass.COLLISION_OBJECT
        and gridEntityStanding.CollisionClass < GridCollisionClass.COLLISION_WALL) then
            return true, zposUtility.GRID_HEIGHT
        end
        return (npcData.Position.Z <= 0), 0
    end
    return false, nil
end

local timeScaleTable = {1, 0.8, 1.43}
function zposUtility:GetTimeScale()
    return timeScaleTable[Game():GetRoom():GetBrokenWatchState() + 1]
end

function zposUtility.evaluateCallbacks(callbackType, evaluateAll, ...)
    local result = nil
    local callbackList = Isaac.GetCallbacks(callbackType)
    if callbackList and (#callbackList > 0) then
        for _, callback in ipairs(callbackList) do
            local temporaryResult = callback.Function(callback.Mod, ...)
            if (not result) or temporaryResult then
                result = temporaryResult
            end
            if ((not evaluateAll) 
            and (result ~= nil)) then
                return result
            end
        end
    end
    return result
end

function zposUtility.canUpdate()
    local gameInstance = Game()
    local renderMode = gameInstance:GetRoom():GetRenderMode()
    local renderingReflection = ((renderMode == RenderMode.RENDER_WATER_REFLECT)
        or (renderMode == RenderMode.RENDER_WATER_REFRACT))
    local isPaused = gameInstance:IsPaused()
    return not (isPaused or renderingReflection), renderingReflection
end

return zposUtility