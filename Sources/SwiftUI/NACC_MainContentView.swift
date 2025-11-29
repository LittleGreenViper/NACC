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
// MARK: - Main App View -
/* ###################################################################################################################################### */
/**
 The initial app container View.
 */
struct NACC_MainContentView: View {
    /* ################################################################## */
    /**
     This is the local instance of the persistent prefs for the app.
     */
    let prefs = NACCPersistentPrefs()
    
    /* ################################################################## */
    /**
     This is the string that displays the "cleantime report."
     */
    private let _reportString = LGV_UICleantimeDateReportString()
    
    /* ################################################################## */
    /**
     This is how big to make the top icon button.
     */
    private static let _iconSizeInDisplayUnits = 80.0
    
    /* ################################################################## */
    /**
     This is how wide to make the displayed image.
     */
    private static let _mainImageWidthInDisplayUnits = 128.0
    
    /* ################################################################## */
    /**
     This contains the cleandate.
     */
    @State private var _selectedDate = Date()
    
    /* ################################################################## */
    /**
     */
    @State private var _displayedImage: UIImage?

    /* ################################################################## */
    /**
     This returns a View, containing the main date display, and keytag/medallion display.
     The user can change the date.
     */
    var body: some View {
        NavigationStack {
            AppBackground {
                VStack {
                    Button {
                        // TBD - This will call in the keytag array display.
                    } label: {
                        Image("Logo")
                            .resizable()
                            .frame(width: Self._iconSizeInDisplayUnits,
                                   height: Self._iconSizeInDisplayUnits
                            )
                    }
                    .accessibilityHint("SLUG-ACC-LOGO".localizedVariant)
                    
                    DatePicker(
                        "",
                        selection: self.$_selectedDate,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .frame(maxWidth: .infinity,
                           alignment: .center
                    )
                    .environment(\.sizeCategory,
                                  .extraExtraExtraLarge
                    )
                    .accessibilityHint("SLUG-ACC-DATEPICKER".localizedVariant)
                    
                    if let report = self._reportString.naCleantimeText(beginDate: self._selectedDate,
                                                                       endDate: .now,
                                                                       calendar: .current
                    )?.localizedVariant {
                        Text(report)
                    }
                    
                    if let image = self._displayedImage {
                        Button {
                            // TBD - This will call in the keytag array display or the medallion display.
                        } label: {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Self._mainImageWidthInDisplayUnits)
                        }
                        .accessibilityHint("SLUG-ACC-IMAGE".localizedVariant)
                        
                    }
                }
                .padding()
            }
        }
        .onAppear {
            self._selectedDate = self.prefs.cleanDate
        }
        .onChange(of: self._selectedDate) { oldValue, newValue in
            self.prefs.cleanDate = newValue
            let calculator = LGV_CleantimeDateCalc(startDate: newValue,
                                                   calendar: .current
            ).cleanTime
            let cleantimeDisplayImage = 0 < calculator.years ? LGV_UISingleCleantimeMedallionImageView() : LGV_UISingleCleantimeKeytagImageView()
            cleantimeDisplayImage.totalDays = calculator.totalDays
            cleantimeDisplayImage.totalMonths = calculator.totalMonths
            guard 0 < calculator.totalDays,
                  let generatedImage = cleantimeDisplayImage.generatedImage
            else {
                self._displayedImage = nil
                return
            }
            self._displayedImage = generatedImage
        }
    }
}
