local runModule = nil

function mpm(module)
    local path = "/mpm/Packages/" .. module .. ".lua"

    if exports("Utils.File").exists(path) then
        return dofile(path)
    end

    error("Module '" .. module .. "' not found in /mpm/Packages")
end

runModule = {
    usage = "mpm run <package>",

    run = function(package)
        local package_path = "/mpm/Packages/" .. package .. ".lua"

        if not exports("Utils.File").exists(package_path) then
            error("Package '" .. package .. "' not found.")
        end

        dofile(package_path)
    end
}

return runModule
