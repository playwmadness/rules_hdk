# C++ HDK rules for Bazel build system

## Configuration

In your project's `WORKSPACE` file include following:
```python
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "rules_hdk",
    remote = "https://github.com/playwmadness/rules_hdk.git",
    branch = "main",
)

load("@rules_hdk//:init.bzl", "init_hdk")
init_hdk(
    # Optional: Path to your houdini installation
    # If not provided, $HFS env var will be used
    hfs = "",

    # Optional: Houdini version string. E.g. "19.5.716"
    # If not provided, $HOUDINI_VERSION env var will be used
    houdini_version = "",
)
```

## Rules

After you initialized HDK, you can use hdk\_rules in a BUILD file:
```python
load("@rules_hdk//:rules_hdk.bzl", "hdk_app", "hdk_dso")

hdk_app(
    name = "executable",
    srcs = [
        # List of your source files and headers
    ],
    link_with_engine = True, # Enables linking with libHAPI.so; Default is False.
)

hdk_dso(
    name = "dso_plugin",
    srcs = [
        # List of your source files and headers
    ],
    copts = [
        "-O3", # Neither rule has any optimization flags set by default
    ],
)
```

`hdk_app` and `hdk_dso` are wrappers for `cc_binary` and `cc_library` rules correspondingly, and support the same parameters as their underlying rules.

Additionally, `hdk_app` has `link_with_engine` boolean parameter (default: False), which provides linker with `libHAPI.so` library.

Both rules should work fine with [bazel-compile-commands-extractor](https://github.com/hedronvision/bazel-compile-commands-extractor).

To install a compiled dso plugin, copy it from `bazel-bin/` to your Houdini dso directory (for example - `$HOME/houdiniX.Y/dso`).

## Known problems

* `rules_hdk` currently works only on Linux.
* `$HDSO` is not provided as rpath to linker, so to run the compiled binary, you need to add it to `LD_LIBRARY_PATH` before running it, or manually add `-Wl,-rpath,/path/to/hfs/dsolib` to linkopts, otherwise it won't find .so libraries provided by Houdini.
* Bazel adds its own RUNPATH symbols to `hdk_app` binaries. They're harmless, but also useless.
* Plugin debugging isn't tested.
