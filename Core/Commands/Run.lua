local runModule = nil

-- Module cache for mpm() to ensure singleton behavior
-- Without caching, each mpm() call returns a NEW table instance,
-- breaking module-level state (like RemotePeripheral.setClient())
local mpmCache = {}

--- Global mpm() function for package dependencies within running scripts
--- @param package string Package path to load (e.g., "peripherals/AEInterface")
--- @return any The loaded module
function mpm(package)
    local Validation = exports("Utils.Validation")

    if Validation.isEmpty(package) then
        error("mpm() requires a package name")
    end

    -- Check cache first (ensures singleton modules)
    if mpmCache[package] then
        return mpmCache[package]
    end

    local path = "/mpm/Packages/" .. package

    if not package:match("%.lua$") then
        path = path .. ".lua"
    end

    if exports("Utils.File").exists(path) then
        local result = dofile(path)
        mpmCache[package] = result
        return result
    end

    error("Package '" .. package .. "' not found in /mpm/Packages")
end

--- Clear the mpm cache (for hot-reloading during development)
function mpmClearCache(package)
    if package then
        mpmCache[package] = nil
    else
        mpmCache = {}
    end
end

runModule = {
    usage = "mpm run <package> [args...]",

    run = function(package, ...)
        local Validation = exports("Utils.Validation")

        if not Validation.requireArg(package, "<package>", runModule.usage) then
            return
        end

        -- Support both "package" and "package/script" formats
        local package_path

        if package:find("/") then
            -- Direct script path: mpm run tools/inspect_peripheral
            package_path = "/mpm/Packages/" .. package .. ".lua"
        else
            -- Package entry point: mpm run mypackage -> start.lua
            package_path = "/mpm/Packages/" .. package .. "/start.lua"
        end

        if not exports("Utils.File").exists(package_path) then
            -- Try without .lua extension for direct file references
            local alt_path = "/mpm/Packages/" .. package
            if exports("Utils.File").exists(alt_path) then
                package_path = alt_path
            else
                print("Error: Package '" .. package .. "' not found.")
                print("Tried: " .. package_path)
                print("\nInstalled packages:")
                local files = exports("Utils.File").list("/mpm/Packages/")
                if files and #files > 0 then
                    for _, file in ipairs(files) do
                        print("  - " .. file)
                    end
                else
                    print("  (none)")
                end
                return
            end
        end

        -- Load and run script with arguments
        -- We use loadfile + custom environment to pass args while preserving mpm()
        local args = {...}

        local fn, err = loadfile(package_path)
        if not fn then
            print("Error loading package: " .. tostring(err))
            return
        end

        -- Create environment with mpm function and standard globals
        local env = setmetatable({
            mpm = mpm,
            exports = exports
        }, { __index = _G })

        setfenv(fn, env)

        -- Run with arguments
        fn(table.unpack(args))
    end
}

return runModule
