local frktest = {}

local test = require("./test")
local assert = require("./assert")

-- make sure to initalize a reporter before running, otherwise you will get no output
-- see `src/reporters` for builtin reporters available
frktest.run = function()
    test.load_suites()
    test.run_tests()
end

frktest.test = test
frktest.assert = assert

return frktest
