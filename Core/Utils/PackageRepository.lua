local PackageRepository

--[[
    The `PackageRepository` module contains helpers to get code from the package repository.
]]

local packageRepository = "https://shelfwood-mpm-packages.netlify.app/"

PackageRepository = {
    getPackage = function(name)
        local response = http.get(packageRepository .. name .. "/manifest.json")

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

        local content = response.readAll()
        response.close()

        if not content then
            return nil
        end

        return content
    end
}

return PackageRepository

