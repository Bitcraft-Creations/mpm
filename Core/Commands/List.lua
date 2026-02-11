--[[
    List command: mpm list [local|remote]

    Lists installed packages (default) or available remote packages.
]]
local listModule = nil

listModule = {
    usage = "mpm list [local|remote]",

    run = function(source)
        local Validation = exports("Utils.Validation")
        local PackageDisk = exports("Utils.PackageDisk")
        local Repo = exports("Utils.PackageRepository")

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
            print("  remote - List available packages from registry")
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
            print("View available: mpm list remote")
            print("")
            return
        end

        print("Installed packages:")
        print("")

        for _, pkg in ipairs(packages) do
            local manifest = PackageDisk.getManifest(pkg)
            if manifest and manifest.description then
                print("  @" .. pkg)
                print("    " .. manifest.description)
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

        print("")
        print("Fetching package index...")

        local packages, err = Repo.listPackages()

        if not packages then
            print("Error: " .. (err or "Failed to fetch package index"))
            print("")
            print("The package registry may not have an index.json file.")
            print("Try installing a known package: mpm install <package>")
            print("")
            return
        end

        print("")
        print("Available packages:")
        print("")

        if type(packages) == "table" then
            -- Handle array of package names
            if #packages > 0 then
                for _, pkg in ipairs(packages) do
                    if type(pkg) == "string" then
                        print("  @" .. pkg)
                    elseif type(pkg) == "table" and pkg.name then
                        print("  @" .. pkg.name)
                        if pkg.description then
                            print("    " .. pkg.description)
                        end
                    end
                end
            else
                -- Handle object with package names as keys
                for name, info in pairs(packages) do
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
        print("Install with: mpm install <package>")
        print("")
    end
}

return listModule
