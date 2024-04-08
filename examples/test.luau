local frktest = require("@frktest/init")
local test = frktest.test
local check = frktest.assert.check

test.case("a global test", function()
    check.equal("global1", "global")
end)

test.suite("a suite1", function()
    test.case("a test1", function()
        check.equal("suite1 test1", "suite test")
    end)
    test.case("a test2", function()
        check.equal("suite1 test2", "suite test")
    end)
end)

test.suite("a suite2", function()
    test.case("a test1", function()
        check.equal("suite2 test1", "suite test")
    end)
    test.case("a test2", function()
        check.equal("suite2 test2", "suite test")
        check.equal(10, 11)
    end)
end)

test.suite("passing suite", function()
    test.case("pass test 1", function()
        check.equal("pass", "pass")
    end)
end)

-- this should be elsewhere
local printer = require("@frktest/printers/lune_printer")
printer.init()
test.load_suites()
test.run_tests()
