--[[
    Help command: mpm help [command]
]]
local helpModule = nil

helpModule = {
    usage = "mpm help [command]",

    commands = {
        install = {
            usage = "mpm install <pkg> [pkg2...]",
            desc = "Install packages from configured taps",
            examples = {"mpm install tools", "mpm install mytap/pkg"}
        },
        remove = {
            usage = "mpm remove <pkg> [pkg2...]",
            desc = "Remove installed packages",
            examples = {"mpm remove tools"}
        },
        update = {
            usage = "mpm update [pkg...]",
            desc = "Update packages (all if none specified)",
            examples = {"mpm update", "mpm update tools"}
        },
        list = {
            usage = "mpm list [remote]",
            desc = "List installed or available packages",
            examples = {"mpm list", "mpm list remote"}
        },
        run = {
            usage = "mpm run <pkg> [args]",
            desc = "Run a package or script",
            examples = {"mpm run displays", "mpm run tools/inspect_peripheral"}
        },
        info = {
            usage = "mpm info <pkg>",
            desc = "Show package details",
            examples = {"mpm info tools"}
        },
        tap = {
            usage = "mpm tap <source> | --list | --remove <name>",
            desc = "Manage package repositories",
            examples = {"mpm tap https://pkg.example.com/", "mpm tap --list"}
        },
        untap = {
            usage = "mpm untap <name>",
            desc = "Remove a tap",
            examples = {"mpm untap mytap"}
        },
        startup = {
            usage = "mpm startup [pkg] | --show | --clear",
            desc = "Configure package to run on boot",
            examples = {"mpm startup displays", "mpm startup --show"}
        },
        self_update = {
            usage = "mpm self_update",
            desc = "Update MPM to latest version",
            examples = {"mpm self_update"}
        },
        uninstall = {
            usage = "mpm uninstall",
            desc = "Remove MPM and all packages",
            examples = {"mpm uninstall"}
        },
        help = {
            usage = "mpm help [command]",
            desc = "Show help for commands",
            examples = {"mpm help", "mpm help tap"}
        },
        intro = {
            usage = "mpm intro",
            desc = "Interactive tutorial for new users",
            examples = {"mpm intro"}
        }
    },

    run = function(cmd)
        if cmd then
            helpModule.showCommand(cmd:lower())
        else
            helpModule.showAll()
        end
    end,

    showAll = function()
        local UI = exports("Utils.UI")
        UI.printBanner()

        print("Usage: mpm <command> [args]")
        print("")
        print("Packages:")
        print("  install <pkg>    Install packages")
        print("  remove <pkg>     Remove packages")
        print("  update [pkg]     Update packages")
        print("  list [remote]    List packages")
        print("  info <pkg>       Package details")
        print("  run <pkg>        Run package")
        print("")
        print("Repository:")
        print("  tap <source>     Add tap")
        print("  tap --list       List taps")
        print("  untap <name>     Remove tap")
        print("")
        print("System:")
        print("  startup [pkg]    Set boot package")
        print("  self_update      Update MPM")
        print("  uninstall        Remove MPM")
        print("")
        print("mpm help <command> for details")
    end,

    showCommand = function(cmd)
        local c = helpModule.commands[cmd]
        if not c then
            print("")
            print("[!] Unknown: " .. cmd)
            print("Run 'mpm help' for commands")
            return
        end

        print("")
        print(c.usage)
        print("")
        print(c.desc)

        if c.examples and #c.examples > 0 then
            print("")
            print("Examples:")
            for _, ex in ipairs(c.examples) do
                print("  " .. ex)
            end
        end
        print("")
    end
}

return helpModule
