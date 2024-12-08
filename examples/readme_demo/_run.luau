function load_tests()
    require("./the_test")()
end

function run_tests()
    local frktest = require("@frktest/frktest")
    local console_reporter = require("@frktest/reporters/console_reporter")

    console_reporter.init()
    frktest.run()
end

load_tests()
run_tests()
