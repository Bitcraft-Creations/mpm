local installModule = nil
local packageRepository = "https://shelfwood-mpm-packages.netlify.app/"

installModule = {
    usage = "mpm install <module> <optional:module_2> etc.",

    run = function(...)
        local names = {...}

        if #names == 0 then
            print("Please specify one or more modules to install.")
            return
        end

        for _, name in ipairs(names) do
            print("Installing module: " .. name)
            installModule.installModule(name)
        end
    end,

    installModule = function(moduleName)
        -- Construct the path to the module's manifest.json (similar to manifest.json)
        local moduleManifest = textutils.unserialiseJSON(http.get(packageRepository .. moduleName .. "/manifest.json")
                                                             .readAll())

        -- Install each package within the module
        for _, packageName in ipairs(moduleManifest.modules) do
            installModule.installModule(fs.combine(moduleName, packageName))
        end

        print("Successfully installed " .. moduleName)
    end,

    downloadFile = function(url, path)
        -- Attempt to open a connection to the given URL
        local response = http.get(url)

        if not response then
            return false
        end

        local content = response.readAll()
        response.close()

        -- Save the content to the specified path
        local file = fs.open(path, "w")
        file.write(content)
        file.close()

        return true
    end,

    -- Check if module is installed
    isModuleInstalled = function(moduleName)
        return fs.exists("/mpm/packages/" .. moduleName .. ".lua")
    end
}

return installModule
