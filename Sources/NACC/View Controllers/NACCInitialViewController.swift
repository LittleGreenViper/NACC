/*
 © Copyright 2022, Little Green Viper Software Development LLC
 
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
    // MARK: Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This stores the original logo height
    */
    var originalLogoHeight = CGFloat(0)
    
    /* ################################################################## */
    /**
     This will contain the cleantime display for this screen. We set it at runtime.
    */
    var cleantimeDisplayView: LGV_UICleantimeImageViewBase?
    
    /* ################################################################################################################################## */
    // MARK: Instance IBOutlet Properties
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
     - parameter tabIndex: The tab index to choose. This is optional. If not specified, we open on tab 0.
    */
    func setDate(_ inDate: Date? = nil, tabIndex inTabIndex: NACCTabBarController.TabIndexes? = nil) {
        if let dateSelector = dateSelector,
           let minDate = dateSelector.minimumDate {
            NACCPersistentPrefs().lastSelectedTabIndex = inTabIndex?.rawValue ?? NACCPersistentPrefs().lastSelectedTabIndex
            let newDateValue = inDate ??  NACCPersistentPrefs().cleanDate
            if (minDate...Date()).contains(newDateValue) {
                dateSelector.date = newDateValue
                newDate(dateSelector)
            
                if nil != inDate {
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
            cleantimeDisplayView?.alpha = 0
            view.layoutIfNeeded()
            UIView.animate(withDuration: Self._fadeAnimationPeriod, animations: { [weak self] in
                                                                                    startupLogo.alpha = 0.0
                                                                                    self?.actionButton?.customView?.alpha = 1.0
                                                                                    self?.infoButton?.customView?.alpha = 1.0
                                                                                    self?.logoContainerView?.alpha = 1.0
                                                                                    self?.dateSelector?.alpha = 1.0
                                                                                    self?.cleantimeReportLabel?.alpha = 1.0
                                                                                    self?.cleantimeDisplayView?.alpha = 1.0
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
        dateSelector?.maximumDate = Date()
        originalLogoHeight = logoHeightConstraint?.constant ?? 0
        dateSelector?.accessibilityLabel = "SLUG-ACC-DATEPICKER".localizedVariant
        logoContainerView?.accessibilityLabel = "SLUG-ACC-LOGO".localizedVariant
        actionButton?.accessibilityLabel = "SLUG-ACC-ACTION-BUTTON".localizedVariant
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
                    logoHeightConstraint?.constant = originalLogoHeight
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
     When a new date is selected, we generate a new report.
     
     - parameter inDatePicker: The picker instance.
    */
    @IBAction func newDate(_ inDatePicker: UIDatePicker!) {
        cleantimeDisplayView?.removeFromSuperview()
        cleantimeDisplayView = nil
        guard let datePicker = inDatePicker else { return }
        NACCPersistentPrefs().cleanDate = datePicker.date
        if let text = LGV_UICleantimeDateReportString().naCleantimeText(beginDate: datePicker.date, endDate: Date(), calendar: Calendar.current) {
            NACCAppSceneDelegate.appDelegateInstance?.report = text
            cleantimeReportLabel?.text = text
        }
        
        let calculator = LGV_CleantimeDateCalc(startDate: datePicker.date, calendar: Calendar.current).cleanTime
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
            if 0 < calculator.years {
                cleantimeDisplayView = LGV_UISingleCleantimeMedallionImageView()
            } else {
                cleantimeDisplayView = LGV_UISingleCleantimeKeytagImageView()
            }
            
            guard let cleantimeDisplayView = cleantimeDisplayView,
                  let cleantimeViewContainer = cleantimeViewContainer
            else { return }
            
            cleantimeDisplayView.translatesAutoresizingMaskIntoConstraints = false
            cleantimeViewContainer.addSubview(cleantimeDisplayView)
            cleantimeDisplayView.centerXAnchor.constraint(equalTo: cleantimeViewContainer.centerXAnchor).isActive = true
            cleantimeDisplayView.centerYAnchor.constraint(equalTo: cleantimeViewContainer.centerYAnchor).isActive = true
            cleantimeDisplayView.widthAnchor.constraint(lessThanOrEqualTo: cleantimeViewContainer.widthAnchor, multiplier: Self._tagSizeCoefficient).isActive = true
            cleantimeDisplayView.heightAnchor.constraint(lessThanOrEqualTo: cleantimeViewContainer.heightAnchor, multiplier: Self._tagSizeCoefficient).isActive = true
            
            cleantimeDisplayView.totalDays = calculator.totalDays
            cleantimeDisplayView.totalMonths = calculator.totalMonths
            cleantimeDisplayView.contentMode = .scaleAspectFit
            cleantimeDisplayView.setNeedsLayout()
        } else {
            actionButton?.isEnabled = false
        }
   }
    
    /* ################################################################## */
    /**
     Called when the action item in the navbar is hit.
     
     - parameter inButton: The action item button.
    */
    @IBAction func actionItemHit(_ inButtonItem: UIBarButtonItem) {
        if let report = NACCAppSceneDelegate.appDelegateInstance?.report {
            let printRenderer = NACCPagePrintRenderer(report: cleantimeReportLabel?.text ?? "ERROR", image: cleantimeDisplayView?.image)
            let imageAsAny = cleantimeDisplayView?.image as Any
            let viewController = UIActivityViewController(activityItems: [printRenderer, report, imageAsAny], applicationActivities: nil)
            
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
}
