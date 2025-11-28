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
     */
    let prefs = NACCPersistentPrefs()
    
    /* ################################################################## */
    /**
     */
    private let _reportString = LGV_UICleantimeDateReportString()
    
    /* ################################################################## */
    /**
     This is how big to make the top icon button.
     */
    private static let _iconSizeInDisplayUnits = 80.0
    
    /* ################################################################## */
    /**
     This contains the cleandate.
     */
    @State private var _selectedDate = NACCPersistentPrefs().cleanDate {
        didSet {
            self.prefs.cleanDate = self._selectedDate
        }
    }

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
                            .frame(width: Self._iconSizeInDisplayUnits, height: Self._iconSizeInDisplayUnits)
                    }
                    
                    DatePicker(
                        "",
                        selection: self.$_selectedDate,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .environment(\.sizeCategory, .extraExtraExtraLarge)
                    
                    Text(self._reportString.naCleantimeText(beginDate: self._selectedDate, endDate: Date(), calendar: Calendar.current)?.localizedVariant ?? "ERROR")
                }
                .padding()
            }
        }
    }
}
