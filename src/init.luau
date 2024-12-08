-- i'm not a fan of having a single entrypoint, but this seems to be idiomatic for pesde/wally
-- with this, reporters will be acessible to folks who want to consume the lib through a single entrypoint
local frktest = require("./frktest")

local console_reporter = require("./reporters/console_reporter")
type ConsoleReporter = typeof(console_reporter)

local reporters = {
    console_reporter = console_reporter,
}

setmetatable(reporters, {
    __index = function(_, k)
        -- for backwards-compatibility
        if k == "lune_console_reporter" then
            warn("[DEPRECATED] lune_console_reporter is deprecated, use console_reporter instead\n")
            return console_reporter
        end
        return nil :: any
    end,
})

type T = typeof(frktest) & { reporters: typeof(reporters) }

(frktest :: any)._reporters = reporters; -- kept for backwards compatibility
(frktest :: any).reporters = reporters

return frktest :: T
