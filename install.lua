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
end

-- Create the /mpm directory if it doesn't exist
if not fs.exists("/mpm") then
    fs.makeDir("/mpm")
end

-- Create the /mpm/packages directory if it doesn't exist
if not fs.exists("/mpm/packages") then
    fs.makeDir("/mpm/packages")
end

local manifest = textutils.unserialiseJSON(http.get(mpm_repository_url .. "manifest.json").readAll())

-- Download each file in the manifest

for _, file in ipairs(manifest) do
    downloadFile(mpm_repository_url .. file, "/mpm/Core/" .. file)
    if file == "mpm.lua" then
        fs.move("/mpm/mpm.lua", "/" .. file)
    end
end

print("MPM has been successfully installed.")
