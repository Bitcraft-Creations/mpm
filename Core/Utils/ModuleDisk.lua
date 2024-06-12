--[[
    The ModuleDisk module is used to handle disk operations related to updating and installing modules
    into the mpm/Packages directory.

    A module is a directory in the mpm/Packages directory. The name of the module is the name
    of the directory. The module contains a manifest.json file which contains:
    - manifest.name
    - manifest.description
    - manifest.modules (a table of strings representing .lua files to download)
]] local this = nil
local repositoryUrl = "https://shelfwood-mpm-packages.netlify.app/"

this = {
    installModule = function(module, package)
        local response = http.get(repositoryUrl .. module .. "/" .. package)
        return response.readAll()
    end,
    isInstalled = function(module)
        return exports("Utils.File").exists("/mpm/Packages/" .. module)
    end
}

return this
