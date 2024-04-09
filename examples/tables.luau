local frktest = require("@frktest/frktest")
local test = frktest.test
local check = frktest.assert.check

return function()
    test.suite("Tables", function()
        test.case("equal", function()
            local a = { foo = 1 }
            local b = { foo = 1 }
            local c = a
            check.equal(a, b) -- fails, equal checks the address of tables
            check.not_equal(a, c) -- fails, the liter
        end)
    end)
end
