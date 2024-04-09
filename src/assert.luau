local types = require("./types")
local utils = require("./utils")

type Failure = types.Failure

local _state = {}
_state.listeners = {}
_state.listeners.check_failed = {} :: { [number]: (Failure) -> nil }
_state.listeners.require_failed = {} :: { [number]: (Failure) -> nil }
_state = require("./state").get_state("assert", _state)

function make_failure(message: string): Failure
    local file, line = debug.info(5, "sl")
    file = utils.clean_filename(file)
    return {
        location = {
            file = file,
            line = line,
        },
        message = message,
    }
end

local test = require("./test")

function exec_listeners<T>(i: T, listeners: { [number]: (T) -> nil })
    for _, l in ipairs(listeners) do
        l(i)
    end
end

function make_assert<T...>(impl: (T...) -> Failure?): (T...) -> Failure?
    return function(...)
        local f = impl(...)
        if f == nil then
            return nil
        end
        local current_test = test.current_test()
        if current_test ~= nil then
            current_test.failed = true
        end
        return f
    end
end

function make_check<T...>(impl: (T...) -> Failure?): (T...) -> nil
    local assertion = make_assert(impl)
    return function(...)
        local f = assertion(...)
        if f == nil then
            return
        end
        exec_listeners(f, _state.listeners.check_failed)
    end
end

function make_require<T...>(impl: (T...) -> Failure?): (T...) -> nil
    local assertion = make_assert(impl)
    return function(...)
        local f = assertion(...)
        if f == nil then
            return
        end
        exec_listeners(f, _state.listeners.require_failed)
        error({ -- halt test execution on require
            _is_frktest_require = true,
            failure = f,
        })
    end
end

local assert = {}

function assert.on_check_failed(f: (Failure) -> nil)
    table.insert(_state.listeners.check_failed, f)
end

function assert.on_require_failed(f: (Failure) -> nil)
    table.insert(_state.listeners.require_failed, f)
end

-- assertion implementaitons
assert.check = {}
assert.require = {}

function impl_equal<T>(a: T, b: T): Failure?
    if a == b then
        return nil
    end

    return make_failure(`{a} == {b}`)
end
assert.check.equal = make_check(impl_equal)
assert.require.equal = make_require(impl_equal)

return assert
