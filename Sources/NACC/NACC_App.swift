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

import SwiftUI
import LGV_Cleantime
import WidgetKit
import RVS_PersistentPrefs

/* ###################################################################################################################################### */
// MARK: - Background Container View -
/* ###################################################################################################################################### */
/**
 This is a general-purpose View that displays the shared Recovrr background under the contained View.
 */
struct AppBackground<Content: View>: View {
    /* ################################################################## */
    /**
     We can provide a different alignment. The default is top.
     */
    @State var alignment: Alignment = .top

    /* ################################################################## */
    /**
     The content Viewbuilder.
     */
    @ViewBuilder let content: () -> Content
    
    /* ################################################################## */
    /**
     Applies the shared adaptive background, system typography, and accent color.
     */
    var body: some View {
        content()
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: self.alignment
            )
            .fontDesign(.default)
            .tint(.accentColor)
            .background(Color("BackgroundColor-Main").ignoresSafeArea())
    }
}

/* ###################################################################################################################################### */
// MARK: - Main App -
/* ###################################################################################################################################### */
/**
 The main app wrapper.
 */
@main
struct NACC_App: App {
    /* ################################################################## */
    /**
     This is our "kind" tag.
     */
    static private let _widgetKind: String = "NACCWidget"

    /* ################################################################## */
    /**
     Tracks scene activity.
     */
    @Environment(\.scenePhase) private var _scenePhase

    /* ################################################################## */
    /**
     The tab to be shown.
     */
    @State private var _selectedTab = NACC_TabIndexes.undefined

    /* ################################################################## */
    /**
     This contains the cleandate.
     */
    @State private var _dateSession = NACC_CleandateSession(savedDate: NACCPersistentPrefs().cleanDate)
    
    /* ################################################################## */
    /**
     If true, then the NavigationStack will bring in the results screen.
     */
    @State private var _showResult = false

    /* ################################################################## */
    /**
     Flag indicating that the most recent activation came from a URL.
     */
    @State private var _wasOpenedViaURL = false

    /* ################################################################## */
    /**
     Handles opening the app through a URL or a URL scheme.
     
     - parameter inURL: The URL query string (for both a Universal and a Deep link).
     */
    func handleOpenWithURL(_ inURL: URL) {
        guard let link = NACC_DeepLink(url: inURL) else { return }

        self._dateSession.open(link)
        self._persistSessionDate()

        var selectedTab = link.tabIndex.flatMap(NACC_TabIndexes.init(rawValue:)) ?? .undefined
        let calculator = LGV_CleantimeDateCalc(startDate: link.date).cleanTime
        // Tab availability is based on the incoming date, including temporary dates.
        if !calculator.isOneYearOrMore, .medallionArray == selectedTab {
            selectedTab = .keytagArray
        }
        if !calculator.isThirtyDaysOrMore {
            selectedTab = .undefined
        }

        self._wasOpenedViaURL = true
        (self._selectedTab, self._showResult) = (selectedTab, .undefined != selectedTab)
    }

    /* ################################################################## */
    /**
     Saves only permanent session dates. All date edits go through this one persistence path.
     */
    private func _persistSessionDate() {
        guard let date = self._dateSession.dateToSave else { return }
        self._saveDate(date)
    }

    /* ################################################################## */
    /**
     Stores the user's own date and refreshes widgets.
     */
    private func _saveDate(_ inDate: Date) {
        let prefs = NACCPersistentPrefs()
        prefs.cleanDate = inDate
        prefs.flush()
        WidgetCenter.shared.reloadTimelines(ofKind: Self._widgetKind)
    }

    /* ################################################################## */
    /**
     Watch updates still change the user's saved date, while a temporary report stays on screen.
     */
    private func _receiveSavedDate(_ inDate: Date) {
        self._saveDate(inDate)
        self._dateSession.receiveSavedDate(inDate)
    }
    
    /* ################################################################## */
    /**
     This is the main application window.
     */
    var body: some Scene {
        WindowGroup {
            NACC_MainContentView(showResult: self.$_showResult,
                                 selectedTab: self.$_selectedTab,
                                 selectedDate: Binding(get: { self._dateSession.selectedDate },
                                                       set: {
                                                           self._dateSession.selectDate($0)
                                                           self._persistSessionDate()
                                                       }),
                                 updateSavedDate: self._receiveSavedDate
            )
            .fontDesign(.default)
            .tint(.accentColor)
            // If we are being opened by a Universal or Deep link, we handle that here.
            .onOpenURL { inURL in self.handleOpenWithURL(inURL) }
        }
        // Forces updates, whenever we become active.
        .onChange(of: self._scenePhase, initial: true) {
            if .background == self._scenePhase, self._dateSession.isTemporary {
                self._dateSession.endTemporarySession(savedDate: NACCPersistentPrefs().cleanDate)
                self._showResult = false
                self._selectedTab = .undefined
                self._wasOpenedViaURL = false
            } else if .active == self._scenePhase {
                // If the change was from being opened by a URL, we say so, and leave the selected tab alone (as it may have been set by the URL).
                if self._wasOpenedViaURL {
                    self._wasOpenedViaURL = false
                } else if !self._dateSession.isTemporary {    // Temporary reports survive share/print interruptions.
                    self._selectedTab = .undefined
                }
                let prefs = NACCPersistentPrefs()
                prefs.flush()

                WidgetCenter.shared.reloadTimelines(ofKind: Self._widgetKind)
            }
        }
    }
}
