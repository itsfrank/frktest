local frktest = require("@frktest/frktest")
local test = frktest.test
local check = frktest.assert.check
local require = frktest.assert.require

return function()
    test.suite("Errors", function()
        test.case("throwing", function()
            error("some error") -- errors end a test
        end)
    end)
end
