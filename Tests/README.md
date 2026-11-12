# Cleandate regression tests

Run from the repository root on a Mac with Xcode selected:

```sh
Tests/run-cleandate-tests.sh
```

The suite compiles the app's deep-link parser and cleandate session directly, then runs XCTest without launching a simulator. It covers both URL schemes, temporary flags and tab indexes, invalid links, permanent and temporary date edits, background restoration, relaunch, replacement links, and incoming Watch dates.
