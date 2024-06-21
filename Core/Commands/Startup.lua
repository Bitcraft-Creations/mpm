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
        local startup_content = [[
print("Press Enter to start the mpm update, or type 'cancel' to abort:")
local input = read()
if input == "cancel" then
    print("Startup script aborted.")
    return
end
shell.run('mpm update')
shell.run('mpm run ]] .. package .. " " .. parameters .. [[')
]]

        -- Write the startup script content to startup.lua
        exports("Utils.File").put("./startup.lua", startup_content)

        print("Startup script set successfully!")
    end
}

return startupModule
