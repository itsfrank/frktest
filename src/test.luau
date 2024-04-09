local types = require("./types")
local utils = require("./utils")

local test = {}

type Test = types.Test
type Suite = types.Suite
type ExecCounts = types.ExecCounts
type ExecResult = types.ExecResult
type TestError = types.TestError

local _state = {}
_state.suites = {} :: { [number]: Suite }
_state.global_suite = {} :: { [number]: Test }
_state.current_load_suite = nil :: Suite?

_state.current_exec_suite = nil :: Suite?
_state.current_exec_test = nil :: Test?

_state.listeners = {}
_state.listeners.suite_enter = {} :: { [number]: (Suite) -> nil }
_state.listeners.suite_leave = {} :: { [number]: (Suite) -> nil }
_state.listeners.test_enter = {} :: { [number]: (Test) -> nil }
_state.listeners.test_leave = {} :: { [number]: (Test) -> nil }
_state.listeners.exec_begin = {} :: { [number]: (ExecCounts) -> nil }
_state.listeners.exec_end = {} :: { [number]: (ExecResult) -> nil }
_state.listeners.test_error = {} :: { [number]: (TestError) -> nil }

_state = require("./state").get_state("test", _state)

function test.suite(name: string, fn: () -> nil)
    table.insert(_state.suites, {
        name = name,
        fn = fn,
        tests = {},
    })
end

function test.case(name: string, fn: () -> nil)
    local suite_tests = _state.global_suite
    if _state.current_load_suite ~= nil then
        suite_tests = _state.current_load_suite.tests
    end

    table.insert(suite_tests, {
        name = name,
        fn = fn,
        failed = false,
    })
end

function test.load_suites()
    for _, suite_i in ipairs(_state.suites) do
        _state.current_load_suite = suite_i
        assert(_state.current_load_suite ~= nil)
        _state.current_load_suite.tests = {} -- empty list so we dont have duplicate tests
        suite_i.fn()
        _state.current_load_suite = nil
    end
end

function exec_listeners<T>(i: T, listeners: { [number]: (T) -> nil })
    for _, l in ipairs(listeners) do
        l(i)
    end
end

function count_tests(): number
    local count = #_state.global_suite
    for _, s in ipairs(_state.suites) do
        count += #s.tests
    end
    return count
end

function test.run_tests()
    local tests_ran = 0
    local tests_passed = 0
    local tests_failed = 0

    local run_test = function(t: Test)
        t.failed = false
        _state.current_exec_test = t
        exec_listeners(t, _state.listeners.test_enter)

        local _, _ = xpcall(function()
            t.fn()
        end, function(err)
            if type(err) == "table" and err["_is_frktest_require"] == true then
                return nil -- no extra work to do listeners will handle the failure
            end
            local strace = debug.traceback("", 2)
            local file, line = debug.info(3, "sl")
            file = utils.clean_filename(file)
            exec_listeners({
                location = {
                    file = file,
                    line = line,
                },
                strace = strace,
                error = err,
            }, _state.listeners.test_error)

            t.failed = true
            return nil
        end)

        exec_listeners(t, _state.listeners.test_leave)
        _state.current_exec_test = nil

        tests_ran += 1
        if t.failed == false then
            tests_passed += 1
        else
            tests_failed += 1
        end
    end

    exec_listeners({
        tests = count_tests(),
        suites = #_state.suites,
    }, _state.listeners.exec_begin)

    for _, t in ipairs(_state.global_suite) do
        run_test(t)
    end

    for _, s in ipairs(_state.suites) do
        _state.current_exec_suite = s
        exec_listeners(s, _state.listeners.suite_enter)
        for _, t in ipairs(s.tests) do
            run_test(t)
        end
        exec_listeners(s, _state.listeners.suite_leave)
        _state.current_exec_suite = nil
    end

    exec_listeners({
        ran = tests_ran,
        passed = tests_passed,
        failed = tests_failed,
    }, _state.listeners.exec_end)
end

function test.on_suite_enter(f: (Suite) -> nil)
    table.insert(_state.listeners.suite_enter, f)
end

function test.on_suite_leave(f: (Suite) -> nil)
    table.insert(_state.listeners.suite_leave, f)
end

function test.on_test_enter(f: (Test) -> nil)
    table.insert(_state.listeners.test_enter, f)
end

function test.on_test_leave(f: (Test) -> nil)
    table.insert(_state.listeners.test_leave, f)
end

function test.on_exec_begin(f: (ExecCounts) -> nil)
    table.insert(_state.listeners.exec_begin, f)
end

function test.on_exec_end(f: (ExecResult) -> nil)
    table.insert(_state.listeners.exec_end, f)
end

function test.on_test_error(f: (TestError) -> nil)
    table.insert(_state.listeners.test_error, f)
end

function test.reset()
    _state.tests = {}
    _state.global_suite = {}
    _state.current_load_suite = nil

    _state.current_exec_suite = nil
    _state.current_exec_test = nil
end

-- returns suite object if currently executing a suite, nil otherwise
function test.current_suite(): Suite?
    return _state.current_exec_suite
end

-- returns test object if currently executing a test, nil otherwise
function test.current_test(): Test?
    return _state.current_exec_test
end

return test
