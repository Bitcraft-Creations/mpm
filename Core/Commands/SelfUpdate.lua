local self_updateModule = nil
local repositoryUrl = "https://shelfwood-mpm.netlify.app/"
local installModule = dofile("/mpm/Core/Commands/install.lua")

--[[
    This module is responsible for updating MPM itself.
]]
self_updateModule = {
    usage = "mpm self_update",

    run = function()
        -- Get the manifest containing a list of files to check for updates
        local manifest = textutils.unserialiseJSON(http.get(repositoryUrl .. "manifest.json").readAll())

        for _, file in ipairs(manifest) do
            print(file)
            -- We get the file from the repository and compare it to our local file (if one exists)
            local remoteFileContents = http.get(repositoryUrl .. file).readAll()
            local filePath = "/mpm/" .. file

            -- If the file is 'mpm.lua', we compare it to `mpm.lua` instead of `mpm/mpm.lua`
            if file == "mpm.lua" then
                filePath = "mpm.lua"
            end

            local localFileContents = exports("Utils.File").get(filePath)

            -- If it's the same, we skip it
            if localFileContents then
                if remoteFileContents == localFileContents then
                    goto continue
                end
            end
            print("- " .. file)

            if file == "mpm.lua" then
                exports("Utils.File").delete("mpm.lua")
                exports("Utils.File").put("mpm.lua", remoteFileContents)
                goto continue
            end

            exports("Utils.File").put(filePath, remoteFileContents)
            ::continue::
        end
    end
}

return self_updateModule
