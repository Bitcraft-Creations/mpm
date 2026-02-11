--[[
    Upgrade command: mpm upgrade [pkg...]

    Alias for mpm update. Updates packages.
]]
local upgradeModule = nil

upgradeModule = {
    usage = "mpm upgrade [pkg...]",

    run = function(...)
        -- Just call update
        local updateModule = dofile("/mpm/Core/Commands/Update.lua")
        return updateModule.run(...)
    end
}

return upgradeModule
