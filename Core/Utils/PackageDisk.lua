local this = nil
--[[
    The ModuleDisk module is used to handle disk operations related to updating and installing modules
    into the mpm/Packages directory.

    A module is a directory in the mpm/Packages directory. The name of the module is the name
    of the directory. The module contains a manifest.json file which contains:
    - manifest.name
    - manifest.description
    - manifest.modules (a table of strings representing .lua files to download)
]]
local repositoryUrl = "https://shelfwood-mpm-packages.netlify.app/"
local packageDirectory = "/mpm/Packages/"

this = {
    install = function(name)
        -- Construct the path to the module's manifest.json (similar to manifest.json)
        local manifest = exports("Utils.PackageRepository").getPackage(name)
        print("\n@" .. manifest.name .. "\n")
        print(manifest.description)

        -- Install each package within the module
        for _, file in ipairs(manifest.files) do
            this.installFile(package, file)
        end

        print("\nSuccessfully installed @" .. name .. '!\n')
    end,
    installFile = function(package, file)
        print("- " .. file)

        local content = exports("Utils.PackageRepository").downloadFile(package, file)

        exports("Utils.File").put(packageDirectory .. package .. "/" .. file, content)
    end,
    remove = function(package)
        exports("Utils.File").delete(packageDirectory .. package)
        print("\nPackage " .. package .. " removed successfully.\n")
    end,
    isInstalled = function(package)
        return exports("Utils.File").exists(packageDirectory .. package)
    end
}

return this
