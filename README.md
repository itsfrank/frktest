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
            req.not_nil(a)
            check.falsy(a.b) -- wont run, a failed req stops the test early
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

### How do I use it

#### Set up your environment

**note:** I am not familiar with how any of the current luau package management solutions, so for now, you will have to clone this repo somewhere.

I suggest creating a `require` alias `"@frktest"`, add this yo your `.luaurc`:

```json
{
  ...
  "aliases": {
    "frktest": "<path to frktest/src>",
  }
}
```

**note:** you should also register the alias with your lsp of choice, with `luau-lsp` using VSCode I think it would look like this:

```json
"luau-lsp.require.mode": "relativeToFile",
"luau-lsp.require.directoryAliases": {
    "@frktest/": "<path to frktest/src>"
}
```

#### Running tests

The framework does not have a cli or test discovery. So you need to make an entrypoint file, see [examples/_run.luau](examples/_run.luau) for how I made mine. But basically all you need is this:

```lua
-- filename: _run.luau

-- require test files and call the returned function
require("./some_test")()

-- initialize a reporter (ther eis currently only one... this one)
local lune_console_reporter = require("@frktest/reporters/lune_console_reporter")
lune_console_reporter.init()

-- run the tests
local frktest = require("@frktest/frktest")
frktest.run()
```

Then you can run this file with lune like so:

```shell
> lune run _run.luau
```

#### Writing tests

I suggest you use these requires (but you do what you want!):

```lua
local frktest = require("@frktest/frktest")
local test = frktest.test
local check = frktest.assert.check
local req = frktest.assert.require
```

A test file should return a function, and for any tests to run the function
needs to create tests with `test.case`. If you want to group tests together you
can use `test.suite` and create tests inside of that. See [examples](examples)
for how I wrote a bunch of test files.

```lua
return function()
    test.case("a global test", function()
        -- ...
    end)

    test.suite("a group of tests", function()
        test.case("a test within a suite", function()
            -- ...
        end)
    end)
end
```

#### Assertions

Every single assertion has at least one examples in the [example](example)
folder. If ther eare any nuances, I added comments.

Really though, they should be self explanatory, your LSP should list them all
out if you type `assert.check.`

### End stuff

#### Acknowledgements

- [martinfelis/luatablediff](https://github.com/martinfelis/luatablediff) for a great table diff inplementation that I adapted for the `table.equal` assertions
- [kikito/inspect](https://github.com/kikito/inspect.lua) because it's the best pretty printer and I use it to print tables
- [catch2](https://github.com/catchorg/Catch2) inspired the test output and probably the assertion syntax

#### What's up with the name?

My name is Frank, I often use `frk` as a namespace/prefix for stuff meant for me :)
