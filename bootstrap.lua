local bootstrapModule = nil
local modules = {}

function exports(moduleNamespace)
    local modulePath = string.format("/mpm/Core/%s.lua", moduleNamespace:gsub("%.", "/"))

    if not fs.exists(modulePath) then
        error("Module " .. moduleNamespace .. " not found")
    end

    if not modules[moduleNamespace] then
        modules[moduleNamespace] = dofile(modulePath)
    end

    return modules[moduleNamespace]
end

bootstrapModule = {
    printUsage = function()
        local UI = exports("Utils.UI")

        UI.printBanner()

        print("Usage: mpm <command> [args]")
        print("")
        print("Commands:")
        print("  install <pkg>    Install packages")
        print("  remove <pkg>     Remove packages")
        print("  update [pkg]     Update packages")
        print("  run <pkg>        Run a package")
        print("  list [remote]    List packages")
        print("  info <pkg>       Package details")
        print("  tap <source>     Add repository")
        print("  startup [pkg]    Configure startup")
        print("  bridge <host>    Connect to MCP AI server")
        print("  selfupdate       Update MPM")
        print("  help [cmd]       Show help")
        print("")
        print("Run 'mpm help <command>' for details")
    end,

    handleCommand = function(tArgs)
        local command = tArgs[1]

        if not command then
            bootstrapModule.printUsage()
            return
        end

        local commandLower = command:lower()
        local files = fs.list("/mpm/Core/Commands/")
        local matchedFile = nil

        for _, file in ipairs(files) do
            if file:find(".lua") and file:sub(1, -5):lower() == commandLower then
                matchedFile = file
                break
            end
        end

        if not matchedFile then
            print("")
            print("[!] Unknown command: " .. command)
            print("")
            print("Run 'mpm help' for available commands")
            return
        end

        local commandPath = string.format("/mpm/Core/Commands/%s", matchedFile)
        local module = dofile(commandPath)

        if module and module.run then
            return module.run(table.unpack(tArgs, 2))
        end

        print("[!] Command module error")
    end
}

return bootstrapModule
