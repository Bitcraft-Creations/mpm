-- mpm.lua
-- Load the mpm API
local env = {
    shell = shell,
    http = http,
    fs = fs
} -- Add any other APIs as needed
setmetatable(env, {
    __index = _G
})

-- Load the core.lua module
local Core = setfenv(loadfile("/mpm/core.lua"), env)()

-- get the command-line arguments
local tArgs = {...}

-- mpm.lua (command-line interface)
-- the first argument is the command
local command = tArgs[1]

-- Functionality mapping
local commandMapping = {
    install = Core.install,
    remove = Core.remove,
    tap_repository = Core.tap_repository,
    list = Core.list,
    run = Core.run,
    self_update = Core.self_update,
    update = Core.update
}

local function printUsage()
    print("Usage:")
    print("mpm install <package>")
    print("mpm remove <package>")
    print("mpm tap_repository <repository url>")
    print("mpm list")
    print("mpm run <package>")
    print("mpm self_update")
    print("mpm update <package>")
end

-- Handle command
if commandMapping[command] then
    if select('#', ...) >= 2 then
        commandMapping[command](select(2, ...))
    else
        commandMapping[command]()
    end
else
    printUsage()
end

