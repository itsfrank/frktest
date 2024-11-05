local frktest = require("@frktest/frktest")
local test = frktest.test
local check = frktest.assert.check

-- use test.focus variants of the case/suire functions to temporarily skip all but one test/suite
return function()
    -- can be used on suites to run only one suite
    test.focus.suite("Only run me [suite]", function()
        test.case("test 1", function()
            check.equal(1, 2)
        end)

        test.case("test 2", function()
            check.equal(1, 2)
        end)
    end)

    -- can be used on case to run only one case
    -- note: focus.case takes precedence over focus.suite, comment out this test to focus on the suite 
    test.focus.case("Only run me [test]", function()
        check.equal(1, 2)
    end)
end
