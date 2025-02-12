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

import WidgetKit
import SwiftUI
import RVS_UIKit_Toolbox
import LGV_UICleantime
import LGV_Cleantime
import RVS_Persistent_Prefs

/* ###################################################################################################################################### */
// MARK: - The Timeline Provider for the Complication -
/* ###################################################################################################################################### */
/**
 */
struct NACCWatchComplicationProvider: TimelineProvider {
    /* ################################################################## */
    /**
     This is the display family variant for this complication.
     */
    @Environment(\.widgetFamily) private var _family
    
    /* ################################################################## */
    /**
     */
    func placeholder(in context: Context) -> NACCWatchComplicationEntry {
        NACCWatchComplicationEntry(date: .now, family: _family)
    }

    /* ################################################################## */
    /**
     */
    func getSnapshot(in context: Context, completion: @escaping (NACCWatchComplicationEntry) -> Void) {
        let entry = NACCWatchComplicationEntry(date: .now, family: _family)
        completion(entry)
    }

    /* ################################################################## */
    /**
     */
    func getTimeline(in context: Context, completion: @escaping (Timeline<NACCWatchComplicationEntry>) -> Void) {
        completion(Timeline(entries: [NACCWatchComplicationEntry(date: .now, family: _family)], policy: .atEnd))
    }
}

/* ###################################################################################################################################### */
// MARK: - A Single Complication Entry -
/* ###################################################################################################################################### */
/**
 A single entry for the timeline.
 */
struct NACCWatchComplicationEntry: TimelineEntry {
    /* ################################################################## */
    /**
     The entry display date
     */
    let date: Date

    /* ################################################################## */
    /**
     This is the display family variant for this complication.
     */
    var family: WidgetFamily = .accessoryCircular
    
    /* ################################################################## */
    /**
     The image to be displayed (based upon the family)
     */
    var image: UIImage {
        switch family {
        case .accessoryRectangular:
            return UIImage(named: "VectorLogo") ?? UIImage()

        default:
            return UIImage(named: "LogoMask") ?? UIImage()
        }
    }
    
    /* ################################################################## */
    /**
     The text to be displayed (based upon the family)
     */
    var text: String {
        switch family {
        case .accessoryCorner:
            let totalDays = LGV_CleantimeDateCalc(startDate: NACCPersistentPrefs().cleanDate).cleanTime.totalDays
            if 0 < totalDays {
                return 1 == totalDays ? "SLUG-PREFIX-CLEANTIME-DAY".localizedVariant : String(format: "SLUG-PREFIX-CLEANTIME-DAYS".localizedVariant, totalDays)
            }
            return "ERROR"

        case .accessoryRectangular:
            if let textTemp = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: NACCPersistentPrefs().cleanDate, endDate: .now, short: true) {
                return textTemp
            }
            return "ERROR"

        default:
            return ""
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - The View, Displaying the Complication -
/* ###################################################################################################################################### */
/**
 */
struct NACCWatchComplicationEntryView: View {
    /* ################################################################## */
    /**
     This is the display family variant for this complication.
     */
    @Environment(\.widgetFamily) private var _family
    
    /* ################################################################## */
    /**
     */
    @State private var _cleantimeReprtText: String = ""

    /* ################################################################## */
    /**
     */
    @State var entry: NACCWatchComplicationProvider.Entry

    /* ################################################################## */
    /**
     */
    var body: some View {
        GeometryReader { inGeom in
            HStack {
                if .accessoryCorner == _family {
                    Image(uiImage: entry.image.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                        .widgetLabel(entry.text)
                } else {
                    Image(uiImage: entry.image.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                    if !entry.text.isEmpty {
                        Text(entry.text).font(.caption)
                    }
                }
            }
            .onAppear { entry.family = _family }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func setCleantimeReport() {
        
    }
}

/* ###################################################################################################################################### */
// MARK: - The Complication Display Widget -
/* ###################################################################################################################################### */
/**
 */
@main
struct NACCWatchComplication: Widget {
    /* ################################################################## */
    /**
     */
    let kind: String = "NACCWatchComplication"

    /* ################################################################## */
    /**
     */
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NACCWatchComplicationProvider()) { inEntry in
            NACCWatchComplicationEntryView(entry: inEntry)
        }
        .supportedFamilies([.accessoryCircular,
                            .accessoryRectangular,
                            .accessoryInline,
                            .accessoryCorner
        ])
        .configurationDisplayName("NACC")
        .description("Calculate Your Cleantime!")
    }
}
