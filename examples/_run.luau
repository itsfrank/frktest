function load_tests()
    -- tests execute in the order they are loaded
    require("./suites_cases")()
    require("./basic_assertions")()
    require("./messages")()
    require("./errors")()
    require("./parametrized")()
    require("./arrays")()
    require("./tables")()
    -- require("./only")() -- this file contains test.only definitions, uncomment and only these definitions will run
end

function run_tests()
    local frktest = require("@frktest/frktest")
    local lune_console_reporter = require("@frktest/reporters/lune_console_reporter")

    lune_console_reporter.init()
    local success = frktest.run()
    if not success then
        require("@lune/process").exit(1)
    end
end

load_tests()
run_tests()
