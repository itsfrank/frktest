local types = require("./types")

type Failure = types.Failure

local _state = {}
_state.listeners = {}
_state.listeners.check_failed = {} :: { (Failure) -> nil }
_state.listeners.require_failed = {} :: { (Failure) -> nil }
_state.current_user_msg = nil :: string?
_state = require("./state").get_state("assert", _state)

local test = require("./test")

function exec_listeners<T>(i: T, listeners: { (T) -> nil })
    for _, l in ipairs(listeners) do
        l(i)
    end
end

function make_assert<T...>(impl: (T...) -> Failure?): (T...) -> Failure?
    return function(...)
        local f = impl(...)
        if f == nil then
            _state.current_user_msg = nil
            return nil
        end

        -- check for user message
        if _state.current_user_msg ~= nil then
            f.user_msg = _state.current_user_msg
        end

        local current_test = test.current_test()
        if current_test ~= nil then
            current_test.failed = true
        end

        _state.current_user_msg = nil
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

-- used to add custom messages on assertion failures
function assert.msg(s: string)
    _state.current_user_msg = s
end

-- assertion implementaitons
assert.check = {}
assert.require = {}

assert.check.array = {}
assert.require.array = {}
assert.check.table = {}
assert.require.table = {}

local assert_impl = require("./assert_impl")

-- value assertions
assert.check.equal = make_check(assert_impl.equal)
assert.require.equal = make_require(assert_impl.equal)

assert.check.not_equal = make_check(assert_impl.not_equal)
assert.require.not_equal = make_require(assert_impl.not_equal)

assert.check.greater = make_check(assert_impl.greater)
assert.require.greater = make_require(assert_impl.greater)

assert.check.greater_eq = make_check(assert_impl.greater_eq)
assert.require.greater_eq = make_require(assert_impl.greater_eq)

assert.check.lesser = make_check(assert_impl.lesser)
assert.require.lesser = make_require(assert_impl.lesser)

assert.check.lesser_eq = make_check(assert_impl.lesser_eq)
assert.require.lesser_eq = make_require(assert_impl.lesser_eq)

assert.check.is_true = make_check(assert_impl.is_true)
assert.require.is_true = make_require(assert_impl.is_true)

assert.check.is_false = make_check(assert_impl.is_false)
assert.require.is_false = make_require(assert_impl.is_false)

assert.check.truthy = make_check(assert_impl.truthy)
assert.require.truthy = make_require(assert_impl.truthy)

assert.check.falsy = make_check(assert_impl.falsy)
assert.require.falsy = make_require(assert_impl.falsy)

assert.check.not_nil = make_check(assert_impl.not_nil)
assert.require.not_nil = make_require(assert_impl.not_nil)

-- error/exception assertions
assert.check.should_error = make_check(assert_impl.should_error)
assert.require.should_errors = make_require(assert_impl.should_error)

assert.check.should_not_error = make_check(assert_impl.should_not_error)
assert.require.should_not_errors = make_require(assert_impl.should_not_error)

-- array assertions
assert.check.array.contains = make_check(assert_impl.array_contains)
assert.require.array.contains = make_require(assert_impl.array_contains)

assert.check.array.equal = make_check(assert_impl.array_equal)
assert.require.array.equal = make_require(assert_impl.array_equal)

-- table assertions
assert.check.table.contains = make_check(assert_impl.table_contains)
assert.require.table.contains = make_require(assert_impl.table_contains)

assert.check.table.equal = make_check(assert_impl.table_equal)
assert.require.table.equal = make_require(assert_impl.table_equal)

return assert
