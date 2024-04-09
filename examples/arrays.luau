local frktest = require("@frktest/frktest")
local test = frktest.test
local check = frktest.assert.check

return function()
    test.suite("Arrays", function()
        test.case("contains", function()
            local a = { "one", "two", "three", "four", "five" }
            check.array.contains(a, "eleven") -- check for one value
            check.array.contains(a, { "four", "five", "six", "seven" }) -- check for multiple values
        end)

        test.case("equal changed", function()
            local a = { 1, 2, 3, 4, 5 }
            local b = { 1, 2, 10, 4, 5 }
            check.array.equal(a, b)
        end)

        test.case("equal extra", function()
            local a = { 1, 2, 3, 4, 5 }
            local b = { 1, 2, 3, 4, 5, 6, 7 }
            check.array.equal(a, b)
        end)

        test.case("equal fewer", function()
            local a = { 1, 2, 3, 4, 5 }
            local b = { 1, 2, 3 }
            check.array.equal(a, b)
        end)

        test.case("equal changed and more", function()
            local a = { 1, 2, 3, 4, 5 }
            local b = { 1, 20, 3, 4, 5, 6, 7 }
            check.array.equal(a, b)
        end)
    end)
end
