-- This command is used to install a package: `mpm install <package_name>`
local installModule

installModule = {
    usage = "mpm install <package> <optional:package_2> etc.",

    run = function(...)
        local names = {...}

        if #names == 0 then
            print("Please specify one or more packages to install.")
            return
        end

        for _, name in ipairs(names) do
            if exports("Utils.PackageDisk").isInstalled(name) then
                print("Package already installed. Did you mean `mpm update " .. name .. "`?")
                goto nextPackage
            end

            exports("Utils.PackageDisk").install(name)

            ::nextPackage::
        end
    end
}

return installModule
