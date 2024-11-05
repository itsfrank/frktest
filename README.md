# frktest

A basic unit test framework for [lune](https://github.com/lune-org/lune).

I developed this mostly for myself at a time where there were no alternatives
for Lune. I plan to keep it simple and use it for my projects that dont require
a heavy framework.

If you require more than basic test running, assertions, and console reporting,
consider using a larger framework (like
[jest-lua](https://github.com/jsdotlua/jest-lua) when it gets ported to lune,
see [issue](https://github.com/jsdotlua/jest-lua/issues/2) for tracking)

### Features

- It runs tests
- Pretty ergonomic to write (I think so)
- Assertion library, including table & array checks with diff printing, should_error, and a few more!
- Builtin console reporter with **colors**
- (undocumented) api to implement custom reporters (see [lune_console_reporter.luau](src/reporters/lune_console_reporter.luau) for sample use)

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

    -- you can use test.focus to temporarily focus on a test case/suite:
    test.focus.suite("only this suite will run", function() end)
    test.focus.case("only this case will run", function() end) 

    -- you can use test.skip to skip test cases/suites:
    test.skip.suite("all tests in this suite will be skipped", function() end)
    test.skip.case("this test will be skipped", function() end) 
end
```

And here is the output (theme is [Rose Pine](https://github.com/rose-pine)):

![image](https://github.com/itsfrank/frktest/assets/7297152/f20a58d6-8e61-4635-893c-b4721ed9f3c9)

### How do I use it

#### Set up your environment

**Installing**

frktest is available on [wally](https://wally.run/), [pesde](https://docs.pesde.daimond113.com/), or you can just clone the repo.

<details>

<summary>using wally</summary>

Add the dependency:

in `wally.toml`:

```toml
[dev-dependencies]
frktest = "itsfrank/frktest@0.0.1"
```

Create alias in `.luaurc`:

```jsonc
{
  "aliases": {
    "frktest": "DevPackages/_Index/itsfrank_frktest@0.0.1/frktest/src",
  }
}
```

</details>

<details>

<summary>using pesde</summary>

in `pesde.toml`:

```toml
[dev_dependencies]
frktest = { name = "itsfrank/frktest", version = "^0.0.1" }
```

Create alias in `.luaurc`:

```jsonc
{
  "aliases": {
    "frktest": "lune_packages/.pesde/itsfrank+frktest/0.0.1/frktest/src/"
  }
}
```

**Note**: If you want to use the generated luau file in `./lune_packages`, in
the examples, replace `require("@frktest/frktest")` with
`require("./lune_packages/frktest")`. Reporters will be avilable in the
`_reporters` member:

```luau
-- from project root
local frktest = require("./lune_packages/frktest")
local lune_console_reporter = frktest._reporters.lune_console_reporter
```

A sample pesde project using frktest can be found here: https://github.com/itsfrank/frktest-pesde-sample

</details>

<details>

<summary>clone the repo</summary>

```shell
# somewhere on your machine
git clone https://github.com/itsfrank/frktest.git
```

Create alias in `.luaurc`:

```jsonc
{
  "aliases": {
    "frktest": "<path to frktest/src>",
  }
}
```

</details>

All example assume you created a `require` alias `"@frktest"` in your project's `.luaurc`:

```jsonc
{
  "aliases": {
    "frktest": "<see install sections above for paths>",
  }
}
```

**note:** you should also register the alias with your lsp of choice, with `luau-lsp` using VSCode I think it would look like this:

```json
"luau-lsp.require.mode": "relativeToFile",
"luau-lsp.require.directoryAliases": {
    "@frktest/": "<alias in luaurc>"
}
```

#### Running tests

The framework does not have a cli or test discovery. So you need to make an entrypoint file, see [examples/_run.luau](examples/_run.luau) for how I made mine. But basically all you need is this:

```lua
-- filename: _run.luau

-- require test files and call the returned function
require("./some_test")()

-- initialize a reporter (there is currently only one... this one, but you can make your own!)
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

Every single assertion has at least one example in the [examples](examples)
folder. If there are any nuances, I added comments.

Really though, they should be self explanatory, your LSP should list them all
out if you type `assert.check.|`

### End stuff

#### TODO

- Write tests to test the framework (ironic...)
- Encapsulate test state so that I can test the framework using the framework (with 2 separate states, one doing the testing, and one being tested)
- Probably add more assertions
- Fix bugs people might report

#### Acknowledgements

- [martinfelis/luatablediff](https://github.com/martinfelis/luatablediff) for a great table diff inplementation that I adapted for the `table.equal` assertions
- [kikito/inspect](https://github.com/kikito/inspect.lua) because it's the best pretty printer and I use it to print tables
- [catch2](https://github.com/catchorg/Catch2) inspired the test output and probably the assertion syntax

#### What's up with the name?

My name is Frank, I often use `frk` as a namespace/prefix for stuff meant for me :)
