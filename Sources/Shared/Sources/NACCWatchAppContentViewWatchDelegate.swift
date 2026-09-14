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

import WatchConnectivity

/* ###################################################################################################################################### */
// MARK: Watch Connecvtivity Handler
/* ###################################################################################################################################### */
/**
 This class exists to give the Watch Connectivity a place to work.
 */
class NACCWatchAppContentViewWatchDelegate: NSObject, WCSessionDelegate {
    /* ###################################################################### */
    /**
     This is a template for the update callback.
     
     - parameter inApplicationContext: The new application context.
     */
    typealias ApplicationContextHandler = (_ inApplicationContext: [String: Any]) -> Void

    #if !os(watchOS)    // Only necessary for iOS
        /* ################################################################## */
        /**
         Just here to satisfy the protocol.
         */
        func sessionDidBecomeInactive(_: WCSession) { }
        
        /* ################################################################## */
        /**
         Just here to satisfy the protocol.
         */
        func sessionDidDeactivate(_: WCSession) { }
    #endif
    
    /* ###################################################################### */
    /**
     This will be called when the context changes. This is always called in the main thread.
     */
    var updateHandler: ApplicationContextHandler?
    
    /* ###################################################################### */
    /**
     This maintains a reference to the session.
     */
    static private var _wcSession = WCSession.default
    
    /* ###################################################################### */
    /**
     This is a simple semaphore, to indicate that an update to/from the peer is in progress.
     */
    var isUpdateInProgress = false
    
    /* ###################################################################### */
    /**
     Called when an activation change occurs.
     
     - parameter inSession: The session experiencing the activation change.
     - parameter inActivationState: The new state.
     - parameter inError: If there was an error, it is sent in here.
     */
    func session(_ inSession: WCSession, activationDidCompleteWith inActivationState: WCSessionActivationState, error inError: (any Error)?) {
        #if DEBUG
            print("The Watch session is\(.activated == inActivationState ? "" : " not") activated.")
        #endif
        
        guard .activated == inActivationState else { return }
        DispatchQueue.main.async {
            #if !os(watchOS)    // Only necessary for iOS
                self.sendApplicationContext()
            #else
                self.sendContextRequest()
            #endif
        }
    }
    
    /* ###################################################################### */
    /**
     Called when the application context is updated from the peer.
     
     - parameter inSession: The session receiving the context update.
     - parameter inApplicationContext: The new context data.
    */
    func session(_ inSession: WCSession, didReceiveApplicationContext inApplicationContext: [String: Any]) {
        DispatchQueue.main.async {
            guard !self.isUpdateInProgress else { return }
            self.isUpdateInProgress = true
            #if DEBUG && os(watchOS)
                print("Watch App Received Context Update: \(inApplicationContext)")
            #elseif DEBUG
                print("iOS App Received Context Update: \(inApplicationContext)")
            #endif
            self.updateHandler?(inApplicationContext)
            self.isUpdateInProgress = false
        }
    }
    
    /* ###################################################################### */
    /**
     Called when the session deactivates.
     
     - parameter inSession: The session being deactivated.
    */
    func wcSessionDidBecomeInactive(_ inSession: WCSession) {
        #if DEBUG
            print("Session is inactive.")
        #endif
    }
    
    #if !os(watchOS)    // Only necessary for iOS
        /* ################################################################## */
        /**
         Called when a context update request message from the watch, is received on the phone.
         - parameter inSession: The session receiving the message.
         - parameter inMessage: The message that we received from the phone.
        */
        func session(_ inSession: WCSession, didReceiveMessage inMessage: [String: Any]) {
            #if DEBUG
                print("Received Message From Watch: \(inMessage)")
            #endif
            if let messageType = inMessage["messageType"] as? String,
               "requestContext" == messageType {
                #if DEBUG
                    print("Responding to context request from the watch")
                #endif
                DispatchQueue.main.async { self.sendApplicationContext() }
            }
        }

        /* ################################################################## */
        /**
         Returns the current context when the watch requests a reply.

         - parameter inSession: The session receiving the message.
         - parameter inMessage: The request from the watch.
         - parameter inReplyHandler: The callback that receives the current context.
         */
        func session(_ inSession: WCSession, didReceiveMessage inMessage: [String: Any], replyHandler inReplyHandler: @escaping ([String: Any]) -> Void) {
            DispatchQueue.main.async {
                // Accept the original request key as well, for watches running an older build.
                guard "requestContext" == inMessage["messageType"] as? String || "requestContext" == inMessage["requestContext"] as? String else {
                    inReplyHandler([:])
                    return
                }
                inReplyHandler(self._applicationContext())
            }
        }
    #else
        /* ############################################################## */
        /**
         This sends a message to the phone (from the watch), that is interpreted as a request for a context update.
        */
        func sendContextRequest(_ inRetries: Int = 5) {
            /* ########################################################## */
            /**
             This handles a valid reply.
             
             - parameter inReply: A dictionary, containing the reply.
            */
            func _replyHandler(_ inReply: [String: Any]) {
                #if DEBUG
                    print("Received Reply from Phone: \(inReply)")
                #endif
                self.session(Self._wcSession, didReceiveApplicationContext: inReply)
            }
            
            /* ########################################################## */
            /**
             This is called for an error. We may retry the call.
             
            - parameter inError: Any error that occurred
            */
            func _errorHandler(_ inError: any Error) {
                #if DEBUG
                    print("Error Sending Message to Phone: \(inError.localizedDescription)")
                #endif
                let nsError = inError as NSError
                if nsError.domain == "WCErrorDomain",
                   7007 == nsError.code,
                   0 < inRetries {
                    #if DEBUG
                        print("Connection failure. Retrying...")
                    #endif
                    let randomDelay = Double.random(in: (0.3...1.0))
                    DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) { self.sendContextRequest(inRetries - 1) }
                    return
                } else {
                    #if DEBUG
                        print("Error Not Handled")
                    #endif
                }
            }

            if .activated == Self._wcSession.activationState {
                #if DEBUG
                    print("Sending context request to the phone")
                #endif
                Self._wcSession.sendMessage(["messageType": "requestContext"], replyHandler: _replyHandler, errorHandler: _errorHandler)
            }
        }
    #endif

    /* ################################################################## */
    /**
     Builds the same state snapshot for queued updates and immediate replies.
     */
    private func _applicationContext() -> [String: Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let prefs = NACCPersistentPrefs()
        return ["cleanDate": dateFormatter.string(from: prefs.cleanDate),
                "watchAppDisplayState": prefs.watchAppDisplayState.rawValue]
    }
    
    /* ################################################################## */
    /**
     This is called to send the current state of the prefs to the peer.
     */
    func sendApplicationContext() {
        guard !self.isUpdateInProgress else { return }
        self.isUpdateInProgress = true
        do {
            let contextData = self._applicationContext()
            
            #if DEBUG
                #if os(watchOS)
                    print("Sending Application Context to the Phone: \(contextData)")
                #else
                    print("Sending Application Context to the Watch: \(contextData)")
                #endif
            #endif

            if .activated == Self._wcSession.activationState {
                try Self._wcSession.updateApplicationContext(contextData)
            }
        } catch {
            #if DEBUG
                print("WC Session Error: \(error.localizedDescription)")
            #endif
        }
        self.isUpdateInProgress = false
    }

    /* ###################################################################### */
    /**
     Initializer
     
     - parameter inUpdateHandler: The function that will be called with any updates.
     */
    init(updateHandler inUpdateHandler: ApplicationContextHandler?) {
        self.updateHandler = inUpdateHandler
        super.init()
        Self._wcSession.delegate = self
        Self._wcSession.activate()
    }
}
