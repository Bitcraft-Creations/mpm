-- mpm.lua

-- Load the core.lua module
local Core = dofile("/mpm/core.lua")

-- get the command-line arguments
local tArgs = {...}

-- the first argument is the command
local command = tArgs[1]

local function printUsage()
  print("Usage:")
  print("mpm install <package>")
  print("mpm uninstall <package>")
  print("mpm tap_repository <repository url>")
  print("mpm list_repositories")
  print("mpm list_installed")
  print("mpm run <package>")
end

-- Check the provided command and execute the appropriate function
if command == "install" then
  if #tArgs < 2 then
    print("Please provide a package name to install. Usage: mpm install <package>")
    return
  end
  if Core.install(tArgs[2]) then
    print("Package " .. tArgs[2] .. " installed successfully.")
  end
elseif command == "uninstall" then
  if #tArgs < 2 then
    print("Please provide a package name to uninstall. Usage: mpm uninstall <package>")
    return
  end
  Core.uninstall(tArgs[2])
  print("Package " .. tArgs[2] .. " uninstalled successfully.")
elseif command == "tap_repository" then
  if #tArgs < 2 then
    print("Please provide a repository URL. Usage: mpm tap_repository <repository url>")
    return
  end
  Core.tap_repository(tArgs[2])
  print("Repository " .. tArgs[2] .. " added successfully.")
elseif command == "run" then
  if #tArgs < 2 then
    print("Please provide a package name to run. Usage: mpm run <package>")
    return
  end
  Core.run(tArgs[2])
else
  print("Invalid command. Here's the list of valid commands:")
  printUsage()
end
