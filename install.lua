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

-- Download manifest.json
downloadFile(mpm_repository_url .. "manifest.json", "/mpm/manifest.json")

-- Load the manifest
local manifest = fs.open("/mpm/manifest.json", "r")
local manifest = textutils.unserialiseJSON(manifest.readAll())

-- Download each module
for _, moduleName in ipairs(manifest) do
    downloadFile(mpm_repository_url .. moduleName .. ".lua", "/mpm/" .. moduleName .. ".lua")
    if moduleName == "mpm" then
        fs.move("/mpm/mpm.lua", "/" .. moduleName .. ".lua")
    end
end

-- Load the core.lua API
-- dofile("/mpm/core.lua")

print("MPM has been successfully installed.")
