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
import WidgetKit

/* ###################################################################################################################################### */
// MARK: - Observable Model -
/* ###################################################################################################################################### */
/**
 This wraps the preferences in an observable wrapper.
 */
@MainActor
final class WatchModel: NSObject, ObservableObject, @preconcurrency WCSessionDelegate {
    /* ################################################################## */
    /**
     The text report.
     */
    @Published var text: String = ""

    /* ################################################################## */
    /**
     The actual cleandate
     */
    @Published var cleanDate: Date = NACCPersistentPrefs().cleanDate

    /* ################################################################## */
    /**
     Which screen to show
     */
    @Published var watchFormat: Int = NACCPersistentPrefs().watchAppDisplayState.rawValue

    /* ################################################################## */
    /**
     The task for rendering the text report
     */
    private var textTask: Task<Void, Never>?

    /* ################################################################## */
    /**
     Tells the app to reload itself from the stored prefs.
     It does this in a separate thread, as rendering the keytags can take a while.
     */
    @MainActor
    func reloadFromPrefs() {
        NACCPersistentPrefs().flush()
        self.cleanDate = NACCPersistentPrefs().cleanDate
        self.watchFormat = NACCPersistentPrefs().watchAppDisplayState.rawValue

        // Cancel any in-flight text generation
        self.textTask?.cancel()
        let date = self.cleanDate   // capture value

        textTask = Task { @MainActor in
            guard !Task.isCancelled else { return }
            let generated = LGV_UICleantimeDateReportString()
                .naCleantimeText(beginDate: date, endDate: .now) ?? ""

            guard !Task.isCancelled else { return }

            self.text = generated
        }
    }

    /* ################################################################## */
    /**
     Called when the app gets its context.
     
     - parameter _: Session. ignored
     - parameter didReceiveApplicationContext: the app context
     */
    func session(_: WCSession, didReceiveApplicationContext inContext: [String: Any]) {
        Task { @MainActor in
            if let raw = inContext["watchFormat"] as? Int {
                NACCPersistentPrefs().watchAppDisplayState = NACCPersistentPrefs.MainWatchState(rawValue: raw) ?? NACCPersistentPrefs.MainWatchState(rawValue: 0) ?? .text
            }
            self.reloadFromPrefs()
        }
    }

    /* ################################################################## */
    /**
     NOP
     - parameter _: The session. ignored
     - parameter activationDidCompleteWith: ignored
     - parameter error: ignored
     */
    func session(_: WCSession, activationDidCompleteWith: WCSessionActivationState, error: (any Error)?) { }
}

/* ###################################################################################################################################### */
// MARK: - Watch App Content View -
/* ###################################################################################################################################### */
/**
 The main app content container view.
 */
struct NACCWatchAppContentView: View {
    /* ################################################################## */
    /**
     This is a thread-safe image renderer for the keytags
     - parameter inDate: The new date that requires an update.
     */
    private static func _renderAssets(for inDate: Date) async -> UIImage? {
        // Bail out quickly if already cancelled.
        if Task.isCancelled { return nil }

        let calc = LGV_CleantimeDateCalc(startDate: inDate).cleanTime

        let keytag = LGV_MultiKeytagImageGenerator(
            isVerticalStrip: true,
            totalDays: calc.totalDays,
            totalMonths: calc.totalMonths,
            widestKeytagImageInDisplayUnits: (calc.years > 2 ? 64 : 128)
        ).generatedImage

        // One last cancellation check before returning.
        if Task.isCancelled { return nil }

        return keytag
    }

    /* ################################################################## */
    /**
     Task used to render keytags in a separate thread.
     */
    static private var _syncTask: Task<Void, Never>?

    /* ################################################################## */
    /**
     Tracks scene activity.
     */
    @Environment(\.scenePhase) private var _scenePhase

    /* ################################################################## */
    /**
     An instance of the observable model class.
     */
    @Binding var model: WatchModel

    /* ################################################################## */
    /**
     The image that represents the keytag chain. May be nil.
     */
    @Binding var keytagChain: UIImage?
    
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
    private func _synchronize() {
        // We’re on the main actor (SwiftUI), so no need for DispatchQueue.main.async
        guard self.syncUp,
              !self.showCleanDatePicker
        else { return }

        self.syncUp = false
        NACCPersistentPrefs().flush()

        // Update text and medallion synchronously on main
        self.text = LGV_UICleantimeDateReportString()
            .naCleantimeText(beginDate: cleanDate, endDate: .now) ?? ""

        let calc = LGV_CleantimeDateCalc(startDate: cleanDate).cleanTime

        self.singleMedallion = (calc.years > 0)
            ? LGV_MedallionImage(totalMonths: calc.totalMonths).drawImage()
            : LGV_KeytagImageGenerator(
                isRingClosed: true,
                totalDays: calc.totalDays,
                totalMonths: calc.totalMonths
            ).generatedImage

        self.keytagChain = nil

        // Cancel any previous render
        Self._syncTask?.cancel()
        Self._syncTask = nil
        
        let date = self.cleanDate  // capture value so it doesn't change under us

        Self._syncTask = Task {
            let keytag = await Self._renderAssets(for: date)
            Self._syncTask = nil
            await MainActor.run { self.keytagChain = keytag }
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
                    Text(self.text)
                        .tag(NACCPersistentPrefs.MainWatchState.text.rawValue)
                        .foregroundStyle(Color.black)
                        .padding()
                    
                    if let singleMedallion = self.singleMedallion?.resized(toNewHeight: inGeom.size.height) {
                        Image(uiImage: singleMedallion)
                            .tag(NACCPersistentPrefs.MainWatchState.medallion.rawValue)
                            .containerRelativeFrame([.horizontal, .vertical], alignment: .center)
                    } else {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.black)
                    }
                    
                    if let keytagChain = self.keytagChain?.resized(toNewWidth: 2 < calculator.years ? 64 : 128) {
                        ScrollView {
                            let image = keytagChain
                            Spacer()
                                .frame(height: 8)
                            Image(uiImage: image)
                                .tag(NACCPersistentPrefs.MainWatchState.keytag.rawValue)
                        }
                        .clipped()
                    } else {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.black)
                    }
                }
                .background {
                    Image("BackgroundGradient")
                        .resizable(resizingMode: .stretch)
                        .cornerRadius(8)
                }
                .onDisappear {
                    Self._syncTask?.cancel()
                    Self._syncTask = nil
                }
                .onChange(of: self.syncUp, initial: true) { self._synchronize() }
                .onChange(of: self._scenePhase, initial: true) {
                    if .active == self._scenePhase {
                        self.model.reloadFromPrefs()
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .navigationDestination(isPresented: self.$showCleanDatePicker) { CleanDatePicker(cleanDate: self.$cleanDate, syncUp: self.$syncUp) }
                .onAppear {
                    self.showCleanDatePicker = false
                    self._synchronize()
                }
            }
            .padding(0)
            .overlay(alignment: .topTrailing) {
                if !self.showCleanDatePicker {
                    Button {
                        self.showCleanDatePicker = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.black)
                            .padding(8)
                    }
                    .buttonStyle(.borderless)
                    .padding(.top, -12)
                    .padding(.trailing, -4)
                }
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
