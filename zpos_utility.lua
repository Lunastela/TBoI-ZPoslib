local zposUtility = {}

function zposUtility:HasLanded(npcData)
    if npcData.Position.Z <= 0 then
        return true
    end
    return false
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

return zposUtility