local updateModule = nil
local repositoryUrl = "https://shelfwood-mpm-packages.netlify.app/"
local installModule = dofile("/mpm/commands/install.lua")

updateModule = {
    usage = "mpm update <package>",

    run = function(...)
        local names = {...}
        local updatedComponents = {}

        if #names == 0 then
            local module_dirs = fs.list("/mpm/packages/")
            for _, module_dir in ipairs(module_dirs) do
                if updateModule.updatePackagesInModule("/mpm/packages/" .. module_dir) then
                    updatedComponents[#updatedComponents+1] = module_dir
                end
            end
        else
            for _, name in ipairs(names) do
                if updateModule.updateSingleComponent(name) then
                    updatedComponents[#updatedComponents+1] = name
                end
            end
        end

        if #updatedComponents <= 0 then
            print("\nNo updates found.")
            return
        end

        print("\nUpdated components:")
        for _, component in ipairs(updatedComponents) do
            print("  - " .. component)
        end
    end,

    updatePackagesInModule = function(moduleDir)
        local packageFiles = fs.list(moduleDir)
        for _, packageFile in ipairs(packageFiles) do
            if not packageFile:match("%.lua$") then -- Check if it's a Lua file
                break
            end

            local package_name = fs.combine(fs.getName(moduleDir), packageFile:match("(.+)%..+$")) -- Construct the package name
            updateModule.updateSingleComponent(package_name)
        end
    end,

    updateSingleComponent = function(name)
        local updated = false
        -- Check if it's a package or a module
        if string.find(name, "/") then
            -- It's a package
            local package_url = repositoryUrl .. "/" .. name .. ".lua"
            local response = http.get(package_url)
            if not response then
                print("Failed to fetch package: " .. name)
                return updated
            end
            local newContent = response.readAll()
            response.close()

            local oldContent = nil
            if fs.exists("/mpm/packages/" .. name .. ".lua") then
                local file = fs.open("/mpm/packages/" .. name .. ".lua", "r")
                oldContent = file.readAll()
                file.close()
            end

            if oldContent ~= newContent then
                if fs.exists("/mpm/packages/" .. name .. ".lua") then
                    fs.delete("/mpm/packages/" .. name .. ".lua")
                end

                local file = fs.open("/mpm/packages/" .. name .. ".lua", "w")
                file.write(newContent)
                file.close()
                updated = true
            end
        else
            -- It's a module, update its file list first
            if not installModule.downloadFile(repositoryUrl .. "/" .. name .. "/filelist.lua", "/mpm/packages/" .. name .. "/filelist.lua") then
                print("Failed to update file list for: " .. name)
                return updated
            end

            local module_filelist = dofile("/mpm/packages/" .. name .. "/filelist.lua")
            for _, package_name in ipairs(module_filelist) do
                if updateModule.updateSingleComponent(fs.combine(name, package_name)) then
                    updated = true
                end
            end
        end
        return updated
    end,
}

return updateModule
