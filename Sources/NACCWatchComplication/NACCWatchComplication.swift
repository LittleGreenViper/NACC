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

import WidgetKit
import SwiftUI
import RVS_UIKit_Toolbox
import LGV_UICleantime
import LGV_Cleantime
import RVS_PersistentPrefs

/* ###################################################################################################################################### */
// MARK: - Timeline Provider -
/* ###################################################################################################################################### */
/**
 The Timeline Provider for the Complication
 */
struct NACCWatchComplicationProvider: TimelineProvider {
    /* ################################################################## */
    /**
     This returns a simple placeholder.
     */
    func placeholder(in context: Context) -> NACCWatchComplicationEntry {
        NACCWatchComplicationEntry(date: .now)
    }

    /* ################################################################## */
    /**
     This sends a "live" snapshot to the completion.
     */
    func getSnapshot(in context: Context, completion: @escaping (NACCWatchComplicationEntry) -> Void) {
        completion(NACCWatchComplicationEntry(date: .now))
    }

    /* ################################################################## */
    /**
     This returns a full timeline entry. We make sure to flush the prefs before returning.
     */
    func getTimeline(in context: Context, completion: @escaping (Timeline<NACCWatchComplicationEntry>) -> Void) {
        NACCPersistentPrefs().flush()
        completion(Timeline(entries: [NACCWatchComplicationEntry(date: .now)], policy: .atEnd))
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
     Uses the current colored logo on full-color faces and a template on tinted faces.
     Rendering follows the environment directly so gallery snapshots use the right artwork.
     */
    func image(for inRenderingMode: WidgetRenderingMode) -> UIImage {
        UIImage(named: .fullColor == inRenderingMode ? "BrandLogo" : "VectorLogo") ?? UIImage()
    }

    /* ################################################################## */
    /**
     The text to be displayed (based upon the family)
     */
    func text(for inFamily: WidgetFamily) -> String {
        switch inFamily {
        case .accessoryRectangular, .accessoryInline:
            if let textTemp = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: NACCPersistentPrefs().cleanDate, endDate: .now, short: true) {
                return textTemp
            }
            return ""

        default:
            let totalDays = LGV_CleantimeDateCalc(startDate: NACCPersistentPrefs().cleanDate).cleanTime.totalDays
            if 0 < totalDays {
                return 1 == totalDays ? "SLUG-COMPLICATION-CLEANTIME-DAY".localizedVariant : String(format: "SLUG-COMPLICATION-CLEANTIME-DAYS".localizedVariant, totalDays)
            }
            return ""
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
     The rendering mode for the complication.
     */
    @Environment(\.widgetRenderingMode) private var _renderingMode

    /* ################################################################## */
    /**
     The timeline entry to be displayed by this view.
     */
    let entry: NACCWatchComplicationProvider.Entry

    /* ################################################################## */
    /**
     We deliver different views, depending on the family.
     */
    var body: some View {
        GeometryReader { inGeom in
            let text = self.entry.text(for: self._family)
            if .accessoryCorner == self._family || .accessoryCircular == self._family {
                self._logo(height: inGeom.size.height)
                    .widgetLabel(text)
            } else if .accessoryInline == self._family {
                if !text.isEmpty { Text(text) }
            } else {
                HStack(alignment: .top) {
                    self._logo(height: inGeom.size.height)
                    if !text.isEmpty { Text(text) }
                }
            }
        }
        .fontDesign(.default)
        .tint(.accentColor)
        .containerBackground(Color("WidgetBackground"), for: .widget)
    }

    /* ################################################################## */
    /**
     Lets the Watch face tint template artwork while preserving the full-color logo.
     */
    private func _logo(height inHeight: CGFloat) -> some View {
        Image(uiImage: self.entry.image(for: self._renderingMode).resized(toNewHeight: inHeight) ?? UIImage())
            .renderingMode(.fullColor == self._renderingMode ? .original : .template)
            .foregroundStyle(.tint)
            .widgetAccentable()
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
