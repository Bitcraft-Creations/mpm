local removeModule = nil

removeModule = {
    usage = "mpm remove <package> <optional:package_2> etc.",

    run = function(...)
        local packages = {...}

        if #packages == 0 then
            print("Please specify one or more packages to remove.")
            return
        end

        for _, package in ipairs(packages) do
            if not exports("Utils.PackageDisk").isInstalled(package) then
                print("Package " .. package .. " is not installed.")
                goto nextPackage
            end

            exports("Utils.PackageDisk").remove(package)

            ::nextPackage::
        end
    end
}

return removeModule
