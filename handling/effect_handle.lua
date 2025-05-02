-- Store locals of mod components
local zposConstants = ZPOS_LIBRARY.Constants
local zposCallbacks = ZPOS_LIBRARY.Callbacks
local zposData = ZPOS_LIBRARY.DataHandler
local zposVector = ZPOS_LIBRARY.VectorFactory

function ZPOS_LIBRARY:ApplySimpleOffset(entity)
    return -Vector(0, self:GetParentHeight(entity))
end
ZPOS_LIBRARY:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, ZPOS_LIBRARY.ApplySimpleOffset)