--[[
    Autoremove command: mpm autoremove [--dry-run]

    Alias for mpm prune.
]]
local autoremoveModule = nil

autoremoveModule = {
    usage = "mpm autoremove [--dry-run]",

    run = function(...)
        local pruneModule = dofile("/mpm/Core/Commands/Prune.lua")
        return pruneModule.run(...)
    end
}

return autoremoveModule
