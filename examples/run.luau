function load_tests()
    require("./test1")()
end

function run_tests()
    local frktest = require("@frktest/frktest")
    local lune_printer = require("@frktest/printers/lune_printer")

    lune_printer.init()
    frktest.run()
end

load_tests()
run_tests()
