local updateModule = nil
local repositoryUrl = "https://shelfwood-mpm-packages.netlify.app/"
local installModule = dofile("/mpm/Core/Commands/install.lua")

--[[
    This command updates the specified module or all modules if no module is specified.
    To update a module we need to:
    - Obtain the manifest.json
    - For each module in the manifest, download the module from the repository
    - Replace the existing module with the new module
    - For any modules that are no longer in the manifest, delete them
]]
updateModule = {
    usage = "mpm update <module>",

    run = function(...)
        local names = {...}
        -- If <module> names are specified, we only update those modules
        if #names > 0 then
            updateModule.updateModules(names)
        end

        -- If no <module> names are specified, we update all modules
        updateModule.updateModules(exports("Utils.File").list("/mpm/packages/"))
    end,

    updateModules = function(modules)
        for _, module in ipairs(modules) do
            updateModule.updateSingleModule(module)
        end
    end,

    updateSingleModule = function(module)
        print("- @" .. module)
        local manifest = textutils.unserialiseJSON(http.get(repositoryUrl .. module .. "/manifest.json").readAll())
        for _, moduleName in ipairs(manifest.modules) do
            updateModule.updateSingleFile(module, moduleName)
        end

        updateModule.removeFilesNotInList(module, manifest.modules)
    end,

    updateSingleFile = function(module, filename)
        -- Obtain the file from the repository
        local content = http.get(repositoryUrl .. module .. "/" .. filename .. ".lua")

        -- If the file content is the same, return
        local installedContent = exports("Utils.File").open("/mpm/packages/" .. module .. "/" .. filename .. '.lua', "r").readAll()

        if installedContent == content then
            return
        end

        -- Replace the existing file with the new updated file
        exports("Utils.File").write("/mpm/packages/" .. module .. "/" .. filename .. '.lua', content)

        -- Print the file name
        print("  - " .. filename)
    end,

    removeFilesNotInList = function(module, modules)
        local files = exports("Utils.File").list("/mpm/packages/" .. module)
        for _, file in ipairs(files) do
            if not updateModule.isInList(file, modules) then
                exports("Utils.File").delete("/mpm/packages/" .. module .. "/" .. file)
                -- Print the file name with an X to indicate it is deleted
                print("X - " .. file)
            end
        end
    end,

    isInList = function(file, list)
        for _, item in ipairs(list) do
            if item .. ".lua" == file then
                return true
            end
        end
        return false
    end
}

return updateModule
