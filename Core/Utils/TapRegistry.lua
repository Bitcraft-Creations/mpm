--[[
    TapRegistry - Manages package repository sources (taps).

    Taps are stored in /mpm/taps.json and allow users to add
    custom package repositories beyond the official registry.

    Supported source formats:
    - GitHub shorthand: "user/repo"
    - GitHub URL: "https://github.com/user/repo"
    - Direct URL: "https://packages.example.com/"
]]
local TapRegistry = nil

local CONFIG_PATH = "/mpm/taps.json"
local CONFIG_VERSION = 1

TapRegistry = {
    --- Load taps configuration
    --- @return table config
    loadConfig = function()
        local File = exports("Utils.File")
        local content = File.get(CONFIG_PATH)

        if not content then
            return nil
        end

        return textutils.unserialiseJSON(content)
    end,

    --- Save taps configuration
    --- @param config table
    --- @return boolean success
    saveConfig = function(config)
        local File = exports("Utils.File")
        config.version = CONFIG_VERSION
        return File.put(CONFIG_PATH, textutils.serializeJSON(config))
    end,

    --- Initialize taps config if not exists
    --- @return table config
    ensureInitialized = function()
        local config = TapRegistry.loadConfig()

        if config then
            return config
        end

        -- Create default config with official tap
        config = {
            version = CONFIG_VERSION,
            defaultTap = "official",
            taps = {
                official = {
                    name = "official",
                    url = "https://shelfwood-mpm-packages.netlify.app/",
                    type = "direct",
                    description = "Official MPM package repository"
                }
            }
        }

        TapRegistry.saveConfig(config)
        return config
    end,

    --- Get all configured taps
    --- @return table taps
    getTaps = function()
        local config = TapRegistry.ensureInitialized()
        return config.taps or {}
    end,

    --- Get a specific tap by name
    --- @param name string
    --- @return table|nil tap
    getTap = function(name)
        local taps = TapRegistry.getTaps()
        return taps[name]
    end,

    --- Get the default tap
    --- @return table tap
    getDefault = function()
        local config = TapRegistry.ensureInitialized()
        local defaultName = config.defaultTap or "official"
        return config.taps[defaultName]
    end,

    --- Set the default tap
    --- @param name string
    --- @return boolean success, string|nil error
    setDefault = function(name)
        local config = TapRegistry.ensureInitialized()

        if not config.taps[name] then
            return false, "Tap '" .. name .. "' does not exist"
        end

        config.defaultTap = name
        TapRegistry.saveConfig(config)
        return true, nil
    end,

    --- Resolve source string to tap info
    --- @param source string
    --- @return table|nil info, string|nil error
    resolveSource = function(source)
        -- Pattern: user/repo (GitHub shorthand)
        if source:match("^[%w%-_%.]+/[%w%-_%.]+$") then
            local user = source:match("^([%w%-_%.]+)/")
            return {
                name = user,
                github = source,
                type = "github",
                url = nil  -- Will need to prompt
            }, nil
        end

        -- Pattern: https://github.com/user/repo
        if source:match("^https?://github%.com/") then
            local user, repo = source:match("github%.com/([%w%-_%.]+)/([%w%-_%.]+)")
            if user and repo then
                return {
                    name = user,
                    github = user .. "/" .. repo,
                    type = "github",
                    url = nil  -- Will need to prompt
                }, nil
            end
        end

        -- Pattern: Direct URL (must end with / or we add it)
        if source:match("^https?://") then
            local url = source
            if not url:match("/$") then
                url = url .. "/"
            end

            -- Extract name from URL
            local name = source:match("://([%w%-_]+)") or
                         source:match("://[%w%-_]+%.([%w%-_]+)") or
                         "custom"

            return {
                name = name,
                url = url,
                type = "direct"
            }, nil
        end

        return nil, "Invalid source format. Use: user/repo, https://github.com/user/repo, or https://url/"
    end,

    --- Add a new tap
    --- @param name string Tap name
    --- @param url string Package URL
    --- @param tapType string "github" or "direct"
    --- @param github string|nil GitHub repo (for github type)
    --- @return boolean success, string|nil error
    addTap = function(name, url, tapType, github)
        local Validation = exports("Utils.Validation")

        if Validation.isEmpty(name) then
            return false, "Tap name is required"
        end

        if Validation.isEmpty(url) then
            return false, "URL is required"
        end

        -- Ensure URL ends with /
        if not url:match("/$") then
            url = url .. "/"
        end

        local config = TapRegistry.ensureInitialized()

        -- Check if tap already exists
        if config.taps[name] then
            return false, "Tap '" .. name .. "' already exists"
        end

        -- Validate URL is reachable
        local testUrl = url .. "index.json"
        local response, err = Validation.safeHttpGet(testUrl)

        if not response then
            -- Try without index.json - just check base URL
            response, err = Validation.safeHttpGet(url)
            if not response then
                return false, "Cannot reach tap URL: " .. url
            end
            Validation.readResponse(response)
        else
            Validation.readResponse(response)
        end

        -- Add tap
        config.taps[name] = {
            name = name,
            url = url,
            type = tapType or "direct",
            github = github
        }

        TapRegistry.saveConfig(config)
        return true, nil
    end,

    --- Remove a tap
    --- @param name string
    --- @return boolean success, string|nil error
    removeTap = function(name)
        local config = TapRegistry.ensureInitialized()

        if not config.taps[name] then
            return false, "Tap '" .. name .. "' does not exist"
        end

        if name == "official" then
            return false, "Cannot remove the official tap"
        end

        if config.defaultTap == name then
            config.defaultTap = "official"
        end

        config.taps[name] = nil
        TapRegistry.saveConfig(config)
        return true, nil
    end,

    --- Get package URL for a given package name
    --- Handles tap/package syntax
    --- @param packageName string
    --- @return string url, string tapName, string pkgName
    resolvePackageUrl = function(packageName)
        local tapName, pkgName = packageName:match("^([%w%-_%.]+)/(.+)$")

        -- Check if it's tap/package format
        if tapName then
            local tap = TapRegistry.getTap(tapName)
            if tap then
                return tap.url, tapName, pkgName
            end
            -- Not a tap name, treat whole thing as package name
        end

        -- Use default tap
        local defaultTap = TapRegistry.getDefault()
        return defaultTap.url, defaultTap.name, packageName
    end,

    --- Check if taps config exists
    --- @return boolean exists
    isInitialized = function()
        local File = exports("Utils.File")
        return File.exists(CONFIG_PATH)
    end
}

return TapRegistry
