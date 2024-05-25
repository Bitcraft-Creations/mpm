-- install.lua
local mpm_repository_url = "https://shelfwood-mpm.netlify.app/"

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

-- Download filelist.lua
downloadFile(mpm_repository_url .. "filelist.lua", "/mpm/filelist.lua")

-- Load the filelist
local files = dofile("/mpm/filelist.lua")

-- Download each file
for _, file in ipairs(files) do
    downloadFile(mpm_repository_url .. file, "/mpm/" .. file)
    if file == "mpm.lua" then
        fs.move("/mpm/mpm.lua", "/" .. file)
    end
end

-- Load the core.lua API
local Core = dofile("/mpm/core.lua")

print("MPM has been successfully installed.")
