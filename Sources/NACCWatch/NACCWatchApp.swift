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

/* ###################################################################################################################################### */
// MARK: - Watch App -
/* ###################################################################################################################################### */
/**
 This is the main app wrapper.
 */
@main
struct NACCWatchApp: App {
    /* ################################################################################################################################## */
    // MARK: Watch Connecvtivity Handler
    /* ################################################################################################################################## */
    /**
     This class exists to give the Watch Connectivity a place to work.
     */
    class NACCWatchAppContentViewWatchDelegate: NSObject, WCSessionDelegate {
        /* ################################################################## */
        /**
         This is a template for the update callback.
         
         - parameter inApplicationContext: The new application context.
         */
        typealias ApplicationContextHandler = (_ inApplicationContext: [String: Any]) -> Void

        /* ################################################################## */
        /**
         This will be called when the context changes.
         */
        var updateHandler: ApplicationContextHandler?
        
        /* ################################################################## */
        /**
         This maintains a reference to the session.
         */
        var wcSession = WCSession.default
        
        /* ############################################################## */
        /**
         Called when an activation change occurs.
         
         - parameter inSession: The session experiencing the activation change.
         - parameter activationDidCompleteWith: The new state.
         - parameter error: If there was an error, it is sent in here.
         */
        func session(_ inSession: WCSession, activationDidCompleteWith inActivationState: WCSessionActivationState, error inError: (any Error)?) {
            print("Session Is: \(inActivationState)")
        }
        
        /* ############################################################## */
        /**
         Called when the application context is updated from the peer.
         
         - parameter inSession: The session receiving the context update.
         - parameter didReceiveApplicationContext: The new context data.
        */
        func session(_ inSession: WCSession, didReceiveApplicationContext inApplicationContext: [String: Any]) {
            #if DEBUG
                print("Watch App Received Context Update: \(inApplicationContext)")
            #endif
            updateHandler?(inApplicationContext)
        }
        
        /* ############################################################## */
        /**
         Initializer
         
         - parameter updateHandler: The function that will be called with any updates.
         */
        init(updateHandler inUpdateHandler: ApplicationContextHandler?) {
            super.init()
            updateHandler = inUpdateHandler
            wcSession.delegate = self
            wcSession.activate()
        }
    }

    /* ################################################################## */
    /**
     This handles the session delegate.
     */
    @State private var _wcSessionDelegateHandler: NACCWatchAppContentViewWatchDelegate?
    
    /* ################################################################## */
    /**
     This is a source for a "trigger," that determines whether or not the set cleandate picker is to be shown.
     */
    @State private var _showCleanDatePicker: Bool = false
    
    /* ################################################################## */
    /**
     The cleandate.
     */
    @State var cleanDate = NACCPersistentPrefs().cleanDate

    /* ################################################################## */
    /**
     This is a local state that determines which screen is shown (0 is text, 1 is keytag, 2 is medallion).
     */
    @State var watchFormat = NACCPersistentPrefs().watchAppDisplayState.rawValue

    /* ################################################################## */
    /**
     This is called to send the current state of the prefs to the peer.
     */
    func sendApplicationContext() {
        guard _showCleanDatePicker else { return }   // Only if we are changing it on the watch.
        
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let contextData: [String: Any] = ["cleanDate": dateFormatter.string(from: NACCPersistentPrefs().cleanDate),
                                              "watchAppDisplayState": NACCPersistentPrefs().watchAppDisplayState.rawValue,
                                              "makeMeUnique": UUID().uuidString
            ]
            
            #if DEBUG
                print("Sending Application Context to the Phone: \(contextData)")
            #endif

            try _wcSessionDelegateHandler?.wcSession.updateApplicationContext(contextData)
        } catch {
            print("ERROR: \(error)")
        }
    }
    
    /* ################################################################## */
    /**
     This will update our internal state, to match the new application context that we received from the phone.
     
     - parameter inApplicationContext: The new context dictionary.
     */
    func updateApplicationContext(_ inApplicationContext: [String: Any]) {
        if let cleanDateTemp = inApplicationContext["cleanDate"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            cleanDate = dateFormatter.date(from: cleanDateTemp) ?? .now
        }
        
        if let watchFormatTemp = inApplicationContext["watchAppDisplayState"] as? Int {
            watchFormat = (NACCPersistentPrefs.MainWatchState(rawValue: watchFormatTemp) ?? .medallion).rawValue
        }
        
        #if DEBUG
            print("Cleandate: \(cleanDate)")
            print("WatchFormat: \(watchFormat)")
        #endif
        
        NACCPersistentPrefs().cleanDate = cleanDate
        NACCPersistentPrefs().watchAppDisplayState = NACCPersistentPrefs.MainWatchState(rawValue: watchFormat) ?? .medallion
    }
    
    /* ################################################################## */
    /**
     We simply show the content view.
     */
    var body: some Scene {
        WindowGroup {
            NACCWatchAppContentView(showCleanDatePicker: $_showCleanDatePicker, cleanDate: $cleanDate, watchFormat: $watchFormat)
                .onAppear { _wcSessionDelegateHandler = NACCWatchAppContentViewWatchDelegate(updateHandler: updateApplicationContext) }
        }
        .onChange(of: cleanDate) {
            NACCPersistentPrefs().cleanDate = cleanDate
            sendApplicationContext()
        }
        .onChange(of: watchFormat) {
            NACCPersistentPrefs().watchAppDisplayState = NACCPersistentPrefs.MainWatchState(rawValue: watchFormat) ?? .medallion
            sendApplicationContext()
        }
    }
}
