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
// MARK: - Tab Bar Controller -
/* ###################################################################################################################################### */
/**
 This is the tab bar controller. We subclass it, in order to localize, and customize its appearance and behavior.
 */
class NACCTabBarController: UITabBarController {
    /* ################################################################################################################################## */
    // MARK: Tab Index Enum
    /* ################################################################################################################################## */
    /**
     This is used to map the three tabs.
     */
    enum TabIndexes: Int {
        // -1 means undefined
        case undefined = -1
        
        /// The first tab is the keytag array
        case keytagArray
        
        /// The second is a vertical strip of keytags.
        case keytagStrip
        
        /// The last is an array of medallions.
        case medallions
    }
    
    /* ################################################################## */
    /**
     This is the "Action Item" button (share, print, etc.).
    */
    @IBOutlet weak var actionButton: UIBarButtonItem?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension NACCTabBarController {
    /* ################################################################## */
    /**
     Called when the view hierarchy load has been completed.
     We use this to set the tab bar colors, and select the last selected tab.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        if let normalColor = UIColor(named: "SelectionTintColor") {
            let selectedColor = UIColor.label
            var backGroundTabBarColor: UIColor?
            
            if #available(iOS 15.0, *) {
                backGroundTabBarColor = .clear
            } else if let backgroundGradientImage = UIImage(named: "Background-Gradient"),
                      let bottomColor = backgroundGradientImage.getRGBColorOfThePixel(at: CGPoint(x: 0, y: backgroundGradientImage.size.height - 1)) {
                backGroundTabBarColor = bottomColor
            }

            let normalTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: normalColor]
            let selectedTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: selectedColor]

            let appearance = UITabBarAppearance()
            appearance.stackedLayoutAppearance.normal.iconColor = normalColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalTextAttributes
            appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedTextAttributes
            appearance.inlineLayoutAppearance.normal.iconColor = normalColor
            appearance.inlineLayoutAppearance.normal.titleTextAttributes = normalTextAttributes
            appearance.inlineLayoutAppearance.selected.iconColor = selectedColor
            appearance.inlineLayoutAppearance.selected.titleTextAttributes = selectedTextAttributes
            appearance.compactInlineLayoutAppearance.normal.iconColor = normalColor
            appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = normalTextAttributes
            appearance.compactInlineLayoutAppearance.selected.iconColor = selectedColor
            appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = selectedTextAttributes
            appearance.backgroundColor = backGroundTabBarColor

            tabBar.standardAppearance = appearance
            tabBar.itemPositioning = .centered
            tabBar.backgroundColor = backGroundTabBarColor
            tabBar.barTintColor = backGroundTabBarColor
        }

        delegate = self
        let calculator = LGV_CleantimeDateCalc(startDate: NACCPersistentPrefs().cleanDate, calendar: Calendar.current).cleanTime
        
        viewControllers?[TabIndexes.keytagStrip.rawValue].tabBarItem?.isEnabled = 29 < calculator.totalDays
        viewControllers?[TabIndexes.medallions.rawValue].tabBarItem?.isEnabled = 0 < calculator.years

        viewControllers?.forEach {
            if let tabBarItemTitle = $0.tabBarItem?.title?.localizedVariant,
               !tabBarItemTitle.isEmpty {
                $0.tabBarItem?.title = tabBarItemTitle
                $0.accessibilityLabel = "SLUG-ACC-\(tabBarItemTitle)".localizedVariant
            }
        }
        
        let lastSelectedTabIndex = NACCPersistentPrefs().lastSelectedTabIndex
        
        if (0..<(viewControllers?.count ?? 0)).contains(lastSelectedTabIndex),
           viewControllers?[lastSelectedTabIndex].tabBarItem?.isEnabled ?? false {
            selectedViewController = viewControllers?[lastSelectedTabIndex]
        } else if !(viewControllers?.isEmpty ?? true) {
            selectedViewController = viewControllers?[TabIndexes.keytagArray.rawValue]
        }
        
        actionButton?.accessibilityLabel = "SLUG-ACC-TABS-ACTION-BUTTON".localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension NACCTabBarController {
    /* ################################################################## */
    /**
     Called when the action item in the navbar is hit.
     
     - parameter inButton: The action item button.
    */
    @IBAction func actionItemHit(_ inButtonItem: UIBarButtonItem) {
        if let report = NACCAppSceneDelegate.appDelegateInstance?.report,
           let date = NACCAppSceneDelegate.appDelegateInstance?.date,
           let image = (selectedViewController as? NACCTabBaseViewController)?.cleantime?.image {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let url = URL(string: String(format: "SLUG-URL-STRING".localizedVariant, dateFormatter.string(from: date)) + "/\(selectedIndex)")
            let viewController = UIActivityViewController(activityItems: [NACCPagePrintRenderer(report: report, image: image),
                                                                          report,
                                                                          image as Any, url as Any],
                                                          applicationActivities: nil)
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

/* ###################################################################################################################################### */
// MARK: UITabBarControllerDelegate Conformance
/* ###################################################################################################################################### */
extension NACCTabBarController: UITabBarControllerDelegate {
    /* ################################################################## */
    /**
     This is called when a new tab is selected. We use it to save the last selected tab in our persistent prefs.
     - parameter inTabBarController: The tab bar controller.
     - parameter didSelect: The selected View Controller.
     */
    func tabBarController(_ inTabBarController: UITabBarController, didSelect inViewController: UIViewController) {
        NACCPersistentPrefs().lastSelectedTabIndex = selectedIndex
    }
}
