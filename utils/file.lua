-- The `File` module contains helpers to read and write to files.
-- It uses computercraft's `fs` module to read and write to files.
local File

File = {
    get = function(path)
        local file = fs.open(path, "r")
        local content = file.readAll()
        file.close()
        return content
    end,
    put = function(path, content)
        local file = fs.open(path, "w")
        file.write(content)
        file.close()
    end,
    exists = function(path)
        return fs.exists(path)
    end,
    list = function(path)
        return fs.list(path)
    end,
    makeDirectory = function(path)
        fs.makeDir(path)
    end,
    delete = function(path)
        fs.delete(path)
    end,
    download = function(url, path)
        -- Attempt to open a connection to the given URL
        local response = http.get(url)

        if not response then
            return false
        end

        local content = response.readAll()
        response.close()

        -- Save the content to the specified path
        File.put(path, content)

        return true
    end
}

return File

