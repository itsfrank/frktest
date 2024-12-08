type Color = "red" | "green" | "yellow" | "purple"

type ColorFn = (Color, string)->string

-- default, fallback to plain print
local color: ColorFn = function(_, s:string)
    return s
end

if type(_VERSION) == "string" and string.sub(_VERSION, 1, 4) === "Lune" then
return function color(c: stdio.Color, s: string)
    return `{stdio.color(c)}{s}{stdio.color("reset")}`
end
else
    -- Running in Roblox
end
