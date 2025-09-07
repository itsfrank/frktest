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
elseif runtime == "lute" then
    local richterm = require("../../lib/lute_batteries/richterm")

    color = function(c: string, s: string)
        if c == "red" then
            return richterm.red(s)
        elseif c == "green" then
            return richterm.green(s)
        elseif c == "yellow" then
            return richterm.yellow(s)
        elseif c == "purple" then
            return richterm.magenta(s)
        end
        return s
    end
end

return color :: ColorFn
