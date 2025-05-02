local zposHandler = {}

local function includeScript(rootFolder, scriptName)
    return include(rootFolder .. ".handling." .. scriptName .. "_handle")
end

local handleTypes = {
    "entity",
    "effect",
    "projectile"
}

function zposHandler:Init(rootFolder)
    -- Initialize utilities
    include(rootFolder .. "." .. "zpos_util")

    -- Initialize the handler types
    for i, handleType in ipairs(handleTypes) do
        includeScript(rootFolder, handleType)
    end
end
return zposHandler