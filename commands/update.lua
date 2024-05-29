local updateModule = nil
local repositoryUrl = "https://shelfwood-mpm-packages.netlify.app/"
local installModule = dofile("/mpm/commands/install.lua")

updateModule = {
    usage = "mpm update <package>",

    run = function(...)
        local names = {...}
        local updatedComponents = {}

        print("Checking for updated modules...")

        if #names == 0 then
            local module_dirs = fs.list("/mpm/packages/")
            for _, module_dir in ipairs(module_dirs) do
                print("  - @" .. module_dir)
                if updateModule.updatePackagesInModule("/mpm/packages/" .. module_dir, updatedComponents) then
                    updatedComponents[#updatedComponents + 1] = module_dir
                end
            end
        else
            for _, name in ipairs(names) do
                if updateModule.updateSingleComponent(name, updatedComponents) then
                    updatedComponents[#updatedComponents + 1] = name
                end
            end
        end

        if #updatedComponents <= 0 then
            print("\nNo updates found.")
            return
        end

        print("\nUpdated components:")
        local function printTree(components, indent)
            indent = indent or ""
            for _, component in ipairs(components) do
                if type(component) == "table" then
                    print(indent .. "- @" .. component.name)
                    printTree(component.children, indent .. "  ")
                else
                    print(indent .. "- " .. component)
                end
            end
        end

        printTree(updatedComponents)
    end,

    updatePackagesInModule = function(moduleDir, updatedComponents)
        local packageFiles = fs.list(moduleDir)
        local updated = false
        local moduleComponents = {
            name = fs.getName(moduleDir),
            children = {}
        }
        for _, packageFile in ipairs(packageFiles) do
            if not packageFile:match("%.lua$") then -- Check if it's a Lua file
                goto continue
            end

            local package_name = fs.combine(fs.getName(moduleDir), packageFile:match("(.+)%..+$")) -- Construct the package name
            if updateModule.updateSingleComponent(package_name, moduleComponents.children) then
                updated = true
            end
            ::continue::
        end
        if updated then
            table.insert(updatedComponents, moduleComponents)
        end
        return updated
    end,

    updateSingleComponent = function(name, updatedComponents)
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
                table.insert(updatedComponents, fs.getName(name) .. " (updated)")
            end
        else
            -- It's a module, update its file list first
            if not installModule.downloadFile(repositoryUrl .. "/" .. name .. "/filelist.lua",
                "/mpm/packages/" .. name .. "/filelist.lua") then
                print("Failed to update file list for: " .. name)
                return updated
            end

            local module_filelist = dofile("/mpm/packages/" .. name .. "/filelist.lua")
            for _, package_name in ipairs(module_filelist) do
                if updateModule.updateSingleComponent(fs.combine(name, package_name), updatedComponents) then
                    updated = true
                end
            end
        end
        return updated
    end
}

return updateModule
