--[[
    Prune command: mpm prune [--dry-run]

    Removes orphaned dependency packages no longer required by any
    manually installed package.
]]
local pruneModule = nil

pruneModule = {
    usage = "mpm prune [--dry-run]",

    run = function(flag)
        local PackageDisk = exports("Utils.PackageDisk")
        local StartupConfig = exports("Utils.StartupConfig")
        local Storage = exports("Utils.Storage")

        local dryRun = (flag == "--dry-run" or flag == "-n")
        local packages = PackageDisk.listInstalled()
        if #packages == 0 then
            print("No packages installed.")
            return
        end

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
            queue[#queue + 1] = root
            keep[root] = true
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

        local orphans = {}
        for _, pkg in ipairs(packages) do
            local reason = PackageDisk.getInstallReason(pkg)
            if reason == "dependency" and not keep[pkg] then
                orphans[#orphans + 1] = pkg
            end
        end

        if #orphans == 0 then
            print("No orphaned dependencies found.")
            return
        end

        print("")
        if dryRun then
            print("Orphaned dependencies (dry run):")
            for _, pkg in ipairs(orphans) do
                print("  - @" .. pkg)
            end
            print("")
            print("Run without --dry-run to remove them.")
            return
        end

        print("Removing orphaned dependencies:")
        local removed = 0
        local failed = 0

        for _, pkg in ipairs(orphans) do
            if PackageDisk.remove(pkg) then
                removed = removed + 1
            else
                failed = failed + 1
            end
        end

        print("")
        print("Prune complete: " .. removed .. " removed, " .. failed .. " failed")
        Storage.printUsage("Disk usage: ", "/")
        print("")
    end
}

return pruneModule
