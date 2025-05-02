-- Store locals of mod components
local zposConstants = ZPOS_LIBRARY.Constants
local zposCallbacks = ZPOS_LIBRARY.Callbacks
local zposData = ZPOS_LIBRARY.DataHandler
local zposVector = ZPOS_LIBRARY.VectorFactory

-- Tear Height Callbacks
function ZPOS_LIBRARY:ProjectileApplyHeight(projectile)
    local heightOffset = self:GetParentHeight(projectile)
    if (heightOffset > 0) or (heightOffset < 0) then
        if projectile:ToTear() then
            -- print(heightOffset)
            heightOffset = heightOffset * zposConstants.KERKEL_BANDAGE_FIX / zposConstants.SCREEN_TO_WORLD_CONVERSION.Y
        else
            -- Ensure we can handle collisions later on ourselves if the tear height is offset
            projectile:AddProjectileFlags(ProjectileFlags.ANY_HEIGHT_ENTITY_HIT)
            projectile.ChangeFlags = projectile.ChangeFlags | ProjectileFlags.ANY_HEIGHT_ENTITY_HIT
        end
        projectile.Height = projectile.Height - (heightOffset * zposConstants.SCREEN_TO_WORLD_CONVERSION.Y)
    end
end
ZPOS_LIBRARY:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, ZPOS_LIBRARY.ProjectileApplyHeight)
ZPOS_LIBRARY:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, ZPOS_LIBRARY.ProjectileApplyHeight)