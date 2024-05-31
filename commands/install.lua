local installModule = nil
local packageRepository = "https://shelfwood-mpm-packages.netlify.app/"

installModule = {
    usage = "mpm install <package> <optional:package_2> etc.",

    run = function(...)
        local names = {...}

        if #names == 0 then
            print("Please specify one or more packages or modules to install.")
            return
        end

        for _, name in ipairs(names) do
            if string.find(name, "/") then
                print("Installing package: " .. name)
                installModule.installPackage(name)
                return
            end

            print("Installing module: " .. name)
            installModule.installModule(name)
        end
    end,

    installModule = function(moduleName)
        -- Construct the path to the module's manifest.json (similar to manifest.json)
        local moduleManifestPath = moduleName .. "/manifest.json"

        if not installModule.downloadFile(packageRepository .. "/" .. moduleManifestPath,
            "/mpm/packages/" .. moduleManifestPath) then
            print("Failed to obtain manifest for: " .. moduleName)
            return
        end

        -- Load the module's manifest
        local moduleManifest = dofile("/mpm/packages/" .. moduleManifestPath)

        -- Install each package within the module
        for _, packageName in ipairs(moduleManifest.modules) do
            installModule.installPackage(fs.combine(moduleName, packageName))
        end

        print("Successfully installed " .. moduleName)
    end,

    installPackage = function(packageName)
        local packageUrl = packageRepository .. "/" .. packageName .. ".lua"
        local moduleName = fs.getDir(packageName)
        local packagePath = "/mpm/packages/" .. packageName .. ".lua"
        local moduleIsInstalled = installModule.isComponentInstalled(moduleName)

        -- Check if package is already installed
        if installModule.isComponentInstalled(packageName) then
            print("Package already installed: " .. packageName)
            return
        end

        -- Download and install the package
        if not installModule.downloadFile(packageUrl, packagePath) then
            print("Failed to install: " .. packageName)
            return
        end

        -- Check for dependencies and install them
        local dependencies = installModule.getDependencies(moduleName)
        if moduleIsInstalled or not dependencies then
            goto continue
        end

        for _, dependency in ipairs(dependencies) do
            if string.find(dependency, "/") then
                installModule.installPackage(dependency)
            else
                installModule.installModule(dependency)
            end
        end

        ::continue::
        print("Successfully installed: " .. packageName)
    end,

    downloadFile = function(url, path)
        -- Attempt to open a connection to the given URL
        local response = http.get(url)

        -- If the connection is successful
        if response then
            -- Read the content from the response
            local content = response.readAll()
            response.close()

            -- Save the content to the specified path
            local file = fs.open(path, "w")
            file.write(content)
            file.close()

            return true -- Indicate a successful download
        end

        return false -- Indicate a failed download
    end,

    getDependencies = function(moduleName)
        local dependencies = {}

        -- Construct the path to the dependencies.txt file
        local depsPath = moduleName .. "/manifest.json"

        -- Check if the dependencies.txt file exists, if not download it
        if not fs.exists("/mpm/packages/" .. depsPath) then
            local depsUrl = packageRepository .. "/" .. depsPath
            if not installModule.downloadFile(depsUrl, "/mpm/packages/" .. depsPath) then
                return
            end

            print("Found dependencies for: " .. moduleName)
        end

        -- Read the dependencies from the file
        local file = fs.open("/mpm/packages/" .. depsPath, "r")
        local manifest = dofile("/mpm/packages/" .. depsPath)
        for _, dependency in ipairs(manifest.dependencies) do
            dependencies[#dependencies + 1] = dependency
        end
        file.close()

        return dependencies
    end,

    -- Check if package is installed
    isComponentInstalled = function(packageName)
        -- If it's a package_name (it has a / in it)
        if string.find(packageName, "/") then
            -- Check if the package is installed
            return fs.exists("/mpm/packages/" .. packageName .. ".lua")
        end

        -- Check if the module is installed
        return fs.exists("/mpm/packages/" .. packageName .. "/manifest.json")
    end
}

return installModule
