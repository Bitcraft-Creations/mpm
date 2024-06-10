local runModule = nil

function mpm(module)
    local path = "/mpm/packages/" .. module .. ".lua"

    if exports("utils.file").exists(path) then
        return dofile(path)
    end

    error("Module '" .. module .. "' not found in /mpm/packages")
end

runModule = {
    usage = "mpm run <package>",

    run = function(package)
        local package_path = "/mpm/packages/" .. package .. ".lua"

        if not exports("utils.file").exists(package_path) then
            error("Package '" .. package .. "' not found.")
        end

        dofile(package_path)
    end
}

return runModule