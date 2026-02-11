--[[
    Intro command: mpm intro

    Interactive tutorial walking users through MPM features.
]]
local introModule = nil

introModule = {
    usage = "mpm intro",

    run = function()
        local UI = exports("Utils.UI")
        local Validation = exports("Utils.Validation")
        local TapRegistry = exports("Utils.TapRegistry")
        local PackageDisk = exports("Utils.PackageDisk")
        local StartupConfig = exports("Utils.StartupConfig")

        -- Track what we do for undo
        local actions = {
            packagesInstalled = {},
            startupConfigured = false
        }

        -- Welcome
        introModule.clear()
        UI.printBanner()
        print("Welcome to MPM!")
        print("")
        print("This intro will walk you through:")
        print("  1. Viewing available packages")
        print("  2. Installing packages")
        print("  3. Running packages")
        print("  4. Managing repositories (taps)")
        print("  5. Setting up startup")
        print("")
        print("Press Enter to continue...")
        read()

        -- Step 1: Taps
        introModule.clear()
        print("=== Step 1: Package Repositories (Taps) ===")
        print("")
        print("MPM uses 'taps' as package sources.")
        print("You have one tap configured:")
        print("")

        local taps = TapRegistry.getTaps()
        for name, tap in pairs(taps) do
            local def = TapRegistry.getDefault()
            local marker = (def.name == name) and " (default)" or ""
            print("  @" .. name .. marker)
            print("    " .. tap.url)
        end

        print("")
        print("Add more taps with: mpm tap <url>")
        print("")
        print("Press Enter to continue...")
        read()

        -- Step 2: List packages
        introModule.clear()
        print("=== Step 2: Available Packages ===")
        print("")
        print("Fetching packages from your taps...")
        print("")

        local Repo = exports("Utils.PackageRepository")
        local allPkgs = Repo.listAllPackages()

        local pkgList = {}
        for tapName, packages in pairs(allPkgs) do
            if not packages._error and type(packages) == "table" then
                print("[" .. tapName .. "]")
                for _, pkg in ipairs(packages) do
                    local name = type(pkg) == "table" and pkg.name or pkg
                    local desc = type(pkg) == "table" and pkg.description or ""
                    print("  @" .. name)
                    if desc ~= "" then
                        print("    " .. desc)
                    end
                    table.insert(pkgList, name)
                end
                print("")
            end
        end

        print("Use 'mpm list remote' to see this anytime.")
        print("")
        print("Press Enter to continue...")
        read()

        -- Step 3: Install packages
        introModule.clear()
        print("=== Step 3: Installing Packages ===")
        print("")
        print("Let's install some packages!")
        print("")
        print("The 'shelfos' package is the Base Information")
        print("System with multi-monitor management, touch")
        print("config, and pocket integration.")
        print("")
        print("It depends on: views, utils, peripherals, ui, net")
        print("")
        print("Install shelfos package? (y/n)")

        local install = read()
        if install:lower() == "y" then
            print("")
            print("Installing...")
            print("")

            -- Install shelfos (will auto-install deps)
            local success = PackageDisk.install("shelfos")

            if success then
                table.insert(actions.packagesInstalled, "shelfos")
                -- Track deps too
                for _, dep in ipairs({"views", "utils", "peripherals", "ui", "net"}) do
                    if PackageDisk.isInstalled(dep) then
                        table.insert(actions.packagesInstalled, dep)
                    end
                end
            end

            print("")
            print("Press Enter to continue...")
            read()
        end

        -- Step 4: Running packages
        introModule.clear()
        print("=== Step 4: Running Packages ===")
        print("")

        if #actions.packagesInstalled > 0 then
            print("You have packages installed!")
            print("")
            print("Run a package with:")
            print("  mpm run shelfos")
            print("")
            print("Run a specific script:")
            print("  mpm run tools/inspect_peripheral")
            print("")
            print("Would you like to run 'shelfos' now? (y/n)")
            print("(This will start the ShelfOS setup wizard)")

            local runIt = read()
            if runIt:lower() == "y" then
                print("")
                print("Starting ShelfOS...")
                print("(Exit with Ctrl+T when done)")
                print("")
                sleep(1)

                -- Run the shelfos package through mpm run (sets up mpm() global)
                shell.run("mpm run shelfos")

                print("")
                print("Press Enter to continue...")
                read()
            end
        else
            print("No packages installed yet.")
            print("")
            print("Install with: mpm install <package>")
            print("Run with:     mpm run <package>")
        end

        print("")
        print("Press Enter to continue...")
        read()

        -- Step 5: Startup configuration
        introModule.clear()
        print("=== Step 5: Startup Configuration ===")
        print("")
        print("You can set a package to run automatically")
        print("when this computer boots.")
        print("")
        print("On boot, MPM will:")
        print("  1. Update itself (mpm selfupdate)")
        print("  2. Update packages (mpm update)")
        print("  3. Run your startup package")
        print("")

        if #actions.packagesInstalled > 0 then
            print("Set 'shelfos' as startup? (y/n)")

            local setStartup = read()
            if setStartup:lower() == "y" then
                StartupConfig.configure("shelfos", "")
                actions.startupConfigured = true
                print("")
                print("[+] Startup configured!")
                print("    This computer will run 'shelfos' on boot.")
            end
        else
            print("Install a package first, then run:")
            print("  mpm startup <package>")
        end

        print("")
        print("Press Enter to continue...")
        read()

        -- Step 6: Managing taps
        introModule.clear()
        print("=== Step 6: Adding More Taps ===")
        print("")
        print("Want packages from other sources?")
        print("")
        print("Add a tap:")
        print("  mpm tap https://packages.example.com/")
        print("")
        print("List taps:")
        print("  mpm tap --list")
        print("")
        print("Remove a tap:")
        print("  mpm untap <name>")
        print("")
        print("Set default tap:")
        print("  mpm tap --default <name>")
        print("")
        print("Press Enter to continue...")
        read()

        -- Summary
        introModule.clear()
        print("=== Setup Complete! ===")
        print("")
        print("What was configured:")
        print("")

        if #actions.packagesInstalled > 0 then
            print("  Packages installed:")
            for _, pkg in ipairs(actions.packagesInstalled) do
                print("    - " .. pkg)
            end
        else
            print("  No packages installed")
        end

        print("")
        if actions.startupConfigured then
            print("  Startup: shelfos")
        else
            print("  Startup: not configured")
        end

        print("")
        print("Commands to remember:")
        print("  mpm list          Installed packages")
        print("  mpm list remote   Available packages")
        print("  mpm update        Update everything")
        print("  mpm help          Show all commands")
        print("")

        -- Offer undo
        if #actions.packagesInstalled > 0 or actions.startupConfigured then
            print("Options:")
            print("  1. Keep this setup")
            print("  2. Undo everything (start fresh)")
            print("")
            print("Choice (1/2):")

            local choice = read()
            if choice == "2" then
                introModule.undo(actions)
            else
                print("")
                print("[+] Setup saved. Enjoy MPM!")
            end
        else
            print("[+] Intro complete. Run 'mpm help' anytime!")
        end

        print("")
    end,

    clear = function()
        term.clear()
        term.setCursorPos(1, 1)
    end,

    undo = function(actions)
        local PackageDisk = exports("Utils.PackageDisk")
        local StartupConfig = exports("Utils.StartupConfig")
        local File = exports("Utils.File")

        print("")
        print("Undoing setup...")
        print("")

        -- Remove startup config
        if actions.startupConfigured then
            StartupConfig.clear(true)
            print("  - Startup cleared")
        end

        -- Remove packages (reverse order to handle deps)
        for i = #actions.packagesInstalled, 1, -1 do
            local pkg = actions.packagesInstalled[i]
            File.delete("/mpm/Packages/" .. pkg)
            print("  - Removed " .. pkg)
        end

        print("")
        print("[+] Reset complete. Fresh start!")
    end
}

return introModule
