local frktest = require("@frktest/frktest")
local test = frktest.test
local check = frktest.assert.check
local require = frktest.assert.require

return function()
    test.suite("Passing", function()
        test.case("The only passing test", function()
            check.is_true(true)
        end)
    end)

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

    test.suite("Inequality", function()
        test.case("not equal", function()
            check.not_equal(10, 10)
        end)

        test.case("greater", function()
            check.greater(10, 10)
            check.greater_eq(9, 10)
        end)

        test.case("lesser", function()
            check.lesser(10, 10)
            check.lesser_eq(10, 9)
        end)
    end)

    test.suite("Boolean checks", function()
        test.case("is_true", function()
            check.is_true(false)
        end)

        test.case("is_false", function()
            check.is_false(true)
        end)

        test.case("truthy", function()
            check.truthy(nil)
        end)

        test.case("falsy", function()
            check.falsy(10)
        end)
    end)
end
