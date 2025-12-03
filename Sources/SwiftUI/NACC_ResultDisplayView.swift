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
// MARK: - Extension To Add NavBar Names -
/* ###################################################################################################################################### */
extension TabIndexes {
    /* ################################################################## */
    /**
     This returns a string, containing a name to use for the tab.
     */
    var navigationTitle: String {
        switch self {
        case .keytagArray:
            return NACC_KeytagArrayTabView.tabName
        case .keytagStrip:
            return NACC_KeytagStripTabView.tabName
        case .medallionArray:
            return NACC_MedallionTabView.tabName
        }
    }
    /* ################################################################## */
    /**
     This returns a string, containing a name to use for the image.
     */
    var imageName: String {
        switch self {
        case .keytagArray:
            return NACC_KeytagArrayTabView.tabImageName
        case .keytagStrip:
            return NACC_KeytagStripTabView.tabImageName
        case .medallionArray:
            return NACC_MedallionTabView.tabImageName
        }
    }
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
     This will have whatever image is being displayed.
     */
    @State private var _displayedImage: UIImage?
    
    /* ################################################################## */
    /**
     The currently selected tab.
     */
    @Binding var selectedTab: TabIndexes
    
    /* ################################################################## */
    /**
     */
    var body: some View {
        AppBackground {
            TabView(selection: self.$selectedTab) {
                NACC_KeytagArrayTabView()
                    .tabItem {
                        Label(TabIndexes.keytagArray.navigationTitle,
                              image: TabIndexes.keytagArray.imageName
                        )
                    }
                    .tag(TabIndexes.keytagArray)
                
                NACC_KeytagStripTabView()
                    .tabItem {
                        Label(TabIndexes.keytagStrip.navigationTitle,
                              image: TabIndexes.keytagStrip.imageName
                        )
                    }
                    .tag(TabIndexes.keytagStrip)

                NACC_MedallionTabView()
                    .tabItem {
                        Label(TabIndexes.medallionArray.navigationTitle,
                              image: TabIndexes.medallionArray.imageName
                        )
                    }
                    .tag(TabIndexes.medallionArray)
            }
        }
        .navigationTitle(self.selectedTab.navigationTitle)
    }
}

/* ###################################################################################################################################### */
// MARK: - Common Base Protocol For All Views -
/* ###################################################################################################################################### */
/**
 */
protocol TabViewProtocol {
    /* ################################################################## */
    /**
     */
    static var tabName: String { get }

    /* ################################################################## */
    /**
     */
    static var tabImageName: String { get }
    
    /* ################################################################## */
    /**
     This is the cleantime keytag or medallion image.
    */
    var cleantime: LGV_UICleantimeImageViewBase? { get }
    
    /* ################################################################## */
    /**
     */
    var displayImage: Image? { get }
}

/* ###################################################################################################################################### */
// MARK: - Keytag Array View -
/* ###################################################################################################################################### */
/**
 */
struct NACC_KeytagArrayTabView: View, TabViewProtocol {
    /* ################################################################## */
    /**
     */
    static var tabName = "SLUG-TAB-0".localizedVariant

    /* ################################################################## */
    /**
     */
    static var tabImageName = "KeytagArray"
    
    /* ################################################################## */
    /**
    */
    var cleantime: LGV_UICleantimeImageViewBase? = LGV_UIMultipleCleantimeKeytagImageView()

    /* ################################################################## */
    /**
     */
    @State var displayImage: Image?

    /* ################################################################## */
    /**
     */
    var body: some View {
        Text(Self.tabName)
            .onAppear {
                let calculator = LGV_CleantimeDateCalc(startDate: NACCPersistentPrefs().cleanDate).cleanTime
                self.cleantime?.totalDays = calculator.totalDays
                self.cleantime?.totalMonths = calculator.totalMonths
                self.cleantime?.renderingCallback = { inImage in
                    #if DEBUG
                        print("Keytag Array View Callback")
                    #endif
                    guard let image = inImage else { return }
                    DispatchQueue.main.async { self.displayImage = Image(uiImage: image) }
                }
                self.cleantime?.layoutSubviews()
            }
    }
}

/* ###################################################################################################################################### */
// MARK: - Keytag Strip View -
/* ###################################################################################################################################### */
/**
 */
struct NACC_KeytagStripTabView: View, TabViewProtocol {
    /* ################################################################## */
    /**
     */
    static var tabName = "SLUG-TAB-1".localizedVariant

    /* ################################################################## */
    /**
     */
    static var tabImageName = "SingleKeytag"
    
    /* ################################################################## */
    /**
    */
    var cleantime: LGV_UICleantimeImageViewBase? = LGV_UIMultipleCleantimeKeytagImageView()

    /* ################################################################## */
    /**
     */
    @State var displayImage: Image?

    /* ################################################################## */
    /**
     */
    var body: some View {
        Text(Self.tabName)
            .onAppear {
                let calculator = LGV_CleantimeDateCalc(startDate: NACCPersistentPrefs().cleanDate).cleanTime
                self.cleantime?.totalDays = calculator.totalDays
                self.cleantime?.totalMonths = calculator.totalMonths
                self.cleantime?.renderingCallback = { inImage in
                    #if DEBUG
                        print("Keytag Strip View Callback")
                    #endif
                    guard let image = inImage else { return }
                    DispatchQueue.main.async { self.displayImage = Image(uiImage: image) }
                }
                self.cleantime?.layoutSubviews()
            }
    }
}

/* ###################################################################################################################################### */
// MARK: - Medallion Array View -
/* ###################################################################################################################################### */
/**
 */
struct NACC_MedallionTabView: View, TabViewProtocol {
    /* ################################################################## */
    /**
     */
    static var tabName = "SLUG-TAB-2".localizedVariant

    /* ################################################################## */
    /**
     */
    static var tabImageName = "Medallion"
    
    /* ################################################################## */
    /**
    */
    var cleantime: LGV_UICleantimeImageViewBase? = LGV_UICleantimeMultipleMedallionsImageView()

    /* ################################################################## */
    /**
     */
    @State var displayImage: Image?

    /* ################################################################## */
    /**
     */
    var body: some View {
        Text(Self.tabName)
            .onAppear {
                let calculator = LGV_CleantimeDateCalc(startDate: NACCPersistentPrefs().cleanDate).cleanTime
                self.cleantime?.totalDays = calculator.totalDays
                self.cleantime?.totalMonths = calculator.totalMonths
                self.cleantime?.renderingCallback = { inImage in
                    #if DEBUG
                        print("Medallion View Callback")
                    #endif
                    guard let image = inImage else { return }
                    DispatchQueue.main.async { self.displayImage = Image(uiImage: image) }
                }
                self.cleantime?.layoutSubviews()
            }
    }
}
