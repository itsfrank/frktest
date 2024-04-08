local frktest = {}

local test = require("./test")
local assert = require("./assert")

frktest.run = function()
    test.load_suites()
    test.run_tests()
end

frktest.test = test
frktest.assert = assert

return frktest
