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

-- value assertions

function assert_impl.equal<T>(a: T, b: T): Failure?
    if a == b then
        return nil
    end
    return make_failure(`{a} == {b}`)
end

function assert_impl.not_equal<T>(a: T, b: T): Failure?
    if a ~= b then
        return nil
    end
    return make_failure(`{a} ~= {b}`)
end

function assert_impl.greater(a: number, b: number): Failure?
    if a > b then
        return nil
    end
    return make_failure(`{a} > {b}`)
end

function assert_impl.greater_eq(a: number, b: number): Failure?
    if a >= b then
        return nil
    end
    return make_failure(`{a} >= {b}`)
end

function assert_impl.lesser(a: number, b: number): Failure?
    if a < b then
        return nil
    end
    return make_failure(`{a} < {b}`)
end

function assert_impl.lesser_eq(a: number, b: number): Failure?
    if a <= b then
        return nil
    end
    return make_failure(`{a} <= {b}`)
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

-- error/exception assertions

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
    return make_failure(`errored: {err}`)
end

-- array assertions

function assert_impl.array_contains(a: { [number]: any }, keys: any | { [number]: any }): Failure?
    if type(keys) ~= "table" then
        keys = { keys }
    end
    local keys_table = {}
    for _, k in ipairs(keys) do
        keys_table[k] = false
    end

    for _, e in ipairs(a) do
        keys_table[e] = true
    end

    local missing = {}
    for k, found in pairs(keys_table) do
        if not found then
            if type(k) == "string" then
                k = '"' .. k .. '"'
            end
            table.insert(missing, k)
        end
    end

    if #missing == 0 then
        return nil
    end

    return make_failure(`missing values: {table.concat(missing, ", ")}`)
end

-- table assertions

function assert_impl.table_contains(t: { [any]: any }, keys: any | { [number]: any }): Failure?
    if type(keys) ~= "table" then
        keys = { keys }
    end

    local missing = {}
    for _, k in ipairs(keys) do
        if t[k] == nil then
            table.insert(missing, k)
        end
    end

    if #missing == 0 then
        return nil
    end

    return make_failure(`missing keys: {table.concat(missing, ", ")}`)
end

return assert_impl
