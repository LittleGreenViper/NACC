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
// MARK: - Widget Bundle Entrypoint -
/* ###################################################################################################################################### */
/**
 This file implements a user-configurable widget that displays the cleantime set in the main app.
 
 The display can be just the textual cleantime report, the highest keytag collected, or keytags (before 1 year), and medallions (after one year).
 
 It can also combine the text with the keytag, by displaying the `systemMedium` family variant. If we display the `systemSmall` variant, then it can only be one of the above choices.
 
 The widget dynamically adjusts to whatever cleantime is set in the main app, and updates in realtime.
 
 The widget will, by default, display against a yellow gradient (the same one in the app icon), but that can be switched off, in the widget configuration, to use the standard color theme.
 */
@main
struct NACCWidgetBundle: WidgetBundle {
    /* ################################################################## */
    /**
     We just make a widget instance for the body.
     */
    var body: some Widget { NACCWidget() }
}

/* ###################################################################################################################################### */
// MARK: - Widget Structure -
/* ###################################################################################################################################### */
/**
 This builds the view for the displayed widget. It reads the configuration, and generates a view that will be crafted to match the configuration.
 */
struct NACCWidget: Widget {
    /* ################################################################## */
    /**
     This is our "kind" tag.
     */
    static let kind: String = "NACCWidget"

    /* ################################################################## */
    /**
     The configuration is actually a container, with the generated view in it.
     */
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: NACCWidgetIntent.self, provider: NACC_IntentProvider()) { entry in
            NACCWidgetEntryView(entry: entry)
                // The background is built, according to the settings in the intent.
                .containerBackground(for: .widget) {
                    if !entry.dontShowBackground,
                       !entry.yellowTag {
                        Image("BackgroundGradient")
                            .resizable(resizingMode: .stretch)
                    } else {
                        Rectangle()
                            .containerBackground(.fill.tertiary, for: .widget)
                            .contentShape(Rectangle())
                    }
                }
        }
        .configurationDisplayName("SLUG-WIDGET-NAME".localizedVariant)
        .description("SLUG-WIDGET-DESCRIPTION".localizedVariant)
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

/* ###################################################################################################################################### */
// MARK: - Widget Intents Data Provider -
/* ###################################################################################################################################### */
/**
 This describes the intent, used to build and read the "Edit Widget" screen.
 */
struct NACC_IntentProvider: AppIntentTimelineProvider {
    /* ################################################################## */
    /**
     This is the entry instance for this provider.
     */
    typealias Entry = NACC_Entry
    
    /* ################################################################## */
    /**
     This is the intent that controls the settings scren.
     */
    typealias Intent = NACCWidgetIntent

    /* ################################################################## */
    /**
     This is a simple placeholder view.
     */
    func placeholder(in context: Context) -> NACC_Entry { NACC_Entry() }

    /* ################################################################## */
    /**
     This is a somewhat more involved view. We use "live data" to build it.
     */
    func snapshot(for inConfiguration: NACCWidgetIntent, in: Context) async -> NACC_Entry {
        var entry = NACC_Entry(cleanDate: NACCPersistentPrefs().cleanDate,
                               forceKeytag: inConfiguration.forceKeytag ?? false,
                               onlyText: inConfiguration.onlyText ?? false,
                               dontShowBackground: inConfiguration.dontShowYellowBackground ?? false
        )
        
        entry.synchronize()
        return entry
    }
    
    /* ################################################################## */
    /**
     This is the final rendereing view. We make sure to flush the shared prefs cache, before creating.
     */
    func timeline(for inConfiguration: NACCWidgetIntent, in: Context) async -> Timeline<NACC_Entry> {
        NACCPersistentPrefs().flush()
        var entry = NACC_Entry(cleanDate: NACCPersistentPrefs().cleanDate,
                               forceKeytag: inConfiguration.forceKeytag ?? false,
                               onlyText: inConfiguration.onlyText ?? false,
                               dontShowBackground: inConfiguration.dontShowYellowBackground ?? false
        )
        entry.synchronize()
        return Timeline(entries: [entry], policy: .atEnd)
    }
}

/* ###################################################################################################################################### */
// MARK: - Widget View For One Entry -
/* ###################################################################################################################################### */
/**
 This is the display for a single widget entry.
 */
struct NACCWidgetEntryView: View {
    /* ################################################################## */
    /**
     This is the entry instance that determines the widget display.
     */
    var entry: NACC_IntentProvider.Entry

    /* ################################################################## */
    /**
     This is the display family variant for this entry panel.
     */
    @Environment(\.widgetFamily) private var _family

    /* ################################################################## */
    /**
     This is used to set the dynamic light mode/dark mode screen, if we are not displaying our yellow background.
     */
    @Environment(\.colorScheme) private var _colorScheme

    /* ################################################################## */
    /**
     If the family variant is `systemSmall`, then we display one thing: either the text report, or a keytag/medallion.
     
     If the family variant is `systemMedium`, then we display the text report on the left, and the keytag or medallion on the right.
     
     It is also possible to only display text, in `systemMedium`.
     */
    var body: some View {
        let labelColor = (self.entry.dontShowBackground || self.entry.yellowTag) ? Color(UIColor.label.inverted) : .black
        if .systemSmall == self._family {
            if let newGeneratedImage = self.entry.singleMedallion ?? self.entry.singleKeytag {
                Image(uiImage: newGeneratedImage)
            } else {
                Text(self.entry.text)
                    .foregroundStyle(labelColor)
                    .minimumScaleFactor(0.5)
            }
        } else {
            HStack {
                Text(self.entry.text)
                    .foregroundStyle(labelColor)
                    .minimumScaleFactor(0.5)
                
                if let newGeneratedImage = self.entry.singleMedallion ?? self.entry.singleKeytag {
                    Image(uiImage: newGeneratedImage)
                }
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Widget Intent Configuration -
/* ###################################################################################################################################### */
/**
 This controls the intent for the settings screen.
 */
struct NACCWidgetIntent: WidgetConfigurationIntent {
    /* ################################################################## */
    /**
     The title of the widget, displayed over the settings screen.
     */
    static var title = LocalizedStringResource("SLUG-INTENT-NAME", table: "WidgetStrings")
    
    /* ################################################################## */
    /**
     The subheading, displayed under the title, in the settings screen.
     */
    static var description = IntentDescription(LocalizedStringResource("SLUG-INTENT-DESC", table: "WidgetStrings"))
    
    /* ################################################################## */
    /**
     A simple switch. If on (default is off), then no image is shown; only the text report. This applies to both family variants.
     */
    @Parameter(title: LocalizedStringResource("SLUG-ONLY-SHOW-TEXT", table: "WidgetStrings"))
    var onlyText: Bool?

    /* ################################################################## */
    /**
     A simple switch. If on (default is off), then medallions will not be displayed, for cleantime over a year. Ignored, if `onlyText` is true.
     */
    @Parameter(title: LocalizedStringResource("SLUG-ONLY-SHOW-KEYTAGS", table: "WidgetStrings"))
    var forceKeytag: Bool?

    /* ################################################################## */
    /**
     A simple switch. If on (default is off), then the yellow background gradient will not be shown.
     */
    @Parameter(title: LocalizedStringResource("SLUG-YELLOW-BACKGROUND", table: "WidgetStrings"))
    var dontShowYellowBackground: Bool?
    
    /* ################################################################## */
    /**
     Parameterized initializer.
     
     - parameter inForceKeytag: If true, then medallions will not be displayed.
     - parameter inOnlyText: If true, then no image is shown; only the text report.
     - parameter inDontShowYellowBackground: If true, then the yellow gradient background will NOT be shown.
     */
    init(forceKeytag inForceKeytag: Bool,
         onlyText inOnlyText: Bool,
         dontShowYellowBackground inDontShowYellowBackground: Bool
    ) {
        self.forceKeytag = inForceKeytag
        self.onlyText = inOnlyText
        self.dontShowYellowBackground = inDontShowYellowBackground
    }
    
    /* ################################################################## */
    /**
     Default initializer.
     */
    init() {
        self.forceKeytag = false
        self.onlyText = false
        self.dontShowYellowBackground = false
    }
}

/* ###################################################################################################################################### */
// MARK: - Widget Timeline Entry -
/* ###################################################################################################################################### */
/**
 This is one data entry for the widget. There will only be one, and it should reflect the current state.
 */
struct NACC_Entry: TimelineEntry {
    /* ################################################################## */
    /**
     This is how big we want our images to be, in display units.
     */
    static private let _imageSizeInDisplayUnits = CGFloat(128)
    
    /* ################################################################## */
    /**
     The entry date (used to determine whether or not to display). This is always set to `Date.now`
     */
    var date: Date
    
    /* ################################################################## */
    /**
     The cleandate. This should reflect the date selected in the main app, and is used to determine the display.
     */
    var cleanDate: Date
    
    /* ################################################################## */
    /**
     If true, then we should not display medallions. Ignored, if `onlyText` is true.
     */
    var forceKeytag: Bool

    /* ################################################################## */
    /**
     If true, then no image should be shown; only the text report.
     */
    var onlyText: Bool

    /* ################################################################## */
    /**
     The text report.
     */
    var text: String = ""

    /* ################################################################## */
    /**
     If true, then the keytag is yellow, and the gradient is not shown.
     */
    var yellowTag = false

    /* ################################################################## */
    /**
     If true, the gradient is not shown (regardless of the selected tag).
     */
    var dontShowBackground = false

    /* ################################################################## */
    /**
     The image that represents a keytag. May be nil. Mutually exclusive with `singleMedallion`.
     */
    var singleKeytag: UIImage?
    
    /* ################################################################## */
    /**
     The image that represents a medallion. May be nil. Mutually exclusive with `singleKeytag`.
     */
    var singleMedallion: UIImage?
    
    /* ################################################################## */
    /**
     This renders the images and text.
     
     This should be called on the main thread.
     */
    mutating func synchronize() {
        let calculator = LGV_CleantimeDateCalc(startDate: cleanDate).cleanTime
        
        if let textTemp = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: cleanDate, endDate: .now) {
            self.text = textTemp
        } else {
            self.text = "ERROR"
        }
        
        self.singleKeytag = nil
        self.singleMedallion = nil
        
        guard !self.onlyText else { return }
        DispatchQueue.main.sync {
            if 0 < calculator.years,
               !self.forceKeytag {
                let medallionView = LGV_UISingleCleantimeMedallionImageView()
                medallionView.totalDays = calculator.totalDays
                medallionView.totalMonths = calculator.totalMonths
                
                self.singleMedallion = medallionView.generatedImage?.resized(toMaximumSize: Self._imageSizeInDisplayUnits)
            } else {
                let keyTagImage = LGV_UISingleCleantimeKeytagImageView()
                keyTagImage.totalDays = calculator.totalDays
                keyTagImage.totalMonths = calculator.totalMonths
                self.yellowTag = self.dontShowBackground || (9..<12).contains(calculator.totalMonths) || (45..<50).contains(calculator.years)
                self.singleKeytag = keyTagImage.generatedImage?.resized(toMaximumSize: Self._imageSizeInDisplayUnits)
            }
        }
    }

    /* ################################################################## */
    /**
     Default initializer
     
     - parameter inDate: The entry date (used to determine whether or not to display). This is always set to `Date.now`
     - parameter inCleandate: The cleandate. This should reflect the date selected in the main app, and is used to determine the display.
     - parameter inForceKeytag: If true, then medallions will not be displayed.
     - parameter inOnlyText: If true, then no image is shown; only the text report.
     - parameter inDontShowBackground: If true, then the yellow gradient background will NOT be shown.

     */
    init(date inDate: Date = .now,
         cleanDate inCleandate: Date = .now.addingTimeInterval(-86400), // Give them a day
         forceKeytag inForceKeytag: Bool = true,
         onlyText inOnlyText: Bool = false,
         dontShowBackground inDontShowBackground: Bool = true
    ) {
        self.date = inDate
        self.cleanDate = inCleandate
        self.forceKeytag = inForceKeytag
        self.onlyText = inOnlyText
        self.dontShowBackground = inDontShowBackground
    }
}
