local listModule = nil

listModule = {
    usage = "mpm list",

    run = function()
        print("\nListing installed packages:")
        local files = exports("utils.file").list("/mpm/packages/")
        for _, file in ipairs(files) do
            print("  - " .. file)
        end
    end,
}

return listModule