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
        if .systemSmall == family {
            if let newGeneratedImage = entry.singleMedallion ?? entry.singleKeytag {
                Image(uiImage: newGeneratedImage)
            } else {
                Text(entry.text)
                    .minimumScaleFactor(0.5)
            }
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
    static let kind: String = "NACCWidget"

    /* ################################################################## */
    /**
     */
    let kind: String = Self.kind

    /* ################################################################## */
    /**
     */
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: NACCWidgetIntent.self, provider: NACC_Provider()) { entry in
            if #available(iOS 17.0, *) {
                NACCWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                NACCWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("SLUG-WIDGET-NAME".localizedVariant)
        .description("SLUG-WIDGET-DESCRIPTION".localizedVariant)
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

/* ###################################################################################################################################### */
// MARK: - Widget Data Provider -
/* ###################################################################################################################################### */
/**
 */
struct NACCWidgetIntent: WidgetConfigurationIntent {
    /* ################################################################## */
    /**
     */
    static var title = LocalizedStringResource("SLUG-INTENT-NAME", table: "WidgetStrings")
    
    /* ################################################################## */
    /**
     */
    static var description = IntentDescription(LocalizedStringResource("SLUG-INTENT-DESC", table: "WidgetStrings"))
    
    /* ################################################################## */
    /**
     */
    @Parameter(title: LocalizedStringResource("SLUG-ONLY-SHOW-TEXT", table: "WidgetStrings"))
    var onlyText: Bool?

    /* ################################################################## */
    /**
     */
    @Parameter(title: LocalizedStringResource("SLUG-ONLY-SHOW-KEYTAGS", table: "WidgetStrings"))
    var forceKeytag: Bool?

    /* ################################################################## */
    /**
     */
    init(forceKeytag inForceKeytag: Bool, onlyText inOnlyText: Bool) {
        forceKeytag = inForceKeytag
        onlyText = inOnlyText
    }
    
    /* ################################################################## */
    /**
     */
    init() {
        forceKeytag = false
        onlyText = false
    }
}

/* ###################################################################################################################################### */
// MARK: - Widget Data Provider -
/* ###################################################################################################################################### */
/**
 */
struct NACC_Provider: AppIntentTimelineProvider {
    /* ################################################################## */
    /**
     */
    typealias Entry = NACC_Entry
    
    /* ################################################################## */
    /**
     */
    typealias Intent = NACCWidgetIntent

    /* ################################################################## */
    /**
     */
    func placeholder(in context: Context) -> NACC_Entry {
        NACC_Entry()
    }
    
    /* ################################################################## */
    /**
     */
    func snapshot(for configuration: NACCWidgetIntent, in context: Context) async -> NACC_Entry { NACC_Entry() }
    
    /* ################################################################## */
    /**
     */
    func timeline(for inConfiguration: NACCWidgetIntent, in inContext: Context) async -> Timeline<NACC_Entry> {
        NACCPersistentPrefs().userDefaults?.synchronize( )
        var entry = NACC_Entry(cleanDate: NACCPersistentPrefs().cleanDate, forceKeytag: inConfiguration.forceKeytag ?? false, onlyText: inConfiguration.onlyText ?? false)
        DispatchQueue.main.sync { entry.synchronize() }
        return Timeline(entries: [entry], policy: .atEnd)
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
    var cleanDate: Date
    
    /* ################################################################## */
    /**
     */
    var forceKeytag: Bool

    /* ################################################################## */
    /**
     */
    var onlyText: Bool

    /* ################################################################## */
    /**
     */
    var text: String = ""
    
    /* ################################################################## */
    /**
     */
    var singleKeytag: UIImage?
    
    /* ################################################################## */
    /**
     */
    var singleMedallion: UIImage?
    
    /* ################################################################## */
    /**
     */
    mutating func synchronize() {
        let calculator = LGV_CleantimeDateCalc(startDate: cleanDate).cleanTime
        
        if let textTemp = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: cleanDate, endDate: .now) {
            text = textTemp
        } else {
            text = "ERROR"
        }
        
        singleKeytag = nil
        singleMedallion = nil
        
        guard !onlyText else { return }
        
        if 0 < calculator.years,
           !forceKeytag {
            let medallionView = LGV_UISingleCleantimeMedallionImageView()
            medallionView.totalDays = calculator.totalDays
            medallionView.totalMonths = calculator.totalMonths
            
            singleMedallion = medallionView.generatedImage?.resized(toMaximumSize: Self._imageSizeInDisplayUnits)
        } else {
            let keyTagImage = LGV_UISingleCleantimeKeytagImageView()
            keyTagImage.totalDays = calculator.totalDays
            keyTagImage.totalMonths = calculator.totalMonths

            singleKeytag = keyTagImage.generatedImage?.resized(toMaximumSize: Self._imageSizeInDisplayUnits)
        }
    }

    /* ################################################################## */
    /**
     */
    init(date inDate: Date = .now, cleanDate inCleandate: Date = .now, forceKeytag inForceKeytag: Bool = true, onlyText inOnlyText: Bool = false) {
        date = inDate
        cleanDate = inCleandate
        forceKeytag = inForceKeytag
        onlyText = inOnlyText
    }
}
