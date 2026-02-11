--[[
    UI utility for consistent MPM branding and output formatting.
]]
local UI = {}

-- MPM ASCII Logo (compact)
UI.logo = [[
 __  __ ___ __  __
|  \/  | _ \  \/  |
| |\/| |  _/ |\/| |
|_|  |_|_| |_|  |_|]]

UI.tagline = "Minecraft Package Manager"
UI.version = "1.0.0"

--- Print the MPM logo
function UI.printLogo()
    print(UI.logo)
    print("")
end

--- Print logo with tagline
function UI.printBanner()
    print("")
    print(UI.logo)
    print(UI.tagline)
    print("")
end

--- Print a section header
--- @param title string
function UI.header(title)
    print("")
    print("=== " .. title .. " ===")
    print("")
end

--- Print a subtle divider
function UI.divider()
    print(string.rep("-", 32))
end

--- Print success message
--- @param msg string
function UI.success(msg)
    print("[+] " .. msg)
end

--- Print error message
--- @param msg string
function UI.error(msg)
    print("[!] " .. msg)
end

--- Print info message
--- @param msg string
function UI.info(msg)
    print("[*] " .. msg)
end

--- Print a list item
--- @param item string
--- @param indent number|nil
function UI.listItem(item, indent)
    local prefix = string.rep("  ", indent or 1)
    print(prefix .. "- " .. item)
end

--- Print package name with formatting
--- @param name string
--- @param tap string|nil
function UI.package(name, tap)
    if tap then
        print("  @" .. name .. " [" .. tap .. "]")
    else
        print("  @" .. name)
    end
end

--- Print a key-value pair
--- @param key string
--- @param value string
--- @param indent number|nil
function UI.keyValue(key, value, indent)
    local prefix = string.rep("  ", indent or 1)
    print(prefix .. key .. ": " .. tostring(value))
end

--- Print command hint
--- @param cmd string
--- @param desc string|nil
function UI.hint(cmd, desc)
    if desc then
        print("  " .. cmd .. "  " .. desc)
    else
        print("  " .. cmd)
    end
end

return UI
