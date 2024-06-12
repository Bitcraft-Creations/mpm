-- This command is used to install a module: `mpm install <module_name>`
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
            if exports("Utils.ModuleDisk").isInstalled(name) then
                print("Module already installed. Did you mean `mpm update " .. name .. "`?")
                goto nextModule
            end

            installModule.installModule(name)

            ::nextModule::
        end
    end,

    installModule = function(name)
        -- Construct the path to the module's manifest.json (similar to manifest.json)
        local manifest = exports("Utils.ModuleRepository").getModule(name)
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
        local file = exports("Utils.ModuleRepository").getFile(module, package)
        exports("Utils.File").put("/mpm/Packages/" .. module .. "/" .. package, file)
    end
}

return installModule
