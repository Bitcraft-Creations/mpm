-- core.lua (the package manager API)
local Core = {} -- Create a table to hold the package manager functionalities.

local Printer = dofile("/mpm/printer.lua")

-- A table to store repository URLs
Core.repositories = {}

-- Function to download a file from a URL
function downloadFile(url, path)
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

        return true -- Indicate a successful download
    else
        return false -- Indicate a failed download
    end
end

function isPackageInstalled(package_name)
    -- Check if the package file exists
    return fs.exists(package_name)
end

function getDependencies(package_name)
    local dependencies = {}

    -- Construct the path to the dependencies.txt file
    local depsPath = fs.combine(fs.getDir(package_name), "dependencies.txt")

    -- Check if the dependencies.txt file exists
    if fs.exists(depsPath) then
        -- Read the dependencies from the file
        local file = fs.open(depsPath, "r")
        for line in file.readLine do
            table.insert(dependencies, line)
        end
        file.close()
    end

    return dependencies
end

function installPackage(package_name)
    -- If the package is already installed, exit the function
    if isPackageInstalled(package_name) then
        return
    end

    -- Construct the URL to download the package
    local package_url = mpm_repository_url .. "/" .. package_name

    -- Download and install the package
    if downloadFile(package_url, package_name) then
        print("Successfully installed: " .. package_name)
    else
        print("Failed to install: " .. package_name)
        return
    end

    -- Check for dependencies and install them
    local dependencies = getDependencies(package_name)
    for _, dependency in ipairs(dependencies) do
        installPackage(dependency)
    end
end

function installModule(module_name)
    -- Construct the path to the module's file list (similar to filelist.lua)
    local module_filelist_path = module_name .. "/filelist.lua"

    -- Check if the module's filelist exists
    if not fs.exists(module_filelist_path) then
        print("Module file list not found for: " .. module_name)
        return
    end

    -- Load the module's filelist
    local module_filelist = dofile(module_filelist_path)

    -- Install each package within the module
    for _, package_name in ipairs(module_filelist) do
        installPackage(fs.combine(module_name, package_name))
    end
end

function Core.updateSinglePackage(package_name)
    -- Construct the URL to download the package
    local package_url = mpm_repository_url .. "/" .. package_name

    -- Download the package content
    local response = http.get(package_url)
    if not response then
        print("Failed to fetch: " .. package_name)
        return
    end
    local newContent = response.readAll()
    response.close()

    -- Compare the downloaded content with the existing content
    local file = fs.open(package_name, "r")
    local oldContent = file.readAll()
    file.close()

    if oldContent == newContent then
        print(package_name .. " is already up-to-date.")
    else
        -- Re-install the package if content has changed
        installPackage(package_name)
    end
end

function Core.update(...)
    local package_names = {...} -- Capture the package names passed as arguments

    -- If no package names are provided, update all installed packages
    if #package_names == 0 then
        local installed_packages = fs.list("/mpm/packages/")
        for _, package_name in ipairs(installed_packages) do
            Core.updateSinglePackage(package_name)
        end
    else
        -- Update each specified package
        for _, package_name in ipairs(package_names) do
            Core.updateSinglePackage(package_name)
        end
    end
end

-- Function to add a new repository
function Core.tap_repository(repo)
    table.insert(Core.repositories, repo)
    local file = fs.open("/mpm/repos.txt", "w")
    for _, repo in ipairs(Core.repositories) do
        file.writeLine(repo)
    end
    file.close()
    Printer.print("\nRepository " .. repo .. " added successfully.")
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
    startup_content = startup_content .. 'shell.run("mpm/packages/' .. package .. '.lua ' .. parameters .. '")'

    -- Write the startup script content to startup.lua
    local file = fs.open("/startup.lua", "w")
    file.write(startup_content)
    file.close()

    print("Startup script set successfully!")
end

function Core.install(...)
    local package_names = {...} -- Capture the package names passed as arguments

    -- Check if no package names are provided
    if #package_names == 0 then
        print("Please specify one or more packages to install.")
        return
    end

    -- Install each specified package
    for _, package_name in ipairs(package_names) do
        installPackage(package_name)
    end
end

-- Function to update MPM
function Core.self_update()
    Printer.print("Updating MPM...")

    -- Set the repository URL to the install repository
    local repository_url = "https://shelfwood-mpm.netlify.app/"

    -- Download filelist.lua from the install repository
    local filelist_content = Core.downloadFile(repository_url .. "filelist.lua", "/mpm/filelist.lua")

    -- Load the filelist
    local files = load(filelist_content)()

    -- Check for updates
    local updates = {}
    local new_files = {}
    for _, file in ipairs(files) do
        local url = repository_url .. file
        local oldContent = nil
        if fs.exists("/mpm/" .. file) then
            -- Delete the old file before writing the new one
            fs.delete("/mpm/" .. file)
            new_files[#new_files + 1] = file
        else
            new_files[#new_files + 1] = file
        end
        local newContent = Core.downloadFile(url, "/mpm/" .. file)
        if newContent then
            updates[file] = true
            -- If the file is mpm.lua then copy it to the root directory
            if file == "mpm.lua" then
                -- If the file already exists; delete it
                if fs.exists("/mpm.lua") then
                    fs.delete("/mpm.lua")
                end
                fs.copy("/mpm/mpm.lua", "/" .. file)
            end
        end
    end

    -- Show output to the user
    if next(updates) then
        for file, _ in pairs(updates) do
            Printer.print("File " .. file .. " has been updated successfully.")
        end
    else
        Printer.print("No updates found.")
    end

    if #new_files > 0 then
        Printer.print("The following new files have been downloaded:")
        for _, file in ipairs(new_files) do
            Printer.print("- " .. file)
        end
    end

    Printer.print("MPM updated successfully.")
end

-- Function to remove a package
function Core.remove(package)
    fs.delete("/mpm/packages/" .. package:gsub("/", "-") .. ".lua")
    print("\nPackage " .. package .. " removed successfully.")
end

function Core.run(package, ...)
    shell.run("/mpm/packages/" .. package .. ".lua", ...)
end

-- Load the list of repositories from a file
if fs.exists("/mpm/repos.txt") then
    local file = fs.open("/mpm/repos.txt", "r")
    while true do
        local line = file.readLine()
        if line == nil then
            break
        end
        table.insert(Core.repositories, line)
    end
    file.close()
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
