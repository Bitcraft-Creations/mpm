local this

--[[
    This command updates the specified package or all packages if no package is specified.
    To update a package we need to:
    - Obtain the manifest.json
    - For each file in the manifest.files, download the file from the package github repository
    - Replace the existing file with the new file
    - For any packages that are no longer in the manifest, delete them
]]

this = {
    usage = "mpm update <package>",

    run = function(...)
        local names = {...}
        print("\nChecking for updates...\n")
        -- If <package> names are specified, we only update those packages
        if #names > 0 then
            this.updatePackages(names)

            return
        end

        -- If no <package> names are specified, we update all packages
        this.updatePackages(exports("Utils.File").list("/mpm/Packages/"))
    end,

    updatePackages = function(packages)
        for _, package in ipairs(packages) do
            this.updatePackage(package)
        end
        print("\nDone!\n")
    end,

    updatePackage = function(package)
        print("- @" .. package)
        local manifest = exports("Utils.PackageRepository").getPackage(package)
        for _, file in ipairs(manifest.files) do
            this.updateFile(package, file)
        end

        -- this.removeFilesNotInList(package, manifest.files)
    end,

    updateFile = function(package, filename)
        -- Obtain the file from the repository
        local content = exports("Utils.PackageRepository").downloadFile(package, filename)
        local filepath = "/mpm/Packages/" .. package .. "/" .. filename

        -- If the file content is the same, return
        local installedContent = exports("Utils.File").get(filepath)

        if installedContent == content then
            return
        end

        -- Replace the existing file with the new updated file
        exports("Utils.File").put(filepath, content)

        -- Print the file name
        print("  - " .. filename)
    end,

    removeFilesNotInList = function(package, files)
        local files = exports("Utils.File").list("/mpm/Packages/" .. package)
        for _, file in ipairs(files) do
            if not this.isInList(file, files) then
                exports("Utils.File").delete("/mpm/Packages/" .. package .. "/" .. file)
                -- Print the file name with an X to indicate it is deleted
                print("X - " .. file)
            end
        end
    end,

    isInList = function(file, list)
        for _, item in ipairs(list) do
            if item .. ".lua" == file then
                return true
            end
        end
        return false
    end
}

return this
