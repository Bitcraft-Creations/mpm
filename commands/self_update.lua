local self_updateModule = nil
local repositoryUrl = "https://shelfwood-mpm.netlify.app/"
local installModule = dofile("/mpm/commands/install.lua")

self_updateModule = {
    usage = "mpm self_update",

    run = function()
        print("Updating MPM...")

        -- Download filelist.lua from the install repository
        local success = installModule.downloadFile(repositoryUrl .. "filelist.lua", "/mpm/filelist.lua")
        if not success then
            print("Failed to download filelist.lua")
            return
        end

        -- Load the filelist
        local file = fs.open("/mpm/filelist.lua", "r")
        local filelist_content = file.readAll()
        file.close()
        local files = load(filelist_content)()

        -- Check for updates
        local updates = self_updateModule.checkUpdates()

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

    checkUpdates = function()
        local updates = {}
        for _, file in ipairs(files) do
            local url = repositoryUrl .. file
            local newContent = installModule.downloadFile(url, "/mpm/temp_" .. file)
            if newContent then
                local oldContent = nil
                if fs.exists("/mpm/" .. file) then
                    local oldFile = fs.open("/mpm/" .. file, "r")
                    oldContent = oldFile.readAll()
                    oldFile.close()
                end
    
                local tempFile = fs.open("/mpm/temp_" .. file, "r")
                local newContent = tempFile.readAll()
                tempFile.close()
    
                if oldContent ~= newContent then
                    updates[#updates + 1] = file

                    fs.delete("/mpm/" .. file)
                    fs.move("/mpm/temp_" .. file, "/mpm/" .. file)

                    -- If the file is mpm.lua then copy it to the root directory
                    if file == "mpm.lua" then
                        if fs.exists("/mpm.lua") then
                            fs.delete("/mpm.lua")
                        end
                        fs.copy("/mpm/mpm.lua", "/mpm.lua")
                    end
                else
                    fs.delete("/mpm/temp_" .. file)
                end
            end
        end
        return updates
    end,
}

return self_updateModule