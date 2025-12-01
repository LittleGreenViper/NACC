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
     This is the string that displays the "cleantime report."
     */
    private let _reportString = LGV_UICleantimeDateReportString()
    
    /* ################################################################## */
    /**
     This denotes the padding above the cleandate picker.
     */
    private static let _cleandatePickerTitlePaddingInDisplayUnits = 20.0
    
    /* ################################################################## */
    /**
     This denotes the padding around the date display.
     */
    private static let _buttonPaddingInDisplayUnits = 8.0
    
    /* ################################################################## */
    /**
     This denotes the horizontal padding around the text display.
     */
    private static let _horizontalPaddingInDisplayUnits = 20.0

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
     This is the local instance of the persistent prefs for the app.
     */
    private let _prefs = NACCPersistentPrefs()

    /* ################################################################## */
    /**
     This handles interaction with the Watch.
     */
    @State private var _watchDelegateObject: NACCWatchAppContentViewWatchDelegate?
    
    /* ################################################################## */
    /**
     This contains the cleandate.
     */
    @State private var _selectedDate = Date()
    
    /* ################################################################## */
    /**
     This displays the last keytag or medallion earned.
     */
    @State private var _displayedImage: UIImage?
    
    /* ################################################################## */
    /**
     If true, then the NavigationStack will bring in the results screen.
     */
    @State private var _showResult = false
    
    /* ################################################################## */
    /**
     This shows a date picker in a modal sheet. If the user taps on the date, they get the sheet.
     */
    @State private var _showingPicker = false
    
    /* ################################################################## */
    /**
     If true, then the NavigationStack will bring in the info screen.
     */
    @State private var _showInfo = false

    /* ################################################################## */
    /**
     This returns a View, containing the main date display, and keytag/medallion display.
     The user can change the date.
     */
    var body: some View {
        NavigationStack {
            AppBackground(alignment: .center) {
                VStack {
                    if LGV_CleantimeDateCalc(startDate: self._selectedDate).cleanTime.isThirtyDaysOrMore {
                        Button {
                            self._prefs.lastSelectedTabIndex = TabInexes.keytagArray.rawValue
                            self._showResult = true
                        } label: {
                            Image("Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: Self._iconSizeInDisplayUnits)
                        }
                        .accessibilityHint("SLUG-ACC-LOGO".localizedVariant)
                    } else {
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: Self._iconSizeInDisplayUnits)
                    }
                    
                    if !LGV_CleantimeDateCalc(startDate: self._selectedDate).cleanTime.isOneDayOrMore {
                        Text("NO CLEANDATE YET")
                    }
                    
                    if let report = self._reportString.naCleantimeText(beginDate: self._selectedDate,
                                                                       endDate: .now
                    )?.localizedVariant,
                       !report.isEmpty {
                        Text(report)
                            .textSelection(.enabled)
                                .padding(Self._buttonPaddingInDisplayUnits)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundStyle(!LGV_CleantimeDateCalc(startDate: _selectedDate).cleanTime.isOneDayOrMore ? Color("SelectionTintColor") : .primary)
                                .background(.thickMaterial, in: Capsule())
                                .contentShape(Rectangle())
                            .onTapGesture {
                                _showingPicker = true
                            }
                            .popover(isPresented: $_showingPicker) {
                                AppBackground {
                                    Text("SLUG-CLEANDATE-PICKER-TITLE".localizedVariant)
                                        .font(.largeTitle)
                                        .padding(.top, Self._cleandatePickerTitlePaddingInDisplayUnits)
                                        .padding([.leading, .trailing], Self._cleandatePickerTitlePaddingInDisplayUnits)
                                    
                                    DatePicker(
                                        "Clean Date",
                                        selection: self.$_selectedDate,
                                        displayedComponents: [.date]
                                    )
                                    .datePickerStyle(.graphical)
                                    .padding()
                                }
                            }
                            .accessibilityAddTraits(.isButton)
                            .accessibilityHint("SLUG-ACC-REPORT-BUTTON".localizedVariant)
                    }
                    
                    if let image = self._displayedImage {
                        if LGV_CleantimeDateCalc(startDate: self._selectedDate).cleanTime.isThirtyDaysOrMore {
                            Button {
                                self._prefs.lastSelectedTabIndex = LGV_CleantimeDateCalc(startDate: self._selectedDate).cleanTime.isOneYearOrMore ? TabInexes.medallionArray.rawValue : TabInexes.keytagStrip.rawValue
                                self._showResult = true
                            } label: {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: Self._mainImageWidthInDisplayUnits)
                            }
                            .accessibilityHint("SLUG-ACC-IMAGE".localizedVariant)
                        } else {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Self._mainImageWidthInDisplayUnits)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("SLUG-INITIAL-TITLE".localizedVariant)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // TODO: This will show the action sheet.
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityHint("SLUG-ACC-ACTION-BUTTON".localizedVariant)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // TODO: This will show the calendar event creation sheet.
                    } label: {
                        Image(systemName: "calendar")
                    }
                    .accessibilityHint("SLUG-ACC-CALENDAR-BUTTON".localizedVariant)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self._showInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityHint("SLUG-ACC-INFO-BUTTON".localizedVariant)
                }
            }
            .navigationDestination(isPresented: self.$_showResult) { NACC_ResultDisplayView() }
            .navigationDestination(isPresented: self.$_showInfo) { NACC_InfoDisplayView() }
        }
        .onAppear {
            self._watchDelegateObject = self._watchDelegateObject ?? NACCWatchAppContentViewWatchDelegate(updateHandler: self.updateApplicationContext)
            self._selectedDate = self._prefs.cleanDate
        }
        .onChange(of: self._selectedDate) { _, inSelectedDate in
            self._prefs.cleanDate = inSelectedDate
            self._watchDelegateObject?.sendApplicationContext()
            let calculator = LGV_CleantimeDateCalc(startDate: inSelectedDate).cleanTime
            let cleantimeDisplayImage = calculator.isOneYearOrMore ? LGV_UISingleCleantimeMedallionImageView() : LGV_UISingleCleantimeKeytagImageView()
            cleantimeDisplayImage.totalDays = calculator.totalDays
            cleantimeDisplayImage.totalMonths = calculator.totalMonths
            guard calculator.isOneDayOrMore,
                  let generatedImage = cleantimeDisplayImage.generatedImage
            else {
                self._displayedImage = nil
                return
            }
            self._displayedImage = generatedImage
        }
    }
    
    /* ################################################################## */
    /**
     This will update our internal state, to match the new application context that we received from the Watch.
     
     - parameter inApplicationContext: The new context dictionary.
     */
    func updateApplicationContext(_ inApplicationContext: [String: Any]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let watchFormatTemp = inApplicationContext["watchAppDisplayState"] as? Int,
           let watchFormatType = NACCPersistentPrefs.MainWatchState(rawValue: watchFormatTemp) {
            let watchFormat = watchFormatType.rawValue
            #if DEBUG
                print("WatchFormat: \(watchFormat)")
            #endif
            self._prefs.watchAppDisplayState = watchFormatType
        }
        
        if let cleanDateTemp = inApplicationContext["cleanDate"] as? String,
           let cleanDate = dateFormatter.date(from: cleanDateTemp) {
            #if DEBUG
                print("Cleandate: \(cleanDate)")
            #endif
            DispatchQueue.main.async { self._selectedDate = cleanDate }
        }
    }
}
