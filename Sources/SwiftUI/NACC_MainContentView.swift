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
// MARK: - Date Picker View -
/* ###################################################################################################################################### */
/**
 This is a view that we use to allow the user to select a new cleandate.
 
 It shows a standard "graphical" date picker (calendar-style), along with a "Today" button (sets the calendar to today), and a "DONE" button.
 
 If the user has changed the date since invoking the screen, a "CANCEL" button also appears, allowing the user to discard any changes.
 */
struct PickerPopoverContent: View {
    /* ################################################################## */
    /**
     This denotes the padding above the cleandate picker.
     */
    private static let _cleandatePickerTitlePaddingInDisplayUnits = 20.0
    
    /* ################################################################## */
    /**
     This stores the initial date, upon invoking the sheet/popover.
     */
    private static var _originalDate: Date = .now

    /* ################################################################## */
    /**
     This is used to dismiss the modal.
     */
    @Environment(\.dismiss) private var _dismiss

    /* ################################################################## */
    /**
     This connects to the main selected date.
     */
    @Binding var selectedDate: Date

    /* ################################################################## */
    /**
     This returns the DatePicker screen.
     */
    var body: some View {
        AppBackground {
            VStack {
                Text("SLUG-CLEANDATE-PICKER-TITLE".localizedVariant)
                    .font(.largeTitle)
                    .padding(.top, Self._cleandatePickerTitlePaddingInDisplayUnits)
                    .padding(.horizontal, Self._cleandatePickerTitlePaddingInDisplayUnits)

                DatePicker("Clean Date",
                           selection: self.$selectedDate,
                           in: ...Date(),
                           displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                
                HStack {
                    if !Calendar.current.isDate(self.selectedDate, inSameDayAs: .now) {
                        Button("SLUG-TODAY".localizedVariant) {
                            self.selectedDate = Date()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    if self.selectedDate != Self._originalDate {
                        Button("SLUG-RESET".localizedVariant) {
                            self.selectedDate = Self._originalDate
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button("SLUG-DONE".localizedVariant) {
                        self._dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .onAppear { Self._originalDate = self.selectedDate }
    }
}

/* ###################################################################################################################################### */
// MARK: - Main App View -
/* ###################################################################################################################################### */
/**
 The initial app container View.
 
 This is the principal view of the app. It is displayed upon startup.
 
 It contains a textual report of the user's set cleantime, and the user can tap the report to change their cleandate.
 
 Below the report, is an image, showing the last keytag (for under a year), or medallion earned by the user, based on their cleandate.
 
 At the top, is the app logo. Tapping on it (or the keytag/medallion logo) will show another screen, with images displaying multiple keytags or medalliuons.
 */
struct NACC_MainContentView: View {
    /* ################################################################## */
    /**
     This is the string that displays the "cleantime report."
     */
    private let _reportString = LGV_UICleantimeDateReportString()
    
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
     This returns the contents of the textual report.
     */
    private var _report: String {
        let calculator = LGV_CleantimeDateCalc(startDate: self._selectedDate).cleanTime

        if calculator.isOneDayOrMore {
            return self._reportString
                .naCleantimeText(beginDate: self._selectedDate,
                                 endDate: .now
                )?
                .localizedVariant ?? "ERROR"
        } else {
            return "SLUG-CLEANDATE-PICKER-TITLE".localizedVariant
        }
    }

    /* ################################################################## */
    /**
     This returns a View, containing the main date display, and keytag/medallion display.
     The user can change the date.
     */
    var body: some View {
        NavigationStack {
            AppBackground(alignment: .center) {
                VStack {
                    // This is the top logo. If the user has thirty days or more, tapping on it will bring in the results screen.
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
                    
                    // If the user has not specified a cleandate, this text item displays a message to that effect.
                    if !LGV_CleantimeDateCalc(startDate: self._selectedDate).cleanTime.isOneDayOrMore {
                        Text("SLUG-NO-CLEANDATE-YET".localizedVariant)
                    }
                    
                    // If there has been a cleandate set, the following displays a text item, with the textual report. If no cleandate, then it prompts the user to set one.
                    // Tapping on the report brings up a date picker, allowing the user to set/change the cleandate.
                    // The text is surrounded by a capsule, indicating that it can be tapped. If no date is set, the color of the text is a button color.
                    Text(self._report)
                        .textSelection(.enabled)
                            .padding(Self._buttonPaddingInDisplayUnits)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(!LGV_CleantimeDateCalc(startDate: self._selectedDate).cleanTime.isOneDayOrMore ? Color("SelectionTintColor") : .primary)
                            .background(.thickMaterial, in: Capsule())
                            .contentShape(Rectangle())
                        .onTapGesture {
                            self._showingPicker = true
                        }
                        .popover(isPresented: $_showingPicker) {
                            PickerPopoverContent(selectedDate: $_selectedDate)
                        }
                        .accessibilityAddTraits(.isButton)
                        .accessibilityHint("SLUG-ACC-REPORT-BUTTON".localizedVariant)
                    
                    // If the user has set a cleandate, then the following is an image, with the user's last earned keytag (under a year), or medallion.
                    // Tapping on the image brings in the results screen.
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
