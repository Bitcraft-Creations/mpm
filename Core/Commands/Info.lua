--[[
    Info command: mpm info <package>

    Displays detailed information about a package.
    Shows local info if installed, otherwise fetches from registry.
]]
local infoModule = nil

infoModule = {
    usage = "mpm info <package>",

    run = function(package)
        local Validation = exports("Utils.Validation")
        local PackageDisk = exports("Utils.PackageDisk")
        local Repo = exports("Utils.PackageRepository")

        if not Validation.requireArg(package, "<package>", infoModule.usage) then
            return
        end

        local manifest = nil
        local source = nil

        -- Check if installed locally first
        if PackageDisk.isInstalled(package) then
            manifest = PackageDisk.getManifest(package)
            source = "installed"
        end

        -- If not installed or no local manifest, fetch from registry
        if not manifest then
            print("Fetching package info...")
            local err
            manifest, err = Repo.getPackage(package)
            if not manifest then
                print("")
                print("Error: Package '" .. package .. "' not found.")
                print(err or "")
                print("")
                return
            end
            source = "registry"
        end

        -- Display package info
        print("")
        print("=== @" .. (manifest.name or package) .. " ===")
        print("")

        if source == "installed" then
            print("Status: Installed")
        else
            print("Status: Available (not installed)")
        end

        if manifest.version then
            print("Version: " .. manifest.version)
        end

        if manifest.description then
            print("")
            print(manifest.description)
        end

        if manifest.author then
            print("")
            print("Author: " .. manifest.author)
        end

        if manifest.repository then
            print("Repository: " .. manifest.repository)
        end

        -- Show dependencies
        if manifest.dependencies and #manifest.dependencies > 0 then
            print("")
            print("Dependencies:")
            for _, dep in ipairs(manifest.dependencies) do
                local depInstalled = PackageDisk.isInstalled(dep)
                local status = depInstalled and "(installed)" or "(not installed)"
                print("  - " .. dep .. " " .. status)
            end
        end

        -- Show files
        if manifest.files and #manifest.files > 0 then
            print("")
            print("Files (" .. #manifest.files .. "):")
            for _, file in ipairs(manifest.files) do
                print("  - " .. file)
            end
        end

        print("")

        -- Action hint
        if source == "registry" then
            print("Install with: mpm install " .. package)
        else
            print("Update with: mpm update " .. package)
            print("Remove with: mpm remove " .. package)
        end
        print("")
    end
}

return infoModule
