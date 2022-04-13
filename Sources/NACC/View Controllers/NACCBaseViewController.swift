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
    var backgroundGradientImage: UIImage? = UIImage(named: "Background-Gradient")
    
    /* ############################################################## */
    /**
     This can be overloaded or set, to provide the image to be used as a "watermark."
     */
    var watermarkImage: UIImage? = UIImage(named: "CenterImage")

    /* ################################################################## */
    /**
     This is the background image view.
     */
    var myBackgroundGradientView: UIImageView?

    /* ################################################################## */
    /**
     This is the background center image view.
     */
    var myCenterImageView: UIImageView?
    
    /* ################################################################## */
    /**
     Called when the view hierarchy has been completed.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBarItemTitle = tabBarItem?.title?.localizedVariant,
           !tabBarItemTitle.isEmpty {
            tabBarController?.navigationItem.title = tabBarItemTitle
        } else {
            navigationItem.title = (navigationItem.title ?? "ERROR").localizedVariant
        }

        if let view = view {
            myBackgroundGradientView = UIImageView()
            if let backgroundGradientView = myBackgroundGradientView,
               let backGroundImage = backgroundGradientImage {
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
                if !isHighContrastMode,
                   !isReducedTransparencyMode {
                    myCenterImageView = UIImageView()
                    if let centerImageView = myCenterImageView,
                       let centerImage = watermarkImage {
                        centerImageView.image = centerImage
                        centerImageView.alpha = Self._watermarkAlpha
                        centerImageView.translatesAutoresizingMaskIntoConstraints = false
                        centerImageView.contentMode = .scaleAspectFit
                        centerImageView.tintColor = .label
                        backgroundGradientView.insertSubview(centerImageView, at: 1)

                        centerImageView.centerXAnchor.constraint(equalTo: backgroundGradientView.centerXAnchor).isActive = true
                        centerImageView.centerYAnchor.constraint(equalTo: backgroundGradientView.centerYAnchor).isActive = true
                        
                        centerImageView.widthAnchor.constraint(lessThanOrEqualTo: backgroundGradientView.widthAnchor, multiplier: Self._watermarkSizeCoefficient).isActive = true
                        centerImageView.heightAnchor.constraint(lessThanOrEqualTo: backgroundGradientView.heightAnchor, multiplier: Self._watermarkSizeCoefficient).isActive = true

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
     Called just before the view appears. We use it to set the date picker date.
     
     - parameter inIsAnimated: True, if the appearance is to be animated.
    */
    override func viewWillAppear(_ inIsAnimated: Bool) {
        super.viewWillAppear(inIsAnimated)
    }
}
