--[[
    Remove command: mpm remove <package> [package2] ...

    Removes one or more installed packages.
]]
local removeModule = nil

removeModule = {
    usage = "mpm remove <package> [package2] ...",

    run = function(...)
        local Validation = exports("Utils.Validation")
        local PackageDisk = exports("Utils.PackageDisk")

        local packages = {...}

        if not Validation.requireAnyArg(packages, removeModule.usage) then
            return
        end

        local removed = 0
        local failed = 0

        for _, package in ipairs(packages) do
            if Validation.isEmpty(package) then
                print("Skipping empty package name.")
                goto nextPackage
            end

            if not PackageDisk.isInstalled(package) then
                print("Package '" .. package .. "' is not installed.")
                failed = failed + 1
                goto nextPackage
            end

            local success = PackageDisk.remove(package)
            if success then
                removed = removed + 1
            else
                failed = failed + 1
            end

            ::nextPackage::
        end

        -- Summary for multiple packages
        if #packages > 1 then
            print("")
            print("Summary: " .. removed .. " removed, " .. failed .. " failed")
        end
    end
}

return removeModule
