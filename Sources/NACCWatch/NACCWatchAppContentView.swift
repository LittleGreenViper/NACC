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
 */
struct NACCWatchAppContentView: View {
    /* ################################################################## */
    /**
     The text report.
     */
    @State var text: String = ""

    /* ################################################################## */
    /**
     The image that represents a keytag. May be nil. Mutually exclusive with `singleMedallion`.
     */
    @State var singleKeytag: UIImage?
    
    /* ################################################################## */
    /**
     The image that represents a medallion. May be nil. Mutually exclusive with `singleKeytag`.
     */
    @State var singleMedallion: UIImage?

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
     This should be called on the main thread.
     */
    func synchronize() {
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

        let keyTagImage = LGV_KeytagImageGenerator(isRingClosed: true, totalDays: calculator.totalDays, totalMonths: calculator.totalMonths)
        singleKeytag = keyTagImage.generatedImage
    }

    /* ################################################################## */
    /**
     */
    var body: some View {
        GeometryReader { inGeom in
            TabView(selection: $watchFormat) {
                Text(text)
                    .tag(NACCPersistentPrefs.MainWatchState.text.rawValue)
                Image(uiImage: (singleKeytag ?? UIImage(systemName: "nosign"))?.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                    .tag(NACCPersistentPrefs.MainWatchState.keytag.rawValue)
                Image(uiImage: (singleMedallion ?? UIImage(systemName: "nosign"))?.resized(toNewHeight: inGeom.size.height) ?? UIImage())
                    .tag(NACCPersistentPrefs.MainWatchState.medallion.rawValue)
            }
            .tabViewStyle(PageTabViewStyle())
            .onAppear(perform: synchronize)
        }
    }
}
