# Examples

This folder contains an example of a testing project.

The run scripts are in the `run/` folder. The basic example is `run/default.luau`

Every other file in this directory is a test file, note that `_run.luau`
requires and calls the returned function for each test file. This test
framework does not have test discovery yet.

You can run the tests from the root folder of this repo with:

```sh
> lune run examples/run/default.luau
```
