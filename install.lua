--[[
    MPM Installer

    Run with: wget run https://shelfwood-mpm.netlify.app/install.lua

    This script downloads and installs MPM (Minecraft Package Manager)
    on a CC:Tweaked computer.
]]

local mpm_repository_url = "https://shelfwood-mpm.netlify.app/"

--- Download a file from URL to local path
--- @param url string Source URL
--- @param path string Destination path
--- @return boolean success
local function downloadFile(url, path)
    local response = http.get(url)

    if not response then
        print("x " .. path .. " (failed to connect)")
        return false
    end

    local code = response.getResponseCode()
    if code ~= 200 then
        print("x " .. path .. " (HTTP " .. code .. ")")
        response.close()
        return false
    end

    local content = response.readAll()
    response.close()

    if not content then
        print("x " .. path .. " (empty response)")
        return false
    end

    -- Ensure directory exists
    local dirPath = fs.getDir(path)
    if dirPath and dirPath ~= "" and not fs.exists(dirPath) then
        fs.makeDir(dirPath)
    end

    local file = fs.open(path, "w")
    if not file then
        print("x " .. path .. " (cannot write)")
        return false
    end

    file.write(content)
    file.close()
    print("+ " .. path)
    return true
end

-- Main installation
print("")
print("=== MPM Installer ===")
print("")

-- Create directories
if not fs.exists("/mpm") then
    fs.makeDir("/mpm")
end

if not fs.exists("/mpm/Packages") then
    fs.makeDir("/mpm/Packages")
end

if not fs.exists("/mpm/Core") then
    fs.makeDir("/mpm/Core")
end

if not fs.exists("/mpm/Core/Commands") then
    fs.makeDir("/mpm/Core/Commands")
end

if not fs.exists("/mpm/Core/Utils") then
    fs.makeDir("/mpm/Core/Utils")
end

-- Fetch manifest
print("Fetching file list...")
local response = http.get(mpm_repository_url .. "manifest.json")

if not response then
    print("")
    print("Error: Failed to connect to MPM repository.")
    print("Check your internet connection and try again.")
    return
end

local content = response.readAll()
response.close()

if not content then
    print("")
    print("Error: Empty response from server.")
    return
end

local manifest = textutils.unserialiseJSON(content)

if not manifest then
    print("")
    print("Error: Invalid manifest format.")
    return
end

print("Installing " .. #manifest .. " files...")
print("")

-- Download each file
local success = 0
local failed = 0

for _, file in ipairs(manifest) do
    local targetPath = "/mpm/" .. file

    -- mpm.lua goes to root
    if file == "mpm.lua" then
        targetPath = "/mpm.lua"
    end

    if downloadFile(mpm_repository_url .. file, targetPath) then
        success = success + 1
    else
        failed = failed + 1
    end
end

print("")

if failed > 0 then
    print("Warning: " .. failed .. " file(s) failed to download.")
    print("Run 'mpm self_update' to retry.")
else
    print("MPM installed successfully!")
end

print("")
print("Usage:")
print("  mpm help           - Show all commands")
print("  mpm install <pkg>  - Install a package")
print("  mpm list remote    - View available packages")
print("")
