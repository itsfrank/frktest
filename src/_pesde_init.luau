-- i'm not a fan of having a single entrypoint, but this seems to be idiomatic for pesde
-- with this, reporters will be acessible to folks who want to consume the lib through the pesde generated file
local frktest = require("./frktest")

local reporters = {
    lune_console_reporter = require("./reporters/console_reporter"), --- kept only for backwards compatibility
    console_reporter = require("./reporters/console_reporter"),
}

type T = typeof(frktest) & { _reporters: typeof(reporters) }

(frktest :: any)._reporters = reporters

return frktest :: T
