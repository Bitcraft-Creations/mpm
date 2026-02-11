local selfUpdateModule = nil
local repositoryUrl = "https://shelfwood-mpm.netlify.app/"

--[[
    This module is responsible for updating MPM itself.

    Update Logic:
    1. Fetch manifest.json from repository
    2. For each file in manifest:
       a. Download remote version
       b. Compare with local version (byte-by-byte)
       c. Update if different OR if local file missing
    3. Handle mpm.lua specially (lives in root, not /mpm/)
    4. Regenerate startup.lua from startup.config if configured
]]
selfUpdateModule = {
    usage = "mpm selfupdate",

    run = function()
        local Validation = exports("Utils.Validation")

        print("Checking for updates to MPM...")

        local manifest, err = selfUpdateModule.getManifest()
        if not manifest then
            print("Error: " .. (err or "Failed to fetch manifest"))
            return
        end

        local updatedFiles = {}
        local failedFiles = {}

        for _, file in ipairs(manifest) do
            local success, updated = selfUpdateModule.processFile(file)
            if success then
                if updated then
                    print("+ " .. file)
                    updatedFiles[#updatedFiles + 1] = file
                end
            else
                print("x " .. file .. " (failed)")
                failedFiles[#failedFiles + 1] = file
            end
        end

        -- Summary
        print("")
        if #updatedFiles > 0 then
            local fileWord = #updatedFiles == 1 and "file" or "files"
            print("Updated " .. #updatedFiles .. " " .. fileWord .. ".")
        else
            print("MPM is up to date.")
        end

        if #failedFiles > 0 then
            print("Warning: " .. #failedFiles .. " file(s) failed to update.")
        end

        -- Regenerate startup.lua if configured
        selfUpdateModule.refreshStartup()
    end,

    getManifest = function()
        local Validation = exports("Utils.Validation")
        local url = repositoryUrl .. "manifest.json"

        local response, err = Validation.safeHttpGet(url)
        if not response then
            return nil, err
        end

        local content = Validation.readResponse(response)
        if not content then
            return nil, "Failed to read manifest response"
        end

        local manifest = textutils.unserialiseJSON(content)
        if not manifest then
            return nil, "Failed to parse manifest JSON"
        end

        return manifest, nil
    end,

    getFileContents = function(file)
        local Validation = exports("Utils.Validation")
        local url = repositoryUrl .. file

        local response, err = Validation.safeHttpGet(url)
        if not response then
            return nil, err
        end

        local content = Validation.readResponse(response)
        if not content then
            return nil, "Failed to read file response"
        end

        return content, nil
    end,

    processFile = function(file)
        -- Get remote content
        local remoteContent, err = selfUpdateModule.getFileContents(file)
        if not remoteContent then
            return false, false
        end

        -- Determine local path
        local localPath
        if file == "mpm.lua" then
            localPath = "/mpm.lua"
        else
            localPath = "/mpm/" .. file
        end

        -- Get local content (may not exist)
        local localContent = exports("Utils.File").get(localPath)

        -- Compare: update if different OR if local doesn't exist
        if localContent == remoteContent then
            return true, false  -- Success, but no update needed
        end

        -- Perform update
        local File = exports("Utils.File")

        if file == "mpm.lua" then
            -- Special handling for root mpm.lua
            File.delete("/mpm.lua")
            local success = File.put("/mpm.lua", remoteContent)
            return success, success
        else
            local success = File.put(localPath, remoteContent)
            return success, success
        end
    end,

    refreshStartup = function()
        -- Check if StartupConfig exists (it might not on older installs)
        local success, StartupConfig = pcall(function()
            return exports("Utils.StartupConfig")
        end)

        if not success or not StartupConfig then
            return  -- StartupConfig not available yet
        end

        if not StartupConfig.isConfigured() then
            return  -- No startup configuration
        end

        local refreshed, err = StartupConfig.regenerateStartup()

        if refreshed then
            print("")
            print("Startup script refreshed from config.")
        elseif err then
            print("")
            print("Note: Could not refresh startup.lua: " .. err)
        end
    end
}

return selfUpdateModule
