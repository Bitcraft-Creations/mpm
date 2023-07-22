-- The URL of your GitHub repository
local repo = "https://raw.githubusercontent.com/j-shelfwood/mpm/master/mpm/"

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

-- Download each file
for _, file in ipairs(files) do
    downloadFile(repo .. file, "/mpm/" .. file)
end

-- Load the mpm API
os.loadAPI("/mpm/mpm.lua")

-- Add the default repository
print("Would you like to add the default package repository? (https://github.com/j-shelfwood/mpm-packages)")
print("(yes/no)")
local answer = read()

if answer == "yes" then
    mpm.tap_repository("https://github.com/j-shelfwood/mpm-packages/")
end

print("Installation completed.")
