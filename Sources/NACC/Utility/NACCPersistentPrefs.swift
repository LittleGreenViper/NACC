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

/* ###################################################################################################################################### */
// MARK: - The Persistent Prefs Subclass -
/* ###################################################################################################################################### */
/// This is the subclass of the preferences type that will provide our persistent app settings.
class NACCPersistentPrefs: RVS_PersistentPrefs {
    /* ################################################################################################################################## */
    // MARK: Widget Format Preference Keys
    /* ################################################################################################################################## */
    /**
     This enum stores how we want to display the cleantime in the widget.
     */
    enum WidgetFormat: String, CaseIterable {
        /* ############################################################## */
        /**
         This displays the cleandats as only a text item.
         */
        case textOnly

        /* ############################################################## */
        /**
         This displays a single keytag, representing the last earned keytag.
         */
        case keytags

        /* ############################################################## */
        /**
         This displays an array of horizontally-arranged medallions (if over a year). If under a year, it is text-only.
         */
        case medallions

        /* ############################################################## */
        /**
         This displays a single keytag, representing the last earned keytag, if less than a year, or a medallion, if after a year.
         */
        case keytagOrMedallion
    }

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
         This stores the selected widget format as a string (must be one of the WidgetFormat values)
         */
        case widgetFormat

        /* ############################################################## */
        /**
         These are all the keys, in an Array of String.
         */
        static var allKeys: [String] {
            [
                cleanDate.rawValue,
                lastSelectedTabIndex.rawValue,
                widgetFormat.rawValue
            ]
        }
    }

    /* ################################################################################################################################## */
    // MARK: RVS_PersistentPrefs Conformance
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is a list of the keys for our prefs.
     We should use the enum for the keys (rawValue).
     */
    override var keys: [String] { Keys.allKeys }

    /* ################################################################################################################################## */
    // MARK: External Prefs Access Computed Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This stores the cleandate, as an instance of Date
     */
    var cleanDate: Date {
        get { values[Keys.cleanDate.rawValue] as? Date ?? .now }
        set { values[Keys.cleanDate.rawValue] = newValue }
    }

    /* ################################################################## */
    /**
     This stores the last selected tab index (0-based).
     */
    var lastSelectedTabIndex: Int {
        get { values[Keys.lastSelectedTabIndex.rawValue] as? Int ?? 0 }
        set { values[Keys.lastSelectedTabIndex.rawValue] = newValue }
    }

    /* ################################################################## */
    /**
     This stores the selected widget format as a WidgetFormat value
     */
    var widgetFormat: WidgetFormat {
        get {
            guard let valueString = values[Keys.widgetFormat.rawValue] as? String,
                  let ret = WidgetFormat(rawValue: valueString)
            else { return .textOnly }

            return ret
        }
        set { values[Keys.widgetFormat.rawValue] = newValue.rawValue }
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
