-- install.lua
local mpm_repository_url = "https://shelfwood-mpm.netlify.app/"

-- Function to download a file from a URL
local function downloadFile(url, path)
    print(url)
    print(path)
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

-- Download manifest.json
downloadFile(mpm_repository_url .. "manifest.json", "/mpm/manifest.json")

-- Load the manifest
local manifest = fs.open("/mpm/manifest.json", "r")
local manifest = textutils.unserialiseJSON(manifest.readAll())
manifest.close()

-- Download each file
for _, file in ipairs(manifest) do
    downloadFile(mpm_repository_url .. file, "/mpm/" .. file)
    if file == "mpm.lua" then
        fs.move("/mpm/mpm.lua", "/" .. file)
    end
end

-- Load the core.lua API
-- dofile("/mpm/core.lua")

print("MPM has been successfully installed.")
