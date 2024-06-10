local startupModule = nil

startupModule = {
    usage = "mpm startup",

    run = function()
        -- Prompt user for package name
        print("Enter the name of the package you wish to set as the startup script:")
        local package = read()

        -- Prompt user for optional parameters
        print("Enter any optional parameters to pass to the package (leave blank for none):")
        local parameters = read()

        -- Construct the startup script content
        local startup_content = "shell.run('mpm update')\n"
        startup_content = startup_content .. "shell.run('mpm run " .. package .. " " .. parameters .. "')"

        -- Write the startup script content to startup.lua
        local file = exports("Utils.File").open("./startup.lua", "w")
        file.write(startup_content)
        file.close()

        print("Startup script set successfully!")
    end,
}

return startupModule