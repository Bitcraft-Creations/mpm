local LuaMinifier = {}

local function matchLongBracket(source, index)
    if source:sub(index, index) ~= "[" then
        return nil
    end
    return source:match("^%[(=*)%[", index)
end

local function longBracketClose(equals)
    return "]" .. equals .. "]"
end

function LuaMinifier.minify(source)
    if type(source) ~= "string" then
        return source
    end

    local out = {}
    local i = 1
    local len = #source
    local state = "normal"
    local delimiter = nil

    while i <= len do
        local ch = source:sub(i, i)

        if state == "normal" then
            if ch == "'" or ch == '"' then
                state = "string"
                delimiter = ch
                out[#out + 1] = ch
                i = i + 1
            elseif ch == "[" then
                local eqs = matchLongBracket(source, i)
                if eqs ~= nil then
                    local open = "[" .. eqs .. "["
                    out[#out + 1] = open
                    i = i + #open
                    state = "longstring"
                    delimiter = eqs
                else
                    out[#out + 1] = ch
                    i = i + 1
                end
            elseif ch == "-" and source:sub(i, i + 1) == "--" then
                local eqs = matchLongBracket(source, i + 2)
                if eqs ~= nil then
                    local open = "--[" .. eqs .. "["
                    i = i + #open
                    state = "blockcomment"
                    delimiter = eqs
                else
                    state = "linecomment"
                    i = i + 2
                end
            else
                out[#out + 1] = ch
                i = i + 1
            end
        elseif state == "string" then
            out[#out + 1] = ch
            if ch == "\\" then
                local nextChar = source:sub(i + 1, i + 1)
                if nextChar ~= "" then
                    out[#out + 1] = nextChar
                    i = i + 2
                else
                    i = i + 1
                end
            elseif ch == delimiter then
                state = "normal"
                delimiter = nil
                i = i + 1
            else
                i = i + 1
            end
        elseif state == "longstring" then
            local close = longBracketClose(delimiter or "")
            if source:sub(i, i + #close - 1) == close then
                out[#out + 1] = close
                i = i + #close
                state = "normal"
                delimiter = nil
            else
                out[#out + 1] = ch
                i = i + 1
            end
        elseif state == "linecomment" then
            if ch == "\n" then
                out[#out + 1] = "\n"
                state = "normal"
            end
            i = i + 1
        elseif state == "blockcomment" then
            local close = longBracketClose(delimiter or "")
            if source:sub(i, i + #close - 1) == close then
                i = i + #close
                state = "normal"
                delimiter = nil
            else
                i = i + 1
            end
        end
    end

    return table.concat(out)
end

function LuaMinifier.shouldMinify(filePath, manifest)
    if type(filePath) ~= "string" then
        return false
    end
    if not filePath:match("%.lua$") then
        return false
    end
    if manifest and manifest.minify == false then
        return false
    end
    if manifest and type(manifest.minify) == "table" and type(manifest.minify.exclude) == "table" then
        for _, excluded in ipairs(manifest.minify.exclude) do
            if excluded == filePath then
                return false
            end
        end
    end
    return true
end

return LuaMinifier
