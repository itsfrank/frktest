local runtime = require("./get_runtime")()
type Color = "red" | "green" | "yellow" | "purple"

type ColorFn = (Color, string) -> string

-- default, fallback to plain print
local color: ColorFn = function(_, s: string)
    return s
end

if runtime == "lune" then
    local stdio = require("@lune/stdio")
    color = function(c, s: string)
        return `{stdio.color(c)}{s}{stdio.color("reset")}`
    end
elseif runtime == "zune" then
    local stdio = zune.stdio
    color = function(c, s: string)
        if c == "purple" then
            c = "magenta" :: any
        end
        return `{stdio.color(c)}{s}{stdio.reset()}`
    end
end

return color :: ColorFn
