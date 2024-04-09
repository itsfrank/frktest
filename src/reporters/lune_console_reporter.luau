-- usage:
--     local reporter = require("@frktest/reporters/lune_console_reporter")
--     reporter.init()
--     -- run tests

local stdio = require("@lune/stdio")
local types = require("../types")
local utils = require("../utils")

type Failure = types.Failure
type TestError = types.TestError

local reporter = {}

local _state = {}
_state.indent = 0
_state.current_suite = nil :: types.Suite?
_state.current_test = nil :: types.Test?
_state.suite_printed = false
_state.test_printed = false
_state = require("../state").get_state("lune_console_reporter", _state)

function print_indent(s: string, offset: number?)
    if offset == nil then
        offset = 0
    end
    local indent = _state.indent + offset :: number
    return print(utils.make_indent(indent) .. s)
end

function color(c: stdio.Color, s: string)
    return `{stdio.color(c)}{s}{stdio.color("reset")}`
end

function print_test_info_once()
    if _state.current_suite ~= nil and _state.suite_printed == false then
        _state.suite_printed = true
        print_indent(`Suite: {color("cyan", _state.current_suite.name)}`, -2)
        print("")
    end
    if _state.current_test ~= nil and _state.test_printed == false then
        _state.test_printed = true
        print_indent(`Test: {color("cyan", _state.current_test.name)}`, -1)
        print("")
    end
end

function reporter.print_failure(type: "CHECK" | "REQUIRE", f: Failure)
    print_test_info_once()
    print_indent(`{color("red", `{type} FAILED:`)} {f.location.file}:{f.location.line}`)
    print_indent(`{color("yellow", f.message)}`, 1)
    print("")
end

function reporter.print_test_error(e: TestError)
    print_test_info_once()
    print_indent(`{color("red", "ERROR:")} {e.location.file}:{e.location.line}`)
    print_indent(`{color("yellow", e.error)}`, 1)
    print_indent("trace:")
    print(`{color("yellow", utils.indent_multiline(utils.trim(e.strace), _state.indent + 1))}`)
    print("")
end

function reporter.print_counts(tests: number, suites: number)
    print(`Running - {tests} tests | {suites} suites...`)
    print("")
end

function reporter.print_summary(ran: number, passed: number, failed: number)
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

function reporter.init()
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
        reporter.print_counts(c.tests, c.suites)
    end)
    test.on_exec_end(function(r)
        reporter.print_summary(r.ran, r.passed, r.failed)
    end)

    test.on_test_error(function(e)
        reporter.print_test_error(e)
    end)

    local assert = require("../assert")
    assert.on_check_failed(function(f)
        reporter.print_failure("CHECK", f)
    end)
    assert.on_require_failed(function(f)
        reporter.print_failure("REQUIRE", f)
    end)
end

return reporter
