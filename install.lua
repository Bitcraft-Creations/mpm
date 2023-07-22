-- Repository URL
local repository_url = "https://raw.githubusercontent.com/j-shelfwood/mpm/main/"

-- File list to download
local files = {"mpm.lua"}

-- Function to download a file
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

-- Create /mpm/packages directory if it doesn't exist
if not fs.exists("/mpm/packages") then
    fs.makeDir("/mpm/packages")
end

-- Download each file
for _, file in ipairs(files) do
    downloadFile(repository_url .. file, "/" .. file)
end

-- Load mpm API
local mpm = dofile("/mpm.lua")

-- Prompt user to add default repository
print("Would you like to add the default package repository? (https://github.com/j-shelfwood/mpm-packages)")
print("(yes/no)")

local answer = read()

if answer == "yes" then
    mpm.tap_repository("https://github.com/j-shelfwood/mpm-packages")
end

print("MPM has been successfully installed.")
fs.delete("install.sh")  -- remove the install script
