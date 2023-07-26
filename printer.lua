-- printer.lua
local Printer = {}

local colors = {
    header = colors.blue,
    normal = colors.white,
    warning = colors.red
}

function Printer.printHeader(text)
    term.setTextColor(colors.header)
    print("\n--- " .. text .. " ---\n")
    term.setTextColor(colors.normal)
end

function Printer.print(text)
    print(text)
end

function Printer.printWarning(text)
    term.setTextColor(colors.warning)
    print(text)
    term.setTextColor(colors.normal)
end

return Printer
