function load_tests()
    -- tests execute in the order they are loaded
    require("./suites_cases")()
    require("./basic_assertions")()
    require("./messages")()
    require("./errors")()
    require("./parametrized")()
    require("./arrays")()
    require("./tables")()
    require("./skip")()
    -- require("./focus")() -- this file contains test.focus definitions, uncomment and only these definitions will run
end

function run_tests()
    local frktest = require("@frktest/frktest")
    local console_reporter = require("@frktest/reporters/console_reporter")

    console_reporter.init()
    local success = frktest.run()
    return success
end

load_tests()
local passed = run_tests()

-- return non-0 exit code on failure (runtime-dependent)
if not passed then
    -- use the version of your preferred runtime
    -- require("@lune/process").exit(1) -- lune
    -- zune.process.exit(1) -- zune

    -- this might do the trick in a version-agnostic way, but it's noisy
    -- error("tests failed")
end
