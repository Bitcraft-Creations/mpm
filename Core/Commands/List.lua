local listModule = nil

listModule = {
    usage = "mpm list",

    run = function()
        local files = exports("Utils.File").list("/mpm/Packages/")
        if #files == 0 then
            print("No packages installed.")
            return
        end
        print("\nListing installed packages:\n")

        for _, file in ipairs(files) do
            print("  - " .. file)
        end
    end
}

return listModule
