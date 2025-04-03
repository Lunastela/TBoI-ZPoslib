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

return zposUtility