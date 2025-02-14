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
import WatchConnectivity
import LGV_Cleantime
import LGV_UICleantime
import RVS_UIKit_Toolbox

/* ###################################################################################################################################### */
// MARK: - Watch App Content View -
/* ###################################################################################################################################### */
/**
 The main app content container view.
 */
struct NACCWatchAppContentView: View {
    /* ################################################################## */
    /**
     The image that represents a keytag. May be nil.
     */
    @Binding var singleKeytag: UIImage?
    
    /* ################################################################## */
    /**
     The image that represents a medallion. May be nil.
     */
    @Binding var singleMedallion: UIImage?

    /* ################################################################## */
    /**
     The text report.
     */
    @Binding var text: String

    /* ################################################################## */
    /**
     This is a binding for a "trigger," that determines whether or not the set cleandate picker is to be shown.
     */
    @Binding var showCleanDatePicker: Bool

    /* ################################################################## */
    /**
     This is a binding for a "trigger," that tells the screen to update to the latest values.
     */
    @Binding var syncUp: Bool

    /* ################################################################## */
    /**
     The cleandate.
     */
    @Binding var cleanDate: Date

    /* ################################################################## */
    /**
     The displayed tab.
     */
    @Binding var watchFormat: Int

    /* ################################################################## */
    /**
     This makes sure that the screen reflects the current state.
     */
    func synchronize() {
        syncUp = false

        NACCPersistentPrefs().flush()

        if let textTemp = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: cleanDate, endDate: .now) {
            text = textTemp
        } else {
            text = "ERROR"
        }
        
        singleKeytag = nil
        singleMedallion = nil
        
        let calculator = LGV_CleantimeDateCalc(startDate: cleanDate).cleanTime
        
        let medallionView = LGV_MedallionImage(totalMonths: calculator.totalMonths)
        singleMedallion = medallionView.drawImage()

        let keyTagImage = LGV_MultiKeytagImageGenerator(isVerticalStrip: true, totalDays: calculator.totalDays, totalMonths: calculator.totalMonths)
        singleKeytag = keyTagImage.generatedImage
    }

    /* ################################################################## */
    /**
     The main view. It's a swiped-tab view (page selector), with text, keytag, and medallion as choices. The choice is saved persistently.
     The user can double-tap on it, to change the cleandate.
     */
    var body: some View {
        GeometryReader { inGeom in
            NavigationStack {
                TabView(selection: $watchFormat) {
                    Text(text)
                        .tag(NACCPersistentPrefs.MainWatchState.text.rawValue)
                        .foregroundStyle(Color.black)
                        .padding()
                    
                    ScrollView {
                        let image = (singleKeytag ?? UIImage(systemName: "nosign"))?.resized(toNewWidth: inGeom.size.width - 16) ?? UIImage()
                        Spacer()
                            .frame(height: 12)
                        Image(uiImage: image)
                            .tag(NACCPersistentPrefs.MainWatchState.keytag.rawValue)
                    }

                    if 0 < LGV_CleantimeDateCalc(startDate: cleanDate).cleanTime.years {
                        Image(uiImage: (singleMedallion ?? UIImage(systemName: "nosign"))?.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                            .tag(NACCPersistentPrefs.MainWatchState.medallion.rawValue)
                            .containerRelativeFrame([.horizontal, .vertical], alignment: .bottom)
                    }
                }
                .onAppear {
                    if .medallion == NACCPersistentPrefs().watchAppDisplayState,
                       1 > LGV_CleantimeDateCalc(startDate: cleanDate).cleanTime.years {
                        watchFormat = NACCPersistentPrefs.MainWatchState.text.rawValue
                    }
                    showCleanDatePicker = false
                    synchronize()
                }
                .onChange(of: syncUp) {
                    if syncUp {
                        synchronize()
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .onTapGesture(count: 2) { showCleanDatePicker = true }
                .navigationDestination(isPresented: $showCleanDatePicker) { CleanDatePicker(cleanDate: $cleanDate) }
           }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Cleandate Picker View -
/* ###################################################################################################################################### */
/**
 This will display a date picker, that the user can use to select a new date.
 */
struct CleanDatePicker: View {
    /* ################################################################## */
    /**
     The cleandate.
     */
    @Binding var cleanDate: Date

    /* ################################################################## */
    /**
     The picker view.
     */
    var body: some View {
        let minDate = Calendar.current.date(from: DateComponents(year: 1953, month: 10, day: 5)) ?? .now
        // That "addingTimeInterval()" thing is because the DatePicker is exhibiting strange behavior, when I simply use .now. It lops off the current year.
        DatePicker(NSLocalizedString("SLUG-SELECT-DATE", tableName: "WatchStrings", comment: ""), selection: $cleanDate, in: minDate...Date.now)
            .onAppear { cleanDate = min(.now, max(minDate, cleanDate)) }
            .foregroundStyle(.black)
    }
}
