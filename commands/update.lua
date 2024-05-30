local updateModule = nil
local repositoryUrl = "https://shelfwood-mpm-packages.netlify.app/"
local installModule = dofile("/mpm/commands/install.lua")

--[[
    This command updates the specified module or all modules if no module is specified.
    To update a module we need to:
    - Obtain the filelist.lua
    - For each file in the list, download the file from the repository
    - Replace the existing file with the new file
    - For any files that are no longer in the list, delete them
]]
updateModule = {
    usage = "mpm update <module>",

    run = function(...)
        local names = {...}
        -- If <module> names are specified, we only update those modules
        if #names > 0 then
            updateModules(names)
        end

        -- If no <module> names are specified, we update all modules
        updateModules(fs.list("/mpm/packages/"))
    end,

    updateModules = function(modules)
        for _, module in ipairs(modules) do
            updateModule.updateSingleModule(module)
        end
    end,

    updateSingleModule = function(module)
        print("- @" .. module)
        local filelist = dofile("/mpm/packages/" .. module .. "/filelist.lua")
        for _, file in ipairs(filelist) do
            updateModule.updateSingleFile(module, file)
        end

        removeFilesNotInList(module, filelist)
    end,

    updateSingleFile = function(module, file)
        -- Obtain the file from the repository
        local file = http.get(repositoryUrl .. module .. "/" .. file)
        -- If the file content is the same, return
        if fs.read("/mpm/packages/" .. module .. "/" .. file) == file then
            return
        end
        -- Replace the existing file with the new updated file
        fs.write("/mpm/packages/" .. module .. "/" .. file, file)

        -- Print the file name
        print("  - " .. file)
    end,

    removeFilesNotInList = function(module, filelist)
        local files = fs.list("/mpm/packages/" .. module)
        for _, file in ipairs(files) do
            if not isInList(file, filelist) then
                fs.delete("/mpm/packages/" .. module .. "/" .. file)
                -- Print the file name with an X to indicate it is deleted
                print("X - " .. file)
            end
        end
    end
}

return updateModule
