print(_VERSION)

local function dump(obj, breakline)
    breakline = breakline == nil or breakline == true
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        if breakline then
            return string.rep("\t", level)
        else
            return ""
        end
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\"') .. '"'
    end
    wrapKey = function(val, breakline)
        if breakline then
            if type(val) == "number" then
                return "" -- "[" .. val .. "] = "
            elseif type(val) == "string" then
                if string.match(val, "[][-.,%%}{)(]\"'") ~= nil then
                    return "[" .. quoteStr(val) .. "] = "
                else
                    return val .. " = "
                end
            else
                return "[" .. tostring(val) .. "] = "
            end
        else
            if type(val) == "string" then
                if string.match(val, "[][-.,%%}{)(]\"'") ~= nil then
                    return quoteStr(val) .. " = "
                else
                    return val .. " = "
                end
            else
                return ""
            end
        end
    end
    wrapVal = function(val, level, ishead)
        if type(val) == "table" then
            if(val.____already_dumped____)then return quoteStr("nested_table") end
            return dumpObj(val, level, ishead)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level, ishead)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1

        local tokens = {}
        tokens[#tokens + 1] = "{"

        obj.____already_dumped____ = true
        if level < 9 then
            for k, v in pairs(obj) do
                local head = false
                if k == "head" then head = true end
                if(k ~= "____already_dumped____")then
                    local vs = getIndent(level) .. wrapKey(k) .. wrapVal(v, level, head) .. ","
                    if type(k) == "string" and type(v) == "table" and #v > 5 then vs = vs .. " -- " .. k end
                    tokens[#tokens + 1] = vs
                end
            end
            local meta = getmetatable(obj)
            if meta ~= nil then tokens[#tokens + 1] = getIndent(level) .. "__meta = " .. wrapVal(meta, level) .. "," end
        else
            tokens[#tokens + 1] = getIndent(level) .. "..."
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        if breakline then
            if #tokens < 6 or ishead then
                local st = table.concat(tokens, " "):gsub("%s%s+", " ")
                if #st < 50 or ishead  then return st end
            end
            return table.concat(tokens, "\n")
        else
            return table.concat(tokens, " ")
        end
    end
    return dumpObj(obj, 0)
end
t={1,y=2}
print("t", dump(t))
--print(dump(_G))
--[[for k,v in pairs(_G)do
	if type(v) == "table" then
		print(k,"table", table.unpack(v))
	else
		print(k,v)
	end
end
]]

local s = "接收零个或多个整数，将每个整数转换为其对应的UTF-8字节序列, a b c 1 2 3，并返回包含所有这些序列的串联的字符串"
print("len", string.len(s), "utf8.len", utf8.len(s))
for f, c in utf8.codes(s) do
	print("utf8.codes", f, c, utf8.char(c))
end
for i in string.gmatch(s, utf8.charpattern) do
	print(i)
end
