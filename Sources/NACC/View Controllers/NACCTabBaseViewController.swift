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
import LGV_Cleantime
import LGV_UICleantime
import RVS_GeneralObserver
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - Cleantime Display View Controller -
/* ###################################################################################################################################### */
/**
 This screen is used for the three cleantime displays.
 */
class NACCTabBaseViewController: NACCBaseViewController {
    /* ################################################################################################################################## */
    // MARK: Private Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################################################################################## */
    // MARK: LGV_UICleantimeImageViewObserver Conformance (Need to be in the main declaration)
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This is a UUID that is used internally
     */
    var uuid = UUID()

    /* ############################################################## */
    /**
     This stores our subscriptions.
     */
    var subscriptions: [RVS_GeneralObservableProtocol] = []

    /* ################################################################################################################################## */
    // MARK: Internal Instance IBOutlet Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     The scroller that holds the display.
    */
    @IBOutlet var scrollView: UIScrollView?
    
    /* ################################################################## */
    /**
     This is the cleantime keytag or medallion image.
    */
    @IBOutlet var cleantime: LGV_UICleantimeImageViewBase?

    /* ################################################################## */
    /**
     This will be a "busy throbber," while the images are being composited.
    */
    @IBOutlet weak var throbber: UIActivityIndicatorView?
}

/* ###################################################################################################################################### */
// MARK: Private Instance Methods
/* ###################################################################################################################################### */
extension NACCTabBaseViewController {
    /* ################################################################## */
    /**
     This will show a "busy throbber," while the images are being composited.
    */
    private func _showThrobber() {
        navigationController?.isNavigationBarHidden = true
        self.throbber?.isHidden = false
        self.cleantime?.isHidden = true
    }
    
    /* ################################################################## */
    /**
     This will hide the "busy throbber," after the images were composited.
    */
    private func _hideThrobber() {
        navigationController?.isNavigationBarHidden = false
        self.throbber?.isHidden = true
        self.cleantime?.isHidden = false
    }
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension NACCTabBaseViewController {
    /* ################################################################## */
    /**
     Called when the view hierarchy has been completed.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self._showThrobber()
        self.cleantime?.subscribe(self)
        let calculator = LGV_CleantimeDateCalc(startDate: NACCPersistentPrefs().cleanDate, calendar: Calendar.current).cleanTime
        self.cleantime?.totalDays = calculator.totalDays
        self.cleantime?.totalMonths = calculator.totalMonths
        self.cleantime?.setNeedsLayout()
        self.scrollView?.accessibilityLabel = "SLUG-ACC-SCROLLVIEW".localizedVariant
    }
    
    /* ################################################################## */
    /**
     Called just before the view appears. We use it to set the date picker date.
     
     - parameter inIsAnimated: True, if the appearance is to be animated.
    */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        super.viewWillAppear(inIsAnimated)
        self.tabBarController?.navigationItem.title = tabBarItem.title
        self.scrollView?.zoomScale = 1.0
        
        // Just in case we show up, and everything is hidden...
        if !(self.windowInterfaceOrientation?.isLandscape ?? false) {
            self.tabBarController?.tabBar.isHidden = false
            self.navigationController?.navigationBar.isHidden = false
        }
    }
    
    /* ################################################################## */
    /**
     This was inspired by [this SO answer](https://stackoverflow.com/a/60577486/879365).
     
     We intercept a transition from portrait to landscape, and hide the navbar and tab bar, for phones. This gives the entire screen to the display.
     If the transition is going the other way, this ensures that the tab and nav bars are shown.
     This will only happen, when starting from portrait, and going into landscape. Otherwise, the bars are always shown.
     
     - parameter to: The trait collection at the end of the transition.
     - parameter with: The object that is coordinating the transition.
    */
    override func willTransition(to inNewCollection: UITraitCollection, with inCoordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: inNewCollection, with: inCoordinator)
        
        inCoordinator.animate { _ in
            guard .phone == self.traitCollection.userInterfaceIdiom,
                  let windowInterfaceOrientation = self.windowInterfaceOrientation
            else { return }
            
            if windowInterfaceOrientation.isLandscape {
                self.tabBarController?.tabBar.isHidden = true
                self.navigationController?.navigationBar.isHidden = true
            } else {
                self.tabBarController?.tabBar.isHidden = false
                self.navigationController?.navigationBar.isHidden = false
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: LGV_UICleantimeImageViewObserverProtocol Conformance
/* ###################################################################################################################################### */
extension NACCTabBaseViewController: LGV_UICleantimeImageViewObserverProtocol {
    /* ################################################################## */
    /**
     This is called when the images have completed rendering.
     We use this to find a top.
     
     - parameter view: The completed UIImageView
     */
    func renderingComplete(view inImageView: LGV_UICleantimeImageViewBase) {
        self._hideThrobber()
        guard let contentSize = self.scrollView?.contentSize,
              0 < contentSize.height
        else {
            self.scrollView?.zoomScale = 1.0
            return
        }

        // This makes sure that the scroller goes to the top of the matrix, if it is resized.
        let intW = inImageView.intrinsicContentSize.width
        let dispW = inImageView.bounds.size.width
        let scale = max(1.0, intW / dispW)
        self.scrollView?.minimumZoomScale = 1
        self.scrollView?.maximumZoomScale = max(1.0, scale)
        if let cleantime = self.cleantime,
           let imageSize = inImageView.image?.size {
            let aspect = imageSize.height / imageSize.width
            cleantime.heightAnchor.constraint(equalTo: cleantime.widthAnchor, multiplier: aspect).isActive = true
        }
    }
}

/* ###################################################################################################################################### */
// MARK: UIScrollViewDelegate Conformance
/* ###################################################################################################################################### */
extension NACCTabBaseViewController: UIScrollViewDelegate {
    /* ################################################################## */
    /**
     This simply sets the image view as a pinch to zoom target.
     
     - parameter in: Ignored
     - returns: The cleantime view.
     */
    func viewForZooming(in: UIScrollView) -> UIView? { self.cleantime }
}
