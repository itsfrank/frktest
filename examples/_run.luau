function load_tests()
    -- tests execute in the order they are loaded
    require("./basic_assertions")()
    require("./errors")()
    require("./tables")()
end

function run_tests()
    local frktest = require("@frktest/frktest")
    local lune_printer = require("@frktest/printers/lune_printer")

    lune_printer.init()
    frktest.run()
end

load_tests()
run_tests()
