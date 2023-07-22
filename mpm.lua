-- Table to store repository URLs
local repositories = {}

-- List of commands
local commands = {
    "install", "uninstall", "tap_repository", "list_repositories", 
    "list_installed", "run"
}

-- Command-line arguments
local tArgs = {...}
local command = tArgs[1]

-- Print usage instructions
local function printUsage()
    print("Usage:")
    print("mpm install <package>")
    print("mpm uninstall <package>")
    print("mpm tap_repository <repository url>")
    print("mpm list_repositories")
    print("mpm list_installed")
    print("mpm run <package>")
end

-- Validate command
if not command then
    printUsage()
    return
end

if not table.contains(commands, command) then
    print("Invalid command. Here's the list of valid commands:")
    printUsage()
    return
end

-- Command-specific argument checks
if command == "install" or command == "uninstall" or command == "run" then
    if #tArgs < 2 then
        print("Please provide a package name. Usage: mpm " .. command .. " <package>")
        return
    end
elseif command == "tap_repository" then
    if #tArgs < 2 then
        print("Please provide a repository URL. Usage: mpm tap_repository <repository url>")
        return
    end
end

-- Download file from URL
local function downloadFile(url, path)
    local response = http.get(url)

    -- Check for successful request
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

-- Add a new repository
function tap_repository(repo)
    table.insert(repositories, repo)
    print("Added repository: " .. repo)
    save_repositories()
end

-- Save repositories to a file
function save_repositories()
    local file = fs.open("/mpm/repos.txt", "w")
    for _, repo in ipairs(repositories) do
        file.writeLine(repo)
    end
    file.close()
end

-- Install a package
function install(package)
    for _, repo in ipairs(repositories) do
        if downloadFile(repo .. package .. ".lua", "/mpm/packages/" .. package .. ".lua") then
            print("Package " .. package .. " installed successfully from " .. repo)
            return
        end
    end
    print("Package not found.")
end

-- Uninstall a package
function uninstall(package)
    fs.delete("/mpm/packages/" .. package .. ".lua")
    print("Package " .. package .. " removed.")
end

-- Run a package
function run(package)
    shell.run("/mpm/packages/" .. package .. ".lua")
end

-- List installed packages
function list_installed()
    local files = fs.list("/mpm/packages")
    local packages = {}
    for _, file in ipairs(files) do
        if file:sub(-4) == ".lua" then
            table.insert(packages, file:sub(1, -5))  -- Remove the extension
        end
    end

    for _, package in ipairs(packages) do
        print(package)
    end
end

-- Load repositories from a file
if fs.exists("/mpm/repos.txt") then
    local file = fs.open("/mpm/repos.txt", "r")
    while true do
        local line = file.readLine()
        if line == nil then break end
        table.insert(repositories, line)
    end
    file.close()
end

-- Execute the command
if command == 'tap_repository' then
    tap_repository(tArgs[2])
elseif command == 'install' then
    install(tArgs[2])
elseif command == 'uninstall' then
    uninstall(tArgs[2])
elseif command == 'run' then
    run(tArgs[2])
elseif command == 'list_installed' then
    list_installed()
end

return {
    tap_repository = tap_repository,
    install = install,
    uninstall = uninstall,
    run = run,
    list_installed = list_installed
}