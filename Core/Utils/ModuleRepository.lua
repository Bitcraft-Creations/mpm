local ModuleRepository

--[[
    The `ModuleRepository` module contains helpers to get code from the module repository.
]]

local packageRepository = "https://shelfwood-mpm-packages.netlify.app/"

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
    getFile = function(module, filename)
        local response = http.get(packageRepository .. module .. "/" .. filename)

        local content = response.readAll()
        response.close()

        if not content then
            return nil
        end

        return content
    end
}

return ModuleRepository

