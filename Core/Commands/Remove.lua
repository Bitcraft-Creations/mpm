local removeModule = nil

removeModule = {
    usage = "mpm remove <package>",

    run = function(package)
        if package == 'self' then
            -- Delete /mpm directory
            exports("Utils.File").delete("/mpm")
            exports("Utils.File").delete("/mpm.lua")

            print("\nMPM removed successfully.")
            return
        end

        exports("Utils.File").delete("/mpm/Packages/" .. package:gsub("/", "-") .. ".lua")
        print("\nPackage " .. package .. " removed successfully.")
    end,
}

return removeModule
