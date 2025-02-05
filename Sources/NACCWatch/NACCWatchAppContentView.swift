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
// MARK: - Watch App Content View -
/* ###################################################################################################################################### */
/**
 */
struct NACCWatchAppContentView: View {
    /* ################################################################################################################################## */
    // MARK: Watch Connecvtivity Handler
    /* ################################################################################################################################## */
    /**
     */
    class NACCWatchAppContentViewWatchDelegate: NSObject, WCSessionDelegate {
        /* ################################################################## */
        /**
         */
        typealias ApplicationContextHandler = (_ inApplicationContext: [String: Any]) -> Void

        /* ################################################################## */
        /**
         This holds the WatchKit session.
         */
        private let _wcSession = WCSession.default

        /* ################################################################## */
        /**
         */
        var updateHandler: ApplicationContextHandler?
        
        /* ############################################################## */
        /**
         */
        func session(_ inSession: WCSession, activationDidCompleteWith inActivationState: WCSessionActivationState, error inError: (any Error)?) {
            print("Session Is: \(inActivationState)")
        }
        
        /* ############################################################## */
        /**
         */
        func session(_ inSession: WCSession, didReceiveApplicationContext inApplicationContext: [String: Any]) {
            #if DEBUG
                print("Application Context Update: \(inApplicationContext)")
            #endif
            updateHandler?(inApplicationContext)
        }
        
        /* ############################################################## */
        /**
         */
        init(updateHandler inUpdateHandler: ApplicationContextHandler?) {
            super.init()
            updateHandler = inUpdateHandler
            _wcSession.delegate = self
            _wcSession.activate()
        }
    }
    
    /* ################################################################## */
    /**
     */
    @State var cleanDate: Date?

    /* ################################################################## */
    /**
     */
    @State var watchFormat: NACCPersistentPrefs.MainWatchState?

    /* ################################################################## */
    /**
     */
    @State var watchDelegateHandler: NACCWatchAppContentViewWatchDelegate?
    
    /* ################################################################## */
    /**
     */
    static let wcSession: WCSession? = WCSession.default
    
    /* ################################################################## */
    /**
     */
    func updateApplicationContext(_ inApplicationContext: [String: Any]) {
        #if DEBUG
            print("Application Context Update: \(inApplicationContext)")
        #endif
        if let cleanDateTemp = inApplicationContext["cleanDate"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            cleanDate = dateFormatter.date(from: cleanDateTemp)
        }
        
        if let watchFormatTemp = inApplicationContext["watchAppDisplayState"] as? Int {
            watchFormat = NACCPersistentPrefs.MainWatchState(rawValue: watchFormatTemp)
        }
        
        #if DEBUG
            print("Cleandate: \(cleanDate.debugDescription)")
            print("WatchFormat: \(watchFormat.debugDescription)")
        #endif
    }

    /* ################################################################## */
    /**
     */
    var body: some View {
        VStack {
            Text("CleanDate: \(nil != cleanDate ? cleanDate!.description : "ERROR")")
        }
        .padding()
        .onAppear {
            cleanDate = .now
            watchFormat = .medallion
            watchDelegateHandler = NACCWatchAppContentViewWatchDelegate(updateHandler: updateApplicationContext)
        }
    }
}
