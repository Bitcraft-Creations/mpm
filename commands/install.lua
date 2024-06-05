-- This command is used to install a module: `mpm install <module_name>`
local File = dofile("/mpm/utils/file.lua")
local ModuleRepository = dofile("/mpm/utils/module_repository.lua")

local installModule

installModule = {
    usage = "mpm install <module> <optional:module_2> etc.",

    run = function(...)
        local names = {...}

        if #names == 0 then
            print("Please specify one or more modules to install.")
            return
        end

        for _, name in ipairs(names) do
            if ModuleRepository.isInstalled(name) then
                print("Module already installed. Did you mean `mpm update " .. name .. "`?")
                goto nextModule
            end

            installModule.installModule(name)

            ::nextModule::
        end
    end,

    installModule = function(name)
        -- Construct the path to the module's manifest.json (similar to manifest.json)
        local manifest = ModuleRepository.getModule(name)
        print("@" .. manifest.name)
        print(manifest.description)

        -- Install each package within the module
        for _, packageName in ipairs(manifest.modules) do
            installModule.installPackage(name, packageName)
        end

        print("Successfully installed @" .. name .. '!')
    end,

    installPackage = function(module, package)
        print("- " .. package)
        local file = ModuleRepository.getPackage(module, package)
        File.put("/mpm/packages/" .. module .. "/" .. package, file)
    end
}

return installModule
