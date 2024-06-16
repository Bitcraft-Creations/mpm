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

        -- Convert command to lowercase for case-insensitive matching
        local commandLower = command:lower()
        local files = fs.list("/mpm/Core/Commands/")
        local matchedFile = nil

        for _, file in ipairs(files) do
            print(file, file:lower())
            -- Remove .lua and match it with the command
            if file:find(".lua") and file:sub(1, -5):lower() == commandLower then
                matchedFile = file
                break
            end
        end

        if not matchedFile then
            error("Error: Command does not exist.")
        end

        local commandPath = string.format("/mpm/Core/Commands/%s", matchedFile)
        local module = dofile(commandPath)

        if module and module.run then
            return module.run(table.unpack(tArgs, 2))
        end

        error("Error: Command module is not properly defined.")
    end
}

return bootstrapModule
