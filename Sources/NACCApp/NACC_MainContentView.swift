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
import RVS_UIKit_Toolbox
import EventKit
import EventKitUI

/* ###################################################################################################################################### */
// MARK: - View Extension for the Date Picker -
/* ###################################################################################################################################### */
fileprivate extension View {
    /* ################################################################## */
    /**
     Called to create our custom picker.
     - parameter inIsPresented: True, if we are presenting the date picker sheet/popover
     - parameter inSelectedDate: The date being show/changed
     - returns: The custom date picker view
     */
    func _adaptivePickerPresentation(isPresented inIsPresented: Binding<Bool>, selectedDate inSelectedDate: Binding<Date>) -> some View {
        // This modifies the view to contain our special DatePicker, selected for the platform.
        self.modifier(NACC_AdaptivePickerPresentation(isPresented: inIsPresented,
                                                 selectedDate: inSelectedDate
                                                )
        )
    }
}

/* ###################################################################################################################################### */
// MARK: - Activity (Share) View -
/* ###################################################################################################################################### */
/**
 Simple wrapper around UIActivityViewController so we can use it from SwiftUI.
 */
struct NACC_ActivityView: UIViewControllerRepresentable {
    /* ############################################################## */
    /**
     The activity items that we're giving to the controller.
     */
    let activityItems: [Any]

    /* ############################################################## */
    /**
     The activities that we're giving to the controller.
     */
    var applicationActivities: [UIActivity] = []

    /* ############################################################## */
    /**
     Returns our various activity sheet items.
     - parameter context: ignored.
     - returns: A general-purpose activity controller, with our items.
     */
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities
        )
    }

    /* ############################################################## */
    /**
     No-Op. Satisfies the protocol.
     */
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

/* ###################################################################################################################################### */
// MARK: - Calendar Event Maker View -
/* ###################################################################################################################################### */
/**
 Ugh. I hate using UIViewControllerRepresentable, but we need it for this.
 
 This is how the Event editor is implemented.
 */
struct NACC_EventEditView: UIViewControllerRepresentable {
    /* ################################################################################################################################## */
    // MARK: This simply controls display of the event add sheet.
    /* ################################################################################################################################## */
    /**
     We need to be able to allow the user to create reminder events, based on the cleandate.
     This handles the wrapped display of the Calendar Entry Edit sheet.
     */
    final class Coordinator: NSObject, EKEventEditViewDelegate {
        /* ############################################################## */
        /**
         The View that contains this wrapper.
         */
        let parent: NACC_EventEditView

        /* ############################################################## */
        /**
         Default initializer. The parent is passed in.
         - parameter inParent: The parent (container) View.
         */
        init(_ inParent: NACC_EventEditView) {
            self.parent = inParent
        }

        /* ############################################################## */
        /**
         The callback, for when the calendar entry edit is complete.
         - parameter inController: The controller for this session.
         - parameter inAction: The action used to complete.
         */
        func eventEditViewController(_ inController: EKEventEditViewController, didCompleteWith inAction: EKEventEditViewAction) {
            inController.dismiss(animated: true) {
                self.parent.onComplete?(inAction)
            }
        }
    }

    /* ################################################################################################################################## */
    // MARK: Identifiable Composition Struct
    /* ################################################################################################################################## */
    /**
     This allows us to treat Event records as identifiable.
     */
    struct EditableEvent: Identifiable {
        /* ############################################################## */
        /**
         This is why we're identifiable.
         */
        let id = UUID()

        /* ############################################################## */
        /**
         The event store that goes with the event.
         We need to hang onto it, because, upon first time called after giving permission, the event store may be different.
         */
        let eventStore: EKEventStore

        /* ############################################################## */
        /**
         The even we want to use as the basis for this calendar entry.
         */
        let event: EKEvent
    }

    /* ################################################################## */
    /**
     The event store that handles the event.
     */
    let eventStore: EKEventStore

    /* ################################################################## */
    /**
     The even we want to make a calendar entry for.
     */
    let event: EKEvent

    /* ################################################################## */
    /**
     The callback, for when we're done.
     */
    var onComplete: ((EKEventEditViewAction) -> Void)?

    /* ################################################################## */
    /**
     This simply instantiates a new coordinator instance
     - returns: A new Coorcinator instance.
     */
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /* ################################################################## */
    /**
     This creates our controller.
     - parameter context: The context for the controller.
     - returns: An event view controller, ready to be shown.
     */
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = self.eventStore
        controller.event = self.event
        controller.editViewDelegate = context.coordinator
        return controller
    }

    /* ################################################################## */
    /**
     This is a NOP function, here to satisfy the type.
     - parameter _: The event (ignored)
     - parameter context: The context (also ignored)
     */
    func updateUIViewController(_: EKEventEditViewController, context: Context) { }
}

/* ###################################################################################################################################### */
// MARK: - Date Picker View -
/* ###################################################################################################################################### */
/**
 This is a view that we use to allow the user to select a new cleandate.
 
 It shows a standard "graphical" date picker (calendar-style), along with a "DONE" button (dismisses the modal).
 
 It shows a a "Today" button (sets the calendar to today), if the selected day is not today.
 
 If the user has changed the date since invoking the screen, a "Reset" button also appears, allowing the user to discard any changes.
 */
struct NACC_PickerPopoverContent: View {
    /* ################################################################## */
    /**
     This is how much padding is given the top title (on iPhone).
     */
    private static let _cleandatePickerTitlePaddingInDisplayUnits = CGFloat(4)

    /* ################################################################## */
    /**
     The spacing to use for VStacks
     */
    private static let _verticalSpacingInDisplayUnits = CGFloat(8)

    /* ################################################################## */
    /**
     The spacing to use for the horizontal axis
     */
    private static let _horizontalSpacingInDisplayUnits = CGFloat(8)

    /* ################################################################## */
    /**
     The minimum width, for popovers.
     */
    private static let _miniumHorizontalWidthInDisplayUnits = CGFloat(400)

    /* ################################################################## */
    /**
     This will have the original date, from when the screen was opened.
     */
    private static var _originalDate: Date?

    /* ################################################################## */
    /**
     We can't start before NA was founded.
     */
    private static let _minimumDate = Calendar.current.date(from: DateComponents(year: 1953, month: 10, day: 5))

    /* ################################################################## */
    /**
     This allows us to dismiss the popover/sheet.
     */
    @Environment(\.dismiss) private var _dismiss

    /* ################################################################## */
    /**
     Binds to the main cleandate storage.
     */
    @Binding var selectedDate: Date

    /* ################################################################## */
    /**
     Set to true, if the screen is being presented in a popover.
     */
    @State var isInPopover: Bool = false
    
    /* ################################################################## */
    /**
     This returns the whole DatePicker screen.
     */
    var body: some View {
        AppBackground {
            if let minimumDate = Self._minimumDate {
                let validDateRange = minimumDate...Date()
                
                VStack(spacing: Self._verticalSpacingInDisplayUnits) {
                    if !self.isInPopover {
                        // Title
                        Text("SLUG-CLEANDATE-PICKER-TITLE".localizedVariant)
                            .font(.largeTitle)
                            .padding(.top, Self._cleandatePickerTitlePaddingInDisplayUnits)
                            .padding(.horizontal, Self._cleandatePickerTitlePaddingInDisplayUnits)
                    }
                    
                    // Graphical if it fits; otherwise wheel
                    ViewThatFits(in: .vertical) {
                        // Preferred: graphical
                        DatePicker("",
                                   selection: self.$selectedDate,
                                   in: validDateRange,
                                   displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                        
                        // Fallback: wheel (more compact)
                        DatePicker("",
                                   selection: self.$selectedDate,
                                   in: validDateRange,
                                   displayedComponents: [.date]
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                    }
                    
                    // Buttons
                    HStack {
                        // We only show today, if we are not at today.
                        if !Calendar.current.isDate(selectedDate, inSameDayAs: .now) {
                            Button("SLUG-TODAY".localizedVariant) {
                                self.selectedDate = Date()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        // We only show reset, if we have changed from the initial date.
                        if let origDate = Self._originalDate,
                           self.selectedDate != origDate {
                            Button("SLUG-RESET".localizedVariant) {
                                self.selectedDate = origDate
                            }
                            .frame(maxWidth: .infinity)
                        }
                        // We always show the dismiss button.
                        Button("SLUG-DONE".localizedVariant) {
                            self._dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, Self._horizontalSpacingInDisplayUnits)
                    .padding(.bottom, Self._verticalSpacingInDisplayUnits)
                }
            }
        }
        .frame(minWidth: isInPopover ? Self._miniumHorizontalWidthInDisplayUnits : nil)
        .onChange(of: self.selectedDate) { _, inNewValue in Self._originalDate = Self._originalDate ?? inNewValue }
        .onAppear {
            guard .now > self.selectedDate else {
                Self._originalDate = nil
                return
            }
            Self._originalDate = self.selectedDate
        }
        .onDisappear { Self._originalDate = nil }
    }
}

/* ###################################################################################################################################### */
// MARK: - Special View Modifier for the Date Picker -
/* ###################################################################################################################################### */
/**
 This ViewModifier will present a body containing our special DatePicker.
 */
struct NACC_AdaptivePickerPresentation: ViewModifier {
    /* ################################################################## */
    /**
     This is used to determine whether or not to present the iPhone sheet as "half-height," or "full-height."
     */
    private static let _screenDetentThresholdInDisplayUnits = CGFloat(900)
    
    /* ################################################################## */
    /**
     Set to true, if we are to be showing.
     */
    @Binding var isPresented: Bool
    
    /* ################################################################## */
    /**
     The date that we are reprsenting/changing.
     */
    @Binding var selectedDate: Date
    
    /* ################################################################## */
    /**
     This returns the detents to use for the modal sheet, containing the DatePicker. Thos only applies to portrait mode.
     */
    private var _screenDetents: Set<PresentationDetent> {
        var ret: Set<PresentationDetent> = [.medium]
        if Self._screenDetentThresholdInDisplayUnits > UIScreen.main.bounds.size.height {
            ret = [.large]
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     This returns the appropriate body for the type of device we're on.
     */
    func body(content: Content) -> some View {
        Group {
            #if os(iOS)
                if UIDevice.current.userInterfaceIdiom == .pad {
                    // iPad: Use a popover
                    content
                        .popover(isPresented: $isPresented) {
                            NACC_PickerPopoverContent(selectedDate: $selectedDate, isInPopover: true)
                        }
                } else {
                    // iPhone: Use a “half-height” sheet with detents
                    content
                        .sheet(isPresented: $isPresented) {
                            NACC_PickerPopoverContent(selectedDate: $selectedDate)
                                .presentationDetents(self._screenDetents)
                                .presentationDragIndicator(.visible)
                        }
                }
            #else
                // fallback for other platforms
                content
                    .popover(isPresented: $isPresented) {
                        PickerPopoverContent(selectedDate: $selectedDate)
                    }
            #endif
        }
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
     This is the string that displays the "cleantime report."
     */
    private let _reportString = LGV_UICleantimeDateReportString()
    
    /* ################################################################## */
    /**
     This is the local instance of the persistent prefs for the app.
     */
    private let _prefs = NACCPersistentPrefs()
    
    /* ################################################################## */
    /**
     This shows a date picker in a modal sheet. If the user taps on the date, they get the sheet.
     */
    private var _calendarIsEnabled: Bool { LGV_CleantimeDateCalc(startDate: self.selectedDate).cleanTime.isOneDayOrMore }
    
    /* ################################################################## */
    /**
     This is set to true, when we want to show the action sheet.
     */
    @State private var _showingActions = false
    
    /* ################################################################## */
    /**
     This is set to true, when we want to show the share sheet.
     */
    @State private var _showingShareSheet = false
    
    /* ################################################################## */
    /**
     These are the items that we'll be sending to the activity sheet.
     */
    @State private var _activityItems: [Any] = []
    
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
     If true, then the event edit was denied permission, and we need to inform the user.
     */
    @State private var _showCalendarAccessAlert = false

    /* ################################################################## */
    /**
     When non-nil, we present the calendar event editor for this event.
     */
    @State private var _eventToEdit: NACC_EventEditView.EditableEvent?

    /* ################################################################## */
    /**
     This handles interaction with the Watch.
     */
    @State private var _watchDelegateObject: NACCWatchAppContentViewWatchDelegate?
    
    /* ################################################################## */
    /**
     This displays the last keytag or medallion earned.
     */
    @State private var _displayedImage: UIImage?
    
    /* ################################################################## */
    /**
     If true, then the NavigationStack will bring in the results screen.
     */
    @Binding var showResult: Bool

    /* ################################################################## */
    /**
     */
    @Binding var selectedTab: NACC_TabIndexes
    
    /* ################################################################## */
    /**
     This contains the cleandate.
     */
    @Binding var selectedDate: Date
    
    /* ################################################################## */
    /**
     Allows us to access the openURL capability.
     */
    @Environment(\.openURL) private var openURL
    
    /* ################################################################## */
    /**
     This returns the contents of the textual report.
     */
    private var _report: String {
        let calculator = LGV_CleantimeDateCalc(startDate: self.selectedDate).cleanTime
        
        if calculator.isOneDayOrMore {
            return self._reportString
                .naCleantimeText(beginDate: self.selectedDate,
                                 endDate: .now
                )?.localizedVariant ?? "ERROR"
        } else {
            return "SLUG-CLEANDATE-PICKER-TITLE".localizedVariant
        }
    }
    
    /* ################################################################## */
    /**
     This returns a URL string, with a universal URL that will open the app to this date, without invoking the report.
     */
    private var _urlString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return String(format: "SLUG-URL-STRING".localizedVariant, dateFormatter.string(from: NACCPersistentPrefs().cleanDate))
    }
    
    /* ################################################################## */
    /**
     Called when the NavBar calendar button is hit.
     We present a custom Calendar Date Entry screen, with a pre-populated state for a yearly repeating all-day event, starting on the cleandate.
     We always use a sheet, becaue it's kind of a "fully modal" screen, and a popover dismisses too easily.
     */
    private func _calendarButtonHit() {
        /* ############################################################## */
        /**
         This creates a new calendar event, based on the event in the stor.
         - parameter inStore: The store for the event we are creating.
         */
        func makeAnniversaryEvent(in inStore: EKEventStore) -> EKEvent? {
            let date = self.selectedDate

            guard let year = Calendar.current.dateComponents([.year], from: date).year else { return nil }

            let event = EKEvent(eventStore: inStore)

            event.startDate = Calendar.current.startOfDay(for: date)
            event.endDate = event.startDate.addingTimeInterval((60 * 60 * 24) - 1) // 23:59:59
            event.title = String(format: "SLUG-CAL-ANNIVERSARY-FORMAT".localizedVariant,
                                 year
            )
            event.isAllDay = true
            event.addRecurrenceRule(
                EKRecurrenceRule(recurrenceWith: .yearly,
                                 interval: 1,
                                 end: nil
                                )
            )
            event.addAlarm(EKAlarm(relativeOffset: 60 * 60 * 9))  // 9 AM

            if let defaultCal = inStore.defaultCalendarForNewEvents {
                event.calendar = defaultCal
            } else if let firstCal = inStore.calendars(for: .event).first {
                event.calendar = firstCal
            } else {
                return nil
            }

            return event
        }

        // Create a fresh store
        let eventStore = EKEventStore()

        eventStore.requestWriteOnlyAccessToEvents { isGranted, inError in
            guard nil == inError,
                  isGranted,
                  let event = makeAnniversaryEvent(in: eventStore)
            else {
                if nil == inError,
                   !isGranted {
                    DispatchQueue.main.async { self._showCalendarAccessAlert = true }
                }
                return
            }

            DispatchQueue.main.async {
                self._eventToEdit = NACC_EventEditView.EditableEvent(eventStore: eventStore,
                                                                event: event
                )
            }
        }
    }
    
    /* ################################################################## */
    /**
     Prepares the items to be shared in the share sheet.
     We add a Report String, Universal URL, and Medallion/Keytag Image.
     */
    private func _prepareActivityItems() {
        var items: [Any] = []

        if let url = URL(string: self._urlString) {
            items.append(url)
        }

        if let image = self._displayedImage {
            items.append(image)
        }

        items.append(self._report)

        self._activityItems = items
    }
    
    /* ################################################################## */
    /**
     Creates the main screen print renderer.
     */
    private func _makePrintRenderer() -> UIPrintPageRenderer? {
        return NACCPagePrintRenderer(report: self._report,
                                     image: self._displayedImage
        )
    }

    /* ################################################################## */
    /**
     Uses a UIPrintPageRenderer to present the standard print UI.
     - parameter inRenderer: The custom renderer we're using.
     */
    private func _print(using inRenderer: UIPrintPageRenderer) {
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .photo
        printInfo.jobName = "Cleantime Report"

        let controller = UIPrintInteractionController.shared
        controller.printInfo = printInfo
        controller.printPageRenderer = inRenderer

        controller.present(animated: true, completionHandler: nil)
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
                    if let appIcon = Bundle.main.appIcon {
                        // This is the top logo. If the user has thirty days or more, tapping on it will bring in the results screen.
                        if LGV_CleantimeDateCalc(startDate: self.selectedDate).cleanTime.isThirtyDaysOrMore {
                            Button {
                                self.selectedTab = .keytagArray
                                self.showResult = true
                            } label: {
                                Image(uiImage: appIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: Self._iconSizeInDisplayUnits)
                                    .cornerRadius(Self._iconSizeInDisplayUnits / 2)
                            }
                            .accessibilityHint("SLUG-ACC-LOGO".localizedVariant)
                        } else {
                            Image(uiImage: appIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Self._iconSizeInDisplayUnits)
                                .cornerRadius(Self._iconSizeInDisplayUnits / 2)
                        }
                        
                        // If the user has not specified a cleandate, this text item displays a message to that effect.
                        if !LGV_CleantimeDateCalc(startDate: self.selectedDate).cleanTime.isOneDayOrMore {
                            Text("SLUG-NO-CLEANDATE-YET".localizedVariant)
                        }
                        
                        // If there has been a cleandate set, the following displays a text item, with the textual report. If no cleandate, then it prompts the user to set one.
                        // Tapping on the report brings up a date picker, allowing the user to set/change the cleandate.
                        // The text is surrounded by a capsule, indicating that it can be tapped. If no date is set, the color of the text is a button color.
                        Text(self._report)
                            .textSelection(.enabled)
                            .padding(Self._buttonPaddingInDisplayUnits)
                            .frame(maxWidth: .infinity,
                                   alignment: .center
                            )
                            .foregroundStyle(!LGV_CleantimeDateCalc(startDate: self.selectedDate).cleanTime.isOneDayOrMore ? Color("SelectionTintColor") : .primary)
                            .background(.thickMaterial,
                                        in: Capsule()
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self._showingPicker = true
                            }
                            ._adaptivePickerPresentation(isPresented: $_showingPicker,
                                                         selectedDate: $selectedDate
                            )
                            .accessibilityAddTraits(.isButton)
                            .accessibilityHint("SLUG-ACC-REPORT-BUTTON".localizedVariant)
                        
                        // If the user has set a cleandate, then the following is an image, with the user's last earned keytag (under a year), or medallion.
                        // If the user has thirty days or more, tapping on the image brings in the results screen.
                        if let image = self._displayedImage {
                            if LGV_CleantimeDateCalc(startDate: self.selectedDate).cleanTime.isThirtyDaysOrMore {
                                Button {
                                    self.selectedTab = LGV_CleantimeDateCalc(startDate: self.selectedDate).cleanTime.isOneYearOrMore ? .medallionArray : .keytagStrip
                                    self.showResult = true
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
                }
                .padding()
                .navigationTitle("SLUG-INITIAL-TITLE".localizedVariant)
                .navigationBarTitleDisplayMode(.inline)
                // Create the various NavBar items.
                .toolbar {
                    // The "Action" button
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            self._prepareActivityItems()
                            self._showingActions = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .accessibilityHint("SLUG-ACC-ACTION-BUTTON".localizedVariant)
                    }
                    // The calendar button (create an event)
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            self._calendarButtonHit()
                        } label: {
                            Image(systemName: "calendar")
                        }
                        .disabled(!self._calendarIsEnabled)
                        .accessibilityHint("SLUG-ACC-CALENDAR-BUTTON".localizedVariant)
                    }
                    // The info screen button
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self._showInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .accessibilityHint("SLUG-ACC-INFO-BUTTON".localizedVariant)
                    }
                }
                // This presents a modal sheet, with an event add screen. We always use a sheet, because the process is quite modal.
                .sheet(item: self.$_eventToEdit) { inEditableEvent in
                    NACC_EventEditView(
                        eventStore: inEditableEvent.eventStore,
                        event: inEditableEvent.event
                    ) { _ in
                        self._eventToEdit = nil
                    }
                }
                // Called when the Calendar does not have permission to add events.
                .alert("SLUR-ERR-CALENDAR-DENY-ALERT-TITLE".localizedVariant,
                       isPresented: $_showCalendarAccessAlert) {
                    Button("SLUR-ERR-CALENDAR-DENY-ALERT-CANCEL".localizedVariant, role: .cancel) { }
                    
                    Button("SLUR-ERR-CALENDAR-DENY-ALERT-SETTINGS".localizedVariant) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                } message: {
                    Text("SLUR-ERR-CALENDAR-DENY-ALERT-MESSAGE".localizedVariant)
                }
                .navigationDestination(isPresented: self.$showResult) { NACC_ResultDisplayView(selectedTab: self.$selectedTab) }
                .navigationDestination(isPresented: self.$_showInfo) { NACC_InfoDisplayView() }
            }
        }
        // When the action button is hit, we ask the user if they want to share, or print.
        .confirmationDialog("SLUG-ACTIONS-TITLE".localizedVariant,
                            isPresented: self.$_showingActions,
                            titleVisibility: .visible) {
            // Share…
            Button("SLUG-ACTIONS-SHARE".localizedVariant) { self._showingShareSheet = true }

            // Print… (only if we can actually print something)
            Button("SLUG-ACTIONS-PRINT".localizedVariant) {
                // Add our custom print renderer.
                if let renderer = self._makePrintRenderer() {
                    self._print(using: renderer)
                }
            }

            Button("SLUG-CANCEL".localizedVariant, role: .cancel) { }
        }
        // If we are shoing the share (activity) sheet, then we set the appropriate state property.
        .sheet(isPresented: self.$_showingShareSheet) {
            NACC_ActivityView(activityItems: self._activityItems)
        }
        .onAppear {
            self._watchDelegateObject = self._watchDelegateObject ?? NACCWatchAppContentViewWatchDelegate(updateHandler: self.updateApplicationContext)
            self.selectedDate = self._prefs.cleanDate
            self._watchDelegateObject?.sendApplicationContext()
            // If we were opened from a URL that specified a tab, then we immediately open the report screen.
            if .undefined != self.selectedTab {
                self.showResult = true
            }
        }
        .onChange(of: self.selectedTab) { _, inNewValue in
            NACCPersistentPrefs().lastSelectedTabIndex = inNewValue.rawValue
        }
        .onChange(of: self.selectedDate) { _, inSelectedDate in
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
            DispatchQueue.main.async { self.selectedDate = cleanDate }
        }
    }
}
