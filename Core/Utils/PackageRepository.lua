local PackageRepository

--[[
    The `PackageRepository` module contains helpers to get code from the package repository.
]]

local packageRepository = "https://shelfwood-mpm-packages.netlify.app/"

PackageRepository = {
    getPackage = function(name)
        local response = http.get(packageRepository .. name .. "/manifest.json")
        if not response then
            print("Error: Unable to fetch manifest for package " .. name)
            return nil
        end

        local content = response.readAll()
        response.close()

        if not content then
            return nil
        end

        local manifest = textutils.unserialiseJSON(content)

        return manifest
    end,
    downloadFile = function(package, filename)
        local response = http.get(packageRepository .. package .. "/" .. filename)
        if not response then
            print("Error: Unable to fetch file " .. filename .. " for package " .. package)
            return nil
        end

        local content = response.readAll()
        response.close()

        if not content then
            return nil
        end

        return content
    end
}

return PackageRepository
