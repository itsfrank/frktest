export type Runtime = "lune" | "zune" | "lute" | "unknown"

return function(): Runtime
    if type(_VERSION) == "string" and string.sub(_VERSION, 1, 4) == "Lune" then
        return "lune"
    elseif type(_VERSION) == "string" and string.sub(_VERSION, 1, 4) == "Zune" then
        return "zune"
    else
        -- test for runtimes that require a pcall last
        -- lute
        local ok, _ = pcall(function()
            return (require)("@lute/process")
        end)
        if ok then
            return "lute"
        end

        return "unknown"
    end
end
