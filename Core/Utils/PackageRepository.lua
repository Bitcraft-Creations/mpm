local PackageRepository = nil

--[[
    The PackageRepository module handles fetching packages from taps.

    Uses TapRegistry to resolve package URLs from configured taps.
    Supports tap/package syntax for explicit tap selection.
]]

PackageRepository = {
    --- Get base URL for a package (resolves tap)
    --- @param packageName string Package name (can be tap/package format)
    --- @return string url, string tapName, string pkgName
    resolvePackage = function(packageName)
        local TapRegistry = exports("Utils.TapRegistry")
        return TapRegistry.resolvePackageUrl(packageName)
    end,

    --- Get the default tap's base URL
    --- @return string
    getBaseUrl = function()
        local TapRegistry = exports("Utils.TapRegistry")
        local defaultTap = TapRegistry.getDefault()
        return defaultTap.url
    end,

    --- Fetch package manifest from appropriate tap
    --- @param name string Package name (can be tap/package format)
    --- @return table|nil manifest, string|nil error, string|nil tapName
    getPackage = function(name)
        local Validation = exports("Utils.Validation")

        if Validation.isEmpty(name) then
            return nil, "Package name is required", nil
        end

        local baseUrl, tapName, pkgName = PackageRepository.resolvePackage(name)
        local url = baseUrl .. pkgName .. "/manifest.json"

        local response, err = Validation.safeHttpGet(url)

        if not response then
            return nil, "Failed to fetch package '" .. pkgName .. "' from tap '" .. tapName .. "'", tapName
        end

        local content = Validation.readResponse(response)
        if not content then
            return nil, "Failed to read manifest for package '" .. pkgName .. "'", tapName
        end

        local manifest = textutils.unserialiseJSON(content)
        if not manifest then
            return nil, "Failed to parse manifest for package '" .. pkgName .. "'", tapName
        end

        -- Store tap info in manifest for tracking
        manifest._tap = tapName
        manifest._tapUrl = baseUrl

        return manifest, nil, tapName
    end,

    --- Download a specific file from a package
    --- @param packageName string Package name (can be tap/package format)
    --- @param filename string File path within package
    --- @return string|nil content, string|nil error
    downloadFile = function(packageName, filename)
        local Validation = exports("Utils.Validation")

        if Validation.isEmpty(packageName) then
            return nil, "Package name is required"
        end

        if Validation.isEmpty(filename) then
            return nil, "Filename is required"
        end

        local baseUrl, tapName, pkgName = PackageRepository.resolvePackage(packageName)
        local url = baseUrl .. pkgName .. "/" .. filename

        local response, err = Validation.safeHttpGet(url)

        if not response then
            return nil, "Failed to download '" .. filename .. "' from '" .. pkgName .. "'"
        end

        local content = Validation.readResponse(response)
        if not content then
            return nil, "Failed to read file content"
        end

        return content, nil
    end,

    --- List all available packages from a tap
    --- @param tapName string|nil Tap name (uses default if nil)
    --- @return table|nil packages, string|nil error
    listPackages = function(tapName)
        local Validation = exports("Utils.Validation")
        local TapRegistry = exports("Utils.TapRegistry")

        local tap
        if tapName then
            tap = TapRegistry.getTap(tapName)
            if not tap then
                return nil, "Tap '" .. tapName .. "' not found"
            end
        else
            tap = TapRegistry.getDefault()
        end

        local url = tap.url .. "index.json"

        local response, err = Validation.safeHttpGet(url)
        if not response then
            return nil, "Failed to fetch package index from '" .. tap.name .. "'"
        end

        local content = Validation.readResponse(response)
        if not content then
            return nil, "Failed to read package index"
        end

        local index = textutils.unserialiseJSON(content)
        if not index then
            return nil, "Failed to parse package index"
        end

        return index, nil
    end,

    --- List packages from all configured taps
    --- @return table packages {tapName = {packages}}
    listAllPackages = function()
        local TapRegistry = exports("Utils.TapRegistry")
        local taps = TapRegistry.getTaps()
        local result = {}

        for tapName, _ in pairs(taps) do
            local packages, err = PackageRepository.listPackages(tapName)
            if packages then
                result[tapName] = packages
            else
                result[tapName] = {_error = err}
            end
        end

        return result
    end,

    --- Check if a package exists in any tap
    --- @param name string Package name
    --- @return boolean exists, string|nil tapName
    packageExists = function(name)
        local manifest, _, tapName = PackageRepository.getPackage(name)
        if manifest then
            return true, tapName
        end
        return false, nil
    end
}

return PackageRepository
