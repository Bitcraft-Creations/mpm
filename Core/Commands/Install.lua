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
        local Storage = exports("Utils.Storage")

        local names = {...}

        if not Validation.requireAnyArg(names, installModule.usage) then
            return
        end

        local hasSpace, spaceErr = Storage.ensureCriticalFree(8 * 1024, "/")
        if not hasSpace then
            print("Error: " .. (spaceErr or "Insufficient disk space"))
            return
        end
        Storage.warnIfLow("/")

        local installed = 0
        local failed = 0

        for _, name in ipairs(names) do
            if Validation.isEmpty(name) then
                print("Skipping empty package name.")
                goto nextPackage
            end

            if PackageDisk.isInstalled(name) then
                print("Package '" .. name .. "' is already installed.")
                local reason = PackageDisk.getInstallReason(name)
                if reason ~= "manual" then
                    PackageDisk.markAsManual(name)
                    print("  Marked as manually installed.")
                else
                    print("  Use: mpm update " .. name)
                end
                goto nextPackage
            end

            local success = PackageDisk.install(name, "manual")
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
