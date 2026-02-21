--[[
    Update command: mpm update [package] [package2] ...

    Updates specified packages, or all installed packages if none specified.
]]
local updateModule = nil

updateModule = {
    usage = "mpm update [package] [package2] ...",

    run = function(...)
        local names = {...}
        local PackageDisk = exports("Utils.PackageDisk")
        local Storage = exports("Utils.Storage")

        print("")
        print("Checking for updates...")
        print("")

        local hasSpace, spaceErr = Storage.ensureCriticalFree(8 * 1024, "/")
        if not hasSpace then
            print("Error: " .. (spaceErr or "Insufficient disk space"))
            print("")
            return
        end
        Storage.warnIfLow("/")

        if #names == 0 then
            names = PackageDisk.listInstalled()
            if #names == 0 then
                print("No packages installed.")
                return
            end
        end

        local updated = 0
        local failed = 0

        for _, package in ipairs(names) do
            local success, filesChanged = updateModule.updatePackage(package)
            if success then
                if filesChanged > 0 then
                    updated = updated + 1
                end
            else
                failed = failed + 1
            end
        end

        local pruned = 0
        local pruneFailed = 0
        if failed == 0 then
            pruned, pruneFailed = updateModule.pruneOrphanDependencies()
            if pruned > 0 or pruneFailed > 0 then
                print("Dependency cleanup: " .. pruned .. " removed, " .. pruneFailed .. " failed")
            end
        end

        print("")
        if updated > 0 or failed > 0 then
            print("Done: " .. updated .. " updated, " .. failed .. " failed")
        else
            print("All packages are up to date.")
        end
        Storage.printUsage("Disk usage: ", "/")
        print("")
    end,

    pruneOrphanDependencies = function()
        local PackageDisk = exports("Utils.PackageDisk")
        local StartupConfig = exports("Utils.StartupConfig")
        local packages = PackageDisk.listInstalled()

        local roots = {}
        for _, pkg in ipairs(packages) do
            if PackageDisk.getInstallReason(pkg) == "manual" then
                roots[pkg] = true
            end
        end

        if StartupConfig and StartupConfig.isConfigured() then
            local config = StartupConfig.getConfig()
            if config and config.package and PackageDisk.isInstalled(config.package) then
                roots[config.package] = true
            end
        end

        local graph = PackageDisk.getDependencyGraph()
        local keep = {}
        local queue = {}

        for root in pairs(roots) do
            keep[root] = true
            queue[#queue + 1] = root
        end

        local i = 1
        while i <= #queue do
            local pkg = queue[i]
            i = i + 1
            local deps = graph[pkg] or {}
            for dep in pairs(deps) do
                if PackageDisk.isInstalled(dep) and not keep[dep] then
                    keep[dep] = true
                    queue[#queue + 1] = dep
                end
            end
        end

        local removed = 0
        local failed = 0

        for _, pkg in ipairs(packages) do
            if PackageDisk.getInstallReason(pkg) == "dependency" and not keep[pkg] then
                if PackageDisk.remove(pkg) then
                    removed = removed + 1
                else
                    failed = failed + 1
                end
            end
        end

        return removed, failed
    end,

    updatePackage = function(package)
        local File = exports("Utils.File")
        local PackageDisk = exports("Utils.PackageDisk")
        local Repo = exports("Utils.PackageRepository")

        print("@" .. package)

        if not PackageDisk.isInstalled(package) then
            print("  Package not installed. Use: mpm install " .. package)
            return false, 0
        end

        local localManifest = PackageDisk.getManifest(package)

        local manifest, err = Repo.getPackage(package)
        if not manifest then
            print("  Error: " .. (err or "Failed to fetch manifest"))
            return false, 0
        end

        local existingReason = PackageDisk.getInstallReason(package)
        manifest._installReason = existingReason
        manifest._installedAt = (localManifest and localManifest._installedAt) or manifest._installedAt

        if manifest.dependencies and type(manifest.dependencies) == "table" then
            for _, dep in ipairs(manifest.dependencies) do
                if not PackageDisk.isInstalled(dep) then
                    print("  Installing missing dependency: " .. dep)
                    local depInstalled = PackageDisk.install(dep, "dependency")
                    if not depInstalled then
                        print("  Error: Failed to install dependency '" .. dep .. "'")
                        return false, 0
                    end
                end
            end
        end

        local changedFiles, stageErr = updateModule.stageFileChanges(package, manifest)
        if not changedFiles then
            print("  Error: " .. (stageErr or "Failed to download files"))
            return false, 0
        end

        local changedCount, writeFailed = updateModule.writeChangedFiles(package, changedFiles)
        if writeFailed then
            return false, 0
        end

        local manifestPath = "/mpm/Packages/" .. package .. "/manifest.json"
        if not File.put(manifestPath, textutils.serializeJSON(manifest)) then
            print("  Error: Failed to save manifest")
            return false, 0
        end

        local removedFiles = updateModule.pruneRemovedFiles(package, localManifest, manifest)

        if changedCount == 0 and removedFiles == 0 then
            print("  (up to date)")
        end

        return true, (changedCount + removedFiles)
    end,

    stageFileChanges = function(package, manifest)
        local File = exports("Utils.File")
        local Repo = exports("Utils.PackageRepository")
        local changes = {}

        if not manifest.files or type(manifest.files) ~= "table" then
            return changes, nil
        end

        for _, file in ipairs(manifest.files) do
            local remoteContent, err = Repo.downloadFile(package, file)
            if not remoteContent then
                return nil, (err or ("Failed to download " .. file))
            end

            local path = "/mpm/Packages/" .. package .. "/" .. file
            local localContent = File.get(path)
            if localContent ~= remoteContent then
                changes[file] = remoteContent
            end
        end

        return changes, nil
    end,

    writeChangedFiles = function(package, changes)
        local File = exports("Utils.File")
        local count = 0
        local failed = false

        for file, content in pairs(changes) do
            local path = "/mpm/Packages/" .. package .. "/" .. file
            if File.put(path, content) then
                print("  + " .. file)
                count = count + 1
            else
                print("  x " .. file .. " (write failed)")
                failed = true
            end
        end

        return count, failed
    end,

    pruneRemovedFiles = function(package, localManifest, remoteManifest)
        local File = exports("Utils.File")

        if not localManifest or type(localManifest.files) ~= "table" then
            return 0
        end

        local remoteFiles = {}
        if remoteManifest and type(remoteManifest.files) == "table" then
            for _, file in ipairs(remoteManifest.files) do
                remoteFiles[file] = true
            end
        end

        local removed = 0
        for _, oldFile in ipairs(localManifest.files) do
            if not remoteFiles[oldFile] then
                local stalePath = "/mpm/Packages/" .. package .. "/" .. oldFile
                if File.exists(stalePath) then
                    if File.delete(stalePath) then
                        print("  - " .. oldFile)
                        File.deleteEmptyParents("/mpm/Packages/" .. package, stalePath)
                        removed = removed + 1
                    end
                end
            end
        end

        return removed
    end
}

return updateModule
