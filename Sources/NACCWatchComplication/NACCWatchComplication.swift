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
// MARK: - Timeline Provider -
/* ###################################################################################################################################### */
/**
 The Timeline Provider for the Complication
 */
struct NACCWatchComplicationProvider: TimelineProvider {
    /* ################################################################## */
    /**
     This is the display family variant for this complication.
     */
    @Environment(\.widgetFamily) private var _family
    
    /* ################################################################## */
    /**
     This returns a simple placeholder.
     */
    func placeholder(in context: Context) -> NACCWatchComplicationEntry {
        NACCWatchComplicationEntry(date: .now, family: self._family)
    }

    /* ################################################################## */
    /**
     This sends a "live" snapshot to the completion.
     */
    func getSnapshot(in context: Context, completion: @escaping (NACCWatchComplicationEntry) -> Void) {
        completion(NACCWatchComplicationEntry(date: .now, family: self._family))
    }

    /* ################################################################## */
    /**
     This returns a full timeline entry. We make sure to flush the prefs before returning.
     */
    func getTimeline(in context: Context, completion: @escaping (Timeline<NACCWatchComplicationEntry>) -> Void) {
        NACCPersistentPrefs().flush()
        completion(Timeline(entries: [NACCWatchComplicationEntry(date: .now, family: self._family)], policy: .atEnd))
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
        case .accessoryRectangular, .accessoryInline:
            if let textTemp = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: NACCPersistentPrefs().cleanDate, endDate: .now, short: true) {
                return textTemp
            }
            return "ERROR"

        default:
            let totalDays = LGV_CleantimeDateCalc(startDate: NACCPersistentPrefs().cleanDate).cleanTime.totalDays
            if 0 < totalDays {
                return 1 == totalDays ? "SLUG-PREFIX-CLEANTIME-DAY".localizedVariant : String(format: "SLUG-PREFIX-CLEANTIME-DAYS".localizedVariant, totalDays)
            }
            return "ERROR"
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Individual Entry Display -
/* ###################################################################################################################################### */
/**
 The View, Displaying the Complication
 */
struct NACCWatchComplicationEntryView: View {
    /* ################################################################## */
    /**
     This is the display family variant for this complication.
     */
    @Environment(\.widgetFamily) private var _family

    /* ################################################################## */
    /**
     The timeline entry to be displayed by this view.
     */
    @State var entry: NACCWatchComplicationProvider.Entry

    /* ################################################################## */
    /**
     We deliver different views, depending on the family.
     */
    var body: some View {
        GeometryReader { inGeom in
            if .accessoryCorner == self._family || .accessoryCircular == self._family {
                Image(uiImage: self.entry.image.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                    .widgetLabel(self.entry.text)
                    .onAppear { self.entry.family = self._family }
            } else if .accessoryInline == self._family,
                      !entry.text.isEmpty {
                Text(entry.text)
                    .onAppear { self.entry.family = self._family }
            } else {
                HStack(alignment: .top) {
                    Image(uiImage: self.entry.image.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                    if !self.entry.text.isEmpty {
                        Text(self.entry.text)
                    }
                }
                .onAppear { self.entry.family = self._family }
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Main Widget -
/* ###################################################################################################################################### */
/**
 The Complication Display Widget
 */
@main
struct NACCWatchComplication: Widget {
    /* ################################################################## */
    /**
     The complication widget kind tag.
     */
    let kind: String = "NACCWatchComplication"

    /* ################################################################## */
    /**
     Tracks scene activity.
     */
    @Environment(\.scenePhase) private var _scenePhase

    /* ################################################################## */
    /**
     This returns a view for the complication.
     */
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NACCWatchComplicationProvider()) { inEntry in
            NACCWatchComplicationEntryView(entry: inEntry)
        }
        .configurationDisplayName("NACC")
        .description("SLUG-WIDGET-SUBTITLE".localizedVariant)
        .supportedFamilies([.accessoryInline,
                            .accessoryCircular,
                            .accessoryRectangular,
                            .accessoryCorner
        ])
    }
}
