--[[
    Help command: mpm help [command]

    Displays help information for MPM commands.
]]
local helpModule = nil

helpModule = {
    usage = "mpm help [command]",

    -- Detailed help for each command
    commands = {
        install = {
            usage = "mpm install <package> [package2] ...",
            description = "Install packages from the remote registry.",
            examples = {
                "mpm install tools",
                "mpm install views displays utils"
            }
        },
        remove = {
            usage = "mpm remove <package> [package2] ...",
            description = "Remove installed packages.",
            examples = {
                "mpm remove tools",
                "mpm remove views displays"
            }
        },
        update = {
            usage = "mpm update [package] [package2] ...",
            description = "Update packages. Updates all if none specified.",
            examples = {
                "mpm update",
                "mpm update tools"
            }
        },
        list = {
            usage = "mpm list [local|remote]",
            description = "List installed packages (default) or available remote packages.",
            examples = {
                "mpm list",
                "mpm list remote"
            }
        },
        run = {
            usage = "mpm run <package> [args...]",
            description = "Run a package's start.lua or a specific script.",
            examples = {
                "mpm run displays",
                "mpm run tools/inspect_peripheral"
            }
        },
        startup = {
            usage = "mpm startup [package] [args...]",
            description = "Configure a package to run on computer boot.",
            examples = {
                "mpm startup displays",
                "mpm startup"
            }
        },
        self_update = {
            usage = "mpm self_update",
            description = "Update MPM itself to the latest version.",
            examples = {
                "mpm self_update"
            }
        },
        info = {
            usage = "mpm info <package>",
            description = "Display detailed information about a package.",
            examples = {
                "mpm info tools"
            }
        },
        uninstall = {
            usage = "mpm uninstall",
            description = "Completely remove MPM and all packages.",
            examples = {
                "mpm uninstall"
            }
        },
        help = {
            usage = "mpm help [command]",
            description = "Display this help or help for a specific command.",
            examples = {
                "mpm help",
                "mpm help install"
            }
        }
    },

    run = function(command)
        if command then
            helpModule.showCommandHelp(command:lower())
        else
            helpModule.showOverview()
        end
    end,

    showOverview = function()
        print("")
        print("MPM - Minecraft Package Manager")
        print("================================")
        print("")
        print("Usage: mpm <command> [arguments]")
        print("")
        print("Commands:")
        print("  install <pkg>     Install a package")
        print("  remove <pkg>      Remove a package")
        print("  update [pkg]      Update packages")
        print("  list [local|remote]  List packages")
        print("  run <pkg>         Run a package")
        print("  startup [pkg]     Set startup package")
        print("  self_update       Update MPM")
        print("  info <pkg>        Package information")
        print("  uninstall         Remove MPM completely")
        print("  help [cmd]        Show this help")
        print("")
        print("Run 'mpm help <command>' for details.")
        print("")
    end,

    showCommandHelp = function(command)
        local cmd = helpModule.commands[command]

        if not cmd then
            print("")
            print("Unknown command: " .. command)
            print("")
            print("Run 'mpm help' for available commands.")
            print("")
            return
        end

        print("")
        print(cmd.usage)
        print("")
        print(cmd.description)
        print("")

        if cmd.examples and #cmd.examples > 0 then
            print("Examples:")
            for _, example in ipairs(cmd.examples) do
                print("  " .. example)
            end
            print("")
        end
    end
}

return helpModule
