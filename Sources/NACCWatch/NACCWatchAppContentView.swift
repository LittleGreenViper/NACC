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
     Tracks scene activity.
     */
    @Environment(\.scenePhase) private var _scenePhase

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
        if self.syncUp,
           !self.showCleanDatePicker {
            NACCPersistentPrefs().flush()
            
            // get the text set, ASAP.
            DispatchQueue.global().async {
                let textTemp = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: self.cleanDate, endDate: .now) ?? ""
                DispatchQueue.main.async {
                    text = textTemp
                }
            }
            
            // Update the keytags (could be slower)
            DispatchQueue.global().async {
                #if DEBUG
                    print("Synchronizing (Global Thread)")
                #endif
                
                let calculator = LGV_CleantimeDateCalc(startDate: self.cleanDate).cleanTime
                
                DispatchQueue.main.async {
                    #if DEBUG
                        print("Synchronizing (Main Thread)")
                    #endif
                    let keyTagImage = LGV_MultiKeytagImageGenerator(isVerticalStrip: true,
                                                                    totalDays: calculator.totalDays,
                                                                    totalMonths: calculator.totalMonths,
                                                                    widestKeytagImageInDisplayUnits: 2 < calculator.years ? 64 : 128
                    ).generatedImage
                    
                    let medallionView = (0 < calculator.years)
                        ? LGV_MedallionImage(totalMonths: calculator.totalMonths).drawImage()
                            : LGV_KeytagImageGenerator(isRingClosed: true, totalDays: calculator.totalDays, totalMonths: calculator.totalMonths).generatedImage
                    
                    (self.syncUp, self.singleKeytag, self.singleMedallion) = (false, keyTagImage, medallionView)
                }
            }
        }
    }

    /* ################################################################## */
    /**
     The main view. It's a swiped-tab view (page selector), with text, keytag, and medallion as choices. The choice is saved persistently.
     The user can double-tap on it, to change the cleandate.
     */
    var body: some View {
        GeometryReader { inGeom in
            let calculator = LGV_CleantimeDateCalc(startDate: self.cleanDate).cleanTime
            NavigationStack {
                TabView(selection: self.$watchFormat) {
                    Text(text)
                        .tag(NACCPersistentPrefs.MainWatchState.text.rawValue)
                        .foregroundStyle(Color.black)
                        .padding()
                    
                    ScrollView {
                        let image = (singleKeytag ?? UIImage(systemName: "nosign"))?.resized(toNewWidth: 2 < calculator.years ? 64 : 128) ?? UIImage()
                        Spacer()
                            .frame(height: 8)
                        Image(uiImage: image)
                            .tag(NACCPersistentPrefs.MainWatchState.keytag.rawValue)
                    }
                    .clipped()
                    
                    Image(uiImage: (singleMedallion ?? UIImage(systemName: "nosign"))?.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                        .tag(NACCPersistentPrefs.MainWatchState.medallion.rawValue)
                        .containerRelativeFrame([.horizontal, .vertical], alignment: .center)
                }
                .background {
                    Image("BackgroundGradient")
                        .resizable(resizingMode: .stretch)
                        .cornerRadius(8)
                }
                .onAppear {
                    self.showCleanDatePicker = false
                    NACCPersistentPrefs().flush()
                    self.synchronize()
                }
                .onChange(of: self.syncUp) {
                    self.synchronize()
                }
                // Forces updates, whenever we become active.
                .onChange(of: self._scenePhase, initial: true) {
                    if .active == self._scenePhase {
                        NACCPersistentPrefs().flush()
                        self.synchronize()
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .onTapGesture(count: 2) { self.showCleanDatePicker = true }
                .navigationDestination(isPresented: self.$showCleanDatePicker) { CleanDatePicker(cleanDate: self.$cleanDate, syncUp: self.$syncUp) }
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
     This is a binding for a "trigger," that tells the screen to update to the latest values.
     */
    @Binding var syncUp: Bool

    /* ################################################################## */
    /**
     The picker view.
     */
    var body: some View {
        let minDate = Calendar.current.date(from: DateComponents(year: 1953, month: 10, day: 5)) ?? .now
        VStack {
            Spacer()
                .frame(height: 4)
            DatePicker(NSLocalizedString("SLUG-SELECT-DATE", tableName: "WatchStrings", comment: ""), selection: self.$cleanDate, in: minDate...Date.now)
                .onAppear { self.cleanDate = min(.now, max(minDate, self.cleanDate)) }
                .foregroundStyle(.black)
            Spacer()
                .frame(height: 4)
        }
        .background {
            Image("BackgroundGradient")
                .resizable(resizingMode: .stretch)
                .cornerRadius(8)
        }
    }
}
