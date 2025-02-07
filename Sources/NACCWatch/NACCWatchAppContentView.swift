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
// MARK: - Watch App Content View -
/* ###################################################################################################################################### */
/**
 */
struct NACCWatchAppContentView: View {
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
         This holds the WatchKit session.
         */
        private let _wcSession = WCSession.default

        /* ################################################################## */
        /**
         This will be called when the context changes.
         */
        var updateHandler: ApplicationContextHandler?
        
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
                print("Application Context Update: \(inApplicationContext)")
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
            _wcSession.delegate = self
            _wcSession.activate()
        }
    }

    /* ################################################################## */
    /**
     This is called to send the current state of the prefs to the peer.
     */
    static func sendApplicationContext() {
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            var contextData: [String: Any] = ["cleanDate": dateFormatter.string(from: NACCPersistentPrefs().cleanDate),
                                              "watchAppDisplayState": NACCPersistentPrefs().watchAppDisplayState.rawValue
            ]
            #if DEBUG
                contextData["makeMeUnique"] = UUID().uuidString
            #endif

            try wcSession?.updateApplicationContext(contextData)
        } catch {
            print("ERROR: \(error)")
        }
    }

    /* ################################################################## */
    /**
     The text report.
     */
    @State var text: String = ""

    /* ################################################################## */
    /**
     The image that represents a keytag. May be nil. Mutually exclusive with `singleMedallion`.
     */
    @State var singleKeytag: UIImage?
    
    /* ################################################################## */
    /**
     The image that represents a medallion. May be nil. Mutually exclusive with `singleKeytag`.
     */
    @State var singleMedallion: UIImage?

    /* ################################################################## */
    /**
     The cleandate.
     */
    @State var cleanDate: Date

    /* ################################################################## */
    /**
     */
    @State var watchFormat: NACCPersistentPrefs.MainWatchState

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
            cleanDate = dateFormatter.date(from: cleanDateTemp) ?? .now
        }
        
        if let watchFormatTemp = inApplicationContext["watchAppDisplayState"] as? Int {
            watchFormat = NACCPersistentPrefs.MainWatchState(rawValue: watchFormatTemp) ?? .medallion
        }
        
        #if DEBUG
            print("Cleandate: \(cleanDate)")
            print("WatchFormat: \(watchFormat)")
        #endif
        
        NACCPersistentPrefs().cleanDate = cleanDate
        NACCPersistentPrefs().watchAppDisplayState = watchFormat
        synchronize()
    }
    
    /* ################################################################## */
    /**
     This renders the images and text.
     
     This should be called on the main thread.
     */
    func synchronize() {
        if let textTemp = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: cleanDate, endDate: .now) {
            text = textTemp
        } else {
            text = "ERROR"
        }
        
        singleKeytag = nil
        singleMedallion = nil
        
        guard .text != NACCPersistentPrefs().watchAppDisplayState else { return }
        
        let calculator = LGV_CleantimeDateCalc(startDate: cleanDate).cleanTime
        
        let medallionView = LGV_MedallionImage(totalMonths: calculator.totalMonths)
        
        singleMedallion = medallionView.drawImage() // ?.resized(toMaximumSize: Self._imageSizeInDisplayUnits)

        let keyTagImage = LGV_KeytagImageGenerator(isRingClosed: true, totalDays: calculator.totalDays, totalMonths: calculator.totalMonths)
        singleKeytag = keyTagImage.generatedImage // ?.resized(toMaximumSize: Self._imageSizeInDisplayUnits)
    }

    /* ################################################################## */
    /**
     */
    var body: some View {
        TabView {
            Text(text)
            if let singleKeytag {
                Image(uiImage: singleKeytag)
            }
            if let singleMedallion {
                Image(uiImage: singleMedallion)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .onAppear {
            cleanDate = .now
            watchFormat = .medallion
            watchDelegateHandler = NACCWatchAppContentViewWatchDelegate(updateHandler: updateApplicationContext)
        }
    }
}
