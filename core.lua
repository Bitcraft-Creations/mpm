-- core.lua (the package manager API)
local Core = {} -- Create a table to hold the package manager functionalities.

local Printer = dofile("/mpm/printer.lua")

-- A table to store repository URLs
Core.repositories = {}

-- Function to download a file from a URL
function Core.downloadFile(url, path)
    local response = http.get(url)
    if response and response.getResponseCode() == 200 then
        local content = response.readAll()
        local file = fs.open(path, "w")
        file.write(content)
        file.close()
        return content
    else
        return nil
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

-- Function to install a package
function Core.install(package)
    -- Iterate over all repositories
    for _, repo in ipairs(Core.repositories) do
        local newPackagePath = "/mpm/packages/" .. package:gsub("/", "-") .. ".lua"
        local oldPackageContent = nil
        if fs.exists(newPackagePath) then
            local oldPackageFile = fs.open(newPackagePath, "r")
            oldPackageContent = oldPackageFile.readAll()
            oldPackageFile.close()
        end
        -- Try to download the new package
        local newPackageContent = Core.downloadFile(repo .. package .. ".lua", newPackagePath)
        if newPackageContent then
            if oldPackageContent ~= newPackageContent then
                Printer.print("\nPackage " .. package .. " installed successfully from " .. repo .. " with changes.")
            else
                Printer.print("\nPackage " .. package .. " reinstalled from " .. repo .. " without changes.")
            end
            return
        end
    end
    Printer.print("\nPackage not found.")
end

-- Function to update a package
function Core.update(package)
    if package then -- If package name is provided
        Printer.printHeader("Updating package: " .. package)
        Core.updateSinglePackage(package, Printer)
    else -- If no package name is provided
        Printer.printHeader("Updating all packages")
        local files = fs.list("/mpm/packages/")
        for _, package in ipairs(files) do
            local packageName = string.gsub(package, "%.lua", "")
            Core.updateSinglePackage(packageName, Printer)
        end
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
            local oldFile = fs.open("/mpm/" .. file, "r")
            oldContent = oldFile.readAll()
            oldFile.close()
        else
            new_files[#new_files + 1] = file
        end
        local newContent = Core.downloadFile(url, "/mpm/" .. file)
        if newContent and oldContent ~= newContent then
            updates[file] = true
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

-- Helper function to update a single package
function Core.updateSinglePackage(package, Printer)
    -- Iterate over all repositories
    for _, repo in ipairs(Core.repositories) do
        local newPackagePath = "/mpm/packages/" .. package:gsub("/", "-") .. ".lua"
        local oldPackageContent = nil
        if fs.exists(newPackagePath) then
            local oldPackageFile = fs.open(newPackagePath, "r")
            oldPackageContent = oldPackageFile.readAll()
            oldPackageFile.close()
        end
        -- Try to download the new package
        local newPackageContent = Core.downloadFile(repo .. package .. ".lua", newPackagePath)
        if newPackageContent then
            if oldPackageContent ~= newPackageContent then
                Printer.print("\nPackage " .. package .. " updated successfully from " .. repo .. " with changes.")
            else
                Printer.printWarning("\nPackage " .. package .. " is already up to date. No changes detected.")
            end
            return
        end
    end
    Printer.printWarning("\nPackage not found.")
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

-- Return the Core table
return Core
