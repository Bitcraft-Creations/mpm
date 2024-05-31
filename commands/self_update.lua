local self_updateModule = nil
local repositoryUrl = "https://shelfwood-mpm.netlify.app/"
local installModule = dofile("/mpm/commands/install.lua")

self_updateModule = {
    usage = "mpm self_update",

    run = function()
        print("Updating MPM...")

        -- Download manifest.json files for each package
        local packages = fs.list("/mpm/packages/")
        for _, package in ipairs(packages) do
            local manifestUrl = repositoryUrl .. package .. "/manifest.json"
            local manifestPath = "/mpm/packages/" .. package .. "/manifest.json"
            local success = installModule.downloadFile(manifestUrl, manifestPath)
            if not success then
                print("Failed to download manifest.json for " .. package)
            end
        end

        -- Check for updates
        local updates = self_updateModule.checkUpdates(packages)

        -- Show output the user
        if #updates == 0 then
            print("No updates found.")
            return
        end

        print("Changes detected for:")
        for _, file in ipairs(updates) do
            print("- " .. file)
        end
        print("MPM updated successfully.")
    end,

    checkUpdates = function(packages)
        local updates = {}
        for _, package in ipairs(packages) do
            local manifestPath = "/mpm/packages/" .. package .. "/manifest.json"
            local manifest = dofile(manifestPath)
            for _, moduleName in ipairs(manifest.modules) do
                local url = repositoryUrl .. package .. "/" .. moduleName .. ".lua"
                local newContent = installModule.downloadFile(url, "/mpm/temp_" .. moduleName .. ".lua")
                if newContent then
                    local oldContent = nil
                    if fs.exists("/mpm/packages/" .. package .. "/" .. moduleName .. ".lua") then
                        local oldFile = fs.open("/mpm/packages/" .. package .. "/" .. moduleName .. ".lua", "r")
                        oldContent = oldFile.readAll()
                        oldFile.close()
                    end

                    local tempFile = fs.open("/mpm/temp_" .. moduleName .. ".lua", "r")
                    local newContent = tempFile.readAll()
                    tempFile.close()

                    if oldContent ~= newContent then
                        updates[#updates + 1] = moduleName

                        fs.delete("/mpm/packages/" .. package .. "/" .. moduleName .. ".lua")
                        fs.move("/mpm/temp_" .. moduleName .. ".lua",
                            "/mpm/packages/" .. package .. "/" .. moduleName .. ".lua")

                        -- If the file is mpm.lua then copy it to the root directory
                        if moduleName == "mpm" then
                            if fs.exists("/mpm.lua") then
                                fs.delete("/mpm.lua")
                            end
                            fs.copy("/mpm/mpm.lua", "/mpm.lua")
                        end
                    else
                        fs.delete("/mpm/temp_" .. moduleName .. ".lua")
                    end
                end
            end
        end
        return updates
    end
}

return self_updateModule
