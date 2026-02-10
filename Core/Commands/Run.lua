local runModule = nil

function mpm(package)
    local path = "/mpm/Packages/" .. package

    if not package:match("%.lua$") then
        path = path .. ".lua"
    end

    if exports("Utils.File").exists(path) then
        return dofile(path)
    end

    error("Package '" .. package .. "' not found in /mpm/Packages")
end

runModule = {
    usage = "mpm run <package>",

    run = function(package)
        local package_path = "/mpm/Packages/" .. package .. "/start.lua"

        if not exports("Utils.File").exists(package_path) then
            error("Package '" .. package .. "' not found.")
        end

        dofile(package_path)
    end
}

return runModule
