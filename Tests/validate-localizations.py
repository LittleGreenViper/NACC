#!/usr/bin/env python3
"""Validate NACC's translated resources, optionally including built app bundles."""

import argparse
from collections import Counter
import json
from pathlib import Path
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
RESOURCES = ROOT / 'Sources/Shared/Resources'
LANGUAGES = ('de', 'el', 'es', 'es-419', 'fr', 'it', 'pt-BR')
INVARIANTS = {'SLUG-INITIAL-TITLE', 'SLUG-URL-STRING', 'SLUG-COPYRIGHT-BUTTON', 'SLUG-WIDGET-NAME'}
REPORT_KEYS = {
    'SLUG-STATEMENT-IN-RECOVERY-SINCE', 'SLUG-STATEMENT-CLEANDATE-SEPARATOR',
    'SLUG-STATEMENT-NO-CLEANTIME', 'SLUG-CLEANTIME-DIVIDER',
    'SLUG-PREFIX-CLEANTIME-YEAR-EXACT', 'SLUG-PREFIX-CLEANTIME-YEARS-EXACT',
    'SLUG-PREFIX-CLEANTIME-YEAR', 'SLUG-PREFIX-CLEANTIME-YEARS',
    'SLUG-PREFIX-CLEANTIME-MONTH', 'SLUG-PREFIX-CLEANTIME-MONTHS',
    'SLUG-PREFIX-CLEANTIME-DAY', 'SLUG-PREFIX-CLEANTIME-DAYS',
    'SLUG-JOINING-CHAR', 'SLUG-ENDING-CHAR',
}
ENTRY = re.compile(r'^\s*"((?:\\.|[^"\\])*)"\s*=\s*"((?:\\.|[^"\\])*)"\s*;', re.M)
ARGUMENT = re.compile(r'%(?:\d+\$)?[-+#0 ]*(?:\d+|\*)?(?:\.(?:\d+|\*))?(?:hh|ll|[hlLzjtq])?([@diouxXfFeEgGcCsSpaA])|\$\{([^}]+)\}')
errors = []
checked = 0


def check(condition, message):
    if not condition:
        errors.append(message)


def arguments(value):
    return Counter(ARGUMENT.findall(value.replace('%%', '')))


def read_strings(path):
    global checked
    checked += 1
    # plutil validates both source text and compiled binary .strings resources.
    result = subprocess.run(['plutil', '-convert', 'json', '-o', '-', str(path)], capture_output=True, text=True)
    if result.returncode:
        errors.append(f'{path}: {result.stderr or result.stdout}')
        return {}
    result = json.loads(result.stdout)
    if path.read_bytes().startswith(b'bplist'):
        return result
    keys = [json.loads('"' + match[0] + '"') for match in ENTRY.findall(path.read_text())]
    duplicates = [key for key, count in Counter(keys).items() if count > 1]
    check(not duplicates, f'{path}: duplicate keys: {duplicates}')
    return result


def compare(reference, translated, path):
    check(reference.keys() <= translated.keys(), f'{path}: missing keys: {reference.keys() - translated.keys()}')
    for key in reference.keys() & translated.keys():
        check(bool(translated[key]), f'{path}: empty value for {key}')
        check(arguments(reference[key]) == arguments(translated[key]), f'{path}: mismatched format arguments for {key}')


def main(bundles):
    base = read_strings(RESOURCES / 'Base.lproj/Localizable.strings')
    info = read_strings(RESOURCES / 'Base.lproj/InfoPlist.strings')
    shortcuts = read_strings(RESOURCES / 'en.lproj/AppShortcuts.strings')
    settings = read_strings(RESOURCES / 'Settings.bundle/en.lproj/Settings.strings')
    intent = read_strings(ROOT / 'Sources/NACCIntents/en.lproj/NACCIntents.strings')
    translations = {}
    for language in LANGUAGES:
        path = RESOURCES / f'{language}.lproj/Localizable.strings'
        values = read_strings(path)
        translations[language] = values
        compare(base, values, path)
        check(set(values) == set(base) | REPORT_KEYS, f'{path}: inconsistent interface/report key set')
        for key in INVARIANTS:
            check(values.get(key) == base[key], f'{path}: changed URL, copyright, or app identity in {key}')
        for key in REPORT_KEYS:
            value = values.get(key, '')
            if key.endswith(('YEARS-EXACT', 'YEARS', 'MONTHS', 'DAYS')):
                check(arguments(value) == Counter({('d', ''): 1}), f'{path}: invalid numeric report format in {key}')
        for key in ('SLUG-STATEMENT-IN-RECOVERY-SINCE', 'SLUG-STATEMENT-CLEANDATE-SEPARATOR', 'SLUG-CLEANTIME-DIVIDER', 'SLUG-JOINING-CHAR'):
            check(values.get(key, '').endswith(' '), f'{path}: missing joining space for report fragment {key}')
        for key in ('SLUG-STATEMENT-CLEANDATE-SEPARATOR', 'SLUG-CLEANTIME-DIVIDER'):
            check(values.get(key, '').startswith('\n'), f'{path}: missing report newline in {key}')
        check(sum(values.get(key) != value for key, value in base.items()) > len(base) // 2, f'{path}: appears to contain English placeholder translations')
        for name, reference in [('InfoPlist', info), ('AppShortcuts', shortcuts)]:
            path = RESOURCES / f'{language}.lproj/{name}.strings'
            translated = read_strings(path)
            compare(reference, translated, path)
            check(set(translated) == set(reference), f'{path}: inconsistent key set')
        for path, reference in [(RESOURCES / f'Settings.bundle/{language}.lproj/Settings.strings', settings), (ROOT / f'Sources/NACCIntents/{language}.lproj/NACCIntents.strings', intent)]:
            translated = read_strings(path)
            compare(reference, translated, path)
            check(set(translated) == set(reference), f'{path}: inconsistent key set')

    catalogs = {}
    for name in ('WatchStrings', 'WidgetStrings'):
        path = RESOURCES / f'{name}.xcstrings'
        catalog = json.loads(path.read_text())
        catalogs[name] = catalog['strings']
        check(catalog['sourceLanguage'] == 'en', f'{path}: unexpected source language')
        for key, item in catalog['strings'].items():
            locales = item['localizations']
            check(set(locales) == {'en', *LANGUAGES}, f'{path}: incomplete language coverage for {key}')
            source = locales['en']['stringUnit']['value']
            for language, translation in locales.items():
                unit = translation['stringUnit']
                check(unit['state'] == 'translated' and bool(unit['value']), f'{path}: unfinished translation for {language}/{key}')
                check(arguments(source) == arguments(unit['value']), f'{path}: mismatched arguments for {language}/{key}')

    # Each localized key used by the app must resolve from its target's resource tables.
    available = set(base) | set().union(*(set(keys) for keys in catalogs.values()))
    for path in (ROOT / 'Sources').rglob('*.swift'):
        for key in re.findall(r'"(SLU[GR]-[^"\n]+)"\s*\.localizedVariant', path.read_text()):
            check(key in available, f'{path}: localized key has no resource: {key}')

    # Ensure the Siri translations use actual IDs from the intent definition.
    definition = ROOT / 'Sources/NACCIntents/Base.lproj/NACCIntents.intentdefinition'
    tree = ET.parse(definition)
    ids = set()
    for dictionary in tree.iter('dict'):
        pairs = list(dictionary)
        for index in range(0, len(pairs), 2):
            if pairs[index].text and pairs[index].text.endswith('ID'):
                ids.add(pairs[index + 1].text)
    check(set(intent) <= ids, f'{definition}: translation IDs do not match the intent definition: {set(intent) - ids}')

    for bundle in bundles:
        for language in LANGUAGES:
            path = bundle / f'{language}.lproj/Localizable.strings'
            check(path.exists(), f'{bundle}: missing compiled {language} interface/report resources')
            if path.exists():
                actual = read_strings(path)
                compare(translations[language], actual, path)
                check(actual == translations[language], f'{path}: compiled interface/report differs from source')
        for name, catalog in catalogs.items():
            if not (bundle / f'en.lproj/{name}.strings').exists():
                continue
            for language in ('en', *LANGUAGES):
                path = bundle / f'{language}.lproj/{name}.strings'
                check(path.exists(), f'{bundle}: missing compiled {language}/{name}')
                if path.exists():
                    expected = {key: item['localizations'][language]['stringUnit']['value'] for key, item in catalog.items()}
                    actual = read_strings(path)
                    check(actual == expected, f'{path}: compiled catalog differs from source')
        if (bundle / 'Settings.bundle').exists():
            for language in ('en', *LANGUAGES):
                path = bundle / f'Settings.bundle/{language}.lproj/Settings.strings'
                check(path.exists(), f'{bundle}: missing compiled Settings for {language}')
        if (bundle / 'en.lproj/NACCIntents.strings').exists():
            for language in ('en', *LANGUAGES):
                check((bundle / f'{language}.lproj/NACCIntents.strings').exists(), f'{bundle}: missing compiled Siri translation for {language}')

    if errors:
        print('\n'.join(errors), file=sys.stderr)
        return 1
    print(f'Passed: {checked} strings files, {len(LANGUAGES)} translated locales, 2 catalogs, all format arguments and report fragments, and {len(bundles)} built bundles.')
    return 0


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--bundle', type=Path, action='append', default=[], help='Built app/extension bundle; may be repeated.')
    sys.exit(main(parser.parse_args().bundle))
