-- This file is used to install MPM
local mpm_repository_url = "https://shelfwood-mpm.netlify.app/"

-- Function to download a file from a URL
local function downloadFile(url, path)
    local response = http.get(url)
    if response and response.getResponseCode() == 200 then
        local content = response.readAll()
        local file = fs.open(path, "w")
        file.write(content)
        file.close()
        print("- " .. path)
    else
        print("x " .. path)
    end
    response.close()
end

-- Create the /mpm directory if it doesn't exist
if not fs.exists("/mpm") then
    fs.makeDir("/mpm")
end

-- Create the /mpm/Packages directory if it doesn't exist
if not fs.exists("/mpm/Packages") then
    fs.makeDir("/mpm/Packages")
end

local response = http.get(mpm_repository_url .. "manifest.json")
local content = response.readAll()
response.close()

local manifest = textutils.unserialiseJSON(content)

-- Download each file in the manifest

for _, file in ipairs(manifest) do
    downloadFile(mpm_repository_url .. file, "/mpm/" .. file)
    if file == "mpm.lua" then
        fs.move("/mpm/mpm.lua", "/" .. file)
    end
end

print("MPM has been successfully installed.")
