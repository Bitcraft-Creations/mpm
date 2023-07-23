-- mpm.lua
-- Load the mpm API
local env = {shell = shell, http = http, fs = fs} -- Add any other APIs as needed
setmetatable(env, {__index = _G})

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
  uninstall = Core.uninstall,
  tap_repository = Core.tap_repository,
  list = Core.list,
  run = Core.run,
}

local function printUsage()
  print("Usage:")
  print("mpm install <package>")
  print("mpm uninstall <package>")
  print("mpm tap_repository <repository url>")
  print("mpm list")
  print("mpm run <package>")
end

-- Check the provided command and execute the appropriate function
if commandMapping[command] then
  if #tArgs < 2 then
    print("Please provide a valid argument for the command. Usage: mpm " .. command .. " <argument>")
    return
  end
  local success, message = pcall(commandMapping[command], tArgs[2])
  if success then
    print("Command " .. command .. " executed successfully.")
  else
    print("An error occurred: " .. message)
  end
else
  print("Invalid command. Here's the list of valid commands:")
  printUsage()
end
