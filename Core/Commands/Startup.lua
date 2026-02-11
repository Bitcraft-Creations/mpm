--[[
    Startup command: mpm startup [package] [args...]

    Configures a package to run on computer startup.
    Creates startup.config for persistence and startup.lua for execution.

    Options:
      mpm startup <package>     Configure startup package
      mpm startup --refresh     Regenerate startup.lua from config
      mpm startup --clear       Remove startup configuration
      mpm startup --show        Show current configuration
]]
local startupModule = nil

startupModule = {
    usage = "mpm startup [package] [args...] | --refresh | --clear | --show",

    run = function(package, ...)
        local Validation = exports("Utils.Validation")
        local StartupConfig = exports("Utils.StartupConfig")
        local PackageDisk = exports("Utils.PackageDisk")

        local args = {...}

        -- Handle flags
        if package == "--refresh" then
            startupModule.refresh()
            return
        end

        if package == "--clear" then
            startupModule.clear()
            return
        end

        if package == "--show" then
            startupModule.show()
            return
        end

        -- Interactive mode if no package specified
        local parameters = ""

        if Validation.isEmpty(package) then
            -- Check if already configured
            if StartupConfig.isConfigured() then
                local config = StartupConfig.getConfig()
                print("")
                print("Current startup: @" .. (config.package or "unknown"))
                if config.parameters and config.parameters ~= "" then
                    print("Parameters: " .. config.parameters)
                end
                print("")
                print("Options:")
                print("  1. Keep current configuration")
                print("  2. Configure new package")
                print("  3. Clear startup configuration")
                print("")
                print("Choice (1/2/3):")
                local choice = read()

                if choice == "1" then
                    print("Keeping current configuration.")
                    return
                elseif choice == "3" then
                    startupModule.clear()
                    return
                end
                -- choice == "2" continues below
            end

            print("")
            print("Enter the package name for startup:")
            package = read()

            if Validation.isEmpty(package) then
                print("Error: Package name cannot be empty.")
                return
            end

            print("Enter optional parameters (or leave blank):")
            parameters = read() or ""
        else
            -- Build parameters from remaining args
            if #args > 0 then
                parameters = table.concat(args, " ")
            end
        end

        -- Validate package exists (warning only)
        if not PackageDisk.isInstalled(package) then
            print("")
            print("Warning: Package '" .. package .. "' is not currently installed.")
            print("It will be installed on first boot if available.")
            print("")
            print("Continue? (y/n)")
            local confirm = read()
            if confirm:lower() ~= "y" then
                print("Cancelled.")
                return
            end
        end

        -- Save configuration and generate startup.lua
        local success = StartupConfig.configure(package, parameters)

        if success then
            print("")
            print("Startup configured!")
            print("  Package: " .. package)
            if parameters ~= "" then
                print("  Args: " .. parameters)
            end
            print("")
            print("On boot, the computer will:")
            print("  1. Update MPM (mpm self_update)")
            print("  2. Update packages (mpm update)")
            print("  3. Run: mpm run " .. package .. (parameters ~= "" and " " .. parameters or ""))
            print("")
            print("Use 'mpm startup --show' to view config")
            print("Use 'mpm startup --refresh' to regenerate")
        else
            print("Error: Failed to configure startup.")
        end
    end,

    refresh = function()
        local StartupConfig = exports("Utils.StartupConfig")

        if not StartupConfig.isConfigured() then
            print("")
            print("No startup configuration found.")
            print("Use 'mpm startup <package>' to configure.")
            print("")
            return
        end

        local success, err = StartupConfig.regenerateStartup()

        if success then
            local config = StartupConfig.getConfig()
            print("")
            print("Startup script regenerated!")
            print("  Package: " .. (config.package or "unknown"))
            print("")
        else
            print("Error: " .. (err or "Failed to regenerate startup"))
        end
    end,

    clear = function()
        local StartupConfig = exports("Utils.StartupConfig")
        local File = exports("Utils.File")

        print("")
        print("This will remove:")
        print("  - /startup.config")
        print("  - /startup.lua")
        print("")
        print("Continue? (y/n)")
        local confirm = read()

        if confirm:lower() ~= "y" then
            print("Cancelled.")
            return
        end

        StartupConfig.clear(true)

        print("")
        print("Startup configuration cleared.")
        print("The computer will no longer auto-run packages on boot.")
        print("")
    end,

    show = function()
        local StartupConfig = exports("Utils.StartupConfig")

        local config = StartupConfig.getConfig()

        print("")
        if not config then
            print("No startup configuration found.")
            print("")
            print("Configure with: mpm startup <package>")
        else
            print("=== Startup Configuration ===")
            print("")
            print("Package: " .. (config.package or "not set"))
            if config.parameters and config.parameters ~= "" then
                print("Parameters: " .. config.parameters)
            end
            if config.updatedAt then
                print("Configured: " .. config.updatedAt)
            end
            print("")
            print("On boot sequence:")
            print("  1. mpm self_update")
            print("  2. mpm update")
            print("  3. mpm run " .. (config.package or "?") .. (config.parameters ~= "" and " " .. config.parameters or ""))
        end
        print("")
    end
}

return startupModule
