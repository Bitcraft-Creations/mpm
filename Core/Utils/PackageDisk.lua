local PackageDisk = nil

local packageDirectory = "/mpm/Packages/"
local MANUAL = "manual"
local DEPENDENCY = "dependency"

local function manifestPath(package)
    return packageDirectory .. package .. "/manifest.json"
end

local function normalizeReason(reason)
    if reason == DEPENDENCY then
        return DEPENDENCY
    end
    return MANUAL
end

local function nowString()
    if os and os.date then
        return os.date("%Y-%m-%d %H:%M:%S")
    end
    return "unknown"
end

PackageDisk = {
    --- Install a package from a tap
    --- @param name string Package name (can be tap/package format)
    --- @param installReason string|nil "manual" or "dependency"
    --- @return boolean success
    install = function(name, installReason)
        local Validation = exports("Utils.Validation")
        local File = exports("Utils.File")
        local Repo = exports("Utils.PackageRepository")
        local LuaMinifier = exports("Utils.LuaMinifier")

        if Validation.isEmpty(name) then
            print("Error: Package name is required.")
            return false
        end

        local reason = normalizeReason(installReason)

        -- Resolve the actual package name (without tap prefix for local storage)
        local _, tapName, pkgName = Repo.resolvePackage(name)

        -- Fetch manifest from remote
        local manifest, err = Repo.getPackage(name)
        if not manifest then
            print("Error: " .. (err or "Package '" .. name .. "' not found."))
            return false
        end

        manifest._installReason = reason
        manifest._installedAt = nowString()

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
                    local depSuccess = PackageDisk.install(dep, DEPENDENCY)
                    if not depSuccess then
                        print("Error: Failed to install dependency '" .. dep .. "'")
                        return false
                    end
                end
            end
        end

        local fileContents = {}
        if manifest.files and type(manifest.files) == "table" then
            for _, file in ipairs(manifest.files) do
                local content, downloadErr = Repo.downloadFile(name, file)
                if not content then
                    print("Error: " .. (downloadErr or "Failed to download " .. file))
                    return false
                end
                if LuaMinifier and LuaMinifier.shouldMinify(file, manifest) then
                    content = LuaMinifier.minify(content)
                end
                fileContents[file] = content
            end
        end

        local path = packageDirectory .. pkgName
        local existed = fs.exists(path)
        if not existed then
            fs.makeDir(path)
        end

        if not File.put(manifestPath(pkgName), textutils.serializeJSON(manifest)) then
            print("Error: Failed to write manifest for '" .. pkgName .. "'")
            if not existed then
                File.delete(path)
            end
            return false
        end

        if manifest.files and type(manifest.files) == "table" then
            for _, file in ipairs(manifest.files) do
                local filePath = packageDirectory .. pkgName .. "/" .. file
                local success = File.put(filePath, fileContents[file])
                if success then
                    print("+ " .. file)
                else
                    print("x " .. file .. " (failed)")
                    if not existed then
                        File.delete(path)
                    end
                    return false
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
        local LuaMinifier = exports("Utils.LuaMinifier")

        local content, err = Repo.downloadFile(fullName, file)
        if not content then
            print("Error: " .. (err or "Failed to download " .. file))
            return false
        end
        if LuaMinifier and LuaMinifier.shouldMinify(file) then
            content = LuaMinifier.minify(content)
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

    --- Promote an installed package to manual
    --- @param package string
    --- @return boolean success
    markAsManual = function(package)
        return PackageDisk.setInstallReason(package, MANUAL)
    end,

    --- Set install reason metadata
    --- @param package string
    --- @param reason string
    --- @return boolean success
    setInstallReason = function(package, reason)
        local File = exports("Utils.File")
        local manifest = PackageDisk.getManifest(package)
        if not manifest then
            return false
        end

        manifest._installReason = normalizeReason(reason)
        return File.put(manifestPath(package), textutils.serializeJSON(manifest))
    end,

    --- Get install reason (defaults to manual for backward compatibility)
    --- @param package string
    --- @return string reason
    getInstallReason = function(package)
        local manifest = PackageDisk.getManifest(package)
        if not manifest or not manifest._installReason then
            return MANUAL
        end
        return normalizeReason(manifest._installReason)
    end,

    --- Resolve package dependency graph
    --- @return table graph map: pkg -> {dep=true}
    getDependencyGraph = function()
        local graph = {}
        local packages = PackageDisk.listInstalled()

        for _, pkg in ipairs(packages) do
            graph[pkg] = {}
            local manifest = PackageDisk.getManifest(pkg)
            if manifest and type(manifest.dependencies) == "table" then
                for _, dep in ipairs(manifest.dependencies) do
                    graph[pkg][dep] = true
                end
            end
        end

        return graph
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

        local content = File.get(manifestPath(package))
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
