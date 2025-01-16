/*
© Copyright 2012-2024, Little Green Viper Software Development LLC

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

import ActivityKit
import WidgetKit
import SwiftUI

/* ###################################################################################################################################### */
// MARK:
/* ###################################################################################################################################### */
struct NACC_WidgetAttributes: ActivityAttributes {
    /* ################################################################## */
    /**
     */
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    /* ################################################################## */
    /**
     */
    var name: String
}

/* ###################################################################################################################################### */
// MARK:
/* ###################################################################################################################################### */
struct NACC_WidgetLiveActivity: Widget {
    /* ################################################################## */
    /**
     */
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NACC_WidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

/* ###################################################################################################################################### */
// MARK:
/* ###################################################################################################################################### */
extension NACC_WidgetAttributes {
    /* ################################################################## */
    /**
     */
    fileprivate static var preview: NACC_WidgetAttributes {
        NACC_WidgetAttributes(name: "World")
    }
}

/* ###################################################################################################################################### */
// MARK:
/* ###################################################################################################################################### */
extension NACC_WidgetAttributes.ContentState {
    /* ################################################################## */
    /**
     */
    fileprivate static var smiley: NACC_WidgetAttributes.ContentState {
        NACC_WidgetAttributes.ContentState(emoji: "😀")
     }
     
    /* ################################################################## */
    /**
     */
     fileprivate static var starEyes: NACC_WidgetAttributes.ContentState {
         NACC_WidgetAttributes.ContentState(emoji: "🤩")
     }
}

/* ###################################################################################################################################### */
// MARK:
/* ###################################################################################################################################### */
#Preview("Notification", as: .content, using: NACC_WidgetAttributes.preview) {
   NACC_WidgetLiveActivity()
} contentStates: {
    NACC_WidgetAttributes.ContentState.smiley
    NACC_WidgetAttributes.ContentState.starEyes
}
