local types = require("./types")

type Failure = types.Failure

local _state = {}
_state.listeners = {}
_state.listeners.check_failed = {} :: { [number]: (Failure) -> nil }
_state.listeners.require_failed = {} :: { [number]: (Failure) -> nil }
_state = require("./state").get_state("assert", _state)

-- i think this is a lune issue, but debug.info returns [string "<filename>"]
function clean_filename(name: string)
    local front_trimmed = name:sub(10)
    return front_trimmed:sub(1, -3)
end

function make_failure(message: string): Failure
    local file, line = debug.info(4, "sl")
    file = clean_filename(file)
    return {
        location = {
            file = file,
            line = line,
        },
        message = message,
    }
end

-- assertion implementaitons
function impl_equal<T>(a: T, b: T): Failure?
    if a == b then
        return nil
    end

    return make_failure(`{a} == {b}`)
end

local test = require("./test")

function exec_listeners<T>(i: T, listeners: { [number]: (T) -> nil })
    for _, l in ipairs(listeners) do
        l(i)
    end
end

function make_check<T...>(impl: (T...) -> Failure?): (T...) -> nil
    return function(...)
        local f = impl(...)
        if f == nil then
            return
        end
        local current_test = test.current_test()
        if current_test ~= nil then
            current_test.failed = true
        end
        exec_listeners(f, _state.listeners.check_failed)
    end
end

local assert = {}

assert.check = {}
assert.require = {}

assert.check.equal = make_check(impl_equal)

function assert.on_check_failed(f: (Failure) -> nil)
    table.insert(_state.listeners.check_failed, f)
end

function assert.on_require_failed(f: (Failure) -> nil)
    table.insert(_state.listeners.require_failed, f)
end

return assert
