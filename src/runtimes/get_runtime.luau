export type Runtime = "lune" | "zune" | "seal" | "unknown"

return function(): Runtime
    if -- lune
        type(_VERSION) == "string" and string.sub(_VERSION, 1, 4) == "Lune"
    then
        return "lune"
    elseif --zune
        type(_VERSION) == "string" and string.sub(_VERSION, 1, 4) == "Zune"
    then
        return "zune"
    elseif --seal
        pcall(function()
            require("@std/io/colors")
        end)
    then
        return "seal"
    end
    return "unknown"
end
