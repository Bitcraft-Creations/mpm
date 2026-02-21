local selfUpdateModule = nil
local repositoryUrl = "https://shelfwood-mpm.netlify.app/"

selfUpdateModule = {
    usage = "mpm selfupdate",

    run = function()
        local Storage = exports("Utils.Storage")

        print("Checking for updates to MPM...")

        local hasSpace, spaceErr = Storage.ensureCriticalFree(8 * 1024, "/")
        if not hasSpace then
            print("Error: " .. (spaceErr or "Insufficient disk space"))
            return
        end
        Storage.warnIfLow("/")

        local localManifest = selfUpdateModule.getLocalManifest()
        local manifest, err = selfUpdateModule.getManifest()
        if not manifest then
            print("Error: " .. (err or "Failed to fetch manifest"))
            return
        end

        local staged, stageErr = selfUpdateModule.stageRemoteFiles(manifest)
        if not staged then
            print("Error: " .. (stageErr or "Failed to stage update files"))
            return
        end

        local updatedFiles, failedFiles = selfUpdateModule.applyStagedFiles(manifest, staged)
        local removedFiles = 0
        if #failedFiles == 0 then
            removedFiles = selfUpdateModule.pruneRemovedFiles(localManifest, manifest)
        else
            print("Skipped stale-file pruning due to update failures.")
        end

        print("")
        if #updatedFiles > 0 then
            local fileWord = #updatedFiles == 1 and "file" or "files"
            print("Updated " .. #updatedFiles .. " " .. fileWord .. ".")
        elseif removedFiles > 0 then
            print("MPM files pruned: " .. removedFiles)
        else
            print("MPM is up to date.")
        end

        if #failedFiles > 0 then
            print("Warning: " .. #failedFiles .. " file(s) failed to update.")
        end

        Storage.printUsage("Disk usage: ", "/")
        selfUpdateModule.refreshStartup()
    end,

    getLocalManifest = function()
        local File = exports("Utils.File")
        local content = File.get("/mpm/manifest.json")
        if not content then
            return nil
        end
        return textutils.unserialiseJSON(content)
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

    stageRemoteFiles = function(manifest)
        local staged = {}
        for _, file in ipairs(manifest) do
            local remoteContent, err = selfUpdateModule.getFileContents(file)
            if not remoteContent then
                return nil, (err or ("Failed to fetch " .. file))
            end
            staged[file] = remoteContent
        end
        return staged, nil
    end,

    applyStagedFiles = function(manifest, staged)
        local File = exports("Utils.File")
        local updatedFiles = {}
        local failedFiles = {}

        for _, file in ipairs(manifest) do
            local remoteContent = staged[file]
            local localPath = selfUpdateModule.localPathFor(file)
            local localContent = File.get(localPath)

            if localContent ~= remoteContent then
                if File.put(localPath, remoteContent) then
                    print("+ " .. file)
                    updatedFiles[#updatedFiles + 1] = file
                else
                    print("x " .. file .. " (failed)")
                    failedFiles[#failedFiles + 1] = file
                end
            end
        end

        return updatedFiles, failedFiles
    end,

    localPathFor = function(file)
        if file == "mpm.lua" then
            return "/mpm.lua"
        end
        return "/mpm/" .. file
    end,

    pruneRemovedFiles = function(localManifest, remoteManifest)
        local File = exports("Utils.File")
        if type(localManifest) ~= "table" then
            return 0
        end

        local keep = {}
        for _, file in ipairs(remoteManifest) do
            keep[file] = true
        end

        local removed = 0
        for _, oldFile in ipairs(localManifest) do
            if not keep[oldFile] then
                local stalePath = selfUpdateModule.localPathFor(oldFile)
                if File.exists(stalePath) and File.delete(stalePath) then
                    print("- " .. oldFile)
                    File.deleteEmptyParents("/mpm", stalePath)
                    removed = removed + 1
                end
            end
        end

        return removed
    end,

    refreshStartup = function()
        local success, StartupConfig = pcall(function()
            return exports("Utils.StartupConfig")
        end)

        if not success or not StartupConfig then
            return
        end

        if not StartupConfig.isConfigured() then
            return
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
