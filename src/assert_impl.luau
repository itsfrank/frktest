local types = require("./types")
local utils = require("./utils")

type Failure = types.Failure

local assert_impl = {}

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

function assert_impl.equal<T>(a: T, b: T): Failure?
    if a == b then
        return nil
    end
    return make_failure(`{a} == {b}`)
end

function assert_impl.is_true<T>(a: boolean): Failure?
    if a == true then
        return nil
    end
    return make_failure(`{a} == true`)
end

function assert_impl.is_false<T>(a: boolean): Failure?
    if a == false then
        return nil
    end
    return make_failure(`{a} == false`)
end

function assert_impl.truthy<T>(a: any): Failure?
    if a then
        return nil
    end
    return make_failure(`if {a} - condition failed`)
end

function assert_impl.falsy<T>(a: any): Failure?
    if not a then
        return nil
    end
    return make_failure(`if not {a} - condition failed`)
end

function assert_impl.should_error<T...>(f: (T...) -> any?): Failure?
    local ok, _ = pcall(f)
    if not ok then
        return nil
    end
    return make_failure(`did not error`)
end

function assert_impl.should_not_error<T...>(f: (T...) -> any?): Failure?
    local ok, err = pcall(f)
    if ok then
        return nil
    end
    error("bug in fwk")
    return make_failure(`errored: {err}`)
end

return assert_impl
