-- mpm.lua
-- Load the core.lua module with the custom environment
local Core = dofile("/mpm/core.lua")

-- Get the command-line arguments
local tArgs = {...}

-- mpm.lua (command-line interface)
-- The first argument is the command
local command = tArgs[1]

-- Functionality mapping
local commandMapping = {
    install = Core.install,
    remove = Core.remove,
    list = Core.list,
    run = Core.run,
    self_update = Core.self_update,
    update = Core.update,
    startup = Core.startup
}

local function printUsage()
    print("Usage:")
    print("mpm install <package>")
    print("mpm remove <package>")
    print("mpm list")
    print("mpm run <package>")
    print("mpm self_update")
    print("mpm update <package>")
    print("mpm startup")
end

if commandMapping[command] then
    if command == "install" then
        if #tArgs >= 2 then
            commandMapping[command](table.unpack(tArgs, 2))
        else
            print("Wrong input: mpm install <package> <optional:package_2> etc.")
        end
    else
        if #tArgs >= 2 then
            commandMapping[command](table.unpack(tArgs, 2))
        else
            commandMapping[command]()
        end
    end
else
    printUsage()
end
