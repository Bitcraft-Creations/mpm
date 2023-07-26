-- install.lua
-- The URL of your GitHub repository
local repository_url = "https://raw.githubusercontent.com/j-shelfwood/mpm/main/"

-- A list of files to download
local files = {"mpm.lua", "core.lua", "printer.lua"}

-- Function to download a file from a URL
local function downloadFile(url, path)
    local response = http.get(url)
    if response and response.getResponseCode() == 200 then
        local content = response.readAll()
        local file = fs.open(path, "w")
        file.write(content)
        file.close()
        print("File " .. path .. " downloaded successfully.")
    else
        print("Failed to download " .. path)
    end
end

-- Create the /mpm directory if it doesn't exist
if not fs.exists("/mpm") then
    fs.makeDir("/mpm")
end

-- Create the /mpm/packages directory if it doesn't exist
if not fs.exists("/mpm/packages") then
    fs.makeDir("/mpm/packages")
end

-- Download each file
for _, file in ipairs(files) do
    if file == "mpm.lua" then
        downloadFile(repository_url .. file, "/" .. file)
    else
        downloadFile(repository_url .. file, "/mpm/" .. file)
    end
end

-- Load the core.lua API
local Core = dofile("/mpm/core.lua")

-- Ask if the user wants to add the default package repository
print("Would you like to add the default package repository? (https://github.com/j-shelfwood/mpm-packages)")
print("(yes/no)")

local answer = read()

if answer == "yes" then
    Core.tap_repository("https://raw.githubusercontent.com/j-shelfwood/mpm-packages")
end

print("MPM has been successfully installed.")
fs.delete("install.lua") -- remove the install script
