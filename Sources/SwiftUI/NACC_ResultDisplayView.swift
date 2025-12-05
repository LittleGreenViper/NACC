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
     Undefined (no tab selected).
     */
    case undefined = -1
    
    /* ################################################################## */
    /**
     Shows a horizontally-arrayed image of all earned keytags.
     */
    case keytagArray
    
    /* ################################################################## */
    /**
     Shows a scrollable vertical strip of all earned keytags.
     */
    case keytagStrip
    
    /* ################################################################## */
    /**
     Shows a horizontally-arrayed image of all the earned medallions.
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
        case .undefined:
            return "ERROR"
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
        case .undefined:
            return "ERROR"
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
    
    @State private var _navTitle: String = ""

    /* ################################################################## */
    /**
     The currently selected tab.
     */
    @Binding var selectedTab: TabIndexes
    
    /* ################################################################## */
    /**
     This returns the entire screen, with the tabs.
     */
    var body: some View {
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
            
            if LGV_CleantimeDateCalc(startDate: NACCPersistentPrefs().cleanDate).cleanTime.isOneYearOrMore {
                NACC_MedallionTabView()
                    .tabItem {
                        Label(TabIndexes.medallionArray.navigationTitle,
                              image: TabIndexes.medallionArray.imageName
                        )
                    }
                    .tag(TabIndexes.medallionArray)
            }
        }
        .navigationTitle("SLUG-RESULTS-TITLE".localizedVariant)
        .navigationBarTitleDisplayMode(.inline)
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
     The name for this TabView
     */
    static var tabName: String { get }

    /* ################################################################## */
    /**
     The name for this TabView's icon image.
     */
    static var tabImageName: String { get }
}

/* ###################################################################################################################################### */
// MARK: - Shared Cleantime Image View -
/* ###################################################################################################################################### */
/**
 A reusable View that:

 - Configures an `LGV_UICleantimeImageViewBase` subclass
 - Waits for it to render into a `UIImage`
 - Shows a spinner until the image is ready
 */
struct CleantimeRenderedImageView: View {
    /* ################################################################## */
    /**
     The indenting, on either side of the displayed image.
     */
    private static let _sideInsetsInDisplayUnits = CGFloat(20)
    
    /* ################################################################## */
    /**
     The underlying UIKit cleantime view that does the actual drawing.
     */
    private let cleantimeView: LGV_UICleantimeImageViewBase

    /* ################################################################## */
    /**
     The image that we will display once rendering is complete.
     */
    @State private var displayImage: UIImage?

    /* ################################################################## */
    /**
     We accept a builder closure that returns a fully-configured cleantime view.
     */
    init(makeCleantimeView: () -> LGV_UICleantimeImageViewBase) {
        self.cleantimeView = makeCleantimeView()
    }

    /* ################################################################## */
    /**
     This returns the rendered image, in a ScrollView, or presents a ProgressView.
     */
    var body: some View {
        AppBackground(alignment: nil == self.displayImage ? .center : .top) {
            Group {
                if let image = self.displayImage {
                    GeometryReader { proxy in
                        let availableWidth = proxy.size.width - (Self._sideInsetsInDisplayUnits * 2)
                        let naturalWidth = image.size.width
                        let naturalHeight = image.size.height
                        
                        // Don't go wider than the image's natural width
                        let targetWidth = min(availableWidth, naturalWidth)
                        let aspectRatio = naturalHeight / naturalWidth
                        let targetHeight = targetWidth * aspectRatio
                        
                        ScrollView(.vertical) {
                            HStack {
                                Spacer()
                                Image(uiImage: image)
                                    .resizable()
                                    .interpolation(.high)
                                    .frame(width: targetWidth,
                                           height: targetHeight
                                    )
                                    .padding(.horizontal,
                                             Self._sideInsetsInDisplayUnits
                                    )
                                Spacer()
                            }
                            .padding(.horizontal,
                                     Self._sideInsetsInDisplayUnits
                            )
                            .frame(width: proxy.size.width)
                        }
                        .scrollBounceBehavior(.basedOnSize)
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
        }
        .onAppear {
            if nil == self.displayImage {
                self.prepareRenderer()
            }
        }
    }

    /* ################################################################## */
    /**
     Sets up the LGV renderer and hooks the callback into our `displayImage` state.
     */
    private func prepareRenderer() {
        let calculator = LGV_CleantimeDateCalc(startDate: NACCPersistentPrefs().cleanDate).cleanTime

        cleantimeView.totalDays = calculator.totalDays
        cleantimeView.totalMonths = calculator.totalMonths
        cleantimeView.renderingCallback = { inImage in
            guard let image = inImage else { return }
            DispatchQueue.main.async { self.displayImage = image }
        }

        cleantimeView.layoutSubviews()
    }
}

/* ###################################################################################################################################### */
// MARK: - Keytag Array View -
/* ###################################################################################################################################### */
/**
 Displays a horizontally-oriented array of earned keytags
 */
struct NACC_KeytagArrayTabView: View, TabViewProtocol {
    /* ################################################################## */
    /**
     The tab name.
     */
    static var tabName = "SLUG-TAB-0".localizedVariant

    /* ################################################################## */
    /**
     The name of the image to show for the tab icon.
     */
    static var tabImageName = "KeytagArray"

    /* ################################################################## */
    /**
     Returns the image in a scroller, or a progress view, if still rendering.
     */
    var body: some View {
        CleantimeRenderedImageView {
            let view = LGV_UIMultipleCleantimeKeytagImageView()
            view.keytagsAreAVerticalStrip = false
            return view
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Keytag Strip View -
/* ###################################################################################################################################### */
/**
 Displays a vertically-oriented strip of earned keytags
 */
struct NACC_KeytagStripTabView: View, TabViewProtocol {
    /* ################################################################## */
    /**
     The tab name.
     */
    static var tabName = "SLUG-TAB-1".localizedVariant

    /* ################################################################## */
    /**
     The name of the image to show for the tab icon.
     */
    static var tabImageName = "SingleKeytag"

    /* ################################################################## */
    /**
     Returns the image in a scroller, or a progress view, if still rendering.
     */
    var body: some View {
        CleantimeRenderedImageView {
            let view = LGV_UIMultipleCleantimeKeytagImageView()
            view.keytagsAreAVerticalStrip = true
            return view
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Medallion Array View -
/* ###################################################################################################################################### */
/**
 Displays a horizontally-oriented array of earned medallions
 */
struct NACC_MedallionTabView: View, TabViewProtocol {
    /* ################################################################## */
    /**
     The tab name.
     */
    static var tabName = "SLUG-TAB-2".localizedVariant

    /* ################################################################## */
    /**
     The name of the image to show for the tab icon.
     */
    static var tabImageName = "Medallion"

    /* ################################################################## */
    /**
     Returns the image in a scroller, or a progress view, if still rendering.
     */
    var body: some View {
        CleantimeRenderedImageView {
            LGV_UICleantimeMultipleMedallionsImageView()
        }
    }
}
