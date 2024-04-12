-- adapted from: https://github.com/martinfelis/luatablediff
--[[
Changes by @itsfrank:
    - Make type and cast return value
    - Change error when function/userdata is found to a warning string and return
    - Add diff.add to differentate items that exist in A but are nil in B, from modified items
    - diff.add and diff.del store both keys and values
]]
--

--[[
Copyright © 2012-14 Martin Felis <martin@fysx.org>

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
]]
--

-- require 'strict'

export type Diff = {
    del: { [number]: { k: any, v: any } }?,
    add: { [number]: { k: any, v: any } }?,
    mod: { [any]: { a: any, b: any } }?,
    sub: Diff?,
}
local ltdiff = {}

local function table_diff(A: any, B: any): (Diff, string?)
    local warning = nil
    local diff: any = { del = {}, add = {}, mod = {}, sub = {} }

    for k, v in pairs(A) do
        if type(A[k]) == "function" or type(A[k]) == "userdata" then
            warning = "`function` and `userdata` types are skipped"
            continue
        elseif B[k] ~= nil and type(A[k]) == "table" and type(B[k]) == "table" then
            diff.sub[k] = table_diff(A[k], B[k])

            if next(diff.sub[k]) == nil then
                diff.sub[k] = nil
            end
        elseif B[k] == nil then
            diff.del[#diff.del + 1] = { k = k, v = A[k] }
        elseif B[k] ~= v then
            diff.mod[k] = { a = A[k], b = B[k] }
        end
    end

    for k, v in pairs(B) do
        if type(B[k]) == "function" or type(B[k]) == "userdata" then
            warning = "`function` and `userdata` types are skipped"
            continue
        elseif diff.sub[k] ~= nil then
            -- skip
        elseif A[k] ~= nil and type(A[k]) == "table" and type(B[k]) == "table" then
            diff.sub[k] = table_diff(B[k], A[k])

            if next(diff.sub[k]) == nil then
                diff.sub[k] = nil
            end
        elseif B[k] ~= nil and A[k] == nil then
            diff.add[#diff.add + 1] = { k = k, v = B[k] }
        elseif B[k] ~= A[k] then
            diff.mod[k] = { a = A[k], b = B[k] }
        end
    end

    if next(diff.sub) == nil then
        diff.sub = nil
    end

    if next(diff.add) == nil then
        diff.add = nil
    end

    if next(diff.mod) == nil then
        diff.mod = nil
    end

    if next(diff.del) == nil then
        diff.del = nil
    end

    return diff, warning
end

ltdiff.diff = table_diff

return ltdiff
