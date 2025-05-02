
-- Store locals of mod components
local zposConstants = ZPOS_LIBRARY.Constants
local zposCallbacks = ZPOS_LIBRARY.Callbacks
local zposData = ZPOS_LIBRARY.DataHandler
local zposVector = ZPOS_LIBRARY.VectorFactory

-- Evaluates all callbacks of callbackType
---@param callbackType string|ZPosCallback The ZPosLib callback type
---@param evaluateAll boolean Whether to break after the first return
---@param ... any The Callback's parameters
---@return any result The result of the ran callback  
function ZPOS_LIBRARY:evaluateCallbacks(callbackType, evaluateAll, ...)
    local result = nil
    ---@diagnostic disable-next-line: param-type-mismatch
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

---@return boolean canUpdate Returns whether or not logic can update
---@return boolean renderingReflection Returns if the reflection is rendering currently
function ZPOS_LIBRARY:canUpdate()
    local gameInstance = Game()
    local renderMode = gameInstance:GetRoom():GetRenderMode()
    local renderingReflection = ((renderMode == RenderMode.RENDER_WATER_REFLECT)
        or (renderMode == RenderMode.RENDER_WATER_REFRACT))
    local isPaused = gameInstance:IsPaused()
    return not (isPaused or renderingReflection), renderingReflection
end

-- Returns the gravity of an entity with any modifiers applied
---@return number NewGravity gravity with modifiers applied
function ZPOS_LIBRARY:GetGravity(entity)
    local entityData = zposData:GenerateData(entity)
    local localGravity = entityData.Gravity
    local callbackList = Isaac.GetCallbacks(zposCallbacks.ZPOS_GRAVITY_APPLY_MODIFIER)
    if callbackList and (#callbackList > 0) then
        for _, callback in ipairs(callbackList) do
            localGravity = (callback.Function(callback.Mod, entity, entityData, localGravity) or localGravity)
        end
    end
    return localGravity
end

---@class Room locally stored room instance for utilities
local roomInstance = (Game() and Game():GetRoom())
ZPOS_LIBRARY:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(_)
    roomInstance = Game():GetRoom()
end)

function ZPOS_LIBRARY:HasLanded(entityData)
    if entityData.Position.Z <= zposConstants.GRID_HEIGHT_BASE then
        -- Attempt to find Baseline Grid Entity
        local gridEntityStanding = roomInstance:GetGridEntityFromPos(entityData.Position:To2D())
        if gridEntityStanding and (gridEntityStanding.CollisionClass >= GridCollisionClass.COLLISION_OBJECT
        and gridEntityStanding.CollisionClass < GridCollisionClass.COLLISION_WALL) then
            return true, zposConstants.GRID_HEIGHT_BASE
        end
        return (entityData.Position.Z <= 0), 0
    end
    return false, nil
end

function ZPOS_LIBRARY:GetParentHeight(entity)
    local parent = (entity.SpawnerEntity or entity.Parent)
    local parentData = parent and zposData:GenerateData(parent)
    if parentData then
        return (parentData.Position:Flatten() - parentData.Position:To2D()).Y
    end
    return 0
end

function ZPOS_LIBRARY:GetTimeScale()
    return zposConstants.TIME_SCALE_TABLE[Game():GetRoom():GetBrokenWatchState() + 1]
end

function ZPOS_LIBRARY:CanCollideWithGrid(entity, gridEntity)

end