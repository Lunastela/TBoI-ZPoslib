local screenToWorldConversion = Isaac.ScreenToWorldDistance(Vector.One)
local worldToScreenConversion = Isaac.WorldToScreenDistance(Vector.One)

return {
    -- Provide conversion rate constants for applying velocities.
    SCREEN_TO_WORLD_CONVERSION = screenToWorldConversion,
    WORLD_TO_SCREEN_CONVERSION = worldToScreenConversion,

    -- named after kerkel who trial and errored their way into finding this value
    KERKEL_BANDAGE_FIX = 3.95, -- todo please fucking remove this im begging you

    -- Once again thank you kerkel (and im_tem)
    TIME_SCALE_TABLE = {1, 0.8, 1.43},

    GRID_HEIGHT_BASE = 15,
    GRID_HEIGHT_PILLAR = 30
}