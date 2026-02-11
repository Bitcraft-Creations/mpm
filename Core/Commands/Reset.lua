--[[
    Reset command: mpm reset [--hard]

    Clear all installed packages and optionally all config.
    --hard also removes taps and startup config.
]]
local resetModule = nil

resetModule = {
    usage = "mpm reset [--hard]",

    run = function(flag)
        local File = exports("Utils.File")
        local PackageDisk = exports("Utils.PackageDisk")

        local hard = (flag == "--hard" or flag == "-h")

        print("")
        print("=== MPM Reset ===")
        print("")

        if hard then
            print("This will remove:")
            print("  - All installed packages")
            print("  - Startup configuration")
            print("  - All taps (reset to official)")
        else
            print("This will remove:")
            print("  - All installed packages")
            print("")
            print("Use --hard to also reset taps and startup")
        end

        print("")
        print("Continue? (y/n)")
        local confirm = read()

        if confirm:lower() ~= "y" then
            print("Cancelled.")
            return
        end

        print("")

        -- Remove all packages
        local packages = PackageDisk.listInstalled()
        for _, pkg in ipairs(packages) do
            File.delete("/mpm/Packages/" .. pkg)
            print("  - Removed @" .. pkg)
        end

        if #packages == 0 then
            print("  (no packages installed)")
        end

        if hard then
            -- Clear startup
            if File.exists("/startup.config") then
                File.delete("/startup.config")
                File.delete("/startup.lua")
                print("  - Cleared startup config")
            end

            -- Reset taps to default
            local TapRegistry = exports("Utils.TapRegistry")
            local defaultConfig = {
                version = 1,
                defaultTap = "official",
                taps = {
                    official = {
                        name = "official",
                        url = "https://shelfwood-mpm-packages.netlify.app/",
                        type = "direct"
                    }
                }
            }
            TapRegistry.saveConfig(defaultConfig)
            print("  - Reset taps to official")
        end

        print("")
        print("[+] Reset complete")
        print("")
    end
}

return resetModule
