--[[
    Doctor command: mpm doctor

    Check MPM health and diagnose issues.
]]
local doctorModule = nil

doctorModule = {
    usage = "mpm doctor",

    run = function()
        local File = exports("Utils.File")
        local Validation = exports("Utils.Validation")
        local TapRegistry = exports("Utils.TapRegistry")
        local PackageDisk = exports("Utils.PackageDisk")

        local issues = {}
        local warnings = {}

        print("")
        print("=== MPM Doctor ===")
        print("")
        print("Checking system health...")
        print("")

        -- Check 1: Core files exist
        print("[*] Core files...")
        local coreFiles = {
            "/mpm.lua",
            "/mpm/bootstrap.lua",
            "/mpm/Core/Commands/Install.lua",
            "/mpm/Core/Utils/Validation.lua"
        }
        for _, f in ipairs(coreFiles) do
            if not File.exists(f) then
                table.insert(issues, "Missing: " .. f)
            end
        end
        print("    Checked " .. #coreFiles .. " files")

        -- Check 2: Taps configuration
        print("[*] Taps configuration...")
        if File.exists("/mpm/taps.json") then
            local config = TapRegistry.loadConfig()
            if config and config.taps then
                local tapCount = 0
                for _ in pairs(config.taps) do tapCount = tapCount + 1 end
                print("    " .. tapCount .. " tap(s) configured")

                -- Check default tap exists
                if config.defaultTap and not config.taps[config.defaultTap] then
                    table.insert(issues, "Default tap '" .. config.defaultTap .. "' not found")
                end
            else
                table.insert(issues, "Invalid taps.json format")
            end
        else
            table.insert(issues, "Missing taps.json - run 'mpm self_update'")
        end

        -- Check 3: Packages directory
        print("[*] Packages...")
        if File.exists("/mpm/Packages") then
            local packages = PackageDisk.listInstalled()
            print("    " .. #packages .. " package(s) installed")

            -- Check each package has manifest
            for _, pkg in ipairs(packages) do
                local manifestPath = "/mpm/Packages/" .. pkg .. "/manifest.json"
                if not File.exists(manifestPath) then
                    table.insert(warnings, "Package '" .. pkg .. "' missing manifest.json")
                end
            end
        else
            table.insert(warnings, "Packages directory missing")
        end

        -- Check 4: Startup configuration
        print("[*] Startup...")
        if File.exists("/startup.config") then
            local StartupConfig = exports("Utils.StartupConfig")
            local config = StartupConfig.getConfig()
            if config and config.package then
                print("    Configured: " .. config.package)
                if not PackageDisk.isInstalled(config.package) then
                    table.insert(warnings, "Startup package '" .. config.package .. "' not installed")
                end
            else
                table.insert(warnings, "Invalid startup.config")
            end
        else
            print("    Not configured")
        end

        -- Check 5: Network connectivity
        print("[*] Network...")
        local testUrl = "https://shelfwood-mpm.netlify.app/manifest.json"
        local response, err = Validation.safeHttpGet(testUrl)
        if response then
            Validation.readResponse(response)
            print("    Connection OK")
        else
            table.insert(issues, "Cannot reach MPM server")
        end

        -- Check 6: Default tap connectivity
        print("[*] Default tap...")
        local defaultTap = TapRegistry.getDefault()
        if defaultTap and defaultTap.url then
            local tapResponse = Validation.safeHttpGet(defaultTap.url .. "index.json")
            if tapResponse then
                Validation.readResponse(tapResponse)
                print("    " .. defaultTap.name .. " OK")
            else
                table.insert(warnings, "Cannot reach tap: " .. defaultTap.name)
            end
        end

        -- Results
        print("")
        print("--- Results ---")
        print("")

        if #issues == 0 and #warnings == 0 then
            print("[+] All checks passed!")
        else
            if #issues > 0 then
                print("Issues (" .. #issues .. "):")
                for _, issue in ipairs(issues) do
                    print("  [!] " .. issue)
                end
                print("")
            end

            if #warnings > 0 then
                print("Warnings (" .. #warnings .. "):")
                for _, warn in ipairs(warnings) do
                    print("  [?] " .. warn)
                end
                print("")
            end

            print("Fixes:")
            if #issues > 0 then
                print("  mpm self_update    Reinstall core files")
            end
            print("  mpm reset --hard   Full reset")
        end

        print("")
    end
}

return doctorModule
