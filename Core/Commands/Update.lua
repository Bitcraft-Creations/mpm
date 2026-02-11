--[[
    Update command: mpm update [package] [package2] ...

    Updates specified packages, or all installed packages if none specified.
]]
local updateModule = nil

updateModule = {
    usage = "mpm update [package] [package2] ...",

    run = function(...)
        local names = {...}
        local File = exports("Utils.File")
        local PackageDisk = exports("Utils.PackageDisk")
        local Repo = exports("Utils.PackageRepository")
        local Validation = exports("Utils.Validation")

        print("")
        print("Checking for updates...")
        print("")

        -- If no packages specified, update all installed
        if #names == 0 then
            names = PackageDisk.listInstalled()
            if #names == 0 then
                print("No packages installed.")
                return
            end
        end

        local updated = 0
        local failed = 0

        for _, package in ipairs(names) do
            local success, filesUpdated = updateModule.updatePackage(package)
            if success then
                if filesUpdated > 0 then
                    updated = updated + 1
                end
            else
                failed = failed + 1
            end
        end

        print("")
        if updated > 0 or failed > 0 then
            print("Done: " .. updated .. " updated, " .. failed .. " failed")
        else
            print("All packages are up to date.")
        end
        print("")
    end,

    updatePackage = function(package)
        local File = exports("Utils.File")
        local PackageDisk = exports("Utils.PackageDisk")
        local Repo = exports("Utils.PackageRepository")

        print("@" .. package)

        -- Check if installed
        if not PackageDisk.isInstalled(package) then
            print("  Package not installed. Use: mpm install " .. package)
            return false, 0
        end

        -- Fetch remote manifest
        local manifest, err = Repo.getPackage(package)
        if not manifest then
            print("  Error: " .. (err or "Failed to fetch manifest"))
            return false, 0
        end

        -- Install missing dependencies
        if manifest.dependencies and type(manifest.dependencies) == "table" then
            for _, dep in ipairs(manifest.dependencies) do
                if not PackageDisk.isInstalled(dep) then
                    print("  Installing missing dependency: " .. dep)
                    PackageDisk.install(dep)
                end
            end
        end

        -- Update manifest file
        local manifestPath = "/mpm/Packages/" .. package .. "/manifest.json"
        File.put(manifestPath, textutils.serializeJSON(manifest))

        -- Update each file
        local filesUpdated = 0

        if manifest.files and type(manifest.files) == "table" then
            for _, file in ipairs(manifest.files) do
                local updated = updateModule.updateFile(package, file)
                if updated then
                    print("  + " .. file)
                    filesUpdated = filesUpdated + 1
                end
            end
        end

        if filesUpdated == 0 then
            print("  (up to date)")
        end

        return true, filesUpdated
    end,

    updateFile = function(package, filename)
        local File = exports("Utils.File")
        local Repo = exports("Utils.PackageRepository")

        -- Fetch remote content
        local content, err = Repo.downloadFile(package, filename)
        if not content then
            print("  x " .. filename .. " (failed)")
            return false
        end

        local filepath = "/mpm/Packages/" .. package .. "/" .. filename

        -- Compare with local
        local localContent = File.get(filepath)
        if localContent == content then
            return false  -- No update needed
        end

        -- Update file
        File.put(filepath, content)
        return true
    end
}

return updateModule
