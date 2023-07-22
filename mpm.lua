-- A table to store repository URLs
local repositories = {}
-- get the command-line arguments
local tArgs = {...} 
-- the first argument is the command
local command = tArgs[1] 

local function printUsage()
  print("Usage:")
  print("mpm install <package>")
  print("mpm uninstall <package>")
  print("mpm tap_repository <repository url>")
  print("mpm list_repositories")
  print("mpm list_installed")
end

if not command then
  printUsage()
  return
end

if command == "install" then
  if #tArgs < 2 then
    print("Please provide a package name to install. Usage: mpm install <package>")
    return
  end

elseif command == "uninstall" then
  if #tArgs < 2 then
    print("Please provide a package name to uninstall. Usage: mpm uninstall <package>")
    return
  end

elseif command == "tap_repository" then
  if #tArgs < 2 then
    print("Please provide a repository URL. Usage: mpm tap_repository <repository url>")
    return
  end
else
  print("Invalid command. Here's the list of valid commands:")
  printUsage()
end


-- Function to download a file from a URL
local function downloadFile(url, path)
    -- Download the file
    local response = http.get(url)

    -- If the request was successful, the status code will be 200
    if response and response.getResponseCode() == 200 then
        -- Read the contents of the response
        local content = response.readAll()

        -- Open a new file on the computer and write the contents into it
        local file = fs.open(path, "w")
        file.write(content)
        file.close()

        return true
    else
        return false
    end
end

-- Function to add a new repository
function tap_repository(repo)
    table.insert(repositories, repo)
    print("Added repository: " .. repo)

    -- Save repositories to a file
    local file = fs.open("/mpm/repos.txt", "w")
    for _, repo in ipairs(repositories) do
        file.writeLine(repo)
    end
    file.close()
end

-- Function to install a package
function install(package)
    -- Iterate over all repositories
    for _, repo in ipairs(repositories) do
        -- Try to download the package
        if downloadFile(repo .. package .. ".lua", "/mpm/" .. package:gsub("/", "-") .. ".lua") then
            print("Package " .. package .. " installed successfully from " .. repo)
            return
        end
    end

    print("Package not found.")
end

-- Function to update a package
function update(package)
    -- Just call the install function
    install(package)
end

-- Function to remove a package
function remove(package)
    -- Delete the file
    fs.delete("/mpm/" .. package:gsub("/", "-") .. ".lua")
    print("Package " .. package .. " removed.")
end

-- Function to list installed packages
function list()
    -- List all the files in the /mpm directory
    local files = fs.list("/mpm")

    -- Filter the list to only include .lua files
    local packages = {}
    for _, file in ipairs(files) do
        if file:sub(-4) == ".lua" then
            table.insert(packages, file:sub(1, -5)) -- Remove the extension
        end
    end

    -- Print the packages
    for _, package in ipairs(packages) do
        print(package)
    end
end

-- Function to list available packages
function available()
    -- TODO: Implement this function
    -- This will likely involve parsing the GitHub repository page HTML, which can be quite complex.
end

-- Load the list of repositories from a file
if fs.exists("/mpm/repos.txt") then
    local file = fs.open("/mpm/repos.txt", "r")
    while true do
        local line = file.readLine()
        if line == nil then break end
        table.insert(repositories, line)
    end
    file.close()
end

if _G.arg ~= nil then
    -- We are running as a standalone program, so interpret command-line arguments
    local command = _G.arg[1]
    if command == 'tap_repository' then
        tap_repository(_G.arg[2])
    elseif command == 'install' then
        install(_G.arg[2])
    elseif command == 'update' then
        update(_G.arg[2])
    elseif command == 'remove' then
        remove(_G.arg[2])
    elseif command == 'list' then
        list()
    elseif command == 'available' then
        available()
    else
        printUsage()
    end
end