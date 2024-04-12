function load_tests()
    require("./the_test")()
end

function run_tests()
    local frktest = require("@frktest/frktest")
    local lune_console_reporter = require("@frktest/reporters/lune_console_reporter")

    lune_console_reporter.init()
    frktest.run()
end

load_tests()
run_tests()
