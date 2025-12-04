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

import SwiftUI
import LGV_Cleantime

/* ###################################################################################################################################### */
// MARK: - Background Container View -
/* ###################################################################################################################################### */
/**
 This is a general-purpose View that displays the background gradient, under the contained View.
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
     This simply adds a gradient background to the contained View.
     */
    var body: some View {
        content()
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: self.alignment
            )
            .background(
                Image("Background-Gradient")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
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
     Scene phase, so we know when the app becomes active.
     */
    @Environment(\.scenePhase) private var scenePhase

    /* ################################################################## */
    /**
     The tab to be shown.
     */
    @State private var _selectedTab = TabIndexes.undefined

    /* ################################################################## */
    /**
     This contains the cleandate.
     */
    @State private var _selectedDate = Date()
    
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
        if var dateString = inURL.query() {
            var selectedTab = TabIndexes.undefined
            let splitter = dateString.split(separator: "/")
            guard !splitter.isEmpty else { return }
            dateString = String(splitter[0])
            if 1 < splitter.count,
               let tabInt = Int(splitter[1]),
               var tab = TabIndexes(rawValue: tabInt) {
                // We don't have a medallion array, if we are less than a year.
                if !LGV_CleantimeDateCalc(startDate: NACCPersistentPrefs().cleanDate).cleanTime.isOneYearOrMore,
                   .medallionArray == tab {
                    tab = .keytagArray
                }
                // We don't show the results screen for less than thirty days.
                if !LGV_CleantimeDateCalc(startDate: NACCPersistentPrefs().cleanDate).cleanTime.isThirtyDaysOrMore {
                    tab = .undefined
                }
                selectedTab = tab
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: dateString) {
                NACCPersistentPrefs().cleanDate = date
                NACCPersistentPrefs().lastSelectedTabIndex = selectedTab.rawValue

                DispatchQueue.main.async {
                    self._wasOpenedViaURL = true
                    (self._selectedDate, self._selectedTab, self._showResult) = (date, selectedTab, .undefined != selectedTab)
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is the main application window.
     */
    var body: some Scene {
        WindowGroup {
            NACC_MainContentView(showResult: self.$_showResult,
                                 selectedTab: self.$_selectedTab,
                                 selectedDate: self.$_selectedDate
            )
            // If we are being opened by a Universal or Deep link, we handle that here.
            .onOpenURL { inURL in self.handleOpenWithURL(inURL) }
        }
        .onChange(of: self.scenePhase) { _, newPhase in
            if newPhase == .active {
                // If the change was from being opened by a URL, we say so, and leave the selected tab alone (as it may have been set by the URL).
                if self._wasOpenedViaURL {
                    self._wasOpenedViaURL = false
                } else {    // Otherwise, we make sure to not force open the results screen.
                    self._selectedTab = .undefined
                }
            }
        }
    }
}
