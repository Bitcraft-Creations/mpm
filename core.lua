-- core.lua (the package manager API)
local Core = {} -- Create a table to hold the package manager functionalities.

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
    print("\nRepository " .. repo .. " added successfully.")
end

-- Function to list installed packages
function Core.list()
    print("\nListing installed packages:")
    local files = fs.list("/mpm/packages/")
    for _, file in ipairs(files) do
        print("  - " .. file)
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
        local newPackageContent = Core.downloadFile(repo .. "/main/" .. package .. ".lua", newPackagePath)
        if newPackageContent then
            if oldPackageContent ~= newPackageContent then
                print("\nPackage " .. package .. " installed successfully from " .. repo .. " with changes.")
            else
                print("\nPackage " .. package .. " reinstalled from " .. repo .. " without changes.")
                print(
                    "If you've recently updated the package, wait a few minutes for GitHub's cache to update before reinstalling.")
            end
            return
        end
    end
    print("\nPackage not found.")
end

-- Function to update core.lua and mpm.lua
function Core.self_update()
    local files = dofile("/mpm/filelist.lua")

    local updates = {}
    for _, file in ipairs(files) do
        local url = "https://shelfwood-mpm.netlify.app/" .. file
        local oldContent = nil
        if fs.exists("/mpm/" .. file) then
            local oldFile = fs.open("/mpm/" .. file, "r")
            oldContent = oldFile.readAll()
            oldFile.close()
        end
        local newContent = Core.downloadFile(url, "/mpm/" .. file)
        if newContent and oldContent ~= newContent then
            updates[file] = true
        end
    end
    if next(updates) then
        for file, _ in pairs(updates) do
            print("\nFile " .. file .. " has been updated successfully.")
        end
    else
        print("\nNo updates found.")
    end
end

-- Function to update a package
function Core.update(package)
    local Printer = dofile("/mpm/printer.lua")

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
        local newPackageContent = Core.downloadFile(repo .. "/main/" .. package .. ".lua", newPackagePath)
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
    print("\nPackage " .. package .. " run successfully.")
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
