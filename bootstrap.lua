local bootstrapModule = nil
local modules = {}

function exports(moduleNamespace)
    local modulePath = string.format("/mpm/Core/%s.lua", moduleNamespace:gsub("%.", "/"))
    
    if not fs.exists(modulePath) then
        error("The util " .. moduleNamespace .. " does not exist.")
    end

    if not modules[moduleNamespace] then
        modules[moduleNamespace] = dofile(modulePath)
    end

    return modules[moduleNamespace]
end

bootstrapModule = {
    printUsage = function()
        print("Usage:")

        local files = fs.list("/mpm/Core/Commands/")

        for _, file in ipairs(files) do
            if not file:find(".lua") then
                return
            end

            local module = dofile("/mpm/Core/Commands/" .. file)
            print(module.usage or "No usage specified.")
        end
    end,

    handleCommand = function(tArgs)
        local command = tArgs[1]

        if not command then
            bootstrapModule.printUsage()
            return
        end

        local commandPath = string.format("/mpm/Core/Commands/%s.lua", command)

        if not fs.exists(commandPath) then
            error("Error: Command does not exist.")
        end

        local module = dofile(commandPath)

        if module and module.run then
            return module.run(table.unpack(tArgs, 2))
        end

        error("Error: Command module is not properly defined.")
    end
}

return bootstrapModule
