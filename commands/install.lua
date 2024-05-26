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

    installPackage = function(packageName)
        local packageURL = packageRepository .. "/" .. packageName .. ".lua"
        local moduleName = fs.getName(packageName)
        local packagePath = "/mpm/packages/" .. packageName .. ".lua"
        local moduleIsInstalled = installModule.isComponentInstalled(packageName)

        if moduleIsInstalled then
            print("Package already installed: " .. packageName)
            return
        end

        if not installModule.downloadFile(packageURL, packagePath) then
            print("Failed to install: " .. packageName)
            return
        end

        local dependencies = getDependencies(packageName)

        if dependencies then
            for _, dependency in ipairs(dependencies) do
                if string.find(dependency, "/") then
                    installModule.installPackage(dependency)
                else
                    installModule.installModule(dependency)
                end
            end
        end

        print("Successfully installed: " .. packageName)
    end,

    installModule = function(moduleName)
        -- Construct the path to the module's file list (similar to filelist.lua)
        local moduleFilelistPath = moduleName .. "/filelist.lua"

        if not installModule.downloadFile(packageRepository .. "/" .. moduleFilelistPath,
            "/mpm/packages/" .. moduleFilelistPath) then
            print("Failed to obtain file list for: " .. moduleName)
            return
        end

        -- Load the module's filelist
        local moduleFilelist = dofile("/mpm/packages/" .. moduleFilelistPath)

        -- Install each package within the module
        for _, packageName in ipairs(moduleFilelist) do
            installPackage(fs.combine(moduleName, packageName))
        end
        
        print("Successfully installed " .. moduleName)
    end,

    installPackage = function(packageName)
        local packageUrl = packageRepository .. "/" .. packageName .. ".lua"
        local moduleName = fs.getDir(packageName)
        local packagePath = "/mpm/packages/" .. packageName .. ".lua"
        local moduleIsInstalled = isComponentInstalled(moduleName)
    
        -- Check if package is already installed
        if isComponentInstalled(packageName) then
            print("Package already installed: " .. packageName)
            return
        end
    
        -- Download and install the package
        if not installModule.downloadFile(packageUrl, packagePath) then
            print("Failed to install: " .. packageName)
            return
        end

        -- Check for dependencies and install them
        local dependencies = getDependencies(moduleName)
        if moduleIsInstalled or not dependencies then
            goto continue
        end

        for _, dependency in ipairs(dependencies) do
            if string.find(dependency, "/") then
                installPackage(dependency)
            else
                installModule(dependency)
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
        local depsPath = moduleName .. "/dependencies.txt"
    
        -- Check if the dependencies.txt file exists, if not download it
        if not fs.exists("/mpm/packages/" .. depsPath) then
            local depsUrl = packageRepository .. "/" .. depsPath
            if not Core.downloadFile(depsUrl, "/mpm/packages/" .. depsPath) then
                return
            end
            
            print("Found dependencies for: " .. moduleName)
        end
    
        -- Read the dependencies from the file
        local file = fs.open("/mpm/packages/" .. depsPath, "r")
        for line in file.readLine do
            dependencies[#dependencies+1] = line
        end
        file.close()
    
        return dependencies
    end,

    -- Check if package is installed
    isComponentInstalled(packageName)
        -- If it's a package_name (it has a / in it)
        if string.find(packageName, "/") then
            -- Check if the package is installed
            return fs.exists("/mpm/packages/" .. packageName .. ".lua")
        end

        -- Check if the module is installed
        return fs.exists("/mpm/packages/" .. packageName .. "/filelist.lua")
    end,
}

return installModule