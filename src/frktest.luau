local frktest = {}

local test = require("./test")
local assert = require("./assert")

-- make sure to initalize a printer before running, otherwise you will get no output
-- see `src/printers` for builtin printers available
frktest.run = function()
    test.load_suites()
    test.run_tests()
end

frktest.test = test
frktest.assert = assert

return frktest
