--[[
    List command: mpm list [local|remote]

    Lists installed packages (default) or available remote packages from all taps.
]]
local listModule = nil

listModule = {
    usage = "mpm list [local|remote]",

    run = function(source)
        source = source or "local"
        source = source:lower()

        if source == "remote" then
            listModule.listRemote()
        elseif source == "local" then
            listModule.listLocal()
        else
            print("Error: Unknown source '" .. source .. "'")
            print("Usage: " .. listModule.usage)
            print("  local  - List installed packages (default)")
            print("  remote - List available packages from all taps")
        end
    end,

    listLocal = function()
        local PackageDisk = exports("Utils.PackageDisk")

        local packages = PackageDisk.listInstalled()

        print("")
        if #packages == 0 then
            print("No packages installed.")
            print("")
            print("Install packages with: mpm install <package>")
            print("View available:        mpm list remote")
            print("")
            return
        end

        print("Installed packages:")
        print("")

        for _, pkg in ipairs(packages) do
            local manifest = PackageDisk.getManifest(pkg)
            local tapInfo = ""

            if manifest then
                if manifest._tap then
                    tapInfo = " [" .. manifest._tap .. "]"
                end

                if manifest.description then
                    print("  @" .. pkg .. tapInfo)
                    print("    " .. manifest.description)
                else
                    print("  @" .. pkg .. tapInfo)
                end
            else
                print("  @" .. pkg)
            end
        end

        print("")
        print("Total: " .. #packages .. " package(s)")
        print("")
    end,

    listRemote = function()
        local Repo = exports("Utils.PackageRepository")
        local TapRegistry = exports("Utils.TapRegistry")

        print("")
        print("Fetching package lists...")

        local allPackages = Repo.listAllPackages()
        local totalPackages = 0
        local tapCount = 0

        print("")
        print("Available packages:")
        print("")

        for tapName, packages in pairs(allPackages) do
            tapCount = tapCount + 1

            -- Check for errors
            if packages._error then
                print("[" .. tapName .. "] (error: " .. packages._error .. ")")
                print("")
            elseif type(packages) == "table" then
                local tap = TapRegistry.getTap(tapName)
                local isDefault = (TapRegistry.getDefault().name == tapName)
                local marker = isDefault and " (default)" or ""

                print("[" .. tapName .. "]" .. marker)

                -- Handle array of packages
                if #packages > 0 then
                    for _, pkg in ipairs(packages) do
                        totalPackages = totalPackages + 1
                        if type(pkg) == "string" then
                            print("  @" .. pkg)
                        elseif type(pkg) == "table" then
                            local name = pkg.name or pkg[1] or "unknown"
                            print("  @" .. name)
                            if pkg.description then
                                print("    " .. pkg.description)
                            end
                        end
                    end
                else
                    -- Handle object with package names as keys
                    for name, info in pairs(packages) do
                        if name ~= "_error" then
                            totalPackages = totalPackages + 1
                            if type(info) == "table" then
                                print("  @" .. name)
                                if info.description then
                                    print("    " .. info.description)
                                end
                            else
                                print("  @" .. name)
                            end
                        end
                    end
                end
                print("")
            end
        end

        if totalPackages == 0 then
            print("No packages found in any tap.")
            print("")
            print("Add a tap with: mpm tap <source>")
        else
            print("Total: " .. totalPackages .. " package(s) from " .. tapCount .. " tap(s)")
        end

        print("")
        print("Install with: mpm install <package>")
        print("From tap:     mpm install <tap>/<package>")
        print("")
    end
}

return listModule
