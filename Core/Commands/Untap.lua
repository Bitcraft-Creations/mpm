--[[
    Untap command: mpm untap <name>

    Alias for: mpm tap --remove <name>
]]
local untapModule = nil

untapModule = {
    usage = "mpm untap <name>",

    run = function(name)
        local Validation = exports("Utils.Validation")
        local TapRegistry = exports("Utils.TapRegistry")

        if Validation.isEmpty(name) then
            print("Error: Tap name required")
            print("Usage: " .. untapModule.usage)
            return
        end

        print("")
        print("Remove tap '" .. name .. "'? (y/n)")
        local confirm = read()

        if confirm:lower() ~= "y" then
            print("Cancelled.")
            return
        end

        local success, err = TapRegistry.removeTap(name)

        if success then
            print("")
            print("Tap '" .. name .. "' removed.")
            print("")
        else
            print("Error: " .. (err or "Failed to remove tap"))
        end
    end
}

return untapModule
