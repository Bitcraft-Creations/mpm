local removeModule = nil

removeModule = {
    usage = "mpm remove <package>",

    run = function(package)
        exports("Utils.PackageDisk").remove(package)
    end
}

return removeModule
