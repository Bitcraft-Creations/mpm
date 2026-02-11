local PackageDisk = nil

--[[
    The PackageDisk module handles local disk operations for packages.

    A package is a directory in /mpm/Packages/. Each package contains:
    - manifest.json: Package metadata (includes _tap and _tapUrl for source tracking)
      - name: Package identifier
      - description: Human-readable description
      - files: Array of files to download
      - dependencies: (optional) Array of package names to install first
      - _tap: Source tap name
      - _tapUrl: Source tap URL
]]

local packageDirectory = "/mpm/Packages/"

PackageDisk = {
    --- Install a package from a tap
    --- @param name string Package name (can be tap/package format)
    --- @return boolean success
    install = function(name)
        local Validation = exports("Utils.Validation")
        local File = exports("Utils.File")
        local Repo = exports("Utils.PackageRepository")

        if Validation.isEmpty(name) then
            print("Error: Package name is required.")
            return false
        end

        -- Resolve the actual package name (without tap prefix for local storage)
        local _, tapName, pkgName = Repo.resolvePackage(name)

        -- Fetch manifest from remote
        local manifest, err = Repo.getPackage(name)
        if not manifest then
            print("Error: " .. (err or "Package '" .. name .. "' not found."))
            return false
        end

        -- Display package info
        print("")
        print("@" .. (manifest.name or pkgName) .. " [" .. tapName .. "]")
        if manifest.description then
            print(manifest.description)
        end
        print("")

        -- Install dependencies first
        if manifest.dependencies and type(manifest.dependencies) == "table" then
            for _, dep in ipairs(manifest.dependencies) do
                if not PackageDisk.isInstalled(dep) then
                    print("Installing dependency: " .. dep)
                    local depSuccess = PackageDisk.install(dep)
                    if not depSuccess then
                        print("Warning: Failed to install dependency '" .. dep .. "'")
                    end
                end
            end
        end

        -- Save manifest locally (use pkgName for local path)
        local manifestPath = packageDirectory .. pkgName .. "/manifest.json"
        File.put(manifestPath, textutils.serializeJSON(manifest))

        -- Install each file
        if manifest.files and type(manifest.files) == "table" then
            for _, file in ipairs(manifest.files) do
                local success = PackageDisk.installFile(name, pkgName, file)
                if success then
                    print("+ " .. file)
                else
                    print("x " .. file .. " (failed)")
                end
            end
        end

        print("")
        print("Installed @" .. pkgName .. " from [" .. tapName .. "]")
        print("")

        return true
    end,

    --- Install a single file from a package
    --- @param fullName string Full package name (may include tap)
    --- @param localName string Local package name (without tap)
    --- @param file string File path within package
    --- @return boolean success
    installFile = function(fullName, localName, file)
        local File = exports("Utils.File")
        local Repo = exports("Utils.PackageRepository")

        local content, err = Repo.downloadFile(fullName, file)
        if not content then
            print("Error: " .. (err or "Failed to download " .. file))
            return false
        end

        local filePath = packageDirectory .. localName .. "/" .. file
        return File.put(filePath, content)
    end,

    --- Remove a package from disk
    --- @param package string Package name
    --- @return boolean success
    remove = function(package)
        local Validation = exports("Utils.Validation")
        local File = exports("Utils.File")

        if Validation.isEmpty(package) then
            print("Error: Package name is required.")
            return false
        end

        if not PackageDisk.isInstalled(package) then
            print("Error: Package '" .. package .. "' is not installed.")
            return false
        end

        local success = File.delete(packageDirectory .. package)
        if success then
            print("")
            print("Package '" .. package .. "' removed.")
            print("")
        else
            print("Error: Failed to remove package '" .. package .. "'")
        end

        return success
    end,

    --- Check if a package is installed locally
    --- @param package string Package name
    --- @return boolean installed
    isInstalled = function(package)
        if not package or package == "" then
            return false
        end
        return exports("Utils.File").exists(packageDirectory .. package)
    end,

    --- Get local manifest for an installed package
    --- @param package string Package name
    --- @return table|nil manifest
    getManifest = function(package)
        local File = exports("Utils.File")

        if not PackageDisk.isInstalled(package) then
            return nil
        end

        local manifestPath = packageDirectory .. package .. "/manifest.json"
        local content = File.get(manifestPath)

        if not content then
            return nil
        end

        return textutils.unserialiseJSON(content)
    end,

    --- List all installed packages
    --- @return table packages Array of package names
    listInstalled = function()
        local File = exports("Utils.File")
        local packages = File.list(packageDirectory)

        if not packages then
            return {}
        end

        -- Filter to only directories (packages)
        local result = {}
        for _, item in ipairs(packages) do
            if fs.isDir(packageDirectory .. item) then
                result[#result + 1] = item
            end
        end

        return result
    end
}

return PackageDisk
