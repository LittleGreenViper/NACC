/*
 © Copyright 2012-2026, Little Green Viper Software Development LLC
 
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
     This is a thread-safe image renderer for the keytags
     - parameter inDates: The clean date and day covered by the report.
     */
    @concurrent private static func _renderAssets(for inDates: _ReportDates) async -> (keytagChain: UIImage?, singleMedallion: UIImage?) {
        // Bail out quickly if already cancelled.
        guard !Task.isCancelled else { return (nil, nil) }

        let calc = LGV_CleantimeDateCalc(startDate: inDates.start, endDate: inDates.end).cleanTime

        guard !Task.isCancelled else { return (nil, nil) }

        let singleMedallion = (calc.years > 0)
            ? LGV_MedallionImage(totalMonths: calc.totalMonths).drawImage()
            : LGV_KeytagImageGenerator(
                isRingClosed: true,
                totalDays: calc.totalDays,
                totalMonths: calc.totalMonths
            ).generatedImage

        guard !Task.isCancelled else { return (nil, singleMedallion) }

        let keytagChain = LGV_MultiKeytagImageGenerator(
            isVerticalStrip: true,
            totalDays: calc.totalDays,
            totalMonths: calc.totalMonths,
            widestKeytagImageInDisplayUnits: (calc.years > 2 ? 64 : 128)
        ).generatedImage

        guard !Task.isCancelled else { return (nil, singleMedallion) }

        return (keytagChain, singleMedallion)
    }

    /// A report changes when the clean date changes or a new day begins.
    private struct _ReportDates: Equatable {
        let start: Date
        let end: Date
    }

    @State private var _today = Calendar.current.startOfDay(for: .now)
    @State private var _renderedDates: _ReportDates?

    /* ################################################################## */
    /**
     Tracks scene activity.
     */
    @Environment(\.scenePhase) private var _scenePhase

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
    private func _synchronize(for inDates: _ReportDates) async {
        guard !self.showCleanDatePicker, self._renderedDates != inDates else { return }
        self._renderedDates = nil
        self.singleMedallion = nil
        self.keytagChain = nil

        async let assets = Self._renderAssets(for: inDates)
        let generated = await Task.detached(priority: .userInitiated) {
            LGV_UICleantimeDateReportString().naCleantimeText(beginDate: inDates.start, endDate: inDates.end) ?? ""
        }.value
        guard !Task.isCancelled, self.cleanDate == inDates.start else { return }
        self.text = generated

        let images = await assets
        guard !Task.isCancelled, self.cleanDate == inDates.start else { return }
        self.singleMedallion = images.singleMedallion
        self.keytagChain = images.keytagChain
        self._renderedDates = inDates
    }

    /* ################################################################## */
    /**
     The main view. It's a swiped-tab view (page selector), with text, keytag, and medallion as choices. The choice is saved persistently.
     The settings button stays above the pages; its initial clearance scrolls away with the content.
     */
    var body: some View {
        NavigationStack {
            GeometryReader { inGeom in
                let settingsHeight: CGFloat = 44
                ZStack(alignment: .topTrailing) {
                    let reportDates = _ReportDates(start: self.cleanDate, end: self._today)
                    let calculator = LGV_CleantimeDateCalc(startDate: self.cleanDate).cleanTime
                    TabView(selection: self.$watchFormat) {
                        ScrollView {
                            Text(self.text)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .padding(.top, settingsHeight)
                        }
                        .accessibilityLabel("SLUG-ACC-REPORT-LABEL".localizedVariant)
                        .accessibilityHint("SLUG-ACC-REPORT-SCROLL-HINT".localizedVariant)
                        .tag(NACCPersistentPrefs.MainWatchState.text.rawValue)

                        // Keep each page stable while its rendered image replaces the spinner.
                        ZStack {
                            if let singleMedallion = self.singleMedallion {
                                Image(uiImage: singleMedallion)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.bottom, 20)
                                    .frame(width: inGeom.size.width, height: max(0, inGeom.size.height - settingsHeight))
                                    .padding(.top, settingsHeight + inGeom.safeAreaInsets.top)
                                    .accessibilityLabel("SLUG-TAB-2".localizedVariant)
                                    .accessibilityValue(self.text)
                                    .accessibilityHint("SLUG-ACC-Medallions".localizedVariant)
                            } else {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.accentColor)
                            }
                        }
                        .tag(NACCPersistentPrefs.MainWatchState.medallion.rawValue)

                        ZStack {
                            if let keytagChain = self.keytagChain?.resized(toNewWidth: 2 < calculator.years ? 64 : 128) {
                                ScrollView {
                                    let image = keytagChain
                                    Spacer()
                                        .frame(height: settingsHeight + 8)
                                    Image(uiImage: image)
                                        .accessibilityLabel("SLUG-TAB-1".localizedVariant)
                                        .accessibilityValue(self.text)
                                }
                                .accessibilityLabel("SLUG-TAB-1".localizedVariant)
                                .accessibilityHint("SLUG-ACC-RECOGNITION-SCROLL-HINT".localizedVariant)
                            } else {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.accentColor)
                            }
                        }
                        .tag(NACCPersistentPrefs.MainWatchState.keytag.rawValue)
                    }
                    .background(Color("BackgroundColor-Main").ignoresSafeArea())
                    .task(id: self.showCleanDatePicker ? nil : reportDates) {
                        await self._synchronize(for: reportDates)
                    }
                    .onChange(of: self._scenePhase, initial: true) {
                        if .active == self._scenePhase {
                            self._today = Calendar.current.startOfDay(for: .now)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .allowsHitTesting(self.singleMedallion != nil && self.keytagChain != nil)
                    .ignoresSafeArea(.container, edges: .top)
                    .accessibilityLabel("SLUG-ACC-WATCH-PAGES-LABEL".localizedVariant)
                    .accessibilityHint("SLUG-ACC-WATCH-PAGES-HINT".localizedVariant)
                    .navigationDestination(isPresented: self.$showCleanDatePicker) { CleanDatePicker(cleanDate: self.$cleanDate) }

                    HStack {
                        Spacer()
                        Button {
                            self.showCleanDatePicker = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(.tint)
                                .frame(minWidth: 44, minHeight: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel(NSLocalizedString("SLUG-SELECT-DATE", tableName: "WatchStrings", comment: ""))
                        .accessibilityHint("SLUG-ACC-REPORT-BUTTON".localizedVariant)
                    }
                    .padding(.horizontal, 4)
                }
            }
            .background(Color("BackgroundColor-Main").ignoresSafeArea())
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
        VStack {
            Spacer()
                .frame(height: 4)
            DatePicker("", selection: self.$cleanDate, in: minDate...Date.now, displayedComponents: [.date])
                .accessibilityLabel("SLUG-ACC-DATEPICKER-LABEL".localizedVariant)
                .accessibilityHint("SLUG-ACC-DATEPICKER".localizedVariant)
                .onAppear { self.cleanDate = min(.now, max(minDate, self.cleanDate)) }
                .foregroundStyle(.primary)
            Spacer()
                .frame(height: 4)
        }
        .background(Color("BackgroundColor-Main").ignoresSafeArea())
    }
}
