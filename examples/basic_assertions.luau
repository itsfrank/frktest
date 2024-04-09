local frktest = require("@frktest/frktest")
local test = frktest.test
local check = frktest.assert.check
local require = frktest.assert.require

return function()
    test.suite("Check and require", function()
        test.case("checks", function()
            -- checks dont halt the test
            check.equal(1, 100)
            check.equal(2, 100)
        end)

        test.case("require", function()
            -- requires do halt the test
            require.equal(1, 100)
            require.equal(2, 100) -- this will never run
        end)
    end)

    test.suite("Basic type equality", function()
        test.case("numbers", function()
            check.equal(10, 11)
        end)

        test.case("booleans", function()
            check.equal(false, true)
        end)

        test.case("strings", function()
            check.equal("foo", "bar")
        end)
    end)
end
