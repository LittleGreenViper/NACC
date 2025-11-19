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
// MARK: - Observable Model -
/* ###################################################################################################################################### */
/**
 This wraps the preferences in an observable wrapper.
 */
final class WatchModel: NSObject, ObservableObject, WCSessionDelegate {
    /* ################################################################## */
    /**
     The Watchkit session, for communicating with the phone.
     */
    private var _session: WCSession?

    /* ################################################################## */
    /**
     The cleantime report text. Observable.
     */
    @Published var text: String = ""

    /* ################################################################## */
    /**
     The cleandate. Observable.
     */
    @Published var cleanDate: Date = Date()

    /* ################################################################## */
    /**
     The selected watch screen. Observable.
     - 0: Text
     - 1: Keytga Strip
     - 2: Medallion/Keytag
     */
    @Published var watchFormat: Int = 0

    /* ################################################################## */
    /**
     Default initializer. We use it to set up the session, and refresh the prefs.
     */
    override init() {
        super.init()
        if WCSession.isSupported() {
            self._session = WCSession.default
            self._session?.delegate = self
            self._session?.activate()
        }
    }

    /* ################################################################## */
    /**
     This flushes the prefs, and reloads them. The observable properties will be affected.
     */
    @MainActor
    func reloadFromPrefs() {
        NACCPersistentPrefs().flush()
        self.cleanDate   = NACCPersistentPrefs().cleanDate
        self.watchFormat = NACCPersistentPrefs().watchAppDisplayState.rawValue

        Task.detached {
            if let text = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: self.cleanDate, endDate: .now) {
                DispatchQueue.main.async { self.text = text }
            }
        }
    }

    // MARK: WCSessionDelegate
    /* ################################################################## */
    /**
     This is an empty function. Just here to satisfy the protocol.
     */
    func session(_: WCSession, activationDidCompleteWith: WCSessionActivationState, error: Error?) {}

    /* ################################################################## */
    /**
     Called when the context is updated by the phone.
     
     - parameter: The session (ignored)
     - parameter inContext: The new context.
     */
    func session(_: WCSession, didReceiveApplicationContext inContext: [String: Any]) {
        Task { @MainActor in
            if let raw = inContext["watchFormat"] as? Int {
                NACCPersistentPrefs().watchAppDisplayState = .init(rawValue: raw) ?? .init(rawValue: 0) ?? .text
            }
            self.reloadFromPrefs()
        }
    }
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
     This is a threaded renderer
     */
    static func _renderAssets(for date: Date) async -> UIImage? {
        // Bail out quickly if already cancelled.
        if Task.isCancelled { return nil }

        // Heavy work off the main actor.
        return await Task.detached(priority: .userInitiated) {
            if Task.isCancelled { return nil }

            let calc = LGV_CleantimeDateCalc(startDate: date).cleanTime

            let keytag = LGV_MultiKeytagImageGenerator(
                isVerticalStrip: true,
                totalDays: calc.totalDays,
                totalMonths: calc.totalMonths,
                widestKeytagImageInDisplayUnits: (calc.years > 2 ? 64 : 128)
            ).generatedImage

            return keytag
        }.value
    }

    /* ################################################################## */
    /**
     Task used to render keytags in a separate thread.
     */
    @State private var _syncTask: Task<Void, Never>?

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
    func synchronize() {
        DispatchQueue.main.async {
            if self.syncUp,
               !self.showCleanDatePicker {
                self.syncUp = false
                NACCPersistentPrefs().flush()
                // get the text set, ASAP.
                text = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: self.cleanDate, endDate: .now) ?? ""
                let calc = LGV_CleantimeDateCalc(startDate: self.cleanDate).cleanTime
                
                self.singleMedallion = (calc.years > 0)
                ? LGV_MedallionImage(totalMonths: calc.totalMonths).drawImage()
                : LGV_KeytagImageGenerator(isRingClosed: true,
                                           totalDays: calc.totalDays,
                                           totalMonths: calc.totalMonths).generatedImage
                self.keytagChain = nil
                self._syncTask?.cancel()
                self._syncTask = Task.detached(priority: .userInitiated) {
                    let keytag = await Self._renderAssets(for: self.cleanDate)
                    if Task.isCancelled { return }
                    DispatchQueue.main.async { self.keytagChain = keytag }
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
                .overlay(alignment: .topTrailing) {
                    if !showCleanDatePicker {
                        Button {
                            showCleanDatePicker = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.black)   // black gear
                                .padding(3)                // tiny hit area
                        }
                        .buttonStyle(.borderless)
                        .padding(3)                    // jam into top-right of card
                    }
                }
                .onAppear {
                    self.showCleanDatePicker = false
                    self.synchronize()
                }
                .onDisappear { self._syncTask?.cancel() }
                .onChange(of: self.syncUp, initial: true) { self.synchronize() }
                .onChange(of: self._scenePhase, initial: true) {
                    if .active == self._scenePhase {
                        self.model.reloadFromPrefs()
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
