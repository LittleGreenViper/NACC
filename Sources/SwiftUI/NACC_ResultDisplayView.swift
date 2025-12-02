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
import LGV_UICleantime
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - Tab Index Enum -
/* ###################################################################################################################################### */
/**
 This provides numerical indexes for each of the image display tabs.
 */
enum TabIndexes: Int {
    /* ################################################################## */
    /**
     */
    case keytagArray
    
    /* ################################################################## */
    /**
     */
    case keytagStrip
    
    /* ################################################################## */
    /**
     */
    case medallionArray
}

/* ###################################################################################################################################### */
// MARK: - Result Display View -
/* ###################################################################################################################################### */
/**
 The image results View.
 */
struct NACC_ResultDisplayView: View {
    /* ################################################################## */
    /**
     This is the local instance of the persistent prefs for the app.
     */
    let prefs = NACCPersistentPrefs()
    
    /* ################################################################## */
    /**
     This will have whatever image is being displayed.
     */
    @State private var _displayedImage: UIImage?
    
    /* ################################################################## */
    /**
     The currently selected tab.
     */
    @State private var _selectedTab: TabIndexes = .keytagArray

    /* ################################################################## */
    /**
     */
    var body: some View {
        AppBackground {
            TabView {
                FirstTabView()
                    .tabItem {
                        Label("", image: "KeytagArray")
                    }

                SecondTabView()
                    .tabItem {
                        Label("", image: "SingleKeytag")
                    }

                ThirdTabView()
                    .tabItem {
                        Label("", systemImage: "circle.fill")
                    }
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: -  -
/* ###################################################################################################################################### */
/**
 */
struct FirstTabView: View {
    var body: some View {
        NavigationStack {
            Text("Keytag Array")
                .navigationTitle("Keytag Array")
        }
    }
}

/* ###################################################################################################################################### */
// MARK: -  -
/* ###################################################################################################################################### */
/**
 */
struct SecondTabView: View {
    var body: some View {
        NavigationStack {
            Text("Keytag Strip")
                .navigationTitle("Keytag Strip")
        }
    }
}

/* ###################################################################################################################################### */
// MARK: -  -
/* ###################################################################################################################################### */
/**
 */
struct ThirdTabView: View {
    var body: some View {
        NavigationStack {
            Text("Medallions")
                .navigationTitle("Medallions")
        }
    }
}
