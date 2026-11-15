# Cleandate regression tests

Run from the repository root on a Mac with Xcode selected:

```sh
Tests/run-cleandate-tests.sh
```

The suite compiles the app's deep-link parser and cleandate session directly, then runs XCTest without launching a simulator. It covers both URL schemes, temporary flags and tab indexes, invalid links, permanent and temporary date edits, background restoration, relaunch, replacement links, and incoming Watch dates.

## Localization resources

Run `python3 Tests/validate-localizations.py` to validate every supported locale, reject duplicate keys and missing format arguments, check report-fragment whitespace, and verify Watch/widget catalogs and Siri intent IDs.

To also compare compiled resources with their source translations, repeat `--bundle` for the built iOS app, Watch app, widget, complication, and Siri extension. For example:

```sh
python3 Tests/validate-localizations.py --bundle /path/to/NACC.app
```

The script uses the Mac's `plutil`; it does not launch a simulator. Review navigation, date editing, sharing/printing choices, and Watch pages with VoiceOver on a device to check pronunciation and interaction flow.
