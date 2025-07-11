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

import Foundation
import RVS_Persistent_Prefs
import WidgetKit

/* ###################################################################################################################################### */
// MARK: - The Persistent Prefs Subclass -
/* ###################################################################################################################################### */
/// This is the subclass of the preferences type that will provide our persistent app settings.
class NACCPersistentPrefs: RVS_PersistentPrefs {
    /* ################################################################################################################################## */
    // MARK: Preference Keys
    /* ################################################################################################################################## */
    /**
     This is an enumeration that will list the prefs keys for us.
     */
    enum Keys: String {
        /* ############################################################## */
        /**
         This stores the cleandate, as an instance of Date
         */
        case cleanDate

        /* ############################################################## */
        /**
         This stores the last selected tab index (0-based).
         */
        case lastSelectedTabIndex

        /* ############################################################## */
        /**
         The Watch app screen display selection.
         */
        case watchAppDisplayState
        
        /* ############################################################## */
        /**
         These are all the keys, in an Array of String.
         */
        static var allKeys: [String] {[cleanDate.rawValue, lastSelectedTabIndex.rawValue, watchAppDisplayState.rawValue]}
    }
    
    /* ################################################################################################################################## */
    // MARK: Display for Main Watch App Screen
    /* ################################################################################################################################## */
    /**
     Choose which of the states to display in the main screen of the Watch app. The secondary screen will always be a keytag list.
     */
    enum MainWatchState: Int {
        /* ############################################################## */
        /**
         Only display the text report of the cleantime.
         */
        case text

        /* ############################################################## */
        /**
         Only display the highest achieved keytag.
         */
        case keytag

        /* ############################################################## */
        /**
         Only display the highest achieved keytag (if less than a year), or the last medallion (if a year or more).
         This is the default.
         */
        case medallion
    }
    
    /* ################################################################################################################################## */
    // MARK: RVS_PersistentPrefs Conformance
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is a list of the keys for our prefs.
     We should use the enum for the keys (rawValue).
     */
    override var keys: [String] { Self.Keys.allKeys }

    /* ################################################################################################################################## */
    // MARK: External Prefs Access Computed Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This stores the cleandate, as an instance of Date
     */
    var cleanDate: Date {
        get { self.values[Self.Keys.cleanDate.rawValue] as? Date ?? .now }
        set {
            self.values[Self.Keys.cleanDate.rawValue] = newValue
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    /* ################################################################## */
    /**
     This stores the last selected tab index (0-based).
     */
    var lastSelectedTabIndex: Int {
        get { self.values[Self.Keys.lastSelectedTabIndex.rawValue] as? Int ?? 0 }
        set { self.values[Self.Keys.lastSelectedTabIndex.rawValue] = newValue }
    }

    /* ################################################################## */
    /**
     This is set and read by the Watch app. It is not accessed by any of the other targets.
     */
    var watchAppDisplayState: NACCPersistentPrefs.MainWatchState {
        get {
            guard let stateIndex = self.values[Self.Keys.watchAppDisplayState.rawValue] as? Int,
                  let ret = Self.MainWatchState(rawValue: stateIndex)
            else { return .text }
            
            return ret
        }
        set { self.values[Self.Keys.watchAppDisplayState.rawValue] = newValue.rawValue }
    }

    /* ################################################################## */
    /**
     We just make sure that we use the shared group for our prefs.
     
     We extract the group string from our info.plist.
     */
    override init() {
        if Self.groupID?.isEmpty ?? true,
           let appGroupString = Bundle.main.infoDictionary?["appGroup"] as? String,
           !appGroupString.isEmpty {
            Self.groupID = appGroupString
        }
        
        super.init()
    }
}
