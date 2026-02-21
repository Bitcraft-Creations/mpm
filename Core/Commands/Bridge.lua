--[[
    Bridge command: mpm bridge <host> [port]

    Connects this computer to an MCP server so AI agents can
    execute Lua, read/write files, and call peripherals here.

    The MCP server (mpm-mcp-server) must be running on the host machine.
]]
local bridgeModule = {
    usage = "mpm bridge <host> [port]",

    run = function(target, port, ...)
        local Validation = exports("Utils.Validation")

        if not Validation.requireArg(target, "<host-or-url>", bridgeModule.usage) then
            return
        end

        -- Delegate to the ai/Bridge package
        local bridgePath = "/mpm/Packages/ai/Bridge.lua"

        if not fs.exists(bridgePath) then
            print("")
            print("[!] The 'ai' package is not installed.")
            print("    Run: mpm install ai")
            return
        end

        local fn, err = loadfile(bridgePath)
        if not fn then
            print("[!] Error loading bridge: " .. tostring(err))
            return
        end

        -- Pass target URL/host and optional port
        fn(target, port)
    end
}

return bridgeModule
