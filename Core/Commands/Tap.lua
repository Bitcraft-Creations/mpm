--[[
    Tap command: mpm tap <source> | --list | --remove <name> | --default <name>

    Manages package repository sources (taps).

    Source formats:
    - GitHub shorthand: j-shelfwood/mpm-packages
    - GitHub URL: https://github.com/j-shelfwood/mpm-packages
    - Direct URL: https://my-packages.netlify.app/
]]
local tapModule = nil

tapModule = {
    usage = "mpm tap <source> | --list | --remove <name> | --default <name>",

    run = function(arg1, arg2)
        local Validation = exports("Utils.Validation")

        if Validation.isEmpty(arg1) then
            tapModule.showUsage()
            return
        end

        if arg1 == "--list" or arg1 == "-l" then
            tapModule.listTaps()
        elseif arg1 == "--remove" or arg1 == "-r" then
            tapModule.removeTap(arg2)
        elseif arg1 == "--default" or arg1 == "-d" then
            tapModule.setDefault(arg2)
        else
            tapModule.addTap(arg1)
        end
    end,

    showUsage = function()
        print("")
        print("Usage: " .. tapModule.usage)
        print("")
        print("Add a tap:")
        print("  mpm tap j-shelfwood/mpm-packages")
        print("  mpm tap https://my-packages.netlify.app/")
        print("")
        print("Manage taps:")
        print("  mpm tap --list              List all taps")
        print("  mpm tap --remove <name>     Remove a tap")
        print("  mpm tap --default <name>    Set default tap")
        print("")
    end,

    addTap = function(source)
        local TapRegistry = exports("Utils.TapRegistry")
        local Validation = exports("Utils.Validation")

        print("")
        print("Adding tap: " .. source)
        print("")

        -- Resolve source to tap info
        local info, err = TapRegistry.resolveSource(source)
        if not info then
            print("Error: " .. err)
            return
        end

        local url = info.url
        local name = info.name

        -- For GitHub sources, prompt for hosting URL
        if info.type == "github" and not url then
            print("GitHub repository: " .. info.github)
            print("")
            print("How are packages hosted?")
            print("")
            print("  1. Netlify (https://<name>.netlify.app/)")
            print("  2. GitHub Pages (https://<user>.github.io/<repo>/)")
            print("  3. Custom URL")
            print("")
            print("Choice (1/2/3):")
            local choice = read()

            if choice == "1" then
                print("")
                print("Enter Netlify site name:")
                local siteName = read()
                if Validation.isEmpty(siteName) then
                    print("Error: Site name required")
                    return
                end
                url = "https://" .. siteName .. ".netlify.app/"
            elseif choice == "2" then
                local user, repo = info.github:match("([^/]+)/([^/]+)")
                url = "https://" .. user .. ".github.io/" .. repo .. "/"
            elseif choice == "3" then
                print("")
                print("Enter full URL (with trailing /):")
                url = read()
                if Validation.isEmpty(url) then
                    print("Error: URL required")
                    return
                end
            else
                print("Cancelled.")
                return
            end
        end

        -- Ask for tap name if needed
        print("")
        print("Tap name (default: " .. name .. "):")
        local customName = read()
        if not Validation.isEmpty(customName) then
            name = customName
        end

        -- Add the tap
        print("")
        print("Validating tap URL...")

        local success, addErr = TapRegistry.addTap(name, url, info.type, info.github)

        if success then
            print("")
            print("Tap '" .. name .. "' added successfully!")
            print("  URL: " .. url)
            print("")
            print("Install packages with: mpm install " .. name .. "/<package>")
            print("Or set as default:     mpm tap --default " .. name)
            print("")
        else
            print("Error: " .. (addErr or "Failed to add tap"))
        end
    end,

    listTaps = function()
        local TapRegistry = exports("Utils.TapRegistry")

        local config = TapRegistry.ensureInitialized()
        local taps = config.taps
        local defaultTap = config.defaultTap

        print("")
        print("Configured taps:")
        print("")

        local count = 0
        for name, tap in pairs(taps) do
            count = count + 1
            local marker = (name == defaultTap) and " (default)" or ""

            print("  @" .. name .. marker)
            print("    URL: " .. tap.url)
            if tap.github then
                print("    GitHub: " .. tap.github)
            end
            print("    Type: " .. tap.type)
            print("")
        end

        if count == 0 then
            print("  No taps configured.")
            print("")
        end

        print("Total: " .. count .. " tap(s)")
        print("")
    end,

    removeTap = function(name)
        local TapRegistry = exports("Utils.TapRegistry")
        local Validation = exports("Utils.Validation")

        if Validation.isEmpty(name) then
            print("Error: Tap name required")
            print("Usage: mpm tap --remove <name>")
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
    end,

    setDefault = function(name)
        local TapRegistry = exports("Utils.TapRegistry")
        local Validation = exports("Utils.Validation")

        if Validation.isEmpty(name) then
            print("Error: Tap name required")
            print("Usage: mpm tap --default <name>")
            return
        end

        local success, err = TapRegistry.setDefault(name)

        if success then
            print("")
            print("Default tap set to '" .. name .. "'")
            print("")
        else
            print("Error: " .. (err or "Failed to set default"))
        end
    end
}

return tapModule
