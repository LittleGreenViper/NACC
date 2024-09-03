/*
 © Copyright 2022, Little Green Viper Software Development LLC
 
 LICENSE:
 
 MIT License
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
 modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import AppIntents
import LGV_UICleantime
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - Get Cleantime Summary -
/* ###################################################################################################################################### */
/**
 This intent calculates the cleantime, based on an input cleandate, and returns a string, summarizing it.
 */
struct NACCGetCleantimeSummaryIntent: AppIntent {
    /* ################################################################## */
    /**
     The intent title.
     */
    static let title: LocalizedStringResource = "SLUG-GET-CLEANTIME-SUMMARY-INTENT-TITLE"

    /* ################################################################## */
    /**
     The intent description.
     */
    static let description: IntentDescription = "SLUG-GET-CLEANTIME-SUMMARY-INTENT-DESC"

    /* ################################################################## */
    /**
     This is the input cleandate, as date components.
     */
    @Parameter(title: LocalizedStringResource("SLUG-GET-CLEANTIME-SUMMARY-INTENT-CLEANDATE"))
    var cleanDate: DateComponents?
    
    /* ################################################################## */
    /**
     This calculates the cleantime, and creates a text string, with the summary.
     */
    func perform() async throws -> some ReturnsValue<String> {
        if let cleanDate = cleanDate {
            if let minimumDate = Calendar.current.date(from: DateComponents(year: 1953, month: 11, day: 5)),
               let currentDate = Calendar.current.date(from: cleanDate),
               (Calendar.current.startOfDay(for: minimumDate)..<Calendar.current.startOfDay(for: .now).addingTimeInterval(86400)).contains(currentDate),
               let text = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: currentDate, endDate: .now, calendar: Calendar.current) {
                return .result(value: text)
            }
        }
        
        return .result(value: "ERROR")
    }
}

/* ###################################################################################################################################### */
// MARK: - -
/* ###################################################################################################################################### */
/**
 */
struct NACCAppShortcuts: AppShortcutsProvider {
    /* ################################################################## */
    /**
     */
    static var shortcutTileColor: ShortcutTileColor = .navy

    /* ################################################################## */
    /**
     */
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: NACCGetCleantimeSummaryIntent(), phrases: ["SLUG-GET-CLEANTIME-SUMMARY-INTENT-\(.applicationName)"], systemImageName: "calendar")
    }
}
