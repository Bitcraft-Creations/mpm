--[[
    Install command: mpm install <package> [package2] ...

    Installs one or more packages from the remote registry.
]]
local installModule = nil

installModule = {
    usage = "mpm install <package> [package2] ...",

    run = function(...)
        local Validation = exports("Utils.Validation")
        local PackageDisk = exports("Utils.PackageDisk")

        local names = {...}

        if not Validation.requireAnyArg(names, installModule.usage) then
            return
        end

        local installed = 0
        local failed = 0

        for _, name in ipairs(names) do
            if Validation.isEmpty(name) then
                print("Skipping empty package name.")
                goto nextPackage
            end

            if PackageDisk.isInstalled(name) then
                print("Package '" .. name .. "' is already installed.")
                print("  Use: mpm update " .. name)
                goto nextPackage
            end

            local success = PackageDisk.install(name)
            if success then
                installed = installed + 1
            else
                failed = failed + 1
            end

            ::nextPackage::
        end

        -- Summary for multiple packages
        if #names > 1 then
            print("")
            print("Summary: " .. installed .. " installed, " .. failed .. " failed")
        end
    end
}

return installModule
