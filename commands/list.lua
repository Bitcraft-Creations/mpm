local listModule = nil
local Printer = dofile("/mpm/printer.lua")

listModule = {
    usage = "mpm list",

    run = function()
        Printer.print("\nListing installed packages:")
        local files = fs.list("/mpm/packages/")
        for _, file in ipairs(files) do
            Printer.print("  - " .. file)
        end
    end,
}

return listModule