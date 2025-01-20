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
import RVS_UIKit_Toolbox
import WidgetKit
import AppIntents
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
    static private let _imageSizeInDisplayUnits = CGFloat(128)
    
    /* ################################################################## */
    /**
     */
    var date: Date
    
    /* ################################################################## */
    /**
     */
    let cleandate: Date
    
    /* ################################################################## */
    /**
     */
    let text: String
    
    /* ################################################################## */
    /**
     */
    let singleKeytag: UIImage?
    
    /* ################################################################## */
    /**
     */
    let singleMedallion: UIImage?

    /* ################################################################## */
    /**
     */
    init(date inDate: Date, cleandate inCleandate: Date) {
        date = inDate
        cleandate = inCleandate
        
        let calculator = LGV_CleantimeDateCalc(startDate: inCleandate).cleanTime
        
        if let textTemp = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: inCleandate, endDate: .now) {
            text = textTemp
        } else {
            text = "ERROR"
        }
        
        if 0 < calculator.years {
            let medallionView = LGV_UISingleCleantimeMedallionImageView()
            medallionView.totalDays = calculator.totalDays
            medallionView.totalMonths = calculator.totalMonths
            
            singleMedallion = medallionView.generatedImage?.resized(toMaximumSize: Self._imageSizeInDisplayUnits)
            singleKeytag = nil
        } else {
            let keyTagImage = LGV_UISingleCleantimeKeytagImageView()
            keyTagImage.totalDays = calculator.totalDays
            keyTagImage.totalMonths = calculator.totalMonths

            singleKeytag = keyTagImage.generatedImage?.resized(toMaximumSize: Self._imageSizeInDisplayUnits)
            singleMedallion = nil
        }
    }
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
    @Environment(\.widgetFamily) var family

    /* ################################################################## */
    /**
     */
    var body: some View {
        if .systemSmall == family,
           let newGeneratedImage = entry.singleMedallion ?? entry.singleKeytag {
            Image(uiImage: newGeneratedImage)
        } else {
            HStack {
                Text(entry.text)
                    .minimumScaleFactor(0.5)
                
                if let newGeneratedImage = entry.singleMedallion ?? entry.singleKeytag {
                    Image(uiImage: newGeneratedImage)
                }
            }
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
        .description("Calculate your cleantime!")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
