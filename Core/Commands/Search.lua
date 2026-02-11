--[[
    Search command: mpm search <query>

    Search packages by name or description across all taps.
]]
local searchModule = nil

searchModule = {
    usage = "mpm search <query>",

    run = function(query)
        local Validation = exports("Utils.Validation")
        local Repo = exports("Utils.PackageRepository")
        local TapRegistry = exports("Utils.TapRegistry")

        if Validation.isEmpty(query) then
            print("")
            print("Usage: " .. searchModule.usage)
            print("")
            print("Examples:")
            print("  mpm search display")
            print("  mpm search ae2")
            print("")
            return
        end

        query = query:lower()

        print("")
        print("Searching for '" .. query .. "'...")
        print("")

        local allPkgs = Repo.listAllPackages()
        local results = {}
        local total = 0

        for tapName, packages in pairs(allPkgs) do
            if not packages._error and type(packages) == "table" then
                for _, pkg in ipairs(packages) do
                    local name = type(pkg) == "table" and pkg.name or pkg
                    local desc = type(pkg) == "table" and (pkg.description or "") or ""

                    -- Search in name and description
                    if name:lower():find(query, 1, true) or desc:lower():find(query, 1, true) then
                        if not results[tapName] then
                            results[tapName] = {}
                        end
                        table.insert(results[tapName], {name = name, description = desc})
                        total = total + 1
                    end
                end
            end
        end

        if total == 0 then
            print("No packages found matching '" .. query .. "'")
            print("")
            print("Try:")
            print("  mpm list remote    See all packages")
            print("  mpm search <term>  Different search term")
            print("")
            return
        end

        for tapName, packages in pairs(results) do
            local def = TapRegistry.getDefault()
            local marker = (def.name == tapName) and " (default)" or ""
            print("[" .. tapName .. "]" .. marker)

            for _, pkg in ipairs(packages) do
                print("  @" .. pkg.name)
                if pkg.description ~= "" then
                    print("    " .. pkg.description)
                end
            end
            print("")
        end

        print("Found: " .. total .. " package(s)")
        print("")
        print("Install with: mpm install <package>")
        print("")
    end
}

return searchModule
