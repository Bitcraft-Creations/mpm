-- core.lua (the package manager API)
local Core = {} -- Create a table to hold the package manager functionalities.

local Printer = dofile("/mpm/printer.lua")

-- A table to store repository URLs
Core.package_repository = "https://shelfwood-mpm-packages.netlify.app/"

-- Function to download a file from a URL
function Core.downloadFile(url, path)
    -- Attempt to open a connection to the given URL
    local response = http.get(url)

    -- If the connection is successful
    if response then
        -- Read the content from the response
        local content = response.readAll()
        response.close()

        -- Save the content to the specified path
        local file = fs.open(path, "w")
        file.write(content)
        file.close()

        return true  -- Indicate a successful download
    else
        return false -- Indicate a failed download
    end
end

function isComponentInstalled(name)
    -- If it's a package_name (it has a / in it)
    if string.find(name, "/") then
        -- Check if the package is installed
        return fs.exists("/mpm/packages/" .. name .. ".lua")
    else
        -- Check if the module is installed
        return fs.exists("/mpm/packages/" .. name .. "/filelist.lua")
    end
end

function getDependencies(module_name)
    local dependencies = {}

    -- Construct the path to the dependencies.txt file
    local depsPath = module_name .. "/dependencies.txt"

    -- Check if the dependencies.txt file exists, if not download it
    if not fs.exists("/mpm/packages/" .. depsPath) then
        local depsUrl = Core.package_repository .. "/" .. depsPath
        if Core.downloadFile(depsUrl, "/mpm/packages/" .. depsPath) then
            print("Found dependencies for: " .. module_name)
        else
            return
        end
    end
    -- Read the dependencies from the file
    local file = fs.open("/mpm/packages/" .. depsPath, "r")
    for line in file.readLine do
        table.insert(dependencies, line)
    end
    file.close()

    return dependencies
end

function installPackage(package_name)
    local package_url = Core.package_repository .. "/" .. package_name .. ".lua"
    local module_name = fs.getDir(package_name)
    local package_path = "/mpm/packages/" .. package_name .. ".lua"
    local moduleIsInstalled = isComponentInstalled(module_name)

    -- Check if package is already installed
    if isComponentInstalled(package_name) then
        print("Package already installed: " .. package_name)
        return
    end

    -- Download and install the package
    if Core.downloadFile(package_url, package_path) then
        -- Check for dependencies and install them
        if not moduleIsInstalled then
            local dependencies = getDependencies(module_name)
            if dependencies then
                for _, dependency in ipairs(dependencies) do
                    if string.find(dependency, "/") then
                        installPackage(dependency)
                    else
                        installModule(dependency)
                    end
                end
            end
        end
        print("Successfully installed: " .. package_name)
    else
        print("Failed to install: " .. package_name)
        return
    end
end

function installModule(module_name)
    -- Construct the path to the module's file list (similar to filelist.lua)
    local module_filelist_path = module_name .. "/filelist.lua"

    if not Core.downloadFile(Core.package_repository .. "/" .. module_filelist_path, "/mpm/packages/" .. module_filelist_path) then
        print("Failed to obtain file list for: " .. module_name)
        return
    end

    -- Load the module's filelist
    local module_filelist = dofile("/mpm/packages/" .. module_filelist_path)

    -- Install each package within the module
    for _, package_name in ipairs(module_filelist) do
        installPackage(fs.combine(module_name, package_name))
    end
    print("Successfully installed " .. module_name)
end

function Core.install(...)
    local names = { ... } -- Capture the names passed as arguments

    -- Check if no names are provided
    if #names == 0 then
        print("Please specify one or more packages or modules to install.")
        return
    end

    -- Install each specified package or module
    for _, name in ipairs(names) do
        if string.find(name, "/") then
            print("Installing package: " .. name)
            installPackage(name)
        else
            print("Installing module: " .. name)
            installModule(name)
        end
    end
end

-- Function to update MPM
function Core.self_update()
    Printer.print("Updating MPM...")

    -- Set the repository URL to the install repository
    local repository_url = "https://shelfwood-mpm.netlify.app/"

    -- Download filelist.lua from the install repository
    local success = Core.downloadFile(repository_url .. "filelist.lua", "/mpm/filelist.lua")
    if not success then
        Printer.print("Failed to download filelist.lua")
        return
    end

    -- Load the filelist
    local file = fs.open("/mpm/filelist.lua", "r")
    local filelist_content = file.readAll()
    file.close()
    local files = load(filelist_content)()

    -- Check for updates
    local updates = {}
    for _, file in ipairs(files) do
        local url = repository_url .. file
        local newContent = Core.downloadFile(url, "/mpm/temp_" .. file)
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

    -- Show output to the user
    if #updates > 0 then
        Printer.print("Changes detected for:")
        for _, file in ipairs(updates) do
            Printer.print("- " .. file)
        end
        Printer.print("MPM updated successfully.")
    else
        Printer.print("No updates found.")
    end
end

-- Function to remove a package
function Core.remove(package)
    fs.delete("/mpm/packages/" .. package:gsub("/", "-") .. ".lua")
    print("\nPackage " .. package .. " removed successfully.")
end

function Core.run(package, ...)
    local package_path = "/mpm/packages/" .. package .. ".lua"
    if not fs.exists(package_path) then
        error("Package '" .. package .. "' not found.")
    end

    -- Create a custom environment with the mpm function
    local env = setmetatable({ mpm = mpm }, { __index = _G })

    -- Load and run the package with the custom environment
    local func, err = loadfile(package_path, "t", env)
    if not func then
        error("Error loading package '" .. package .. "': " .. err)
    end
    func(...)
end

function Core.updateSingleComponent(name)
    -- Check if it's a package or a module
    if string.find(name, "/") then
        -- It's a package
        local package_url = Core.package_repository .. "/" .. name .. ".lua"

        -- Download the package content
        local response = http.get(package_url)
        if not response then
            print("Failed to fetch package: " .. name)
            return
        end
        local newContent = response.readAll()
        response.close()

        -- Compare the downloaded content with the existing content
        local oldContent = nil
        if fs.exists("/mpm/packages/" .. name .. ".lua") then
            local file = fs.open("/mpm/packages/" .. name .. ".lua", "r")
            oldContent = file.readAll()
            file.close()
        end

        if oldContent == newContent then
            print(name .. " is already up-to-date.")
        else
            -- Delete the old file before writing the new one
            if fs.exists("/mpm/packages/" .. name .. ".lua") then
                fs.delete("/mpm/packages/" .. name .. ".lua")
            end
            -- Write the new content to the file
            local file = fs.open("/mpm/packages/" .. name .. ".lua", "w")
            file.write(newContent)
            file.close()

            print(name .. " has been updated successfully.")
        end
    else
        -- It's a module, update its file list first
        if not Core.downloadFile(Core.package_repository .. "/" .. name .. "/filelist.lua",
                "/mpm/packages/" .. name .. "/filelist.lua") then
            print("Failed to update file list for: " .. name)
            return
        end
        -- Load the module's file list and update each package in it
        local module_filelist = dofile("/mpm/packages/" .. name .. "/filelist.lua")
        for _, package_name in ipairs(module_filelist) do
            Core.updateSingleComponent(fs.combine(name, package_name))
        end
    end
end

-- Helper function to update all packages in a given module directory
local function updatePackagesInModule(module_dir)
    local package_files = fs.list(module_dir)
    for _, package_file in ipairs(package_files) do
        if package_file:match("%.lua$") then                                                         -- Check if it's a Lua file
            local package_name = fs.combine(fs.getName(module_dir), package_file:match("(.+)%..+$")) -- Construct the package name
            Core.updateSingleComponent(package_name)
        end
    end
end

function Core.update(...)
    local names = { ... } -- Capture the names passed as arguments

    -- If no names are provided, update only the installed packages
    if #names == 0 then
        local module_dirs = fs.list("/mpm/packages/")
        for _, module_dir in ipairs(module_dirs) do
            updatePackagesInModule("/mpm/packages/" .. module_dir)
        end
    else
        -- Update each specified package or module
        for _, name in ipairs(names) do
            if string.find(name, "/") then -- It's a package
                Core.updateSingleComponent(name)
            else                           -- It's a module
                updatePackagesInModule("/mpm/packages/" .. name)
            end
        end
    end
end

-- Function to list installed packages
function Core.list()
    Printer.print("\nListing installed packages:")
    local files = fs.list("/mpm/packages/")
    for _, file in ipairs(files) do
        Printer.print("  - " .. file)
    end
end

-- Function to set a package as the startup script
function Core.startup()
    -- Prompt user for package name
    print("Enter the name of the package you wish to set as the startup script:")
    local package = read()

    -- Prompt user for optional parameters
    print("Enter any optional parameters to pass to the package (leave blank for none):")
    local parameters = read()

    -- Construct the startup script content
    local startup_content = "shell.run('mpm update')\n"
    startup_content = startup_content .. "shell.run('mpm run " .. package .. " " .. parameters .. "')"

    -- Write the startup script content to startup.lua
    local file = fs.open("/startup.lua", "w")
    file.write(startup_content)
    file.close()

    print("Startup script set successfully!")
end

-- string.split implementation
function string.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

-- Return the Core table
return Core
