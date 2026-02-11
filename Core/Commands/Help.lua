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
            description = "Install packages from configured taps.",
            examples = {
                "mpm install tools",
                "mpm install views displays utils",
                "mpm install mytap/custom-package"
            },
            notes = {
                "Use tap/package syntax to install from specific tap"
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
            description = "List installed packages (default) or available packages from all taps.",
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
            usage = "mpm startup [package] [args...] | --refresh | --clear | --show",
            description = "Configure a package to run on computer boot.",
            options = {
                "<package>  - Set the startup package",
                "--show     - Display current configuration",
                "--refresh  - Regenerate startup.lua from config",
                "--clear    - Remove startup configuration"
            },
            examples = {
                "mpm startup displays",
                "mpm startup --show",
                "mpm startup --refresh",
                "mpm startup --clear"
            },
            notes = {
                "On boot: runs self_update, then update, then your package",
                "Config stored in /startup.config for persistence"
            }
        },
        tap = {
            usage = "mpm tap <source> | --list | --remove <name> | --default <name>",
            description = "Manage package repository sources (taps).",
            options = {
                "<source>        - Add a new tap",
                "--list          - List all configured taps",
                "--remove <name> - Remove a tap",
                "--default <name>- Set default tap"
            },
            examples = {
                "mpm tap j-shelfwood/mpm-packages",
                "mpm tap https://my-packages.netlify.app/",
                "mpm tap --list",
                "mpm tap --remove mytap",
                "mpm tap --default mytap"
            },
            notes = {
                "GitHub shorthand: user/repo (prompts for hosting URL)",
                "Direct URL: https://packages.example.com/"
            }
        },
        untap = {
            usage = "mpm untap <name>",
            description = "Remove a tap. Alias for: mpm tap --remove <name>",
            examples = {
                "mpm untap mytap"
            }
        },
        self_update = {
            usage = "mpm self_update",
            description = "Update MPM itself. Also refreshes startup.lua if configured.",
            examples = {
                "mpm self_update"
            }
        },
        info = {
            usage = "mpm info <package>",
            description = "Display detailed information about a package.",
            examples = {
                "mpm info tools",
                "mpm info mytap/package"
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
                "mpm help tap"
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
        print("Package Management:")
        print("  install <pkg>       Install a package")
        print("  remove <pkg>        Remove a package")
        print("  update [pkg]        Update packages")
        print("  list [local|remote] List packages")
        print("  info <pkg>          Package information")
        print("")
        print("Running:")
        print("  run <pkg>           Run a package")
        print("  startup [pkg]       Set startup package")
        print("")
        print("Repository:")
        print("  tap <source>        Add a tap")
        print("  tap --list          List taps")
        print("  untap <name>        Remove a tap")
        print("")
        print("System:")
        print("  self_update         Update MPM")
        print("  uninstall           Remove MPM")
        print("  help [cmd]          Show help")
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

        if cmd.options and #cmd.options > 0 then
            print("Options:")
            for _, option in ipairs(cmd.options) do
                print("  " .. option)
            end
            print("")
        end

        if cmd.examples and #cmd.examples > 0 then
            print("Examples:")
            for _, example in ipairs(cmd.examples) do
                print("  " .. example)
            end
            print("")
        end

        if cmd.notes and #cmd.notes > 0 then
            print("Notes:")
            for _, note in ipairs(cmd.notes) do
                print("  - " .. note)
            end
            print("")
        end
    end
}

return helpModule
