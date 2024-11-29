-- usage:
--     local reporter = require("@frktest/reporters/lune_console_reporter")
--     reporter.init()
--     -- run tests

local stdio = require("@lune/stdio")
local fs = require("@lune/fs")
local types = require("../types")
local utils = require("../utils")
local inspect = require("../lib/inspect")

type Failure = types.Failure
type DiffEntry<T> = types.DiffEntry<T>
type TableDiff = types.TableDiff
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

function style(sty: stdio.Style, s: string)
    return `{stdio.style(sty)}{s}{stdio.style("reset")}`
end

function print_test_info_once()
    if _state.current_suite ~= nil and _state.suite_printed == false then
        _state.suite_printed = true
        print_indent(`Suite: {color("purple", _state.current_suite.name)}`, -2)
        print("")
    end
    if _state.current_test ~= nil and _state.test_printed == false then
        _state.test_printed = true
        print_indent(`Test: {color("purple", _state.current_test.name)}`, -1)
        print("")
    end
end

function make_array_diff_string<T>(diff: { [number]: DiffEntry<T> }): string
    local make_line = function<T>(e: DiffEntry<T>): string
        local colors = {
            ["+"] = "green",
            ["-"] = "red",
            ["~"] = "yellow",
        }
        local value_s
        if e.t == "~" then
            value_s = `{(e.v :: any).a} == {(e.v :: any).b}`
        else
            value_s = `{e.v}`
        end
        return color(colors[e.t], `{e.t} [{e.k}]: {value_s}`)
    end
    local message = {}
    for _, d in ipairs(diff) do
        table.insert(message, make_line(d))
    end
    return table.concat(message, "\n")
end

function make_table_diff_string(diff: TableDiff): string
    local make_line = function<T>(i: number, e: DiffEntry<any>): string
        local colors = {
            ["+"] = "green",
            ["-"] = "red",
            ["~"] = "yellow",
        }
        local value_s = ""
        local inspect_opts = { newline = "", indent = "" }
        if e.t == "~" then
            value_s = `{inspect((e.v :: any).a, inspect_opts)} == {inspect((e.v :: any).b, inspect_opts)}`
        else
            value_s = inspect(e.v, inspect_opts)
        end
        return color(colors[e.t], `{utils.make_indent(i)}{e.t} [{e.k}]: {value_s}`)
    end
    local message = {}

    local function add_to_diff_message(diff: TableDiff, i: number)
        for _, v in ipairs(diff.diff) do
            table.insert(message, make_line(i, v))
        end
        if diff.sub ~= nil then
            for k, v in pairs(diff.sub) do
                table.insert(message, `{utils.make_indent(i)}  [{k}]:`)
                add_to_diff_message(v, i + 1)
            end
        end
    end
    add_to_diff_message(diff, 0)

    return table.concat(message, "\n")
end

function handle_complex_info(type: string, data: any): string?
    if type == "ArrayDiff" then
        return make_array_diff_string(data :: { [number]: DiffEntry<any> })
    elseif type == "TableDiff" then
        return make_table_diff_string(data :: TableDiff)
    end
    return nil
end

function preview_avaliable_line(lines: {string}, line: number): string
    if (lines[line]) then
        return ` {style("dim", lines[line])}`
    end
    return ""
end

function reporter.print_failure(type: "CHECK" | "REQUIRE", f: Failure)
    print_test_info_once()
    local line = tonumber(f.location.line)
    print_indent(`{color("red", `{type} FAILED:`)} {f.location.file}:{line}`)
    if (line) then
        local spacing = string.rep(" ", #tostring(f.location.line))
        local source_lines = fs.readFile(f.location.file):split("\n")
        print_indent(color("blue", `{spacing} |{preview_avaliable_line(source_lines, line - 1)}`))
        print_indent(color("blue", `{f.location.line} | {source_lines[f.location.line]}`))
        print_indent(color("blue", `{spacing} |{preview_avaliable_line(source_lines, line + 1)}`))
    end
    print_indent(`{color("yellow", f.message)}`, 1)
    if f.complex_info ~= nil then
        local complex_msg = handle_complex_info(f.complex_info.type, f.complex_info.data)
        if complex_msg ~= nil then
            print(utils.indent_multiline(complex_msg, _state.indent + 1))
        end
    end
    if f.user_msg ~= nil then
        print_indent("with message:")
        print_indent(color("yellow", f.user_msg), 1)
    end
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

function reporter.print_summary(ran: number, passed: number, failed: number, skipped: number)
    print("--------------------")
    local summary = `Tests Ran: {ran}`
    if passed > 0 then
        summary = summary .. " | " .. color("green", `Passed: {passed}`)
    end
    if failed > 0 then
        summary = summary .. " | " .. color("red", `Failed: {failed}`)
    end
    if skipped > 0 then
        summary = summary .. " | " .. color("yellow", `Skipped: {skipped}`)
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
        reporter.print_summary(r.ran, r.passed, r.failed, r.skipped)
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
