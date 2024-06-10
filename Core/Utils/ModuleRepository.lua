-- The `ModuleRepository` module contains helpers to get code from the module repository.
local File = dofile("/mpm/utils/file.lua")
local packageRepository = "https://shelfwood-mpm-packages.netlify.app/"

local ModuleRepository

ModuleRepository = {
    getModule = function(name)
        local response = http.get(packageRepository .. name .. "/manifest.json")

        local content = response.readAll()
        response.close()

        if not content then
            return nil
        end

        local manifest = textutils.unserialiseJSON(content)

        return manifest
    end,
    getPackage = function(module, package)
        local response = http.get(packageRepository .. module .. "/" .. package)

        local content = response.readAll()
        response.close()

        if not content then
            return nil
        end

        return content
    end,
    isInstalled = function(module)
        return File.exists("/mpm/packages/" .. module)
    end
}

return ModuleRepository

