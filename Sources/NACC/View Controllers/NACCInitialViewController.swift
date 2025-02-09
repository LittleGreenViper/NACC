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

import UIKit
import RVS_Generic_Swift_Toolbox
import LGV_Cleantime
import LGV_UICleantime
import EventKit
import EventKitUI
import WatchConnectivity

/* ###################################################################################################################################### */
// MARK: - Initial View Controller -
/* ###################################################################################################################################### */
/**
 This screen displays the date selector, and the textual cleantime report.
 This is the first screen to be shown.
 */
class NACCInitialViewController: NACCBaseViewController {
    /* ################################################################################################################################## */
    // MARK: Private Static Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This has the minimal screen height for viewing the logo.
    */
    private static let _minimumScreenHeight = CGFloat(400)
    
    /* ############################################################## */
    /**
     The sizing coefficient to use. This compares against the screen size (center image "watermark").
     */
    private static let _tagSizeCoefficient = CGFloat(0.6)
    
    /* ################################################################## */
    /**
     The period that we use for the "fade in" animation.
    */
    private static let _fadeAnimationPeriod = CGFloat(1.0)
    
    /* ################################################################## */
    /**
     The ID of a segue to show the tabs.
    */
    private static let _cleandateDisplaySegueID = "display-cleantime"
    
    /* ################################################################################################################################## */
    // MARK: Private Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This will allow us to add events to the Calendar, without leaving this app.
     */
    private let _eventStore = EKEventStore()

    /* ################################################################## */
    /**
     This holds the WatchKit session.
     */
    private let _wcSession = WCSession.default

    /* ################################################################## */
    /**
     This stores the original logo height
    */
    private var _originalLogoHeight = CGFloat(0)
    
    /* ################################################################## */
    /**
     This will contain the cleantime display for this screen. We set it at runtime.
    */
    private var _cleantimeDisplayView: LGV_UICleantimeImageViewBase?

    /* ################################################################################################################################## */
    // MARK: Internal Instance IBOutlet Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This allows the tester to select a date.
    */
    @IBOutlet weak var dateSelector: UIDatePicker?
    
    /* ################################################################## */
    /**
     This displays a textual representation of the cleantime.
    */
    @IBOutlet weak var cleantimeReportLabel: UILabel?
    
    /* ################################################################## */
    /**
     This is where the cleantime view is shown, and centers it.
    */
    @IBOutlet weak var cleantimeViewContainer: UIView?
    
    /* ################################################################## */
    /**
     This button brings in the info screen.
    */
    @IBOutlet weak var infoButton: UIBarButtonItem?
    
    /* ################################################################## */
    /**
     This button allows us to create calendar events.
    */
    @IBOutlet weak var calendarButton: UIBarButtonItem?
    
    /* ################################################################## */
    /**
     This is a container view for the logo, at the top of the screen.
    */
    @IBOutlet weak var logoContainerView: UIView?
    
    /* ################################################################## */
    /**
     This is a switched-off constraint that collapses the medallion/keytag view, when the screen is a shorty.
    */
   @IBOutlet weak var cleantimeDisplayHeightConstraint: NSLayoutConstraint?
    
    /* ################################################################## */
    /**
     This does the same for the logo (but we use the constant, so it animates better).
    */
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint?
    
    /* ################################################################## */
    /**
     This is the "Action Item" button (share, print, etc.).
    */
    @IBOutlet weak var actionButton: UIBarButtonItem?
    
    /* ################################################################## */
    /**
     The "startup" logo that we fade out.
    */
    @IBOutlet weak var startupLogo: UIImageView?
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension NACCInitialViewController {
    /* ################################################################## */
    /**
     Sets the date, first time through.
     
     If we pass in a date, then we ignore the prefs.
     
     - parameter inDate: The date to set. It's optional. Don't specify it to use the prefs.
     - parameter tabIndex: The tab index to choose. This is optional. If not specified, we do not open a tab.
    */
    func setDate(_ inDate: Date? = nil, tabIndex inTabIndex: NACCTabBarController.TabIndexes? = nil) {
        if let dateSelector = dateSelector,
           let minDate = dateSelector.minimumDate {
            let newDateValue = inDate ?? NACCPersistentPrefs().cleanDate
            if (minDate...Date()).contains(newDateValue) {
                dateSelector.date = newDateValue
                newDate()
                navigationController?.popToRootViewController(animated: false)
                if let tabIndex = inTabIndex,
                   .undefined != tabIndex {  // We only open to a tab, if it was explicitly requested, by indicating a tab number.
                    NACCPersistentPrefs().lastSelectedTabIndex = tabIndex.rawValue
                    performSegue(withIdentifier: Self._cleandateDisplaySegueID, sender: nil)
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     This handles the "fade in" animation. This only happens, the first time.
     */
    func fadeInAnimation() {
        view.layoutIfNeeded()
        if let startupLogo = startupLogo {
            startupLogo.alpha = 1.0
            logoContainerView?.alpha = 0.0
            dateSelector?.alpha = 0.0
            cleantimeReportLabel?.alpha = 0.0
            infoButton?.customView?.alpha = 0.0
            actionButton?.customView?.alpha = 0.0
            calendarButton?.customView?.alpha = 0.0
            _cleantimeDisplayView?.alpha = 0
            view.layoutIfNeeded()
            UIView.animate(withDuration: Self._fadeAnimationPeriod, animations: { [weak self] in
                                                                                    startupLogo.alpha = 0.0
                                                                                    self?.actionButton?.customView?.alpha = 1.0
                                                                                    self?.calendarButton?.customView?.alpha = 1.0
                                                                                    self?.infoButton?.customView?.alpha = 1.0
                                                                                    self?.logoContainerView?.alpha = 1.0
                                                                                    self?.dateSelector?.alpha = 1.0
                                                                                    self?.cleantimeReportLabel?.alpha = 1.0
                                                                                    self?._cleantimeDisplayView?.alpha = 1.0
                                                                                    self?.view.layoutIfNeeded()
                                                                                },
                           completion: { [weak self] _ in
                                            DispatchQueue.main.async {
                                                startupLogo.removeFromSuperview()
                                                self?.startupLogo = nil
                                            }
                            }
            )
        }
    }
    
    /* ################################################################## */
    /**
     Forces a recalculation
    */
    func updateScreen() {
        if let tab = NACCTabBarController.TabIndexes(rawValue: NACCPersistentPrefs().lastSelectedTabIndex) {
            setDate(NACCPersistentPrefs().cleanDate, tabIndex: tab)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension NACCInitialViewController {
    /* ################################################################## */
    /**
     Called when the view hierarchy has been completed.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        _wcSession.delegate = self
        _originalLogoHeight = logoHeightConstraint?.constant ?? 0
        dateSelector?.accessibilityLabel = "SLUG-ACC-DATEPICKER".localizedVariant
        logoContainerView?.accessibilityLabel = "SLUG-ACC-LOGO".localizedVariant
        actionButton?.accessibilityLabel = "SLUG-ACC-ACTION-BUTTON".localizedVariant
        calendarButton?.accessibilityLabel = "SLUG-ACC-CALENDAR-BUTTON".localizedVariant
        infoButton?.accessibilityLabel = "SLUG-ACC-INFO-BUTTON".localizedVariant
        cleantimeReportLabel?.accessibilityLabel = "SLUG-ACC-REPORT-BUTTON".localizedVariant
        cleantimeViewContainer?.accessibilityLabel = "SLUG-ACC-IMAGE".localizedVariant
    }
    
    /* ################################################################## */
    /**
     Called just before the view appears. We use it to set the date picker date.
     
     - parameter inIsAnimated: True, if the appearance is to be animated.
    */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        super.viewWillAppear(inIsAnimated)
        navigationController?.navigationBar.isHidden = false    // Just in case...
        if inIsAnimated {
            fadeInAnimation()
        } else {
            startupLogo?.removeFromSuperview()  // Should never happen, but what the hell...
            startupLogo = nil
        }
        setDate()
    }
    
    /* ################################################################## */
    /**
     Called just after the view appears. We use it to send the Watch sync.
     
     - parameter inIsAnimated: True, if the appearance is to be animated.
    */
    override func viewDidAppear(_ inIsAnimated: Bool) {
        super.viewDidAppear(inIsAnimated)
        _wcSession.activate()
    }

    /* ################################################################## */
    /**
     Called when the subviews have been arranged.
    */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let view = view {
            if 0 < view.bounds.size.height {
                if Self._minimumScreenHeight > view.bounds.size.height {
                    cleantimeDisplayHeightConstraint?.isActive = true
                    logoHeightConstraint?.constant = 0
                } else {
                    cleantimeDisplayHeightConstraint?.isActive = false
                    logoHeightConstraint?.constant = _originalLogoHeight
                }
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension NACCInitialViewController {
    /* ################################################################## */
    /**
     If the report text is hit, we open to whatever tab was last selected.
     
     - parameter: ignored
    */
    @IBAction func textHit(_: Any) {
        performSegue(withIdentifier: Self._cleandateDisplaySegueID, sender: nil)
    }
    
    /* ################################################################## */
    /**
     If the logo is hit, we open to the keytag array tab
     
     - parameter: ignored
    */
    @IBAction func logoImageHit(_: Any) {
        NACCPersistentPrefs().lastSelectedTabIndex = NACCTabBarController.TabIndexes.keytagArray.rawValue
        performSegue(withIdentifier: Self._cleandateDisplaySegueID, sender: nil)
    }
    
    /* ################################################################## */
    /**
     If the medallion/keytag is hit, we open to medallions, if over a year, keytag array, otherwise.
     
     - parameter: ignored
    */
    @IBAction func medallionImageHit(_: Any) {
        guard let date = dateSelector?.date else { return }
        NACCPersistentPrefs().lastSelectedTabIndex = 0 < LGV_CleantimeDateCalc(startDate: date, calendar: Calendar.current).cleanTime.years
                                                        ? NACCTabBarController.TabIndexes.medallions.rawValue
                                                        : NACCTabBarController.TabIndexes.keytagArray.rawValue
        performSegue(withIdentifier: Self._cleandateDisplaySegueID, sender: nil)
    }
    
    /* ################################################################## */
    /**
     When a new date is selected, we generate a new report.
     
     - parameter inDatePicker: The picker instance. This can be ignored (in which case we try the date selector).
    */
    @IBAction func newDate(_ inDatePicker: UIDatePicker! = nil) {
        NACCAppSceneDelegate.appDelegateInstance?.date = inDatePicker?.date ?? dateSelector?.date ?? NACCPersistentPrefs().cleanDate
        
        // If this actually came from the date selector changing (as opposed to the screen being initialized), we clear the stored prefs.
        if nil != inDatePicker {
            NACCAppSceneDelegate.appDelegateInstance?.clearOriginalPrefs()
        }
        
        if let date = NACCAppSceneDelegate.appDelegateInstance?.date {
            _cleantimeDisplayView?.removeFromSuperview()
            _cleantimeDisplayView = nil

            NACCPersistentPrefs().cleanDate = date
            
            if let text = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: date, endDate: Date(), calendar: Calendar.current) {
                NACCAppSceneDelegate.appDelegateInstance?.report = text
                cleantimeReportLabel?.text = text
            }
            
            // The text is set to the action color, if it is selectable (valid date).
            let calculator = LGV_CleantimeDateCalc(startDate: date, calendar: Calendar.current).cleanTime
            if 0 < calculator.totalDays {
                logoContainerView?.isUserInteractionEnabled = true
                cleantimeViewContainer?.isUserInteractionEnabled = true
                cleantimeReportLabel?.isUserInteractionEnabled = true
                cleantimeReportLabel?.textColor = UIColor(named: "SelectionTintColor")
            } else {
                logoContainerView?.isUserInteractionEnabled = false
                cleantimeViewContainer?.isUserInteractionEnabled = false
                cleantimeReportLabel?.isUserInteractionEnabled = false
                cleantimeReportLabel?.textColor = .label
            }
            
            // Have to have at least one day, for a tag.
            if 0 < calculator.totalDays {
                actionButton?.isEnabled = true
                calendarButton?.isEnabled = true
                if 0 < calculator.years {
                    _cleantimeDisplayView = LGV_UISingleCleantimeMedallionImageView()
                } else {
                    _cleantimeDisplayView = LGV_UISingleCleantimeKeytagImageView()
                }
                
                guard let cleantimeDisplayView = _cleantimeDisplayView,
                      let cleantimeViewContainer = cleantimeViewContainer
                else { return }
                
                cleantimeDisplayView.translatesAutoresizingMaskIntoConstraints = false
                cleantimeViewContainer.addSubview(cleantimeDisplayView)
                cleantimeDisplayView.centerXAnchor.constraint(equalTo: cleantimeViewContainer.centerXAnchor).isActive = true
                cleantimeDisplayView.centerYAnchor.constraint(equalTo: cleantimeViewContainer.centerYAnchor).isActive = true
                cleantimeDisplayView.widthAnchor.constraint(lessThanOrEqualTo: cleantimeViewContainer.widthAnchor,
                                                            multiplier: Self._tagSizeCoefficient).isActive = true
                cleantimeDisplayView.heightAnchor.constraint(lessThanOrEqualTo: cleantimeViewContainer.heightAnchor,
                                                             multiplier: Self._tagSizeCoefficient).isActive = true
                
                cleantimeDisplayView.totalDays = calculator.totalDays
                cleantimeDisplayView.totalMonths = calculator.totalMonths
                cleantimeDisplayView.contentMode = .scaleAspectFit
                cleantimeDisplayView.setNeedsLayout()
            } else {
                actionButton?.isEnabled = false
                calendarButton?.isEnabled = false
            }
        }
   }
    
    /* ################################################################## */
    /**
     Called when the action item in the navbar is hit.
     
     - parameter inButton: The action item button.
    */
    @IBAction func actionItemHit(_ inButtonItem: UIBarButtonItem) {
        if let date = dateSelector?.date,
           let report = NACCAppSceneDelegate.appDelegateInstance?.report {
            let printRenderer = NACCPagePrintRenderer(report: cleantimeReportLabel?.text ?? "ERROR", image: _cleantimeDisplayView?.image)
            let image = _cleantimeDisplayView?.image
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let url = URL(string: String(format: "SLUG-URL-STRING".localizedVariant, dateFormatter.string(from: date)))
            let viewController = UIActivityViewController(activityItems: [printRenderer, report, image as Any, url as Any], applicationActivities: nil)
            
            if .pad == traitCollection.userInterfaceIdiom,
               let size = view?.bounds.size {
                viewController.modalPresentationStyle = .popover
                viewController.preferredContentSize = CGSize(width: size.width, height: size.height)
                viewController.popoverPresentationController?.barButtonItem = inButtonItem
                viewController.popoverPresentationController?.permittedArrowDirections = [.up]
            }

            present(viewController, animated: true, completion: nil)
        }
    }

    /* ################################################################## */
    /**
     Called when the calendar button is hit.
     
     - parameter: ignored.
    */
    @IBAction func calendarButtonHit(_: UIBarButtonItem) {
        /* ################################################################## */
        /**
         This creates a recurring event for the anniversary.
         
         - returns: a new EKEvent for the anniversary, or nil.
         */
        func makeAnniversaryEvent() -> EKEvent? {
            guard let date = dateSelector?.date,
                  let year = Calendar.current.dateComponents([.year], from: date).year
            else { return nil }
            
            let event = EKEvent(eventStore: _eventStore)
            event.startDate = Calendar.current.startOfDay(for: date)
            event.endDate = event.startDate.addingTimeInterval((60 * 60 * 24) - 1) // A full 23:59:59 hours, makes a day.
            event.title = String(format: "SLUG-CAL-ANNIVERSARY".localizedVariant, year)
            event.isAllDay = true
            event.addRecurrenceRule(EKRecurrenceRule(recurrenceWith: .yearly, interval: 1, end: nil))
            event.addAlarm(EKAlarm(relativeOffset: (60 * 60 * 9)))  // Adds an extra alarm for the date, itself, at 9AM.
            return event
        }
        
        _eventStore.requestFullAccessToEvents { (inIsGranted, inError) in
                DispatchQueue.main.async { [weak self] in
                    guard nil == inError,
                          inIsGranted,
                          let self = self,
                          let event = makeAnniversaryEvent()
                    else { return }

                    let eventController = EKEventEditViewController()
                    eventController.event = event
                    eventController.eventStore = self._eventStore
                    eventController.editViewDelegate = self
                    
                    if .pad == self.traitCollection.userInterfaceIdiom {
                        eventController.modalPresentationStyle = .popover
                        eventController.popoverPresentationController?.barButtonItem = self.calendarButton
                        eventController.popoverPresentationController?.permittedArrowDirections = [.up]
                    }
                    
                    self.present(eventController, animated: true, completion: nil)
                }
            }
    }
}

/* ###################################################################################################################################### */
// MARK: EKEventEditViewDelegate Conformance
/* ###################################################################################################################################### */
extension NACCInitialViewController: EKEventEditViewDelegate {
    /* ################################################################## */
    /**
     Called when the even kit has completed with an action to add the reminder to the calendar.
     
     - parameter inController: The controller we're talking about.
     - parameter didCompleteWith: The even action that completed.
     */
    func eventEditViewController(_ inController: EKEventEditViewController, didCompleteWith inAction: EKEventEditViewAction) {
        inController.dismiss(animated: true, completion: nil)
    }
}

/* ###################################################################################################################################### */
// MARK: WCSessionDelegate Conformance
/* ###################################################################################################################################### */
extension NACCInitialViewController: WCSessionDelegate {
    /* ################################################################## */
    /**
     Just here to satisfy the protocol.
     */
    func sessionDidBecomeInactive(_: WCSession) { }
    
    /* ################################################################## */
    /**
     Just here to satisfy the protocol.
     */
    func sessionDidDeactivate(_: WCSession) { }

    /* ################################################################## */
    /**
     Called when an activation change occurs.
     
     - parameter inSession: The session experiencing the activation change.
     - parameter activationDidCompleteWith: The new state.
     - parameter error: If there was an error, it is sent in here.
     */
    public func session(_ inSession: WCSession, activationDidCompleteWith inActivationState: WCSessionActivationState, error inError: Error?) {
        if nil == inError,
           .activated == inActivationState {
            #if DEBUG
                print("Watch Session Active.")
            #endif
            DispatchQueue.main.async {
                do {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    var contextData: [String: Any] = ["cleanDate": dateFormatter.string(from: NACCPersistentPrefs().cleanDate),
                                                      "watchAppDisplayState": NACCPersistentPrefs().watchAppDisplayState.rawValue
                    ]
                    #if DEBUG
                        contextData["makeMeUnique"] = UUID().uuidString // This forces the update to occur (if not, it is cached).
                    #endif
                    try inSession.updateApplicationContext(contextData)
                } catch {
                    print("ERROR: \(error)")
                }
            }
        } else if let error = inError {
            print("ERROR: \(error.localizedDescription)")
        }
    }
    
    /* ############################################################## */
    /**
     Called when the application context is updated from the peer.
     
     - parameter inSession: The session receiving the context update.
     - parameter didReceiveApplicationContext: The new context data.
     */
    func session(_ inSession: WCSession, didReceiveApplicationContext inApplicationContext: [String: Any]) {
        #if DEBUG
            print("iOS App Received Context Update: \(inApplicationContext)")
        #endif
        if let cleanDateTemp = inApplicationContext["cleanDate"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            NACCPersistentPrefs().cleanDate = dateFormatter.date(from: cleanDateTemp) ?? .now
        }
        
        if let watchFormatTemp = inApplicationContext["watchAppDisplayState"] as? Int {
            NACCPersistentPrefs().watchAppDisplayState = NACCPersistentPrefs.MainWatchState(rawValue: watchFormatTemp) ?? .medallion
        }
        
        DispatchQueue.main.async {
            self.setDate(NACCPersistentPrefs().cleanDate)
        }
    }
}
