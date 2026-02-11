--[[
    The Validation module provides centralized argument validation utilities.
    All commands should use these to ensure consistent error handling.
]]
local Validation = {}

--- Check if a value is nil or empty string
--- @param value any
--- @return boolean
function Validation.isEmpty(value)
    return value == nil or value == ""
end

--- Validate required argument exists
--- @param value any
--- @param argName string
--- @param usage string
--- @return boolean success
function Validation.requireArg(value, argName, usage)
    if Validation.isEmpty(value) then
        print("Error: Missing required argument: " .. argName)
        if usage then
            print("Usage: " .. usage)
        end
        return false
    end
    return true
end

--- Validate at least one argument provided
--- @param args table
--- @param usage string
--- @return boolean success
function Validation.requireAnyArg(args, usage)
    if not args or #args == 0 then
        print("Error: At least one argument is required.")
        if usage then
            print("Usage: " .. usage)
        end
        return false
    end
    return true
end

--- Validate HTTP response is valid
--- @param response table|nil
--- @param url string
--- @return boolean success
function Validation.requireResponse(response, url)
    if not response then
        print("Error: Failed to fetch: " .. (url or "unknown URL"))
        return false
    end
    return true
end

--- Validate package exists locally
--- @param package string
--- @return boolean success
function Validation.requireInstalledPackage(package)
    if Validation.isEmpty(package) then
        print("Error: Package name required.")
        return false
    end

    local packagePath = "/mpm/Packages/" .. package
    if not fs.exists(packagePath) then
        print("Error: Package '" .. package .. "' is not installed.")
        return false
    end
    return true
end

--- Safe HTTP GET with error handling
--- @param url string
--- @return table|nil response, string|nil error
function Validation.safeHttpGet(url)
    local success, response = pcall(http.get, url)
    if not success then
        return nil, "HTTP request failed: " .. tostring(response)
    end
    if not response then
        return nil, "No response from server"
    end
    return response, nil
end

--- Read and close HTTP response safely
--- @param response table
--- @return string|nil content
function Validation.readResponse(response)
    if not response then
        return nil
    end

    local success, content = pcall(function()
        local data = response.readAll()
        response.close()
        return data
    end)

    if not success then
        pcall(function() response.close() end)
        return nil
    end

    return content
end

return Validation
