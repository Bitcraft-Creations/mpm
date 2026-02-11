--[[
    MPM Installer
    wget run https://shelfwood-mpm.netlify.app/install.lua
]]

local mpm_url = "https://shelfwood-mpm.netlify.app/"
local tap_url = "https://shelfwood-mpm-packages.netlify.app/"

local logo = [[
 __  __ ___ __  __
|  \/  | _ \  \/  |
| |\/| |  _/ |\/| |
|_|  |_|_| |_|  |_|]]

local function download(url, path)
    local r = http.get(url)
    if not r or r.getResponseCode() ~= 200 then
        if r then r.close() end
        print("  x " .. path)
        return false
    end
    local c = r.readAll()
    r.close()
    local d = fs.getDir(path)
    if d ~= "" and not fs.exists(d) then fs.makeDir(d) end
    local f = fs.open(path, "w")
    if not f then return false end
    f.write(c)
    f.close()
    print("  + " .. path)
    return true
end

local function createTaps()
    local cfg = {
        version = 1,
        defaultTap = "official",
        taps = {
            official = {
                name = "official",
                url = tap_url,
                type = "direct"
            }
        }
    }
    local f = fs.open("/mpm/taps.json", "w")
    if f then
        f.write(textutils.serializeJSON(cfg))
        f.close()
    end
end

-- Main
print("")
print(logo)
print("Minecraft Package Manager")
print("")

-- Directories
for _, d in ipairs({"/mpm", "/mpm/Packages", "/mpm/Core", "/mpm/Core/Commands", "/mpm/Core/Utils"}) do
    if not fs.exists(d) then fs.makeDir(d) end
end

-- Fetch manifest
print("[*] Fetching files...")
local r = http.get(mpm_url .. "manifest.json")
if not r then
    print("[!] Connection failed")
    return
end
local manifest = textutils.unserialiseJSON(r.readAll())
r.close()

if not manifest then
    print("[!] Invalid manifest")
    return
end

-- Download
print("")
local ok, fail = 0, 0
for _, file in ipairs(manifest) do
    local path = file == "mpm.lua" and "/mpm.lua" or "/mpm/" .. file
    if download(mpm_url .. file, path) then ok = ok + 1 else fail = fail + 1 end
end

createTaps()

print("")
if fail > 0 then
    print("[!] " .. fail .. " files failed - run 'mpm self_update'")
else
    print("[+] Installed successfully!")
end

print("")
print("Quick start:")
print("  mpm list remote    View packages")
print("  mpm install <pkg>  Install package")
print("  mpm help           Show all commands")
print("")
