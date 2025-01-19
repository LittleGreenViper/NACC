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

import LGV_UICleantime
import LGV_Cleantime
import RVS_Persistent_Prefs
import WidgetKit
import SwiftUI

/* ###################################################################################################################################### */
// MARK: - Widget Data Provider -
/* ###################################################################################################################################### */
/**
 */
struct NACC_Provider: TimelineProvider {
    /* ################################################################## */
    /**
     */
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<NACC_Entry>) -> Void) {
        let timeline = Timeline(entries: [NACC_Entry(date: .now, cleandate: NACCPersistentPrefs().cleanDate)],
                                policy: .atEnd
        )
        completion(timeline)
    }
    
    /* ################################################################## */
    /**
     */
    func placeholder(in context: Context) -> NACC_Entry {
        .init(date: .now, cleandate: NACCPersistentPrefs().cleanDate)
    }
    
    /* ################################################################## */
    /**
     */
    func getSnapshot(in context: Context, completion: @escaping (NACC_Entry) -> ()) {
        completion(NACC_Entry(date: .now, cleandate: NACCPersistentPrefs().cleanDate))
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

/* ###################################################################################################################################### */
// MARK: - Widget Timeline Entry -
/* ###################################################################################################################################### */
/**
 */
struct NACC_Entry: TimelineEntry {
    /* ################################################################## */
    /**
     */
    var date: Date
    
    /* ################################################################## */
    /**
     */
    let cleandate: Date
}

/* ###################################################################################################################################### */
// MARK: - Widget View For One Entry -
/* ###################################################################################################################################### */
/**
 */
struct NACCWidgetEntryView : View {
    /* ################################################################## */
    /**
     */
    var entry: NACC_Provider.Entry

    /* ################################################################## */
    /**
     */
    var body: some View {
        VStack {
            Text("Date:")
            Text(entry.date, style: .date)

            Text("Cleandate:")
            Text(entry.cleandate, style: .date)
        }
    }
}


/* ###################################################################################################################################### */
// MARK: - Widget Structure -
/* ###################################################################################################################################### */
/**
 */
struct NACCWidget: Widget {
    /* ################################################################## */
    /**
     */
    let kind: String = "NACCWidget"

    /* ################################################################## */
    /**
     */
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NACC_Provider()) { entry in
            if #available(iOS 17.0, *) {
                NACCWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                NACCWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("NACC Widget")
        .description("This is an example widget.")
    }
}
