-- The URL of your GitHub repository
local repository_url = "https://raw.githubusercontent.com/j-shelfwood/mpm/main/"

-- A list of files to download
local files = {"mpm.lua"}

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

        print("File " .. path .. " downloaded successfully.")
    else
        print("Failed to download " .. path)
    end
end

-- Create the mpm directory if it doesn't exist
if not fs.exists("/mpm") then
    fs.makeDir("/mpm")
end

-- Create the /mpm/packages directory if it doesn't exist
if not fs.exists("/mpm/packages") then
    fs.makeDir("/mpm/packages")
end

-- Download the mpm.lua file
downloadFile(repository_url .. "mpm.lua", "mpm.lua")

-- Now you can use the MPM functions like this
local MPM = dofile("mpm.lua")

-- Add the default repository
print("Would you like to add the default package repository? (https://github.com/j-shelfwood/mpm-packages)")
print("(yes/no)")

local answer = read()

if answer == "yes" then
    MPM.tap_repository("https://github.com/j-shelfwood/mpm-packages")
end

print("MPM has been successfully installed.")
fs.delete("install.lua")  -- remove the install script
