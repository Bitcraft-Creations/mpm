local PackageRepository = nil

--[[
    The PackageRepository module handles fetching packages from the remote registry.
]]

local packageRepositoryUrl = "https://shelfwood-mpm-packages.netlify.app/"

PackageRepository = {
    --- Get the repository base URL
    --- @return string
    getBaseUrl = function()
        return packageRepositoryUrl
    end,

    --- Fetch package manifest from registry
    --- @param name string Package name
    --- @return table|nil manifest, string|nil error
    getPackage = function(name)
        local Validation = exports("Utils.Validation")

        if Validation.isEmpty(name) then
            return nil, "Package name is required"
        end

        local url = packageRepositoryUrl .. name .. "/manifest.json"
        local response, err = Validation.safeHttpGet(url)

        if not response then
            return nil, "Failed to fetch package '" .. name .. "': " .. (err or "unknown error")
        end

        local content = Validation.readResponse(response)
        if not content then
            return nil, "Failed to read manifest for package '" .. name .. "'"
        end

        local manifest = textutils.unserialiseJSON(content)
        if not manifest then
            return nil, "Failed to parse manifest for package '" .. name .. "'"
        end

        return manifest, nil
    end,

    --- Download a specific file from a package
    --- @param package string Package name
    --- @param filename string File path within package
    --- @return string|nil content, string|nil error
    downloadFile = function(package, filename)
        local Validation = exports("Utils.Validation")

        if Validation.isEmpty(package) then
            return nil, "Package name is required"
        end

        if Validation.isEmpty(filename) then
            return nil, "Filename is required"
        end

        local url = packageRepositoryUrl .. package .. "/" .. filename
        local response, err = Validation.safeHttpGet(url)

        if not response then
            return nil, "Failed to download '" .. filename .. "' from '" .. package .. "'"
        end

        local content = Validation.readResponse(response)
        if not content then
            return nil, "Failed to read file content"
        end

        return content, nil
    end,

    --- List all available packages from registry
    --- @return table|nil packages, string|nil error
    listPackages = function()
        local Validation = exports("Utils.Validation")
        local url = packageRepositoryUrl .. "index.json"

        local response, err = Validation.safeHttpGet(url)
        if not response then
            return nil, "Failed to fetch package index: " .. (err or "unknown error")
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

    --- Check if a package exists in the registry
    --- @param name string Package name
    --- @return boolean exists
    packageExists = function(name)
        local manifest, _ = PackageRepository.getPackage(name)
        return manifest ~= nil
    end
}

return PackageRepository
