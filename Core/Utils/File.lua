-- The `File` module contains helpers to read and write to files.
-- It uses computercraft's `fs` module to read and write to files.
local this

local function ensureParentDirectory(path)
    local dirPath = fs.getDir(path)
    if dirPath ~= "" and not fs.exists(dirPath) then
        fs.makeDir(dirPath)
    end
end

local function tempPathFor(path)
    local token = tostring(math.random(100000, 999999))
    return path .. ".mpm.tmp." .. token
end

this = {
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
        ensureParentDirectory(path)

        for _, stale in ipairs(fs.find(path .. ".mpm.tmp.*")) do
            pcall(fs.delete, stale)
        end

        local tmpPath = tempPathFor(path)
        local file = fs.open(tmpPath, "w")
        if not file then
            print("Error: Unable to open file for writing: " .. path)
            return false
        end
        file.write(content)
        file.close()

        if fs.exists(path) then
            local deleted = pcall(fs.delete, path)
            if not deleted then
                pcall(fs.delete, tmpPath)
                print("Error: Unable to replace file: " .. path)
                return false
            end
        end

        local moved = pcall(fs.move, tmpPath, path)
        if not moved then
            pcall(fs.delete, tmpPath)
            print("Error: Unable to finalize file write: " .. path)
            return false
        end

        return true
    end,
    exists = function(path)
        local exists = fs.exists(path)
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
    deleteEmptyParents = function(rootPath, path)
        if not rootPath or not path then
            return
        end

        local dir = fs.getDir(path)
        while dir and dir ~= "" and dir ~= rootPath do
            if not fs.exists(dir) or not fs.isDir(dir) then
                break
            end

            local children = fs.list(dir)
            if #children > 0 then
                break
            end

            local deleted = pcall(fs.delete, dir)
            if not deleted then
                break
            end

            dir = fs.getDir(dir)
        end
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
        local success = this.put(path, content)
        if not success then
            print("Error: Unable to save downloaded content to file: " .. path)
            return false
        end

        return true
    end
}

return this
