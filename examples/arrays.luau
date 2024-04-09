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
    end)
end
