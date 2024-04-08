local stdio = require("@lune/stdio")
local types = require("../types")

type Failure = types.Failure

local printer = {}

local _state = {}
_state.indent = 0
_state.current_suite = nil :: types.Suite?
_state.current_test = nil :: types.Test?
_state.suite_printed = false
_state.test_printed = false
_state = require("../state").get_state("lune_printer", _state)

function print_indent(s: string, offset: number?)
    if offset == nil then
        offset = 0
    end
    local indent = _state.indent + offset :: number
    local indent_s = ""
    for j = 0, indent - 1 do
        indent_s ..= "    "
    end
    return print(indent_s .. s)
end

function color(c: stdio.Color, s: string)
    return `{stdio.color(c)}{s}{stdio.color("reset")}`
end

function printer.print_failure(f: Failure)
    if _state.current_suite ~= nil and _state.suite_printed == false then
        _state.suite_printed = true
        print_indent(`Suite: {color("cyan", _state.current_suite.name)}`, -2)
        print("--------------------")
        print("")
    end
    if _state.current_test ~= nil and _state.test_printed == false then
        _state.test_printed = true
        print_indent(`Test: {color("cyan", _state.current_test.name)}`, -1)
        print("")
    end

    print_indent(`{color("red", "CHECK FAILED:")} {f.location.file}:{f.location.line}`)
    print_indent(`{color("yellow", f.message)}`, 1)
    print("")
end

function printer.print_counts(tests: number, suites: number)
    print(`Running - {tests} tests | {suites} suites...`)
    print("")
end

function printer.print_summary(ran: number, passed: number, failed: number)
    print("--------------------")
    local summary = `Tests Ran: {ran}`
    if passed > 0 then
        summary = summary .. " | " .. color("green", `Passed: {passed}`)
    end
    if failed > 0 then
        summary = summary .. " | " .. color("red", `Failed: {failed}`)
    end
    print(summary)
    local status = if failed == 0 then color("green", "OK") else color("red", "FAIL")
    status = if ran == 0 then color("yellow", "SKIPPED") else status
    print(`status: {status}`)
end

function printer.init()
    -- register testing events to keep track of current testing state
    local test = require("../test")
    test.on_suite_enter(function(s)
        _state.suite_printed = false
        _state.current_suite = s
        _state.indent += 1
    end)
    test.on_suite_leave(function(_)
        _state.current_suite = nil
        _state.indent -= 1
    end)
    test.on_test_enter(function(t)
        _state.test_printed = false
        _state.current_test = t
        _state.indent += 1
    end)
    test.on_test_leave(function(_)
        _state.current_test = nil
        _state.indent -= 1
    end)

    test.on_exec_begin(function(c)
        printer.print_counts(c.tests, c.suites)
    end)
    test.on_exec_end(function(r)
        printer.print_summary(r.ran, r.passed, r.failed)
    end)

    local assert = require("../assert")
    assert.on_check_failed(function(f)
        printer.print_failure(f)
    end)
end

return printer
