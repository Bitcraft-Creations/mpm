-- mpm.lua
local bootstrap = dofile("/mpm/bootstrap.lua")

-- Get the command-line arguments
local tArgs = {...}
bootstrap.handleCommand(tArgs)