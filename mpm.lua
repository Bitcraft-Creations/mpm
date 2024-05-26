-- mpm.lua

function mpm(module)
    local path = "/mpm/packages/" .. module .. ".lua"

    if fs.exists(path) then
        return dofile(path)
    end

    error("Module '" .. module .. "' not found in /mpm/packages")
end

_G.mpm = mpm

local bootstrap = dofile("/mpm/bootstrap.lua")

-- Get the command-line arguments
local tArgs = {...}
bootstrap.handleCommand(tArgs)