local utils = {}

-- i think this is a lune issue, but debug.info returns [string "<filename>"]
function utils.clean_filename(name: string): string
    local front_trimmed = name:sub(10)
    return front_trimmed:sub(1, -3)
end

function utils.trim(s: string): string
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function utils.make_indent(i: number): string
    local spaces = "    "
    local s = ""
    for j = 0, i - 1 do
        s = s .. spaces
    end
    return s
end

function utils.multiline_to_array(s: string): { [number]: string }
    local res = {}
    for line in string.gmatch(s .. "\n", "(.-)\n") do
        table.insert(res, line)
    end
    return res
end

function utils.indent_multiline(s: string, i: number): string
    local res = ""
    for _, s in ipairs(utils.multiline_to_array(s)) do
        res ..= utils.make_indent(i) .. s .. "\n"
    end
    return res
end

return utils
