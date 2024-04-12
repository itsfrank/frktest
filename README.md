# frktest

A basic unit test framework for [lune](https://github.com/lune-org/lune), will
probably abandon when [jest-lua](https://github.com/jsdotlua/jest-lua) is
ported to lune

### Features

- It runs tests
- Pretty ergonomic to write
- Assertion library, including table & array checks with diff printing, should_error, and a few more!
- Builtin console reporter with **colors**
- (undocumented) api to implement custom reporters

### What does it look like tho?

Here's what a test looks like:

```lua
return function()
    test.suite("A collection of tests", function()
        test.case("A test that passes", function()
            local exp = 4
            local got = 2 + 2
            check.equal(got, exp)
        end)

        test.case("A test that fails", function()
            local exp = 3
            local got = 2 + 2
            check.equal(got, exp)
        end)

        test.case("Halt early", function()
            local a = nil
            require.not_nil(a)
            check.falsy(a.b)
        end)

        test.case("Custom messages!", function()
            check.equal(1, 2, msg("my message prints in addition to the expansion"))
        end)

        test.case("Array assertions", function()
            local a = { "a", "b", "c" }
            local b = { "a", "z" }
            check.array.contains(a, { "z", "x" })
            check.array.equal(a, b)
        end)

        test.case("Table assertions", function()
            local a = { a = 1, b = 2, c = { a = 1, b = 2 } }
            local b = { a = 1, b = 22, c = { a = -1 } }
            check.table.contains(a, "b")
            check.table.equal(a, b)
        end)
    end)
end
```

And here is the output (theme is [Rose Pine](https://github.com/rose-pine)):

![image](https://github.com/itsfrank/frktest/assets/7297152/d7a34cb4-4a24-4d31-b2e5-b4cf98e89180)

#### What's up with the name?

My name is Frank, I often use `frk` as a namespace/prefix for stuff meant for me :)
