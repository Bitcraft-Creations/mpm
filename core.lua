-- core.lua

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
        return true
    else
        return false
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
end

-- Function to install a package
function Core.install(package)
    -- Iterate over all repositories
    for _, repo in ipairs(Core.repositories) do
        -- Try to download the package
        if downloadFile(repo .. "/main/" .. package .. ".lua", "/mpm/packages/" .. package:gsub("/", "-") .. ".lua") then
            print("Package " .. package .. " installed successfully from " .. repo)
            return
        end
    end
    print("Package not found.")
end

-- Function to uninstall a package
function Core.uninstall(package)
    fs.delete("/mpm/packages/" .. package:gsub("/", "-") .. ".lua")
end

-- Function to run a package
function Core.run(package)
    shell.run("/mpm/packages/" .. package:gsub("/", "-") .. ".lua")
end

-- Load the list of repositories from a file
if fs.exists("/mpm/repos.txt") then
    local file = fs.open("/mpm/repos.txt", "r")
    while true do
        local line = file.readLine()
        if line == nil then break end
        table.insert(Core.repositories, line)
    end
    file.close()
end

-- Return the Core table
return Core
