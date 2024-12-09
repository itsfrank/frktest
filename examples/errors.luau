local frktest = require("./../src/frktest.luau")
local test = frktest.test
local check = frktest.assert.check

return function()
    test.suite("Errors", function()
        test.case("throwing", function()
            error("some error") -- errors end a test
        end)

        test.case("should error", function()
            check.should_error(function()
                return 10
            end)
        end)

        test.case("should not error", function()
            check.should_not_error(function()
                error("some error")
            end)
        end)
    end)
end
