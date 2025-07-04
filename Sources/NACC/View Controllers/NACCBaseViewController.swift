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

/* ###################################################################################################################################### */
// MARK: - Base Class View Controller -
/* ###################################################################################################################################### */
/**
 This is a base class that provides a background gradient, and "watermark" image.
 It should be the base for all screens.
 */
class NACCBaseViewController: UIViewController {
    /* ############################################################## */
    /**
     The alpha to use for normal contrast (center image "watermark").
     */
    private static let _watermarkAlpha = CGFloat(0.015)
    
    /* ############################################################## */
    /**
     The sizing coefficient to use. This compares against the screen size (center image "watermark").
     */
    private static let _watermarkSizeCoefficient = CGFloat(0.6)
    
    /* ############################################################## */
    /**
     This can be overloaded or set, to provide the image to be used as a background gradient.
     */
    private var _backgroundGradientImage: UIImage? = UIImage(named: "Background-Gradient")
    
    /* ############################################################## */
    /**
     This can be overloaded or set, to provide the image to be used as a "watermark."
     */
    private var _watermarkImage: UIImage? = UIImage(named: "CenterImage")
    
    /* ################################################################## */
    /**
     This is the background image view.
     */
    private var _myBackgroundGradientView: UIImageView?
    
    /* ################################################################## */
    /**
     This is the background center image view.
     */
    private var _myCenterImageView: UIImageView?
    
    /* ################################################################## */
    /**
     This is set to the tab index for the page.
     */
    var myTabIndex: NACCTabBarController.TabIndexes = .undefined
}

/* ###################################################################################################################################### */
// MARK: Instance Methods
/* ###################################################################################################################################### */
extension NACCBaseViewController {
    /* ################################################################## */
    /**
     This creates a user activity for the given cleandate (as components).
     
     - parameter for: The cleandate (as date components).
     - parameter with: The tab index of the page calling this.
     */
    func activateActivity(for inCleandate: DateComponents, with inTabIndex: NACCTabBarController.TabIndexes = .undefined) {
        self.userActivity = NSUserActivity(activityType: NACCAppSceneDelegate.displayCleantimeID)
        let title = "SLUG-DISPLAY-CLEANTIME-ACTIVITY-TITLE".localizedVariant
        self.userActivity?.title = title
        let stringData = String(format: "%04d-%02d-%02d", inCleandate.year ?? 0, inCleandate.month ?? 0, inCleandate.day ?? 0)
        var userInfo: [String: String] = [NACCAppSceneDelegate.cleanDateUserDataID: stringData]
        if .undefined != inTabIndex {
            userInfo[NACCAppSceneDelegate.selectedTabUserDataID] = String(inTabIndex.rawValue)
        }
        self.userActivity?.userInfo = userInfo
        self.userActivity?.isEligibleForPrediction = true
        self.userActivity?.persistentIdentifier = String(inCleandate.hashValue)
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension NACCBaseViewController {
    /* ################################################################## */
    /**
     Called when the view hierarchy has been completed.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBarItemTitle = self.tabBarItem?.title?.localizedVariant,
           !tabBarItemTitle.isEmpty {
            self.tabBarController?.navigationItem.title = tabBarItemTitle
        } else {
            self.navigationItem.title = (navigationItem.title ?? "ERROR").localizedVariant
        }

        if let view = self.view {
            self._myBackgroundGradientView = UIImageView()
            if let backgroundGradientView = self._myBackgroundGradientView,
               let backGroundImage = self._backgroundGradientImage {
                backgroundGradientView.image = backGroundImage
                backgroundGradientView.translatesAutoresizingMaskIntoConstraints = false
                backgroundGradientView.contentMode = .scaleToFill
                view.insertSubview(backgroundGradientView, at: 0)
                
                backgroundGradientView.translatesAutoresizingMaskIntoConstraints = false
                backgroundGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                backgroundGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                backgroundGradientView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                backgroundGradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                
                // No watermark for high contrast or reduced transparency mode.
                if !self.isHighContrastMode,
                   !self.isReducedTransparencyMode {
                    self._myCenterImageView = UIImageView()
                    if let centerImageView = self._myCenterImageView,
                       let centerImage = self._watermarkImage {
                        centerImageView.image = centerImage
                        centerImageView.alpha = Self._watermarkAlpha
                        centerImageView.translatesAutoresizingMaskIntoConstraints = false
                        centerImageView.contentMode = .scaleAspectFit
                        centerImageView.tintColor = .label
                        backgroundGradientView.insertSubview(centerImageView, at: 1)

                        centerImageView.centerXAnchor.constraint(equalTo: backgroundGradientView.centerXAnchor).isActive = true
                        centerImageView.centerYAnchor.constraint(equalTo: backgroundGradientView.centerYAnchor).isActive = true
                        
                        centerImageView.widthAnchor.constraint(lessThanOrEqualTo: backgroundGradientView.widthAnchor,
                                                               multiplier: Self._watermarkSizeCoefficient).isActive = true
                        centerImageView.heightAnchor.constraint(lessThanOrEqualTo: backgroundGradientView.heightAnchor,
                                                                multiplier: Self._watermarkSizeCoefficient).isActive = true

                        if let aspectConstraint = centerImageView.autoLayoutAspectConstraint(aspectRatio: 1.0) {
                            aspectConstraint.isActive = true
                            backgroundGradientView.addConstraint(aspectConstraint)
                        }
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called just after the view appears. We use it to create a user activity.
     
     - parameter inIsAnimated: True, if the appearance is to be animated.
    */
    override func viewDidAppear(_ inIsAnimated: Bool) {
        super.viewDidAppear(inIsAnimated)
        self.activateActivity(for: Calendar.current.dateComponents([.year, .month, .day], from: NACCPersistentPrefs().cleanDate))
    }
}
