--[[
    Uninstall command: mpm uninstall

    Completely removes MPM and all installed packages from the computer.
    This is a destructive operation requiring confirmation.
]]
local uninstallModule = nil

uninstallModule = {
    usage = "mpm uninstall",

    run = function(force)
        local File = exports("Utils.File")
        local PackageDisk = exports("Utils.PackageDisk")

        print("")
        print("=== MPM UNINSTALL ===")
        print("")
        print("This will permanently remove:")
        print("  - All installed packages (/mpm/Packages/)")
        print("  - MPM core files (/mpm/)")
        print("  - MPM command (/mpm.lua)")
        print("")

        -- Show what will be deleted
        local packages = PackageDisk.listInstalled()
        if #packages > 0 then
            print("Installed packages to be removed:")
            for _, pkg in ipairs(packages) do
                print("  - @" .. pkg)
            end
            print("")
        end

        -- Require confirmation unless --force
        if force ~= "--force" and force ~= "-f" then
            print("Type 'uninstall' to confirm:")
            local confirm = read()

            if confirm ~= "uninstall" then
                print("")
                print("Cancelled. No changes made.")
                return
            end
        end

        print("")
        print("Removing MPM...")

        -- 1. Remove all packages
        for _, pkg in ipairs(packages) do
            File.delete("/mpm/Packages/" .. pkg)
            print("  - Removed @" .. pkg)
        end

        -- 2. Remove the Packages directory
        File.delete("/mpm/Packages")

        -- 3. Remove Core directory contents
        File.delete("/mpm/Core")

        -- 4. Remove other mpm files
        File.delete("/mpm/bootstrap.lua")
        File.delete("/mpm/install.lua")
        File.delete("/mpm/manifest.json")

        -- 5. Remove the mpm directory itself
        File.delete("/mpm")

        -- 6. Remove the main mpm.lua command
        File.delete("/mpm.lua")

        -- 7. Check if startup.lua references mpm and offer to remove
        local startupContent = File.get("/startup.lua")
        if startupContent and startupContent:find("mpm") then
            print("")
            print("Note: /startup.lua references MPM.")
            print("Remove startup script? (y/n)")
            local removeStartup = read()
            if removeStartup:lower() == "y" then
                File.delete("/startup.lua")
                print("  - Removed /startup.lua")
            end
        end

        print("")
        print("MPM has been completely removed.")
        print("")
        print("To reinstall, run:")
        print("  wget run https://shelfwood-mpm.netlify.app/install.lua")
        print("")
    end
}

return uninstallModule
