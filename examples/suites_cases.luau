local frktest = require("@frktest/frktest")
local test = frktest.test
local check = frktest.assert.check

return function()
    -- use suites to group test cases together
    test.suite("A collection of test cases", function()
        test.case("case 1", function()
            check.is_true(false)
        end)

        test.case("case 2", function()
            check.is_true(false)
        end)
    end)

    -- casses don't have to be in a suite
    -- global tests run before suites no matter where they are defined
    test.case("case in the global suite", function()
        check.is_true(false)
    end)
end
