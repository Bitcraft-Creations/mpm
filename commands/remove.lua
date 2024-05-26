local removeModule = nil

removeModule = {
    usage = "mpm remove <package>",

    run = function(package)
        if package == 'self' then
            -- Delete /mpm directory
            fs.delete("/mpm")
            fs.delete("/mpm.lua")
    
            print("\nMPM removed successfully.")
            return
        end
    
        fs.delete("/mpm/packages/" .. package:gsub("/", "-") .. ".lua")
        print("\nPackage " .. package .. " removed successfully.")
    end,
}

return removeModule