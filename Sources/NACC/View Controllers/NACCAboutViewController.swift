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

/* ###################################################################################################################################### */
// MARK: - Private UIImage Extension For Resizing -
/* ###################################################################################################################################### */
fileprivate extension UIImage {
    /* ################################################################## */
    /**
     This allows an image to be resized, given a maximum dimension, and a scale will be determined to meet that dimension.
     If the image is currently smaller than the maximum size, it will not be scaled.
     
     - parameter toMaximumSize: The maximum size, in either the X or Y axis, of the image, in pixels.
     
     - returns: A new image, with the given dimensions. May be nil, if there was an error.
     */
    func _resized(toMaximumSize: CGFloat) -> UIImage? {
        let scaleX: CGFloat = toMaximumSize / size.width
        let scaleY: CGFloat = toMaximumSize / size.height
        return _resized(toScaleFactor: min(1.0, min(scaleX, scaleY)))
    }

    /* ################################################################## */
    /**
     This allows an image to be resized, given a maximum dimension, and a scale will be determined to meet that dimension.
     
     - parameter toScaleFactor: The scale of the resulting image, as a multiplier of the current size.
     
     - returns: A new image, with the given scale. May be nil, if there was an error.
     */
    func _resized(toScaleFactor inScaleFactor: CGFloat) -> UIImage? { _resized(toNewWidth: size.width * inScaleFactor, toNewHeight: size.height * inScaleFactor) }
    
    /* ################################################################## */
    /**
     This allows an image to be resized, given both a width and a height, or just one of the dimensions.
     
     - parameters:
         - toNewWidth: The width (in pixels) of the desired image. If not provided, a scale will be determined from the toNewHeight parameter.
         - toNewHeight: The height (in pixels) of the desired image. If not provided, a scale will be determined from the toNewWidth parameter.
     
     - returns: A new image, with the given dimensions. May be nil, if no width or height was supplied, or if there was an error.
     */
    func _resized(toNewWidth inNewWidth: CGFloat? = nil, toNewHeight inNewHeight: CGFloat? = nil) -> UIImage? {
        guard nil == inNewWidth,
              nil == inNewHeight else {
            var scaleX: CGFloat = (inNewWidth ?? size.width) / size.width
            var scaleY: CGFloat = (inNewHeight ?? size.height) / size.height

            scaleX = nil == inNewWidth ? scaleY : scaleX
            scaleY = nil == inNewHeight ? scaleX : scaleY

            let destinationSize = CGSize(width: size.width * scaleX, height: size.height * scaleY)
            let destinationRect = CGRect(origin: .zero, size: destinationSize)

            UIGraphicsBeginImageContextWithOptions(destinationSize, false, 0)
            defer { UIGraphicsEndImageContext() }   // This makes sure that we get rid of the offscreen context.
            draw(in: destinationRect, blendMode: .normal, alpha: 1)
            return UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(renderingMode)
        }
        
        return nil
    }
}

/* ###################################################################################################################################### */
// MARK: - About Screen View Controller -
/* ###################################################################################################################################### */
/**
 This screen displays the information about the app.
 */
class NACCAboutViewController: NACCBaseViewController {
    /* ################################################################## */
    /**
     This is the size of the icon for the logo button.
     */
    private static let _iconSizeInDisplayUnits = CGFloat(100)

    /* ################################################################################################################################## */
    // MARK: Instance IBOutlet Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     This displays the app icon.
     It is a button, that links to the main Web site.
     */
    @IBOutlet weak var appIconButton: UIButton?

    /* ################################################################## */
    /**
     This displays the app version.
     Selecting it brings up an alert that includes the build number.
     */
    @IBOutlet weak var versionLabelButton: UIButton?

    /* ################################################################## */
    /**
     This displays a button that links to the app privacy site.
     */
    @IBOutlet weak var privacyButton: UIButton?

    /* ################################################################## */
    /**
     This displays the help text.
     */
    @IBOutlet weak var helpView: UITextView?
}

/* ###################################################################################################################################### */
// MARK: Base Class Overrides
/* ###################################################################################################################################### */
extension NACCAboutViewController {
    /* ################################################################## */
    /**
     Called when the view hierarchy has completed loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        if let aboutLogo = UIImage(named: "AboutLogo")?.withRenderingMode(.alwaysOriginal)._resized(toMaximumSize: Self._iconSizeInDisplayUnits) {
            appIconButton?.setImage(aboutLogo, for: .normal)
        }
        appIconButton?.imageView?.contentMode = .scaleAspectFit
        versionLabelButton?.setTitle(String(format: "SLUG-APP-INFO-VERSION-FORMAT-SMALL".localizedVariant, Bundle.main.appVersionString), for: .normal)
        helpView?.text = "SLUG-APP-INFO-TEXT".localizedVariant
        
        privacyButton?.setTitle((privacyButton?.title(for: .normal) ?? "ERROR").localizedVariant, for: .normal)
        privacyButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        privacyButton?.titleLabel?.minimumScaleFactor = 0.5
        
        appIconButton?.accessibilityLabel = "SLUG-ACC-APPICON-BUTTON".localizedVariant
        versionLabelButton?.accessibilityLabel = "SLUG-ACC-VERSION-BUTTON".localizedVariant
        privacyButton?.accessibilityLabel = "SLUG-ACC-PRIVACY-BUTTON".localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: Callbacks
/* ###################################################################################################################################### */
extension NACCAboutViewController {
    /* ################################################################## */
    /**
     Called when the version label button is tapped.
     - parameter: ignored.
     */
    @IBAction func displayVersionInfo(_: UIButton) {
        let displayString = String(format: "SLUG-APP-INFO-VERSION-FORMAT".localizedVariant, Bundle.main.appDisplayName, Bundle.main.appVersionString, Bundle.main.appVersionBuildString)
        
        let alertController = UIAlertController(title: displayString, message: nil, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "SLUG-OK-BUTTON-TEXT".localizedVariant, style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }

    /* ################################################################## */
    /**
     Called when the privacy button is hit.
     - parameter: ignored
     */
    @IBAction func privacyButtonHit(_: Any) {
        guard let uri = Bundle.main.privacyURI else { return }
        UIApplication.shared.open(uri, options: [:], completionHandler: nil)
    }

    /* ################################################################## */
    /**
     Called when the app icon button is hit.
     - parameter: ignored
     */
    @IBAction func appIconButtonHit(_: Any) {
        guard let uri = Bundle.main.siteURI else { return }
        UIApplication.shared.open(uri, options: [:], completionHandler: nil)
    }
}
