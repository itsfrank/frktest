# Examples

This folder contains an example of a testing project.

The entrypoint is `_run.luau` (the `_` has no meaning, I just want the file to
be sorted at the top)

Every other file is a test file, note that `_run.luau` requires and calls the
returned function for each test file. This test framework does not have test
discovery yet.

You can run the tests from the root folder of this repo with:

```sh
> lune run examples/_run.luau
```
