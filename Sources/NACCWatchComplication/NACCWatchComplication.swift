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
     */
    func placeholder(in context: Context) -> NACCWatchComplicationEntry {
        NACCWatchComplicationEntry(date: .now)
    }

    /* ################################################################## */
    /**
     */
    func getSnapshot(in context: Context, completion: @escaping (NACCWatchComplicationEntry) -> Void) {
        let entry = NACCWatchComplicationEntry(date: .now)
        completion(entry)
    }

    /* ################################################################## */
    /**
     */
    func getTimeline(in context: Context, completion: @escaping (Timeline<NACCWatchComplicationEntry>) -> Void) {
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
     This is the display family variant for this complication.
     */
    var family: WidgetFamily = .accessoryCircular
    
    /* ################################################################## */
    /**
     The image to be displayed (based upon the family)
     */
    var image: UIImage {
        switch family {
        case .systemSmall:
            return UIImage(named: "LogoMask") ?? UIImage()
        case .systemMedium:
            return UIImage(named: "LogoMask") ?? UIImage()
        case .systemLarge:
            return UIImage(named: "LogoMask") ?? UIImage()
        case .systemExtraLarge:
            return UIImage(named: "VectorLogo") ?? UIImage()
        case .accessoryCorner:
            return UIImage(named: "LogoMask") ?? UIImage()
        case .accessoryCircular:
            return UIImage(named: "LogoMask") ?? UIImage()
        case .accessoryRectangular:
            return UIImage(named: "VectorLogo") ?? UIImage()
        case .accessoryInline:
            return UIImage(named: "LogoMask") ?? UIImage()

        default:
            return UIImage(named: "LogoMask") ?? UIImage()
        }
    }
    
    /* ################################################################## */
    /**
     The text to be displayed (based upon the family)
     */
    var text: String {
        var shortReport = "ERROR"
        
        if let textTemp = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: NACCPersistentPrefs().cleanDate, endDate: .now, short: true) {
            shortReport = textTemp
        }

        switch family {
        case .accessoryCorner:
            return "Acc Corner"
        case .accessoryCircular:
            return "Acc Circular"
        case .accessoryRectangular:
            return shortReport
        case .accessoryInline:
            return "Inline"

        default:
            return "Default"
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
    @State var _maxHeight: CGFloat = 64
    
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
                Image(uiImage: entry.image.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                Text(entry.text)
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
