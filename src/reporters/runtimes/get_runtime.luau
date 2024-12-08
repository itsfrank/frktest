export type Runtime = "lune" | "unknown"

return function(): Runtime
    if type(_VERSION) == "string" and string.sub(_VERSION, 1, 4) == "Lune" then
        return "lune"
    end
    return "unknown"
end

