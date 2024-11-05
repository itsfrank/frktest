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

        test.case("table equal modified", function()
            local a = { a = 1, b = 2 }
            local b = { a = 1, b = 20 }
            check.table.equal(a, b)
        end)

        test.case("table equal added", function()
            local a = { a = 1, b = 2 }
            local b = { a = 1 }
            check.table.equal(a, b)
        end)

        test.case("table equal missing", function()
            local a = { a = 1 }
            local b = { a = 1, b = 2 }
            check.table.equal(a, b)
        end)

        test.case("arrays of tables fit here", function()
            local a = { { a = 1 }, { a = 3 } }
            local b = { { a = 1 }, { a = 22 }, { a = 3 } }
            check.table.equal(a, b)
        end)

        test.case("table-ness is checked at runtime", function()
            local not_table = "str"
            local a = { a = 1, b = 2 }

            -- passing non-tables will fail the asserting with helpful message
            check.table.contains(not_table, "a")
            check.table.equal(a, not_table)
            check.table.equal(not_table, a)
        end)
    end)
end
