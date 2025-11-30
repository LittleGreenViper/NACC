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
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - Bundle Extension -
/* ###################################################################################################################################### */
/**
 This extension adds a few simple accessors for some of the more common bundle items.
 */
extension Bundle {
    /* ################################################################## */
    /**
     If there is a copyright site URI, it is returned here as a String. It may be nil.
     */
    var siteURIAsString: String? { object(forInfoDictionaryKey: "InfoScreenCopyrightSiteURL") as? String }

    /* ################################################################## */
    /**
     If there is a help site URI, it is returned here as a String. It may be nil.
     */
    var helpURIAsString: String? { object(forInfoDictionaryKey: "InfoScreenHelpSiteURL") as? String }

    /* ################################################################## */
    /**
     If there is a privacy site URI, it is returned here as a String. It may be nil.
     */
    var privacyURIAsString: String? { object(forInfoDictionaryKey: "InfoScreenPrivacySiteURL") as? String }
    
    /* ################################################################## */
    /**
     If there is a copyright site URI, it is returned here as a URL. It may be nil.
     */
    var siteURI: URL? { URL(string: siteURIAsString ?? "") }
    
    /* ################################################################## */
    /**
     If there is a help site URI, it is returned here as a URL. It may be nil.
     */
    var helpURI: URL? { URL(string: helpURIAsString ?? "") }

    /* ################################################################## */
    /**
     If there is a privacy site URI, it is returned here as a URL. It may be nil.
     */
    var privacyURI: URL? { URL(string: privacyURIAsString ?? "") }
}

/* ###################################################################################################################################### */
// MARK: - Info Screen Display View -
/* ###################################################################################################################################### */
/**
 The Information Screen View
 */
struct NACC_InfoDisplayView: View {
    /* ################################################################## */
    /**
     */
    @Environment(\.openURL) private var openURL
    
    /* ################################################################## */
    /**
     This denotes the padding around the text display.
     */
    private static let _edgePaddingInDisplayUnits = 16.0
    
    /* ################################################################## */
    /**
     This is how big to make the top icon button.
     */
    private static let _iconSizeInDisplayUnits = 80.0
    
    /* ################################################################## */
    /**
     This is the local instance of the persistent prefs for the app.
     */
    let prefs = NACCPersistentPrefs()
    
    /* ################################################################## */
    /**
     */
    var body: some View {
        AppBackground {
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    Image("AboutLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Self._iconSizeInDisplayUnits)
                        .onTapGesture {
                            if let url = Bundle.main.helpURI {
                                openURL(url)
                            }
                        }
                    
                    Text("SLUG-APP-INFO-TEXT".localizedVariant)
                        .padding(.horizontal, Self._edgePaddingInDisplayUnits)
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.top, 16)
            }
        }
        .navigationTitle("SLUG-ABOUT".localizedVariant)
        .navigationBarTitleDisplayMode(.inline)
    }
}
