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

/* ###################################################################################################################################### */
// MARK: - Get Cleantime Summary -
/* ###################################################################################################################################### */
/**
 This intent calculates the cleantime, based on an input cleandate, and returns a string, summarizing it.
 
 This is meant for a "faceless" query, where the user is told their cleantime, without opening the app.
 */
struct NACCGetCleantimeSummaryAppIntent: AppIntent {
    /* ################################################################## */
    /**
     The intent title.
     */
    static var title: LocalizedStringResource = "Calculate My Cleantime"

    /* ################################################################## */
    /**
     The intent description.
     */
    static let description: IntentDescription = "Returns a summary of your cleantime"

    /* ################################################################## */
    /**
     This is the input cleandate, as date components.
     */
    @Parameter(title: LocalizedStringResource("Enter Your Clean Date"), kind: .date)
    var cleanDate: DateComponents?
    
    /* ################################################################## */
    /**
     This calculates the cleantime, and creates a text string, with the summary.
     */
    func perform() async throws -> some ReturnsValue<String> & ProvidesDialog {
        if let cleanDate = cleanDate {
            if let minimumDate = Calendar.current.date(from: DateComponents(year: 1953, month: 10, day: 5)),
               let currentDate = Calendar.current.date(from: cleanDate),
               (Calendar.current.startOfDay(for: minimumDate)..<Calendar.current.startOfDay(for: .now).addingTimeInterval(86400)).contains(currentDate),
               let textTemp = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: currentDate, endDate: .now, calendar: Calendar.current) {
                let dialog = IntentDialog(stringLiteral: textTemp)
                return .result(value: textTemp, dialog: dialog)
            }
        }
        
        let dialog = IntentDialog(stringLiteral: "You must enter a valid clean date!")
        return .result(value: "", dialog: dialog)
    }
}

/* ###################################################################################################################################### */
// MARK: - -
/* ###################################################################################################################################### */
/**
 This provides the shortcut for the app intent.
 */
struct NACCAppShortcuts: AppShortcutsProvider {
    /* ################################################################## */
    /**
     The tile color for shortcuts generated from this app intent.
     */
    static var shortcutTileColor: ShortcutTileColor = .navy

    /* ################################################################## */
    /**
     The shortcuts available to the app.
     */
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: NACCGetCleantimeSummaryAppIntent(), phrases: ["SLUG-GET-CLEANTIME-SUMMARY-INTENT-\(.applicationName)"], systemImageName: "calendar")
    }
}
