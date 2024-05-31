local self_updateModule = nil
local repositoryUrl = "https://shelfwood-mpm.netlify.app/"
local installModule = dofile("/mpm/commands/install.lua")

--[[
    This module is responsible for updating MPM itself.
]]
self_updateModule = {
    usage = "mpm self_update",

    run = function()
        print("Updating MPM...")
        -- Get the manifest containing a list of files to check for updates
        local manifest = textutils.unserialiseJSON(http.get(repositoryUrl .. "manifest.json").readAll())

        for _, file in ipairs(manifest) do
            -- We get the file from the repository and compare it to our local file (if one exists)
            local remoteFile = http.get(repositoryUrl .. file)
            local localFile = fs.open(file, "r")
            local remoteFileContents = remoteFile.readAll()
            local localFileContents = localFile.readAll()

            if remoteFileContents ~= localFileContents then
                print("- " .. file)
                localFile.write(remoteFileContents)
            end

            remoteFile.close()
            localFile.close()
        end

        -- Finally we clean up any files that are no longer in the manifest 
        -- By checking any file path in the mpm folder (except for packages) to check if it's present in the file list
        for _, file in ipairs(manifest) do
            local filePath = "/mpm/" .. file
            if not fs.exists(filePath) then
                fs.delete(filePath)
                print("x " .. filePath)
            end
        end
    end
}

return self_updateModule
