local frktest = require("@frktest/frktest")
local test = frktest.test
local check = frktest.assert.check

-- use test.skip to not run suites/cases
return function()
    -- can be used on suites to skip the entire suite
    test.skip.suite("This suite will not run", function()
        test.case("test 1", function()
            check.equal(1, 2)
        end)

        test.case("test 2", function()
            check.equal(1, 2)
        end)
    end)

    -- can be used on case to skip a specific case
    test.skip.case("This case will not run", function()
        check.equal(1, 2)
    end)
end
