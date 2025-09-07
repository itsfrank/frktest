function load_tests()
    require("../basic_assertions")()
end

function run_tests()
    -- same as run, but uses the entrypoint.luau entrypoint script, like a pesde project would
    local frktest = require("../../src/entrypoint")
    local console_reporter = frktest.reporters.console_reporter

    console_reporter.init()
    local success = frktest.run()
    return success
end

load_tests()
run_tests()
