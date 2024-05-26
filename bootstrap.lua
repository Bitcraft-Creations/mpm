local bootstrapModule = nil

bootstrapModule = {
    printUsage = function()
        print("Usage:")

        local files = fs.read("./commands")

        for _, file in ipairs(files) do
            local module = dofile("./commands/" .. file)
            print(module.usage or "No usage specified.")
        end
    end,

    handleCommand = function(tArgs)
        local command = tArgs[1]

        if not command then
            bootstrapModule.printUsage()
            return
        end

        local module = dofile("./commands/" .. command .. ".lua")

        module.run(table.unpack(tArgs, 2))
    end
}

return bootstrapModule