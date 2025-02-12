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
        NACCWatchComplicationEntry(date: Date(), value: "Placeholder")
    }

    /* ################################################################## */
    /**
     */
    func getSnapshot(in context: Context, completion: @escaping (NACCWatchComplicationEntry) -> Void) {
        let entry = NACCWatchComplicationEntry(date: Date(), value: "Now")
        completion(entry)
    }

    /* ################################################################## */
    /**
     */
    func getTimeline(in context: Context, completion: @escaping (Timeline<NACCWatchComplicationEntry>) -> Void) {
        let entries = (0..<5).map { offset in
            NACCWatchComplicationEntry(date: Calendar.current.date(byAdding: .minute, value: offset * 15, to: Date())!,
                              value: "\(offset * 15) min")
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

/* ###################################################################################################################################### */
// MARK: - A Single Complication Entry -
/* ###################################################################################################################################### */
/**
 */
struct NACCWatchComplicationEntry: TimelineEntry {
    /* ################################################################## */
    /**
     */
    let date: Date
    
    /* ################################################################## */
    /**
     */
    let value: String
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
    var entry: NACCWatchComplicationProvider.Entry

    /* ################################################################## */
    /**
     */
    var body: some View {
        GeometryReader { inGeom in
            HStack {
                switch _family {
                case .systemSmall:
                    Image(uiImage: UIImage(named: "LogoMask")?.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                    Text("Small")
                case .systemMedium:
                    Image(uiImage: UIImage(named: "LogoMask")?.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                    Text("Med")
                case .systemLarge:
                    Image(uiImage: UIImage(named: "LogoMask")?.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                    Text("Large")
                case .systemExtraLarge:
                    Image(uiImage: UIImage(named: "VectorLogo")?.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                    Text("Extra Large")
                case .accessoryCorner:
                    Image(uiImage: UIImage(named: "LogoMask")?.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                    Text("Acc Corner")
                case .accessoryCircular:
                    Image(uiImage: UIImage(named: "LogoMask")?.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                    Text("Acc Circular")
                case .accessoryRectangular:
                    Image(uiImage: UIImage(named: "VectorLogo")?.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                    Text("Rectangular")
                case .accessoryInline:
                    Image(uiImage: UIImage(named: "LogoMask")?.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                    Text("Inline")

                default:
                    Image(uiImage: UIImage(named: "LogoMask")?.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                }
            }
        }
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
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
        .configurationDisplayName("NACC")
        .description("Calculate Your Cleantime!")
    }
}
