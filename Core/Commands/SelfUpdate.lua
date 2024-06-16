local self_updateModule = nil
local repositoryUrl = "https://shelfwood-mpm.netlify.app/"

--[[
    This module is responsible for updating MPM itself.
]]
self_updateModule = {
    usage = "mpm self_update",

    run = function()
        print("Checking for updates to MPM...")
        local manifest = self_updateModule.getManifest()

        local updatedFiles = {}
        for _, file in ipairs(manifest) do
            local remoteFileContents = self_updateModule.getFileContents(file)
            if self_updateModule.updateFile(file, remoteFileContents) then
                print("- " .. file)
                updatedFiles[#updatedFiles + 1] = file
            end
        end

        if #updatedFiles > 0 then
            local fileWord = #updatedFiles == 1 and "file" or "files"
            print("Updated " .. #updatedFiles .. " " .. fileWord .. ".")
        else
            print("No updates found.")
        end
    end,

    getManifest = function()
        return textutils.unserialiseJSON(http.get(repositoryUrl .. "manifest.json").readAll())
    end,

    getFileContents = function(file)
        return http.get(repositoryUrl .. file).readAll()
    end,

    updateFile = function(file, remoteFileContents)
        local filePath = "/mpm/" .. file
        if file == "mpm.lua" then
            filePath = "mpm.lua"
        end

        local localFileContents = exports("Utils.File").get(filePath)

        if localFileContents and remoteFileContents == localFileContents then
            return false
        end

        if file == "mpm.lua" then
            exports("Utils.File").delete("mpm.lua")
            exports("Utils.File").put("mpm.lua", remoteFileContents)
        else
            exports("Utils.File").put(filePath, remoteFileContents)
        end

        return true
    end
}

return self_updateModule
