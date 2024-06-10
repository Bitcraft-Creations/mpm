local removeModule = nil

removeModule = {
    usage = "mpm remove <package>",

    run = function(package)
        if package == 'self' then
            -- Delete /mpm directory
            exports("utils.file").delete("/mpm")
            exports("utils.file").delete("/mpm.lua")

            print("\nMPM removed successfully.")
            return
        end

        exports("utils.file").delete("/mpm/packages/" .. package:gsub("/", "-") .. ".lua")
        print("\nPackage " .. package .. " removed successfully.")
    end,
}

return removeModule
