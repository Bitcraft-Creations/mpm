-- The `File` module contains helpers to read and write to files.
-- It uses computercraft's `fs` module to read and write to files.
local File

File = {
    get = function(path)
        local file = fs.open(path, "r")
        if not file then
            return nil
        end
        local content = file.readAll()
        file.close()
        return content
    end,
    put = function(path, content)
        -- Check if the file exists, if not create it
        local file = fs.open(path, "w")
        if not file then
            print("Error: Unable to open file for writing: " .. path)
            return false
        end
        file.write(content)
        file.close()
        return true
    end,
    exists = function(path)
        local exists = fs.exists(path)
        if not exists then
            print("Error: File does not exist: " .. path)
        end
        return exists
    end,
    list = function(path)
        local success, result = pcall(fs.list, path)
        if not success then
            print("Error: Unable to list directory: " .. path)
            return nil
        end
        return result
    end,
    makeDirectory = function(path)
        local success, result = pcall(fs.makeDir, path)
        if not success then
            print("Error: Unable to create directory: " .. path)
            return false
        end
        return true
    end,
    delete = function(path)
        local success, result = pcall(fs.delete, path)
        if not success then
            print("Error: Unable to delete file: " .. path)
            return false
        end
        return true
    end,
    download = function(url, path)
        -- Attempt to open a connection to the given URL
        local response = http.get(url)
        if not response then
            print("Error: Unable to download from URL: " .. url)
            return false
        end

        local content = response.readAll()
        response.close()

        -- Save the content to the specified path
        local success = File.put(path, content)
        if not success then
            print("Error: Unable to save downloaded content to file: " .. path)
            return false
        end

        return true
    end
}

return File
