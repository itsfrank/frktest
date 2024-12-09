function load_tests()
    require("./the_test.luau")()
end

function run_tests()
    local frktest = require("./src/frktest.luau")
    local console_reporter = require("./src/console_reporter.luau")

    console_reporter.init()
    frktest.run()
end

load_tests()
run_tests()
