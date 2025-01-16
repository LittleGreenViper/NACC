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

import WidgetKit
import SwiftUI

/* ###################################################################################################################################### */
// MARK:
/* ###################################################################################################################################### */
struct Provider: AppIntentTimelineProvider {
    /* ################################################################## */
    /**
     */
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: NACC_ConfigurationAppIntent())
    }

    /* ################################################################## */
    /**
     */
    func snapshot(for configuration: NACC_ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    /* ################################################################## */
    /**
     */
    func timeline(for configuration: NACC_ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    /* ################################################################## */
    /**
     */
//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

/* ###################################################################################################################################### */
// MARK:
/* ###################################################################################################################################### */
struct SimpleEntry: TimelineEntry {
    /* ################################################################## */
    /**
     */
    let date: Date
    
    /* ################################################################## */
    /**
     */
    let configuration: NACC_ConfigurationAppIntent
}

/* ###################################################################################################################################### */
// MARK:
/* ###################################################################################################################################### */
struct NACC_WidgetEntryView : View {
    /* ################################################################## */
    /**
     */
    var entry: Provider.Entry

    /* ################################################################## */
    /**
     */
    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Favorite Emoji:")
            Text(entry.configuration.favoriteEmoji)
        }
    }
}

/* ###################################################################################################################################### */
// MARK:
/* ###################################################################################################################################### */
struct NACC_Widget: Widget {
    /* ################################################################## */
    /**
     */
    let kind: String = "NACC_Widget"

    /* ################################################################## */
    /**
     */
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: NACC_ConfigurationAppIntent.self, provider: Provider()) { entry in
            NACC_WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

/* ###################################################################################################################################### */
// MARK:
/* ###################################################################################################################################### */
extension NACC_ConfigurationAppIntent {
    /* ################################################################## */
    /**
     */
    fileprivate static var smiley: NACC_ConfigurationAppIntent {
        let intent = NACC_ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    /* ################################################################## */
    /**
     */
    fileprivate static var starEyes: NACC_ConfigurationAppIntent {
        let intent = NACC_ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

/* ###################################################################################################################################### */
// MARK:
/* ###################################################################################################################################### */
#Preview(as: .systemSmall) {
    NACC_Widget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}
