/*
 © Copyright 2012-2026, Little Green Viper Software Development LLC
 
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

import SwiftUI
import WatchConnectivity
import LGV_Cleantime
import LGV_UICleantime
import WidgetKit

/* ###################################################################################################################################### */
// MARK: - Watch App -
/* ###################################################################################################################################### */
/**
 This is the main app wrapper.
 */
@main
struct NACCWatchApp: App {
    /* ################################################################## */
    /**
     Tracks scene activity.
     */
    @Environment(\.scenePhase) private var _scenePhase

    /* ################################################################## */
    /**
     This handles the session delegate.
     */
    static private var _wcSessionDelegateHandler: NACCWatchAppContentViewWatchDelegate?
    
    /* ################################################################## */
    /**
     The image that represents the keytag chain.
     */
    @State private var _keytagChain: UIImage?
    
    /* ################################################################## */
    /**
     The image that represents a medallion. May be nil.
     */
    @State private var _singleMedallion: UIImage?

    /* ################################################################## */
    /**
     This is a source for a "trigger," that determines whether or not the set cleandate picker is to be shown.
     */
    @State private var _showCleanDatePicker: Bool = false

    /* ################################################################## */
    /**
     The text report.
     */
    @State private var _text: String = ""

    /* ################################################################## */
    /**
     The cleandate.
     */
    @State private var _cleanDate = NACCPersistentPrefs().cleanDate

    /* ################################################################## */
    /**
     This is a local state that determines which screen is shown (0 is text, 1 is keytag, 2 is medallion).
     */
    @State private var _watchFormat = NACCPersistentPrefs().watchAppDisplayState.rawValue
    
    /* ################################################################## */
    /**
     This will update our internal state, to match the new application context that we received from the phone.
     
     - parameter inApplicationContext: The new context dictionary.
     */
    func updateApplicationContext(_ inApplicationContext: [String: Any]) {
        // The selected page belongs to the Watch. The phone may echo an older selection.
        if let cleanDateTemp = inApplicationContext["cleanDate"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let cleanDate = dateFormatter.date(from: cleanDateTemp) {
                if !Calendar.current.isDate(cleanDate, inSameDayAs: self._cleanDate) {
                    self._cleanDate = cleanDate
                }
                let prefs = NACCPersistentPrefs()
                // An unset preference also displays today. Save the first received date in that case.
                if cleanDate != prefs.values[NACCPersistentPrefs.Keys.cleanDate.rawValue] as? Date {
                    prefs.cleanDate = cleanDate
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     We simply show the content view.
     */
    var body: some Scene {
        WindowGroup {
            NACCWatchAppContentView(keytagChain: $_keytagChain,
                                    singleMedallion: $_singleMedallion,
                                    text: $_text,
                                    showCleanDatePicker: $_showCleanDatePicker,
                                    cleanDate: $_cleanDate,
                                    watchFormat: $_watchFormat
            )
            .fontDesign(.default)
            .tint(.accentColor)
        }
        .onChange(of: self._cleanDate) {
            if NACCPersistentPrefs().cleanDate != self._cleanDate {
                NACCPersistentPrefs().cleanDate = self._cleanDate
                if self._showCleanDatePicker {   // Only if we are changing it on the watch.
                    Self._wcSessionDelegateHandler?.sendApplicationContext()
                }
                WidgetCenter.shared.reloadTimelines(ofKind: "NACCWatchComplication")
            }
        }
        .onChange(of: self._watchFormat) {
            if let formatTemp = NACCPersistentPrefs.MainWatchState(rawValue: self._watchFormat),
               formatTemp != NACCPersistentPrefs().watchAppDisplayState {
                NACCPersistentPrefs().watchAppDisplayState = formatTemp
            }
        }
        // Forces updates, whenever we become active.
        .onChange(of: self._scenePhase, initial: true) {
            if .active == self._scenePhase {
                NACCPersistentPrefs().flush()
                if let handler = Self._wcSessionDelegateHandler {
                    handler.sendContextRequest()
                } else {
                    Self._wcSessionDelegateHandler = NACCWatchAppContentViewWatchDelegate(updateHandler: self.updateApplicationContext)
                }
                WidgetCenter.shared.reloadTimelines(ofKind: "NACCWatchComplication")
            }
        }
    }
}
