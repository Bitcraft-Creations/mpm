local runModule = nil

runModule = {
    usage = "mpm remove <package>",

    run = function(package)
        local package_path = "/mpm/packages/" .. package .. ".lua"
        
        if not fs.exists(package_path) then
            error("Package '" .. package .. "' not found.")
        end
    
        dofile(package_path)
    end,
}

return runModule