local frktest = require("@frktest/frktest")
local test = frktest.test
local check = frktest.assert.check
local req = frktest.assert.require
local msg = frktest.assert.msg

return function()
    test.suite("A collection of tests", function()
        test.case("A test that passes", function()
            local exp = 4
            local got = 2 + 2
            check.equal(got, exp)
        end)

        test.case("A test that fails", function()
            local exp = 3
            local got = 2 + 2
            check.equal(got, exp)
        end)

        test.case("Halt early", function()
            local a = nil
            req.not_nil(a)
            check.falsy(a.b)
        end)

        test.case("Custom messages!", function()
            check.equal(1, 2, msg("my message prints in addition to the expansion"))
        end)

        test.case("Array assertions", function()
            local a = { "a", "b", "c" }
            local b = { "a", "z" }
            check.array.contains(a, { "z", "x" })
            check.array.equal(a, b)
        end)

        test.case("Table assertions", function()
            local a = { a = 1, b = 2, c = { a = 1, b = 2 } }
            local b = { a = 1, b = 22, c = { a = -1 } }
            check.table.contains(a, "b")
            check.table.equal(a, b)
        end)
    end)
end
