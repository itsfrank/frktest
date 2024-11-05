local types = require("./types")
local utils = require("./utils")

type Failure = types.Failure
type DiffEntry<T> = types.DiffEntry<T>
type TableDiff = types.TableDiff

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

function assert_impl.not_nil(a: any): Failure?
    if a ~= nil then
        return nil
    end
    return make_failure("value was nil")
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

function assert_impl.array_contains<T>(a: { T }, keys: T | { T }): Failure?
    if type(keys) ~= "table" then
        keys = { keys }
    end
    local keys_table = {}
    for _, k in ipairs(keys :: { T }) do
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

function assert_impl.array_equal<T>(a: { [number]: T }, b: { [number]: T }): Failure?
    local min_len = math.min(#a, #b)
    local diff = {} :: { [number]: DiffEntry<T> }

    for i = 1, min_len do
        if a[i] ~= b[i] then
            table.insert(diff, { k = i, v = { a = a[i], b = b[i] }, t = "~" })
        end
    end

    if #a ~= #b then
        local max_len = math.max(#a, #b)
        local longer: { [number]: T } = if #a > #b then a else b
        local type: "+" | "-" = if #a > #b then "+" else "-"
        for i = min_len + 1, max_len do
            table.insert(diff, { k = i, t = type, v = longer[i] })
        end
    end

    if #diff == 0 then
        return nil
    end

    local f = make_failure("Arrays were not equal")
    f.complex_info = {
        type = "ArrayDiff",
        data = diff,
    }

    return f
end

-- table assertions

function assert_impl.table_contains(t: any, keys: any | { [number]: any }): Failure?
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

local ltdiff = require("./lib/ltdiff")
function assert_impl.table_equal(a: any, b: any): Failure?
    -- convert ltdiff into our diff format
    local function ltdiff_to_frkdiff(lt_diff: ltdiff.Diff): (boolean, TableDiff)
        local has_diff = false
        local frk_diff: TableDiff = { diff = {} }

        if lt_diff.add ~= nil then
            has_diff = true
            for _, v in ipairs(lt_diff.add) do
                table.insert(frk_diff.diff, { k = v.k, t = "-", v = v.v })
            end
        end

        if lt_diff.del ~= nil then
            has_diff = true
            for _, v in ipairs(lt_diff.del) do
                table.insert(frk_diff.diff, { k = v.k, t = "+", v = v.v })
            end
        end

        if lt_diff.mod ~= nil then
            has_diff = true
            for k, v in pairs(lt_diff.mod) do
                table.insert(frk_diff.diff, { k = k, t = "~", v = { a = v.a, b = v.b } })
            end
        end

        if lt_diff.sub ~= nil then
            has_diff = true
            frk_diff.sub = {}
            for k, v in pairs(lt_diff.sub) do
                assert(frk_diff.sub)
                local sub_has_diff
                sub_has_diff, frk_diff.sub[k] = ltdiff_to_frkdiff(v)
                has_diff = has_diff or sub_has_diff
            end
        end

        return has_diff, frk_diff
    end
    local lt_diff, _warning = ltdiff.diff(a, b)

    local has_diff, diff = ltdiff_to_frkdiff(lt_diff)
    if not has_diff then
        return nil
    end

    local f = make_failure("Tables were not equal")
    f.complex_info = {
        type = "TableDiff",
        data = diff,
    }

    return f
end

return assert_impl
