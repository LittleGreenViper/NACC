/*
 © Copyright 2012-2025, Little Green Viper Software Development LLC
 
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
     This handles the session delegate.
     */
    @State private var _wcSessionDelegateHandler: NACCWatchAppContentViewWatchDelegate?
    
    /* ################################################################## */
    /**
     The image that represents a keytag. May be nil.
     */
    @State private var _singleKeytag: UIImage?
    
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
     This is a binding for a "trigger," that tells the screen to update to the latest values.
     */
    @State private var _syncUp: Bool = false

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
        if let cleanDateTemp = inApplicationContext["cleanDate"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            _cleanDate = dateFormatter.date(from: cleanDateTemp) ?? .now
            NACCPersistentPrefs().cleanDate = _cleanDate
            #if DEBUG
                print("Cleandate: \(_cleanDate)")
            #endif
        }
        
        if let watchFormatTemp = inApplicationContext["watchAppDisplayState"] as? Int,
           let format = NACCPersistentPrefs.MainWatchState(rawValue: watchFormatTemp) {
            _watchFormat = format.rawValue
            NACCPersistentPrefs().watchAppDisplayState = format
            
            #if DEBUG
                print("WatchFormat: \(format)")
            #endif
        }
        
        _syncUp = true
    }
    
    /* ################################################################## */
    /**
     We simply show the content view.
     */
    var body: some Scene {
        WindowGroup {
            NACCWatchAppContentView(singleKeytag: $_singleKeytag,
                                    singleMedallion: $_singleMedallion,
                                    text: $_text,
                                    showCleanDatePicker: $_showCleanDatePicker,
                                    syncUp: $_syncUp,
                                    cleanDate: $_cleanDate,
                                    watchFormat: $_watchFormat
            )
                .onAppear { _wcSessionDelegateHandler = NACCWatchAppContentViewWatchDelegate(updateHandler: updateApplicationContext) }
                .background {
                    Image("BackgroundGradient")
                        .resizable(resizingMode: .stretch)
                        .cornerRadius(16)
                }
        }
        .onChange(of: _cleanDate) {
            NACCPersistentPrefs().cleanDate = _cleanDate
            if _showCleanDatePicker {   // Only if we are changing it on the watch.
                _wcSessionDelegateHandler?.sendApplicationContext()
            }
        }
        .onChange(of: _watchFormat) {
            if let formatTemp = NACCPersistentPrefs.MainWatchState(rawValue: _watchFormat),
               formatTemp != NACCPersistentPrefs().watchAppDisplayState {   // We only send it, if we changed the screen that we're viewing.
                NACCPersistentPrefs().watchAppDisplayState = formatTemp
                _wcSessionDelegateHandler?.sendApplicationContext()
            }
        }
    }
}
