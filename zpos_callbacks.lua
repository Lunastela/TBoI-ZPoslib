---@enum ZPosCallback
return {
    --[[
        ZPOS_PRE_APPLY_VELOCITY:
        Ideally used for controls and applying velocities before they are calculated.

        Return true to cancel the calculation of Z position and velocity.
    --]]
    ZPOS_PRE_APPLY_VELOCITY = "ZPOSLIB_PRE_APPLY_VELOCITY",
    --[[
        ZPOS_POST_APPLY_VELOCITY:
        Ideally used for collision checks, after the initial velocities have been added.
    --]]
    ZPOS_POST_APPLY_VELOCITY = "ZPOSLIB_POST_APPLY_VELOCITY",
    --[[
        ZPOS_POST_ENTITY_LAND:
        Used to run code whenever an entity has newly landed. 
    --]]
    ZPOS_POST_ENTITY_LAND = "ZPOSLIB_POST_ENTITY_LAND",
    --[[
        ZPOS_GRAVITY_APPLY_MODIFIER:
        Used to calculate gravity whenever :GetGravity() is used.
    --]]
    ZPOS_GRAVITY_APPLY_MODIFIER = "ZPOSLIB_GRAVITY_APPLY_MODIFIER",
    --[[
        ZPOS_POST_ENTITY_INIT:
        Used to be able to manipulate default values
        after entities are initialized.

        (Entity entity, EntityData entityData, number Gravity): Return a number to modify the gravity.
    --]]
    ZPOS_POST_ENTITY_INIT = "ZPOSLIB_POST_ENTITY_INIT"
}