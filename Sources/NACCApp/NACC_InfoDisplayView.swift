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
import RVS_UIKit_Toolbox

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
     This is the size of the rounded corners.
     */
    private static let _iconCornerRadiusInDisplayUnits = 16.0

    /* ################################################################## */
    /**
     This is the local instance of the persistent prefs for the app.
     */
    let prefs = NACCPersistentPrefs()
    
    /* ################################################################## */
    /**
     This returns the screen structure.
     */
    var body: some View {
        AppBackground {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .center,
                           spacing: Self._edgePaddingInDisplayUnits
                    ) {
                        // The app icon button, at the top.
                        if let appIcon = Bundle.main.appIcon {
                            Image(uiImage: appIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Self._iconSizeInDisplayUnits)
                                .cornerRadius(Self._iconCornerRadiusInDisplayUnits)
                                .onTapGesture {
                                    if let url = Bundle.main.helpURI {
                                        self.openURL(url)
                                    }
                                }
                                .accessibilityHint("SLUG-ACC-APPICON-BUTTON".localizedVariant)
                        }
                        
                        // The app name and version string.
                        let displayString = String(format: "SLUG-APP-INFO-VERSION-FORMAT".localizedVariant,
                                                   Bundle.main.appDisplayName,
                                                   Bundle.main.appVersionString,
                                                   Bundle.main.appVersionBuildString)
                        Text(displayString)
                            .textSelection(.enabled)
                            .font(.caption)
                            .italic()
                        
                        // The main text display.
                        Text("SLUG-APP-INFO-TEXT".localizedVariant)
                            .padding(.horizontal,
                                     Self._edgePaddingInDisplayUnits
                            )
                            .textSelection(.enabled)
                            .font(.footnote)
                    }
                    .frame(maxWidth: .infinity,
                           alignment: .top
                    )
                    .padding(.top,
                             Self._edgePaddingInDisplayUnits
                    )
                }
                .scrollBounceBehavior(.basedOnSize)
                
                // The three buttons along the bottom.
                HStack {
                    // The app settings button
                    Button("SLUG-SETTINGS-BUTTON".localizedVariant) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .accessibilityHint("SLUG-ACC-SETTINGS-BUTTON".localizedVariant)

                    // The privacy link button
                    Button("SLUG-PRIVACY-BUTTON".localizedVariant) {
                        if let url = Bundle.main.siteURI {
                            self.openURL(url)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .accessibilityHint("SLUG-ACC-PRIVACY-BUTTON".localizedVariant)

                    // The main Web site button
                    Button("SLUG-LGV-BUTTON".localizedVariant) {
                        if let url = Bundle.main.siteURI {
                            self.openURL(url)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .accessibilityHint("SLUG-ACC-LGV-BUTTON".localizedVariant)
                }
                .padding()
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity,
                   alignment: .top
            )
        }
        .navigationTitle("SLUG-ABOUT".localizedVariant)
        .navigationBarTitleDisplayMode(.inline)
    }
}
