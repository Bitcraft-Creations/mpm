local Storage = nil

local PACKAGE_ROOT = "/mpm/Packages"

local function dirSize(path)
    if not fs.exists(path) then
        return 0
    end

    if not fs.isDir(path) then
        return fs.getSize(path)
    end

    local total = 0
    for _, child in ipairs(fs.list(path)) do
        total = total + dirSize(fs.combine(path, child))
    end
    return total
end

Storage = {
    getUsage = function(path)
        path = path or "/"

        local capacityOk, capacity = pcall(fs.getCapacity, path)
        local freeOk, free = pcall(fs.getFreeSpace, path)

        if not capacityOk or type(capacity) ~= "number" or capacity <= 0 then
            return nil, "Capacity data unavailable"
        end

        if not freeOk or type(free) ~= "number" then
            return nil, "Free space data unavailable"
        end

        local used = math.max(0, capacity - free)
        local percent = (used / capacity) * 100

        return {
            path = path,
            capacity = capacity,
            free = free,
            used = used,
            percent = percent
        }, nil
    end,

    formatBytes = function(bytes)
        local units = {"B", "KB", "MB", "GB"}
        local value = bytes
        local unit = 1

        while value >= 1024 and unit < #units do
            value = value / 1024
            unit = unit + 1
        end

        if unit == 1 then
            return string.format("%d %s", value, units[unit])
        end

        return string.format("%.1f %s", value, units[unit])
    end,

    formatUsage = function(usage)
        return string.format(
            "%.1f%% (%s / %s)",
            usage.percent,
            Storage.formatBytes(usage.used),
            Storage.formatBytes(usage.capacity)
        )
    end,

    printUsage = function(prefix, path)
        local usage = Storage.getUsage(path)
        if not usage then
            return false
        end

        print((prefix or "Disk usage: ") .. Storage.formatUsage(usage))
        return true
    end,

    ensureCriticalFree = function(minFreeBytes, path)
        local usage, err = Storage.getUsage(path)
        if not usage then
            return false, err or "Disk usage unavailable"
        end

        if usage.free < minFreeBytes then
            local message = string.format(
                "Low disk space: %s free (< %s required)",
                Storage.formatBytes(usage.free),
                Storage.formatBytes(minFreeBytes)
            )
            return false, message
        end

        return true, nil
    end,

    warnIfLow = function(path)
        local usage = Storage.getUsage(path)
        if not usage then
            return
        end

        if usage.free < 64 * 1024 or usage.percent >= 92 then
            print("Warning: Disk is getting full (" .. Storage.formatUsage(usage) .. ")")
        end
    end,

    largestPackages = function(limit)
        local PackageDisk = exports("Utils.PackageDisk")
        local packages = PackageDisk.listInstalled()
        local entries = {}

        for _, pkg in ipairs(packages) do
            entries[#entries + 1] = {
                name = pkg,
                bytes = dirSize(fs.combine(PACKAGE_ROOT, pkg))
            }
        end

        table.sort(entries, function(a, b)
            return a.bytes > b.bytes
        end)

        if limit and #entries > limit then
            local trimmed = {}
            for i = 1, limit do
                trimmed[i] = entries[i]
            end
            return trimmed
        end

        return entries
    end
}

return Storage
