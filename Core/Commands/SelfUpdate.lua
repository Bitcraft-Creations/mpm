local self_updateModule = nil
local repositoryUrl = "https://shelfwood-mpm.netlify.app/"
local installModule = dofile("/mpm/Core/Commands/install.lua")

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
            local remoteFileContents = http.get(repositoryUrl .. file).readAll()
            local filePath = "/mpm/" .. file
            local localFile = exports("Utils.File").open(filePath, "r")

            -- If it's the same, we skip it
            if localFile then
                local localFileContents = localFile.readAll()
                if remoteFileContents == localFileContents then
                    localFile.close()
                    goto continue
                end
                localFile.close()
            end

            if file == "mpm.lua" then
                exports("Utils.File").delete("mpm.lua")
                exports("Utils.File").open("mpm.lua", "w+").write(remoteFileContents)
            end

            print("- " .. file)
            exports("Utils.File").open(filePath, "w+").write(remoteFileContents)
            ::continue::
        end
    end
}

return self_updateModule
