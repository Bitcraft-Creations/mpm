local this = nil
--[[
    The ModuleDisk module is used to handle disk operations related to updating and installing packages
    into the mpm/Packages directory.

    A package is a directory in the mpm/Packages directory. The name of the package is the name
    of the directory. The package contains a manifest.json file which contains:
    - manifest.name
    - manifest.description
    - manifest.files (a table of strings representing files to download)
]]
local repositoryUrl = "https://shelfwood-mpm-packages.netlify.app/"
local packageDirectory = "/mpm/Packages/"

this = {
    install = function(name)
        -- Construct the path to the package's manifest.json (similar to manifest.json)
        local manifest = exports("Utils.PackageRepository").getPackage(name)
        print("\n@" .. manifest.name .. "\n")
        print(manifest.description)

        -- Save the manifest to the package directory
        exports("Utils.File").put(packageDirectory .. name .. "/manifest.json", textutils.serializeJSON(manifest))

        -- Install each file within the package
        for _, file in ipairs(manifest.files) do
            this.installFile(name, file)
        end

        print("\nSuccessfully installed @" .. name .. '!\n')
    end,
    installFile = function(package, file)
        print("- " .. file)

        local content = exports("Utils.PackageRepository").downloadFile(package, file)
        local filePath = packageDirectory .. package .. "/" .. file

        exports("Utils.File").put(filePath, content)
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
