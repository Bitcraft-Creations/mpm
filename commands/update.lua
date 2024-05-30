local updateModule = nil
local repositoryUrl = "https://shelfwood-mpm-packages.netlify.app/"
local installModule = dofile("/mpm/commands/install.lua")

updateModule = {
    usage = "mpm update <package>",

    run = function(...)
        local names = {...}

        print("Checking for updated modules...")

        -- Update all the specified packags e.g. mpm update a b c
        if #names > 0 then
            for _, name in ipairs(names) do
                updateModule.updateSingleComponent(name)
            end
            return
        end

        -- Update all modules if no package is specified
        local module_dirs = fs.list("/mpm/packages/")

        for _, module_dir in ipairs(module_dirs) do
            print("  - @" .. module_dir)
            updateModule.updatePackagesInModule("/mpm/packages/" .. module_dir)
        end
    end,

    updatePackagesInModule = function(moduleDir)
        local packageFiles = fs.list(moduleDir)
        local moduleName = fs.getName(moduleDir)
        for _, packageFile in ipairs(packageFiles) do
            if not packageFile:match("%.lua$") then
                goto continue
            end

            local package_name = fs.combine(moduleName, packageFile:match("(.+)%..+$")) -- Construct the package name
            updateModule.updateSingleComponent(package_name, "  - @" .. moduleName)
            ::continue::
        end
    end,

    updateSingleComponent = function(name)
        -- Check if it's a package or a module
        if string.find(name, "/") then
            -- It's a package
            local package_url = repositoryUrl .. "/" .. name .. ".lua"
            local response = http.get(package_url)
            if not response then
                print("Failed to fetch package: " .. name)
                return
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
                print("  - " .. fs.getName(name) .. " (updated)")
            end
            return
        end

        -- It's a module, update its file list first
        if not installModule.downloadFile(repositoryUrl .. "/" .. name .. "/filelist.lua",
            "/mpm/packages/" .. name .. "/filelist.lua") then
            print("Failed to update file list for: " .. name)
            return
        end

        local module_filelist = dofile("/mpm/packages/" .. name .. "/filelist.lua")
        for _, package_name in ipairs(module_filelist) do
            updateModule.updateSingleComponent(fs.combine(name, package_name), prefix .. "  - @" .. name)
        end
    end
}

return updateModule
