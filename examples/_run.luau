function load_tests()
    -- tests execute in the order they are loaded
    require("./basic_assertions")()
    require("./messages")()
    require("./errors")()
    require("./parametrized")()
    require("./tables")()
end

function run_tests()
    local frktest = require("@frktest/frktest")
    local lune_console_reporter = require("@frktest/reporters/lune_console_reporter")

    lune_console_reporter.init()
    frktest.run()
end

load_tests()
run_tests()
