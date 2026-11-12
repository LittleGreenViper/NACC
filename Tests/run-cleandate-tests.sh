#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
build_dir="$(mktemp -d "${TMPDIR:-/tmp}/nacc-cleandate-tests.XXXXXX")"
trap 'rm -rf "$build_dir"' EXIT

xcode_dev="$(xcode-select -p)"
test_frameworks="$xcode_dev/Platforms/MacOSX.platform/Developer/Library/Frameworks"
test_libraries="$xcode_dev/Platforms/MacOSX.platform/Developer/usr/lib"

xcrun swiftc -F "$test_frameworks" -I "$test_libraries" \
    -L "$test_libraries" -Xlinker -rpath -Xlinker "$test_frameworks" \
    -Xlinker -rpath -Xlinker "$test_libraries" \
    "$repo_root/Sources/NACC/NACC_CleandateSession.swift" \
    "$repo_root/Tests/main.swift" -o "$build_dir/CleandateSessionTests"
"$build_dir/CleandateSessionTests"
