-- parametrized testing, also known as 'data driven tests' or 'table driven tests'
-- quite popular in the golang community, is a style of testing where the data
-- and logic are separated so that you can run the same test logic on multiple
-- input/output pairs

local frktest = require("@frktest/frktest")
local test = frktest.test
local check = frktest.assert.check

return function()
    test.suite("Parametrized tests", function()
        -- we can run code in the suite function!

        local test_data = {
            {
                name = "10 plus 10",
                data_in = {
                    a = 10,
                    b = 10,
                },
                exp = 21,
            },
            {
                name = "11 plus 10",
                data_in = {
                    a = 11,
                    b = 10,
                },
                exp = 20,
            },
        }

        -- for loop makes a test case for every element in test_data
        -- to add new cases we only need to add elements to the array
        for _, tt in test_data do
            test.case("case: " .. tt.name, function()
                local got = tt.data_in.a + tt.data_in.b
                check.equal(got, tt.exp)
            end)
        end
    end)
end
