-- i'm not a fan of having a single entrypoint, but this seems to be idiomatic for pesde
-- with this, reporters will be acessible to folks who want to consume the lib through the pesde generated file
local frktest = require("./frktest")

local console_reporter = require("./reporters/console_reporter")
type ConsoleReporter = typeof(console_reporter)

local reporters = {
    lune_console_reporter = nil :: any, -- kept here for lsp purposes
    console_reporter = console_reporter,
}

setmetatable(reporters, {
    __index = function(_, k)
        if k == "lune_console_reporter" then
            warn("[DEPRECATED] lune_console_reporter is deprecated, use console_reporter instead\n")
            return console_reporter
        end
        return nil :: any
    end,
})

type T = typeof(frktest) & { _reporters: typeof(reporters) }

(frktest :: any)._reporters = reporters

return frktest :: T
