export type Runtime = "lune" | "zune" | "unknown"

return function(): Runtime
    if type(_VERSION) == "string" and string.sub(_VERSION, 1, 4) == "Lune" then
        return "lune"
    elseif type(_VERSION) == "string" and string.sub(_VERSION, 1, 4) == "Zune" then
        return "zune"
    end
    return "unknown"
end
