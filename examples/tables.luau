local frktest = require("@frktest/frktest")
local test = frktest.test
local check = frktest.assert.check

return function()
    test.suite("Tables", function()
        test.case("value equal", function()
            local a = { foo = 1 }
            local b = { foo = 1 }
            local c = a
            check.equal(a, b) -- fails, equal checks the address of tables
            check.not_equal(a, c) -- fails, variables pointing to the same table equal eachother
        end)

        test.case("contains", function()
            local a = { a = 1, b = 2, c = 3 }
            check.table.contains(a, "d") -- check for one key
            check.table.contains(a, { "b", "c", "d", "e" }) -- check for multiple keys
        end)
    end)
end
